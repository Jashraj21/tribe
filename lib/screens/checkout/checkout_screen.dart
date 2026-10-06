import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../models/booking_model.dart';
import '../../models/travel_package_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../services/payment_service.dart';
import '../../services/razorpay_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../auth/auth_screen.dart';
import 'booking_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final BookingType bookingType;
  final String itemId;
  final String title;
  final String subtitle;
  final String venue;
  final String city;
  final DateTime dateTime;
  final String imageUrl;
  final double baseAmount;

  // Type specific details
  final List<BookingTicketItem>? concertTickets;
  final List<String>? concertAddOns;
  final BookingDineInDetail? dineInDetail;
  final TravelPackageModel? travelPackage;
  final TravelBatchModel? travelBatch;
  final int? travelersCount;
  final BookingTravelDetail? travelDetail;

  CheckoutScreen({
    super.key,
    BookingType? bookingType,
    String? itemId,
    String? title,
    String? subtitle,
    String? venue,
    String? city,
    DateTime? dateTime,
    String? imageUrl,
    double? baseAmount,
    this.concertTickets,
    this.concertAddOns,
    this.dineInDetail,
    this.travelPackage,
    this.travelBatch,
    this.travelersCount,
    this.travelDetail,
  })  : bookingType = bookingType ?? (travelPackage != null ? BookingType.travel : BookingType.concert),
        itemId = itemId ?? (travelPackage?.id ?? ''),
        title = title ?? (travelPackage?.title ?? ''),
        subtitle = subtitle ??
            (travelPackage != null
                ? '${travelPackage.durationDays}D/${travelPackage.durationNights}N • ${travelPackage.state} • ${travelersCount ?? 1} ${(travelersCount ?? 1) == 1 ? 'Traveler' : 'Travelers'}'
                : ''),
        venue = venue ?? (travelPackage?.pickupLocation ?? ''),
        city = city ?? (travelPackage?.state ?? ''),
        dateTime = dateTime ?? (travelBatch?.startDate ?? DateTime.now()),
        imageUrl = imageUrl ?? (travelPackage?.imageUrl ?? ''),
        baseAmount = baseAmount ??
            ((travelPackage != null && travelersCount != null)
                ? (travelPackage.pricePerPerson * travelersCount)
                : 0.0);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Custom Zomato & Swiggy In-App Payment Menu State
  String _selectedCategory = 'upi'; // 'upi', 'card', 'netbanking', 'wallet', 'venue', 'hosted'
  String _selectedUpiOption = 'gpay'; // 'gpay', 'phonepe', 'paytm_upi', 'cred', 'custom_upi'
  String _selectedCardOption = 'saved_hdfc'; // 'saved_hdfc', 'new_card'
  String _selectedBank = 'HDFC Bank';
  String _selectedWallet = 'paytm_wallet'; // 'paytm_wallet', 'mobikwik', 'simpl', 'tribe_cash'
  bool _saveNewCard = true;

  late RazorpayService _razorpayService;

  final _couponController = TextEditingController();
  final _upiIdController = TextEditingController(text: 'user@okaxis');
  final _cardNumberController = TextEditingController(text: '4532 8901 2345 6789');
  final _cardExpiryController = TextEditingController(text: '12/28');
  final _cardCvvController = TextEditingController(text: '821');
  final _cardNameController = TextEditingController(text: 'ARYAN SHARMA');

  String? _appliedCoupon;
  String? _couponMessage;
  bool _isCouponValid = false;

  late PriceBreakdown _pricing;

  // Seat Reservation Countdown Timer (BookMyShow / Zomato Live standard: 8 mins)
  Timer? _reservationTimer;
  int _secondsRemaining = 480;
  final int _totalHoldSeconds = 480;
  bool _isSeatHoldExpired = false;
  bool _isExpiredSheetOpen = false;

  void _startReservationTimer() {
    _reservationTimer?.cancel();
    _reservationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
          _isSeatHoldExpired = true;
        });
        _handleSeatHoldExpired();
      }
    });
  }

  void _fastForwardExpiryTest() {
    if (_isSeatHoldExpired) return;
    setState(() {
      _secondsRemaining = 5;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.bolt_rounded, color: AppColors.gold, size: 18),
            SizedBox(width: 8),
            Text('Timer fast-forwarded: expiring in 5s for QA review',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.grey.shade900,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTimerDisplay(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _handleSeatHoldExpired() {
    if (!mounted) return;
    _showSeatExpiredSheet(context);
  }

  void _showSeatExpiredSheet(BuildContext context) {
    if (!mounted || _isExpiredSheetOpen) return;
    _isExpiredSheetOpen = true;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: AppTheme.surface(ctx),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.red.withOpacity(0.35), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.12),
                  border: Border.all(color: Colors.red.withOpacity(0.4), width: 2),
                ),
                child: const Icon(
                  Icons.timer_off_rounded,
                  color: Colors.redAccent,
                  size: 38,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Seat Reservation Expired',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary(ctx),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Your 8-minute reservation window has ended. To ensure fair access for everyone, your held seats have been returned to the general pool.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  height: 1.5,
                  color: AppTheme.textSecondary(ctx),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor(ctx),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary(ctx),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Status: Released / Unreserved',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _isExpiredSheetOpen = false;
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.replay_rounded, size: 18),
                  label: Text(
                    'Re-select Seats & Try Again',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  _isExpiredSheetOpen = false;
                  Navigator.of(ctx).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(
                  'Cancel & Return to Explore',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted(ctx),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      _isExpiredSheetOpen = false;
    });
  }

  Widget _buildReservationTimerBanner(BuildContext context) {
    final isWarning = _secondsRemaining <= 120 && !_isSeatHoldExpired;
    final progress = (_secondsRemaining / _totalHoldSeconds).clamp(0.0, 1.0);

    Color accentColor;
    Color bgTint;
    Color borderTint;
    String statusTitle;
    String subText;

    if (_isSeatHoldExpired) {
      accentColor = Colors.redAccent;
      bgTint = Colors.red.withOpacity(0.12);
      borderTint = Colors.red.withOpacity(0.35);
      statusTitle = 'Seat Hold Expired (00:00)';
      subText = 'Seats released back to pool. Payment disabled.';
    } else if (isWarning) {
      accentColor = const Color(0xFFFF9500); // vibrant amber
      bgTint = const Color(0xFFFF9500).withOpacity(0.12);
      borderTint = const Color(0xFFFF9500).withOpacity(0.35);
      statusTitle = 'Hurry! Seats held for ${_formatTimerDisplay(_secondsRemaining)}';
      subText = 'Complete payment before timer ends to lock your booking.';
    } else {
      accentColor = const Color(0xFF10B981); // Emerald
      bgTint = const Color(0xFF10B981).withOpacity(0.08);
      borderTint = const Color(0xFF10B981).withOpacity(0.25);
      statusTitle = 'Seats held for ${_formatTimerDisplay(_secondsRemaining)}';
      subText = 'Your seats are reserved while you finish payment.';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderTint, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isSeatHoldExpired
                      ? Icons.timer_off_rounded
                      : isWarning
                          ? Icons.hourglass_bottom_rounded
                          : Icons.timer_outlined,
                  color: accentColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusTitle,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: accentColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      _formatTimerDisplay(_secondsRemaining),
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  if (!_isSeatHoldExpired) ...[
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: _fastForwardExpiryTest,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated(context),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.border(context)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.flash_on_rounded, size: 10, color: AppColors.gold),
                            const SizedBox(width: 2),
                            Text(
                              '5s Test',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.border(context).withOpacity(0.4),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
    _recalculatePricing();
    _startReservationTimer();
  }

  @override
  void dispose() {
    _reservationTimer?.cancel();
    _razorpayService.dispose();
    _couponController.dispose();
    _upiIdController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardNameController.dispose();
    super.dispose();
  }

  void _recalculatePricing() {
    setState(() {
      _pricing = PaymentService.calculatePricing(
        basePrice: widget.baseAmount,
        couponCode: _appliedCoupon,
      );
    });
  }

  void _applyCoupon() {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    final result = PaymentService.validateCoupon(code, widget.baseAmount);
    setState(() {
      _isCouponValid = result.isValid;
      _couponMessage = result.message;
      if (result.isValid) {
        _appliedCoupon = result.code;
      } else {
        _appliedCoupon = null;
      }
    });
    _recalculatePricing();
  }

  void _completeBookingSuccess(PaymentResult paymentResult) {
    // Build travel detail if travel package
    BookingTravelDetail? travelDetail = widget.travelDetail;
    if (travelDetail == null && widget.travelPackage != null && widget.travelBatch != null) {
      final startFormatted = DateFormat('MMM d, yyyy').format(widget.travelBatch!.startDate);
      final endFormatted = DateFormat('MMM d, yyyy').format(widget.travelBatch!.endDate);
      travelDetail = BookingTravelDetail(
        packageId: widget.travelPackage!.id,
        packageName: widget.travelPackage!.title,
        state: widget.travelPackage!.state,
        duration: '${widget.travelPackage!.durationDays}D / ${widget.travelPackage!.durationNights}N',
        pickupLocation: widget.travelPackage!.pickupLocation,
        batchDate: '$startFormatted - $endFormatted',
        travelersCount: widget.travelersCount ?? 1,
        pricePerPerson: widget.travelPackage!.pricePerPerson,
      );
    }

    // Create confirmed booking
    final booking = BookingModel(
      id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
      bookingReference: paymentResult.referenceNumber,
      type: widget.bookingType,
      itemId: widget.itemId,
      title: widget.title,
      subtitle: widget.subtitle,
      venue: widget.venue,
      city: widget.city,
      dateTime: widget.dateTime,
      imageUrl: widget.imageUrl,
      totalAmount: _pricing.totalPayable,
      baseAmount: _pricing.basePrice,
      taxAmount: _pricing.gstAmount,
      discountAmount: _pricing.discountAmount,
      convenienceFee: _pricing.convenienceFee,
      status: 'CONFIRMED',
      qrCodeData: paymentResult.qrPayload,
      paymentMethod: paymentResult.paymentMethod,
      transactionId: paymentResult.transactionId,
      concertTickets: widget.concertTickets,
      concertAddOns: widget.concertAddOns,
      dineInDetail: widget.dineInDetail,
      travelDetail: travelDetail,
    );

    // Save to provider & storage
    context.read<BookingProvider>().addBooking(booking);

    // Navigate to confirmation screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BookingConfirmationScreen(booking: booking),
      ),
    );
  }

  void _handleRazorpaySuccess(PaymentSuccessResponse response) {
    if (!mounted) return;
    final paymentResult = PaymentService.createRazorpaySuccessResult(
      paymentId: response.paymentId ?? 'pay_${DateTime.now().millisecondsSinceEpoch}',
      orderId: response.orderId,
      signature: response.signature,
      amount: _pricing.totalPayable,
      itemName: widget.title,
      paymentMethod: 'Razorpay Gateway (${response.paymentId ?? "Instant"})',
    );
    _completeBookingSuccess(paymentResult);
  }

  void _handleRazorpayError(PaymentFailureResponse response) {
    if (!mounted) return;
    final isCancelled = response.code == Razorpay.PAYMENT_CANCELLED ||
        (response.message != null && response.message!.toLowerCase().contains('cancel'));

    if (isCancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Razorpay checkout closed. You can retry or configure your API Key.',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.grey.shade900,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Informative Gateway Error Notice
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface(ctx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Razorpay Gateway Notice',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary(ctx),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: Text(
                response.message?.isNotEmpty == true
                    ? response.message!
                    : 'No appropriate payment method found.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Why this occurs:\n'
              '• The default test key requires payment methods (UPI, Cards, NetBanking) to be activated in your Razorpay Merchant Dashboard.\n'
              '• Or you can enter your own Razorpay Key ID (rzp_test_... or rzp_live_...).\n'
              '• You can also run a test simulation to verify your tickets, QR pass, and booking records.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppTheme.textSecondary(ctx),
                height: 1.45,
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showRazorpayKeyConfigModal(context);
            },
            child: Text(
              'Configure API Key',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3395FF),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final simResult = PaymentService.createRazorpaySuccessResult(
                paymentId: 'pay_sim_${DateTime.now().millisecondsSinceEpoch}',
                orderId: 'order_test_razorpay',
                amount: _pricing.totalPayable,
                itemName: widget.title,
              );
              _completeBookingSuccess(simResult);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Test Simulation'),
          ),
        ],
      ),
    );
  }

  void _handleRazorpayWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Redirected to external wallet: ${response.walletName ?? ""}'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _processPayment() async {
    // 0. Seat Reservation Timer Guard - Do not proceed if timer expired
    if (_isSeatHoldExpired || _secondsRemaining <= 0) {
      _showSeatExpiredSheet(context);
      return;
    }

    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      // Require Sign-in if not logged in
      final bool? loggedIn = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: AuthScreen(
            onAuthSuccess: () => Navigator.pop(context, true),
          ),
        ),
      );

      if (loggedIn != true) return;
    }

    if (_selectedCategory == 'hosted') {
      // Launch standard Razorpay hosted sheet only if user explicitly selects it
      _razorpayService.openCheckout(
        amount: _pricing.totalPayable,
        itemName: widget.title,
        userName: auth.user?.name ?? 'TRIBE Explorer',
        userEmail: auth.user?.email ?? 'guest@tribe.in',
        userContact: auth.user?.phone ?? '9876543210',
        onSuccess: _handleRazorpaySuccess,
        onError: _handleRazorpayError,
        onExternalWallet: _handleRazorpayWallet,
      );
      return;
    }

    // In-App Custom Razorpay Payment (Zero web redirect - Zomato / Swiggy style)
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _buildInAppProcessingDialog(ctx),
    );

    // Call payment service with custom in-app Razorpay processor
    final paymentResult = await PaymentService.processCustomRazorpayPayment(
      amount: _pricing.totalPayable,
      paymentMethod: _getPaymentMethodLabel(),
      itemName: widget.title,
    );

    if (!mounted) return;
    Navigator.pop(context); // close processing dialog

    if (paymentResult.isSuccess) {
      _completeBookingSuccess(paymentResult);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment transaction failed. Please try another method.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _getPaymentMethodLabel() {
    switch (_selectedCategory) {
      case 'upi':
        switch (_selectedUpiOption) {
          case 'gpay':
            return 'Razorpay UPI (Google Pay)';
          case 'phonepe':
            return 'Razorpay UPI (PhonePe)';
          case 'paytm_upi':
            return 'Razorpay UPI (Paytm)';
          case 'cred':
            return 'Razorpay UPI (CRED)';
          case 'custom_upi':
            final id = _upiIdController.text.trim();
            return 'Razorpay UPI (${id.isNotEmpty ? id : "Custom VPA"})';
          default:
            return 'Razorpay UPI';
        }
      case 'card':
        if (_selectedCardOption == 'saved_hdfc') {
          return 'Razorpay Card (HDFC Millennia •••• 6789)';
        } else {
          final raw = _cardNumberController.text.replaceAll(' ', '');
          final last4 = raw.length >= 4 ? raw.substring(raw.length - 4) : '6789';
          return 'Razorpay Card (•••• $last4)';
        }
      case 'netbanking':
        return 'Razorpay NetBanking ($_selectedBank)';
      case 'wallet':
        switch (_selectedWallet) {
          case 'tribe_cash':
            return 'Tribe Pay Cash Balance';
          case 'simpl':
            return 'Razorpay Pay Later (Simpl)';
          case 'paytm_wallet':
            return 'Razorpay Wallet (Paytm)';
          case 'mobikwik':
            return 'Razorpay Wallet (Mobikwik)';
          default:
            return 'Razorpay Wallet';
        }
      case 'venue':
        return 'Pay at Venue / Entry Desk';
      case 'hosted':
        return 'Razorpay Gateway (Standard Sheet)';
      default:
        return 'Razorpay In-App Payment';
    }
  }

  String _getButtonLabel() {
    if (_isSeatHoldExpired || _secondsRemaining <= 0) {
      return 'Seat Hold Expired (00:00)';
    }
    final amount = '₹${NumberFormat('#,##,###').format(_pricing.totalPayable.toInt())}';
    switch (_selectedCategory) {
      case 'upi':
        switch (_selectedUpiOption) {
          case 'gpay':
            return 'Pay $amount with Google Pay';
          case 'phonepe':
            return 'Pay $amount with PhonePe';
          case 'paytm_upi':
            return 'Pay $amount with Paytm UPI';
          case 'cred':
            return 'Pay $amount with CRED';
          case 'custom_upi':
            return 'Pay $amount with UPI ID';
          default:
            return 'Pay $amount with UPI';
        }
      case 'card':
        if (_selectedCardOption == 'saved_hdfc') {
          return 'Pay $amount with HDFC •••• 6789';
        }
        return 'Pay $amount with Card';
      case 'netbanking':
        return 'Pay $amount with $_selectedBank';
      case 'wallet':
        if (_selectedWallet == 'tribe_cash') {
          return 'Pay $amount using Tribe Cash';
        } else if (_selectedWallet == 'simpl') {
          return 'Pay $amount via Simpl Pay Later';
        }
        return 'Pay $amount with Wallet';
      case 'venue':
        return 'Confirm Booking (Pay at Venue)';
      case 'hosted':
        return 'Open Razorpay Gateway Sheet';
      default:
        return 'Pay $amount';
    }
  }

  IconData _getButtonIcon() {
    switch (_selectedCategory) {
      case 'upi':
        return Icons.bolt_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'netbanking':
        return Icons.account_balance_rounded;
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      case 'venue':
        return Icons.storefront_rounded;
      case 'hosted':
        return Icons.open_in_new_rounded;
      default:
        return Icons.lock_outline_rounded;
    }
  }

  Widget _buildInAppProcessingDialog(BuildContext context) {
    final formattedAmount = '₹${NumberFormat('#,##,###').format(_pricing.totalPayable.toInt())}';
    final isDark = AppTheme.isDark(context);

    return Dialog(
      backgroundColor: AppTheme.surface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Razorpay Engine Glow Shield
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFF3395FF), Color(0xFF0F172A)],
                  radius: 0.85,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3395FF).withOpacity(0.35),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 3.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Authorizing Payment...',
              style: GoogleFonts.outfit(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Direct In-App Handshake with Bank\nPlease do not close or press back.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppTheme.textSecondary(context),
              ),
            ),
            const SizedBox(height: 18),
            // Amount badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F1E36) : const Color(0xFFEEF4FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3395FF).withOpacity(0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Amount: ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                  Text(
                    formattedAmount,
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF3395FF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Live Step Indicators
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withOpacity(0.3) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border(context)),
              ),
              child: Column(
                children: [
                  _dialogStepRow(
                    context,
                    icon: Icons.check_circle_rounded,
                    iconColor: AppColors.emerald,
                    title: 'Razorpay Engine Handshake Active',
                    subtitle: 'Key ID: ${RazorpayConfig.keyId.substring(0, 10)}••••',
                  ),
                  const SizedBox(height: 8),
                  _dialogStepRow(
                    context,
                    icon: Icons.lock_outline_rounded,
                    iconColor: const Color(0xFF3395FF),
                    title: '256-Bit SSL Bank Tokenization',
                    subtitle: _getPaymentMethodLabel(),
                  ),
                  const SizedBox(height: 8),
                  _dialogStepRow(
                    context,
                    icon: Icons.verified_rounded,
                    iconColor: AppColors.gold,
                    title: 'Zero Web Redirect Verified',
                    subtitle: 'Instant pass with dynamic entry QR',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security_rounded, size: 14, color: AppColors.emerald),
                const SizedBox(width: 6),
                Text(
                  '100% In-App Safe • RBI Compliant',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.emerald,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogStepRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary(context),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: AppTheme.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: Text(
          'Checkout & Payment',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary(context),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 130),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live Seat Reservation Countdown Timer Banner
                _buildReservationTimerBanner(context),

                // Order Item Summary Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border(context)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          widget.imageUrl,
                          width: 65,
                          height: 65,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 65,
                            height: 65,
                            color: AppTheme.surfaceElevated(context),
                            child: const Icon(Icons.event, color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: widget.bookingType == BookingType.concert
                                    ? AppColors.primary.withOpacity(0.12)
                                    : widget.bookingType == BookingType.dineIn
                                        ? AppColors.emerald.withOpacity(0.12)
                                        : const Color(0xFF0284C7).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.bookingType == BookingType.concert
                                    ? 'CONCERT'
                                    : widget.bookingType == BookingType.dineIn
                                        ? 'DINE-IN'
                                        : 'NORTHEAST TRAVEL',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: widget.bookingType == BookingType.concert
                                      ? AppColors.primary
                                      : widget.bookingType == BookingType.dineIn
                                          ? AppColors.emerald
                                          : const Color(0xFF0284C7),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                            Text(
                              widget.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppTheme.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Promo Coupon Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border(context)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_offer_outlined, size: 18, color: AppColors.gold),
                          const SizedBox(width: 8),
                          Text(
                            'Apply Coupon / Promo',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _couponController,
                              textCapitalization: TextCapitalization.characters,
                              style: TextStyle(color: AppTheme.textPrimary(context)),
                              decoration: InputDecoration(
                                hintText: 'Try TRIBE20, TRIBE1000 or WELCOME500',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppTheme.textMuted(context),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _applyCoupon,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              'Apply',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_couponMessage != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              _isCouponValid ? Icons.check_circle : Icons.error_outline,
                              size: 14,
                              color: _isCouponValid ? AppColors.emerald : AppColors.error,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _couponMessage!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _isCouponValid ? AppColors.emerald : AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Zomato & Swiggy Custom In-App Payment Menu
                _buildZomatoSwiggyPaymentMenu(context),

                const SizedBox(height: 24),

                // Detailed Price Breakdown
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border(context)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price Summary',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _priceRow(context, 'Base Amount', '₹${NumberFormat('#,##,###').format(_pricing.basePrice.toInt())}'),
                      const SizedBox(height: 8),
                      _priceRow(context, 'Convenience Fee (2.5%)', '₹${_pricing.convenienceFee.toInt()}'),
                      const SizedBox(height: 8),
                      _priceRow(context, 'GST (18% on fee)', '₹${_pricing.gstAmount.toInt()}'),
                      if (_pricing.discountAmount > 0) ...[
                        const SizedBox(height: 8),
                        _priceRow(
                          context,
                          'Promo Discount (${_pricing.appliedCoupon})',
                          '- ₹${_pricing.discountAmount.toInt()}',
                          color: AppColors.emerald,
                        ),
                      ],
                      const SizedBox(height: 14),
                      Divider(height: 1, color: AppTheme.border(context)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary(context),
                            ),
                          ),
                          Text(
                            '₹${NumberFormat('#,##,###').format(_pricing.totalPayable.toInt())}',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Checkout Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                border: Border(top: BorderSide(color: AppTheme.border(context), width: 1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(AppTheme.isDark(context) ? 0.3 : 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Grand Total',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppTheme.textMuted(context),
                          ),
                        ),
                        Text(
                          '₹${NumberFormat('#,##,###').format(_pricing.totalPayable.toInt())}',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: AppButton(
                        text: _getButtonLabel(),
                        icon: _isSeatHoldExpired ? Icons.timer_off_rounded : _getButtonIcon(),
                        gradient: _isSeatHoldExpired
                            ? const LinearGradient(colors: [Color(0xFF991B1B), Color(0xFF7F1D1D)])
                            : null,
                        onPressed: _isSeatHoldExpired ? () => _showSeatExpiredSheet(context) : _processPayment,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZomatoSwiggyPaymentMenu(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Payment Options',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary(context),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.emerald.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.emerald.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, size: 11, color: AppColors.emerald),
                  const SizedBox(width: 4),
                  Text(
                    '100% IN-APP SAFE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.emerald,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Razorpay Engine & Security Header Bar
        _buildRazorpayTrustBanner(context),
        const SizedBox(height: 16),

        // Section 1: ⚡ UPI (Recommended)
        _buildUpiSection(context),
        const SizedBox(height: 16),

        // Section 2: 💳 Credit & Debit Cards
        _buildCardsSection(context),
        const SizedBox(height: 16),

        // Section 3: 🏦 Net Banking
        _buildNetBankingSection(context),
        const SizedBox(height: 16),

        // Section 4: 👛 Wallets & Pay Later
        _buildWalletsSection(context),
        const SizedBox(height: 16),

        // Section 5: 💵 Pay at Venue
        _buildVenueSection(context),
        const SizedBox(height: 14),

        // Discrete Hosted Razorpay Sheet Fallback
        _buildHostedRazorpayOption(context),
      ],
    );
  }

  Widget _buildRazorpayTrustBanner(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final hasCustomKey = RazorpayConfig.isCustomKeySet;
    final isLive = RazorpayConfig.isLiveKey;
    final displayKey = RazorpayConfig.keyId.length > 12
        ? '${RazorpayConfig.keyId.substring(0, 10)}••••'
        : RazorpayConfig.keyId;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0F1E36), const Color(0xFF14294A)]
              : [const Color(0xFFEEF4FF), const Color(0xFFE0ECFF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3395FF).withOpacity(0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0C2340),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF3395FF), width: 1.2),
            ),
            child: const Icon(Icons.bolt_rounded, color: Color(0xFF3395FF), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    Text(
                      'Powered by Razorpay Engine',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0C2340),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: hasCustomKey
                            ? (isLive ? AppColors.emerald.withOpacity(0.2) : const Color(0xFF3395FF).withOpacity(0.2))
                            : Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        hasCustomKey ? (isLive ? 'LIVE' : 'CUSTOM') : 'ACTIVE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: hasCustomKey
                              ? (isLive ? AppColors.emerald : const Color(0xFF3395FF))
                              : const Color(0xFF3395FF),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$displayKey • Zero Web Redirects',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: isDark ? Colors.white70 : const Color(0xFF4A5568),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showRazorpayKeyConfigModal(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Key Settings',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3395FF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpiSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _selectedCategory == 'upi'
              ? const Color(0xFF3395FF).withOpacity(0.5)
              : AppTheme.border(context),
          width: _selectedCategory == 'upi' ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bolt_rounded, size: 16, color: AppColors.gold),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UPI (Instant & Free)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      Text(
                        'Google Pay, PhonePe, Paytm, CRED or any UPI App',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '⚡ FASTEST',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.emerald,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.border(context)),

          // Google Pay
          _buildUpiOptionTile(
            context,
            id: 'gpay',
            title: 'Google Pay',
            subtitle: 'Pay directly via linked UPI bank account',
            badge: 'INSTANT REFUND',
            iconWidget: _brandIcon('GPay', const Color(0xFF4285F4), Colors.white),
          ),
          Divider(height: 1, color: AppTheme.border(context).withOpacity(0.5)),

          // PhonePe
          _buildUpiOptionTile(
            context,
            id: 'phonepe',
            title: 'PhonePe UPI',
            subtitle: '1-Click seamless UPI authorization',
            iconWidget: _brandIcon('Pe', const Color(0xFF5F259F), Colors.white),
          ),
          Divider(height: 1, color: AppTheme.border(context).withOpacity(0.5)),

          // Paytm UPI
          _buildUpiOptionTile(
            context,
            id: 'paytm_upi',
            title: 'Paytm UPI',
            subtitle: 'Pay securely from Paytm payments bank',
            iconWidget: _brandIcon('Paytm', const Color(0xFF002E6E), const Color(0xFF00BAF2)),
          ),
          Divider(height: 1, color: AppTheme.border(context).withOpacity(0.5)),

          // CRED UPI
          _buildUpiOptionTile(
            context,
            id: 'cred',
            title: 'CRED UPI',
            subtitle: 'Earn CRED coins & exclusive cashback',
            badge: 'CASHBACK',
            iconWidget: _brandIcon('CRED', Colors.black, Colors.white),
          ),
          Divider(height: 1, color: AppTheme.border(context).withOpacity(0.5)),

          // Enter custom UPI ID / VPA
          _buildUpiOptionTile(
            context,
            id: 'custom_upi',
            title: 'Add Any Other UPI ID',
            subtitle: 'e.g. mobile@upi, name@okhdfcbank',
            iconWidget: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border(context)),
              ),
              child: const Center(
                child: Text('@', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF3395FF))),
              ),
            ),
          ),

          // Custom UPI Input Field when selected
          if (_selectedCategory == 'upi' && _selectedUpiOption == 'custom_upi') ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3395FF).withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _upiIdController,
                      style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 13),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Enter UPI ID (e.g. yourname@oksbi)',
                        hintStyle: TextStyle(color: AppTheme.textMuted(context), fontSize: 12),
                        border: InputBorder.none,
                        prefixIconConstraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        prefixIcon: const Icon(Icons.alternate_email, size: 16, color: Color(0xFF3395FF)),
                        suffixIconConstraints: const BoxConstraints(minWidth: 60, minHeight: 24),
                        suffixIcon: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'VERIFIED',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.emerald,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUpiOptionTile(
    BuildContext context, {
    required String id,
    required String title,
    required String subtitle,
    required Widget iconWidget,
    String? badge,
  }) {
    final isSelected = _selectedCategory == 'upi' && _selectedUpiOption == id;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = 'upi';
          _selectedUpiOption = id;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: AppColors.emerald,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF3395FF) : AppTheme.border(context),
                  width: isSelected ? 5.5 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _selectedCategory == 'card'
              ? const Color(0xFF3395FF).withOpacity(0.5)
              : AppTheme.border(context),
          width: _selectedCategory == 'card' ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3395FF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.credit_card_rounded, size: 16, color: Color(0xFF3395FF)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Credit & Debit Cards',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      Text(
                        'Visa, Mastercard, RuPay & Diners Club',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'RBI TOKENIZED',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF3395FF),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.border(context)),

          // Saved Card (HDFC Millennia)
          InkWell(
            onTap: () {
              setState(() {
                _selectedCategory = 'card';
                _selectedCardOption = 'saved_hdfc';
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C2340),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF3395FF).withOpacity(0.5)),
                    ),
                    child: const Center(
                      child: Text(
                        'VISA',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'HDFC Bank Millennia Card',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'SAVED',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.emerald,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '•••• •••• •••• 6789  |  Expires 12/28',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppTheme.textSecondary(context),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Inline CVV Box
                        Row(
                          children: [
                            SizedBox(
                              width: 80,
                              height: 36,
                              child: TextField(
                                controller: _cardCvvController,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                maxLength: 3,
                                style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 13, fontWeight: FontWeight.w700),
                                decoration: InputDecoration(
                                  counterText: '',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  hintText: 'CVV',
                                  hintStyle: TextStyle(color: AppTheme.textMuted(context), fontSize: 11),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '3 digits on card back',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: AppTheme.textMuted(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (_selectedCategory == 'card' && _selectedCardOption == 'saved_hdfc')
                            ? const Color(0xFF3395FF)
                            : AppTheme.border(context),
                        width: (_selectedCategory == 'card' && _selectedCardOption == 'saved_hdfc') ? 5.5 : 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: AppTheme.border(context).withOpacity(0.5)),

          // Add New Card Tile
          InkWell(
            onTap: () {
              setState(() {
                _selectedCategory = 'card';
                _selectedCardOption = 'new_card';
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.border(context)),
                    ),
                    child: const Icon(Icons.add_rounded, size: 18, color: Color(0xFF3395FF)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Credit or Debit Card',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                        Text(
                          'Save card securely as per RBI guidelines',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            color: AppTheme.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (_selectedCategory == 'card' && _selectedCardOption == 'new_card')
                            ? const Color(0xFF3395FF)
                            : AppTheme.border(context),
                        width: (_selectedCategory == 'card' && _selectedCardOption == 'new_card') ? 5.5 : 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable New Card Form
          if (_selectedCategory == 'card' && _selectedCardOption == 'new_card') ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border(context)),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Card Number',
                        prefixIcon: Icon(Icons.credit_card, size: 18),
                        suffixIcon: Icon(Icons.payment, color: AppColors.cyan, size: 18),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cardExpiryController,
                            keyboardType: TextInputType.datetime,
                            style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 13),
                            decoration: const InputDecoration(
                              labelText: 'Valid Thru (MM/YY)',
                              hintText: 'MM/YY',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _cardCvvController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            maxLength: 3,
                            style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 13),
                            decoration: const InputDecoration(
                              labelText: 'CVV',
                              counterText: '',
                              hintText: '3 digits',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _cardNameController,
                      textCapitalization: TextCapitalization.characters,
                      style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Name on Card',
                        prefixIcon: Icon(Icons.person_outline, size: 18),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: _saveNewCard,
                          activeColor: const Color(0xFF3395FF),
                          onChanged: (val) => setState(() => _saveNewCard = val ?? true),
                        ),
                        Expanded(
                          child: Text(
                            'Save this card securely as per RBI tokenization guidelines',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: AppTheme.textSecondary(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNetBankingSection(BuildContext context) {
    const popularBanks = [
      'HDFC Bank',
      'ICICI Bank',
      'State Bank of India',
      'Axis Bank',
      'Canara Bank',
      'Bank of Baroda',
      'Punjab National Bank',
      'Kotak Bank',
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _selectedCategory == 'netbanking'
              ? const Color(0xFF3395FF).withOpacity(0.5)
              : AppTheme.border(context),
          width: _selectedCategory == 'netbanking' ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance_rounded, size: 16, color: AppColors.emerald),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Net Banking',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    Text(
                      'Direct netbanking from 50+ Indian banks',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 8 Popular Bank Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: popularBanks.map((bank) {
              final isSelected = _selectedCategory == 'netbanking' && _selectedBank == bank;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = 'netbanking';
                    _selectedBank = bank;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF3395FF).withOpacity(0.15)
                        : AppTheme.surfaceElevated(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF3395FF) : AppTheme.border(context),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.account_balance,
                        size: 13,
                        color: isSelected ? const Color(0xFF3395FF) : AppTheme.textSecondary(context),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        bank,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? const Color(0xFF3395FF) : AppTheme.textPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),
          // + 50 Other Banks modal button
          OutlinedButton.icon(
            onPressed: () => _showOtherBanksModal(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              side: BorderSide(color: AppTheme.border(context)),
            ),
            icon: const Icon(Icons.search, size: 16, color: Color(0xFF3395FF)),
            label: Text(
              'Select from 50+ Other Indian Banks...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3395FF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _selectedCategory == 'wallet'
              ? const Color(0xFF3395FF).withOpacity(0.5)
              : AppTheme.border(context),
          width: _selectedCategory == 'wallet' ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, size: 16, color: AppColors.cyan),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wallets & Pay Later',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      Text(
                        'Simpl Pay Later, Paytm, Mobikwik & Tribe Cash',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.border(context)),

          // Tribe Cash Balance
          _buildWalletOptionTile(
            context,
            id: 'tribe_cash',
            title: 'Tribe Pay Cash Balance',
            subtitle: 'Available: ₹15,000 • Instant 1-tap booking',
            badge: 'INSTANT DEBIT',
            icon: Icons.account_balance_wallet,
            iconColor: AppColors.emerald,
          ),
          Divider(height: 1, color: AppTheme.border(context).withOpacity(0.5)),

          // Simpl Pay Later
          _buildWalletOptionTile(
            context,
            id: 'simpl',
            title: 'Simpl Pay Later',
            subtitle: 'Pre-approved limit ₹10,000 • Pay in 15 days',
            badge: 'NO OTP NEEDED',
            icon: Icons.access_time_filled,
            iconColor: const Color(0xFF00D1B2),
          ),
          Divider(height: 1, color: AppTheme.border(context).withOpacity(0.5)),

          // Paytm Wallet
          _buildWalletOptionTile(
            context,
            id: 'paytm_wallet',
            title: 'Paytm Wallet',
            subtitle: 'Linked balance: ₹2,450',
            icon: Icons.wallet_membership,
            iconColor: const Color(0xFF00BAF2),
          ),
          Divider(height: 1, color: AppTheme.border(context).withOpacity(0.5)),

          // Mobikwik
          _buildWalletOptionTile(
            context,
            id: 'mobikwik',
            title: 'Mobikwik Wallet',
            subtitle: 'Instant wallet payment',
            icon: Icons.electric_bolt,
            iconColor: Colors.deepOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildWalletOptionTile(
    BuildContext context, {
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    String? badge,
  }) {
    final isSelected = _selectedCategory == 'wallet' && _selectedWallet == id;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = 'wallet';
          _selectedWallet = id;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: AppColors.emerald,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF3395FF) : AppTheme.border(context),
                  width: isSelected ? 5.5 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueSection(BuildContext context) {
    final isSelected = _selectedCategory == 'venue';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = 'venue';
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppTheme.border(context),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.storefront_rounded, size: 18, color: AppColors.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Pay at Venue / Entry Desk',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'NO CARD NEEDED',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Instant confirmed pass with QR. Settle payment upon arrival at venue.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.gold : AppTheme.border(context),
                  width: isSelected ? 5.5 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostedRazorpayOption(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          if (_isSeatHoldExpired || _secondsRemaining <= 0) {
            _showSeatExpiredSheet(context);
            return;
          }
          setState(() {
            _selectedCategory = 'hosted';
          });
          _processPayment();
        },
        icon: const Icon(Icons.open_in_new_rounded, size: 13, color: Color(0xFF3395FF)),
        label: Text(
          'Need Razorpay standard hosted popup? Tap to launch',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF3395FF),
          ),
        ),
      ),
    );
  }

  Widget _brandIcon(String text, Color bg, Color textCol) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            fontSize: text.length > 3 ? 9 : 12,
            color: textCol,
          ),
        ),
      ),
    );
  }

  void _showOtherBanksModal(BuildContext context) {
    const allBanks = [
      'Axis Bank',
      'Bank of Baroda',
      'Bank of India',
      'Canara Bank',
      'Central Bank of India',
      'City Union Bank',
      'Federal Bank',
      'HDFC Bank',
      'ICICI Bank',
      'IDBI Bank',
      'IDFC FIRST Bank',
      'Indian Bank',
      'Indian Overseas Bank',
      'IndusInd Bank',
      'Jammu & Kashmir Bank',
      'Karnataka Bank',
      'Karur Vysya Bank',
      'Kotak Mahindra Bank',
      'Punjab National Bank',
      'RBL Bank',
      'South Indian Bank',
      'State Bank of India',
      'UCO Bank',
      'Union Bank of India',
      'Yes Bank',
    ];

    final searchCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final query = searchCtrl.text.toLowerCase().trim();
            final filtered = allBanks.where((b) => b.toLowerCase().contains(query)).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: AppTheme.border(context)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.border(context),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select Your Bank',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: searchCtrl,
                    style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 13),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, size: 18),
                      hintText: 'Search 50+ Indian banks...',
                      hintStyle: TextStyle(color: AppTheme.textMuted(context), fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onChanged: (_) => setModalState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: AppTheme.border(context)),
                      itemBuilder: (context, index) {
                        final bank = filtered[index];
                        final isSelected = _selectedBank == bank;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          leading: const Icon(Icons.account_balance, size: 18, color: Color(0xFF3395FF)),
                          title: Text(
                            bank,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? const Color(0xFF3395FF) : AppTheme.textPrimary(context),
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: Color(0xFF3395FF), size: 18)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedCategory = 'netbanking';
                              _selectedBank = bank;
                            });
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRazorpayKeyConfigModal(BuildContext context) {
    final keyController = TextEditingController(
      text: RazorpayConfig.isCustomKeySet ? RazorpayConfig.keyId : '',
    );
    final isDark = AppTheme.isDark(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface(context),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(color: AppTheme.border(context)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.border(context),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3395FF).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.key, color: Color(0xFF3395FF), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Razorpay API Key Setup',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary(context),
                                ),
                              ),
                              Text(
                                'Enter your Key ID from Razorpay Dashboard',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border(context)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFF3395FF)),
                              const SizedBox(width: 6),
                              Text(
                                'Where to find your Key ID:',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary(context),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '1. Sign in to https://dashboard.razorpay.com\n'
                            '2. Go to Account & Settings > API Keys\n'
                            '3. Copy your Key ID (starts with rzp_test_ or rzp_live_)\n'
                            '4. Go to Account & Settings > Payment Methods and toggle ON UPI, Cards & NetBanking.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppTheme.textSecondary(context),
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: keyController,
                      style: TextStyle(
                        color: AppTheme.textPrimary(context),
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Razorpay Key ID',
                        hintText: 'rzp_test_... or rzp_live_...',
                        prefixIcon: const Icon(Icons.vpn_key_outlined),
                        suffixIcon: keyController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  keyController.clear();
                                  setModalState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (_) => setModalState(() {}),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        if (RazorpayConfig.isCustomKeySet) ...[
                          OutlinedButton(
                            onPressed: () async {
                              await RazorpayConfig.resetToDefault();
                              if (mounted) setState(() {});
                              if (context.mounted) Navigator.pop(context);
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text('Reset to default test key configuration.'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Reset'),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final text = keyController.text.trim();
                              if (text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter a valid Razorpay Key ID.'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return;
                              }
                              await RazorpayConfig.setKeyId(text);
                              if (mounted) setState(() {});
                              if (context.mounted) Navigator.pop(context);
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text('Saved Razorpay Key: ${text.substring(0, text.length > 12 ? 12 : text.length)}...'),
                                  backgroundColor: AppColors.emerald,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3395FF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              'Save & Activate Key',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Widget _priceRow(BuildContext context, String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppTheme.textSecondary(context),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color ?? AppTheme.textPrimary(context),
          ),
        ),
      ],
    );
  }
}
