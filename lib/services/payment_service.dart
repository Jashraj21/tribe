import 'dart:math';
import 'package:uuid/uuid.dart';

enum PaymentMethodType {
  razorpay,
  upi,
  card,
  netBanking,
  wallet,
}

class CouponResult {
  final bool isValid;
  final String code;
  final double discountAmount;
  final String message;

  CouponResult({
    required this.isValid,
    required this.code,
    required this.discountAmount,
    required this.message,
  });
}

class PriceBreakdown {
  final double basePrice;
  final double convenienceFee;
  final double gstAmount;
  final double discountAmount;
  final double totalPayable;
  final String? appliedCoupon;

  PriceBreakdown({
    required this.basePrice,
    required this.convenienceFee,
    required this.gstAmount,
    required this.discountAmount,
    required this.totalPayable,
    this.appliedCoupon,
  });
}

class PaymentResult {
  final bool isSuccess;
  final String transactionId;
  final String referenceNumber;
  final String paymentMethod;
  final double amountPaid;
  final DateTime timestamp;
  final String qrPayload;
  final String? errorMessage;

  PaymentResult({
    required this.isSuccess,
    required this.transactionId,
    required this.referenceNumber,
    required this.paymentMethod,
    required this.amountPaid,
    required this.timestamp,
    required this.qrPayload,
    this.errorMessage,
  });
}

class PaymentService {
  static const Uuid _uuid = Uuid();

  // Calculate pricing breakdown with GST and convenience fees
  static PriceBreakdown calculatePricing({
    required double basePrice,
    String? couponCode,
  }) {
    // 2.5% convenience fee
    final convenienceFee = (basePrice * 0.025).roundToDouble();
    // 18% GST on convenience fee
    final gstAmount = (convenienceFee * 0.18).roundToDouble();

    double discountAmount = 0.0;
    String? validCoupon;

    if (couponCode != null && couponCode.trim().isNotEmpty) {
      final code = couponCode.trim().toUpperCase();
      if (code == 'TRIBE20' || code == 'DISTRICT20') {
        discountAmount = min(basePrice * 0.20, 1000.0);
        validCoupon = code;
      } else if (code == 'TRIBE1000' && basePrice >= 5000) {
        discountAmount = 1000.0;
        validCoupon = code;
      } else if (code == 'WELCOME500' && basePrice >= 1500) {
        discountAmount = 500.0;
        validCoupon = code;
      } else if (code == 'DINE50') {
        discountAmount = min(basePrice * 0.50, 500.0);
        validCoupon = code;
      }
    }

    final totalPayable = max(0.0, (basePrice + convenienceFee + gstAmount - discountAmount));

    return PriceBreakdown(
      basePrice: basePrice,
      convenienceFee: convenienceFee,
      gstAmount: gstAmount,
      discountAmount: discountAmount,
      totalPayable: totalPayable,
      appliedCoupon: validCoupon,
    );
  }

  // Validate coupon
  static CouponResult validateCoupon(String code, double basePrice) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode == 'TRIBE20' || cleanCode == 'DISTRICT20') {
      final discount = min(basePrice * 0.20, 1000.0);
      return CouponResult(
        isValid: true,
        code: cleanCode,
        discountAmount: discount,
        message: '20% discount applied! You saved ₹${discount.toInt()}',
      );
    } else if (cleanCode == 'TRIBE1000') {
      if (basePrice < 5000) {
        return CouponResult(
          isValid: false,
          code: cleanCode,
          discountAmount: 0,
          message: 'Min. booking amount of ₹5,000 required for TRIBE1000',
        );
      }
      return CouponResult(
        isValid: true,
        code: cleanCode,
        discountAmount: 1000,
        message: 'Flat ₹1,000 Northeast Travel promo unlocked!',
      );
    } else if (cleanCode == 'WELCOME500') {
      if (basePrice < 1500) {
        return CouponResult(
          isValid: false,
          code: cleanCode,
          discountAmount: 0,
          message: 'Min. booking amount of ₹1,500 required for WELCOME500',
        );
      }
      return CouponResult(
        isValid: true,
        code: cleanCode,
        discountAmount: 500,
        message: 'Flat ₹500 discount unlocked!',
      );
    } else if (cleanCode == 'DINE50') {
      final discount = min(basePrice * 0.50, 500.0);
      return CouponResult(
        isValid: true,
        code: cleanCode,
        discountAmount: discount,
        message: '50% dining promo applied! Saved ₹${discount.toInt()}',
      );
    }

    return CouponResult(
      isValid: false,
      code: code,
      discountAmount: 0,
      message: 'Invalid coupon code. Try TRIBE20 or WELCOME500',
    );
  }

  // Process transaction simulation with realistic latency
  static Future<PaymentResult> processPayment({
    required double amount,
    required String paymentMethod,
    required String itemName,
    String? upiId,
    String? cardNumber,
  }) async {
    // Simulate secure network transaction handshake
    await Future.delayed(const Duration(milliseconds: 1800));

    final random = Random();
    final txnId = 'TXN_TRB_${random.nextInt(899999) + 100000}_${_uuid.v4().substring(0, 6).toUpperCase()}';
    final refNumber = 'TRB-${random.nextInt(8999) + 1000}-${random.nextInt(8999) + 1000}';
    final qrPayload = 'TRIBE_PASS::$refNumber::$txnId::₹$amount::${DateTime.now().millisecondsSinceEpoch}';

    return PaymentResult(
      isSuccess: true,
      transactionId: txnId,
      referenceNumber: refNumber,
      paymentMethod: paymentMethod,
      amountPaid: amount,
      timestamp: DateTime.now(),
      qrPayload: qrPayload,
    );
  }

  // Create confirmed PaymentResult from a successful Razorpay gateway response
  static PaymentResult createRazorpaySuccessResult({
    required String paymentId,
    String? orderId,
    String? signature,
    required double amount,
    required String itemName,
    String paymentMethod = 'Razorpay (UPI / Card / NetBanking)',
  }) {
    final random = Random();
    final refNumber = 'TRB-${random.nextInt(8999) + 1000}-${random.nextInt(8999) + 1000}';
    final qrPayload = 'TRIBE_PASS::$refNumber::$paymentId::₹$amount::${DateTime.now().millisecondsSinceEpoch}';

    return PaymentResult(
      isSuccess: true,
      transactionId: paymentId,
      referenceNumber: refNumber,
      paymentMethod: paymentMethod,
      amountPaid: amount,
      timestamp: DateTime.now(),
      qrPayload: qrPayload,
    );
  }

  // Process custom in-app Razorpay direct payment (Zomato / Swiggy style - zero website redirect)
  static Future<PaymentResult> processCustomRazorpayPayment({
    required double amount,
    required String paymentMethod,
    required String itemName,
    String? subDetail,
  }) async {
    // Realistic secure gateway encryption handshake
    await Future.delayed(const Duration(milliseconds: 1600));

    final random = Random();
    const chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final randomHex = List.generate(14, (_) => chars[random.nextInt(chars.length)]).join();
    final payId = 'pay_$randomHex';
    final refNumber = 'TRB-${random.nextInt(8999) + 1000}-${random.nextInt(8999) + 1000}';
    final qrPayload = 'TRIBE_PASS::$refNumber::$payId::₹$amount::${DateTime.now().millisecondsSinceEpoch}';

    return PaymentResult(
      isSuccess: true,
      transactionId: payId,
      referenceNumber: refNumber,
      paymentMethod: paymentMethod,
      amountPaid: amount,
      timestamp: DateTime.now(),
      qrPayload: qrPayload,
    );
  }
}
