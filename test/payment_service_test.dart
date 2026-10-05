import 'package:flutter_test/flutter_test.dart';
import 'package:district_app/services/payment_service.dart';

void main() {
  group('PaymentService Pricing & Calculations', () {
    test('Calculates base pricing with convenience fee and GST', () {
      final pricing = PaymentService.calculatePricing(basePrice: 1000.0);

      expect(pricing.basePrice, 1000.0);
      expect(pricing.convenienceFee, 25.0); // 2.5% of 1000
      expect(pricing.gstAmount, 5.0); // 18% of 25 = 4.5.roundToDouble() = 5.0
      expect(pricing.discountAmount, 0.0);
      expect(pricing.totalPayable, greaterThanOrEqualTo(1025.0));
    });

    test('Validates DISTRICT20 coupon correctly with 20% discount', () {
      final coupon = PaymentService.validateCoupon('DISTRICT20', 2000.0);

      expect(coupon.isValid, true);
      expect(coupon.code, 'DISTRICT20');
      expect(coupon.discountAmount, 400.0); // 20% of 2000
    });

    test('Validates WELCOME500 coupon requirement', () {
      final invalidCoupon = PaymentService.validateCoupon('WELCOME500', 1000.0);
      expect(invalidCoupon.isValid, false);

      final validCoupon = PaymentService.validateCoupon('WELCOME500', 2500.0);
      expect(validCoupon.isValid, true);
      expect(validCoupon.discountAmount, 500.0);
    });

    test('Processes simulated payment transaction and generates QR pass payload', () async {
      final result = await PaymentService.processPayment(
        amount: 3500.0,
        paymentMethod: 'UPI (Google Pay)',
        itemName: 'Coldplay Spheres Tour',
      );

      expect(result.isSuccess, true);
      expect(result.amountPaid, 3500.0);
      expect(result.transactionId, startsWith('TXN_TRB_'));
      expect(result.referenceNumber, startsWith('TRB-'));
      expect(result.qrPayload, contains('TRIBE_PASS::'));
    });

    test('Creates valid PaymentResult from Razorpay payment success response', () {
      final result = PaymentService.createRazorpaySuccessResult(
        paymentId: 'pay_N9KjX123456789',
        orderId: 'order_987654321',
        signature: 'sig_abcdef123456',
        amount: 2499.0,
        itemName: 'Zakir Khan Live',
      );

      expect(result.isSuccess, true);
      expect(result.transactionId, 'pay_N9KjX123456789');
      expect(result.amountPaid, 2499.0);
      expect(result.referenceNumber, startsWith('TRB-'));
      expect(result.qrPayload, contains('TRIBE_PASS::TRB-'));
      expect(result.qrPayload, contains('pay_N9KjX123456789'));
      expect(result.paymentMethod, contains('Razorpay'));
    });

    test('Processes custom in-app Razorpay payment (Zomato/Swiggy zero-redirect style)', () async {
      final result = await PaymentService.processCustomRazorpayPayment(
        amount: 3499.0,
        paymentMethod: 'Razorpay UPI (Google Pay)',
        itemName: 'Soulmate Blues Live',
      );

      expect(result.isSuccess, true);
      expect(result.amountPaid, 3499.0);
      expect(result.transactionId, startsWith('pay_'));
      expect(result.referenceNumber, startsWith('TRB-'));
      expect(result.paymentMethod, 'Razorpay UPI (Google Pay)');
      expect(result.qrPayload, contains('TRIBE_PASS::'));
      expect(result.qrPayload, contains(result.transactionId));
    });
  });
}
