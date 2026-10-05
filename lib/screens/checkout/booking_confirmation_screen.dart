import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/booking_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/qr_ticket_modal.dart';
import '../main_navigation_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingConfirmationScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('EEE, MMMM d, yyyy').format(booking.dateTime);
    final isConcert = booking.type == BookingType.concert;
    final isTravel = booking.type == BookingType.travel;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen(initialIndex: 0)),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.bg(context),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: AppTheme.textPrimary(context)),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainNavigationScreen(initialIndex: 0)),
                (route) => false,
              );
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // Success Checkmark Circle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.emerald,
                    size: 38,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Booking Confirmed!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isTravel
                      ? 'Your Northeast travel expedition has been successfully booked'
                      : isConcert
                          ? 'Your concert entry tickets are ready in your passes'
                          : 'Your table reservation has been confirmed',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppTheme.textSecondary(context),
                  ),
                ),

                const SizedBox(height: 20),

                // Ticket Card Preview with QR
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border(context)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(AppTheme.isDark(context) ? 0.2 : 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Top info
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isTravel
                                        ? const Color(0xFF0284C7)
                                        : isConcert
                                            ? AppColors.primary
                                            : AppColors.emerald,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isTravel
                                        ? 'NORTHEAST TRAVEL PASS'
                                        : isConcert
                                            ? 'CONCERT PASS'
                                            : 'DINE-IN RESERVATION',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  'PASS #${booking.bookingReference}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              booking.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              booking.subtitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppTheme.textSecondary(context),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: AppColors.accent),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${booking.venue}, ${booking.city}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: AppTheme.textMuted(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 13, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  dateFormatted,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // QR Code Container
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border(context)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: QrImageView(
                                data: booking.qrCodeData,
                                version: QrVersions.auto,
                                size: 130.0,
                                backgroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'SCAN FOR ENTRY / HOSTESS CHECK-IN',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textSecondary(context),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Payment Receipt row
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated(context),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Amount Paid',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary(context),
                                    ),
                                  ),
                                  Text(
                                    '₹${NumberFormat('#,##,###').format(booking.totalAmount.toInt())}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.emerald,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Method',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary(context),
                                    ),
                                  ),
                                  Text(
                                    booking.paymentMethod,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary(context),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Actions
                AppButton(
                  text: 'View Full Digital Pass',
                  icon: Icons.qr_code,
                  onPressed: () => QrTicketModal.show(context, booking),
                ),
                const SizedBox(height: 10),
                AppButton(
                  text: 'Go to My Passes',
                  isSecondary: true,
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainNavigationScreen(initialIndex: 2), // Index 2 is Passes
                      ),
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainNavigationScreen(initialIndex: 0),
                      ),
                      (route) => false,
                    );
                  },
                  child: Text(
                    'Return to Home',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
