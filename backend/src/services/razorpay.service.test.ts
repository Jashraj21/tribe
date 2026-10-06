import test from 'node:test';
import assert from 'node:assert/strict';
import { RazorpayService } from './razorpay.service.js';
import { PassService } from './pass.service.js';
import { SeatLockService } from './seat-lock.service.js';

test('RazorpayService - Order creation generates valid parameters', async () => {
  const service = RazorpayService.getInstance();
  const order = await service.createOrder({
    amountInRupees: 18999,
    receipt: 'rcpt_test_001',
    notes: { tour: 'Meghalaya Living Bridges' },
  });

  assert.ok(order.orderId);
  assert.equal(order.amount, 1899900); // 18999 * 100 paise
  assert.equal(order.currency, 'INR');
  assert.equal(order.receipt, 'rcpt_test_001');
});

test('PassService - Signs and verifies dynamic entry pass with HMAC', async () => {
  const passService = PassService.getInstance();

  const payload = passService.generateSignedPayload({
    passNumber: 'TRB-9631-7212',
    bookingId: 'bk_101',
    eventId: 'pkg_meghalaya_roots',
    userId: 'usr_jashraaj',
    guestCount: 2,
    amount: 39119,
    paymentId: 'pay_MveTcTwBI6WqpW',
  });

  assert.ok(payload.startsWith('TRIBE_PASS::TRB-9631-7212'));
  assert.ok(payload.includes('::SIG_'));

  // Validate at Gate Scanner
  const validation = passService.validateQrPayload(payload);
  assert.equal(validation.valid, true);
  assert.equal(validation.passNumber, 'TRB-9631-7212');
  assert.equal(validation.amount, 39119);
  assert.equal(validation.guestCount, 2);

  // Tampered payload detection
  const tampered = payload.replace('39119', '1000');
  const tamperedValidation = passService.validateQrPayload(tampered);
  assert.equal(tamperedValidation.valid, false);
  assert.ok(tamperedValidation.message.includes('Tampered pass detected'));
});

test('SeatLockService - Acquires and releases inventory locks', async () => {
  const lockService = SeatLockService.getInstance();

  const lock1 = await lockService.acquireLock('concert_ziro_2026', 'SEAT_VIP_A1', 'user_alpha');
  assert.equal(lock1.success, true);

  // Second user trying same seat while locked must be rejected
  const lock2 = await lockService.acquireLock('concert_ziro_2026', 'SEAT_VIP_A1', 'user_beta');
  assert.equal(lock2.success, false);

  // Release lock
  const released = await lockService.releaseLock('concert_ziro_2026', 'SEAT_VIP_A1', 'user_alpha');
  assert.equal(released, true);

  // Now user beta can acquire
  const lock3 = await lockService.acquireLock('concert_ziro_2026', 'SEAT_VIP_A1', 'user_beta');
  assert.equal(lock3.success, true);
});

test('SeatLockService - Validates active locks and detects expiration', async () => {
  const lockService = SeatLockService.getInstance();

  // 1. Acquire short 1-second lock
  const lock = await lockService.acquireLock('concert_shillong_2026', 'SEAT_FRONT_B2', 'user_gamma', 1);
  assert.equal(lock.success, true);

  // 2. Lock should be valid immediately
  const isValidImmediately = await lockService.isLockValid('concert_shillong_2026', 'SEAT_FRONT_B2', 'user_gamma');
  assert.equal(isValidImmediately, true);

  // 3. Different user checking should return false
  const isDifferentUserValid = await lockService.isLockValid('concert_shillong_2026', 'SEAT_FRONT_B2', 'user_intruder');
  assert.equal(isDifferentUserValid, false);

  // 4. Wait 1.1s for lock to expire
  await new Promise((resolve) => setTimeout(resolve, 1100));

  // 5. Expired lock must return false
  const isStillValidAfterExpiry = await lockService.isLockValid('concert_shillong_2026', 'SEAT_FRONT_B2', 'user_gamma');
  assert.equal(isStillValidAfterExpiry, false);
});

