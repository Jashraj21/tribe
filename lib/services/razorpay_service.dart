import 'package:shared_preferences/shared_preferences.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayConfig {
  // Default test key (or user-provided Razorpay Key ID)
  static const String defaultTestKey = 'rzp_test_TjoMcngj0CGZMk';
  static const String _prefKey = 'tribe_razorpay_key_id';

  static String _keyId = defaultTestKey;

  static String get keyId => _keyId;

  static bool get isCustomKeySet => _keyId != defaultTestKey && _keyId.isNotEmpty;

  static bool get isLiveKey => _keyId.startsWith('rzp_live_');

  /// Initialize and load saved API key from SharedPreferences
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString(_prefKey);
      if (savedKey != null && savedKey.trim().isNotEmpty && savedKey.trim() != 'rzp_test_1DP5mmOlF5G5ag') {
        _keyId = savedKey.trim();
      } else {
        _keyId = defaultTestKey;
      }
    } catch (_) {
      _keyId = defaultTestKey;
    }
  }

  /// Save new Key ID to memory and persistent storage
  static Future<void> setKeyId(String key) async {
    _keyId = key.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, _keyId);
    } catch (_) {}
  }

  /// Reset back to default test key
  static Future<void> resetToDefault() async {
    _keyId = defaultTestKey;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKey);
    } catch (_) {}
  }
}

class RazorpayService {
  late Razorpay _razorpay;
  Function(PaymentSuccessResponse)? _onSuccess;
  Function(PaymentFailureResponse)? _onError;
  Function(ExternalWalletResponse)? _onExternalWallet;

  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _onSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _onError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _onExternalWallet?.call(response);
  }

  void openCheckout({
    required double amount,
    required String itemName,
    String? userName,
    String? userEmail,
    String? userContact,
    String? orderId,
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
    Function(ExternalWalletResponse)? onExternalWallet,
  }) {
    _onSuccess = onSuccess;
    _onError = onError;
    _onExternalWallet = onExternalWallet;

    final options = <String, dynamic>{
      'key': RazorpayConfig.keyId,
      'amount': (amount * 100).toInt(), // in paise
      'currency': 'INR', // Essential for Indian payment options
      'name': 'TRIBE Experiences',
      'description': itemName,
      'prefill': {
        'name': userName ?? 'TRIBE Explorer',
        'contact': userContact ?? '9876543210',
        'email': userEmail ?? 'explorer@tribeapp.in',
      },
      'theme': {
        'color': '#0F172A', // TRIBE premium dark slate theme
        'backdrop_color': '#0B0F17',
      },
      'modal': {
        'confirm_close': true,
        'animation': true,
      },
      'retry': {
        'enabled': true,
        'max_count': 2,
      },
      'send_sms_hash': true,
      'notes': {
        'merchant_name': 'TRIBE Experiences',
        'booking_item': itemName,
        'platform': 'TRIBE Android App',
      },
    };

    if (orderId != null && orderId.isNotEmpty) {
      options['order_id'] = orderId;
    }

    _razorpay.open(options);
  }

  void dispose() {
    _razorpay.clear();
  }
}
