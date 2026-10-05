import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/booking_model.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

class QrTicketModal extends StatelessWidget {
  final BookingModel booking;

  const QrTicketModal({super.key, required this.booking});

  static void show(BuildContext context, BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QrTicketModal(booking: booking),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('EEEE, MMMM d, yyyy').format(booking.dateTime);
    final isConcert = booking.type == BookingType.concert;
    final isTravel = booking.type == BookingType.travel;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: AppTheme.bg(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.border(context),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // Top title bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isTravel
                      ? 'Northeast Expedition Pass'
                      : isConcert
                          ? 'Official Concert Pass'
                          : 'Dine-In Reservation Pass',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: AppTheme.textSecondary(context)),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // Pass Container (styled like an authentic pass)
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor(context),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.border(context), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(AppTheme.isDark(context) ? 0.08 : 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header banner / event image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          child: Stack(
                            children: [
                              Image.network(
                                booking.imageUrl,
                                height: 130,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 130,
                                  color: AppTheme.surfaceElevated(context),
                                ),
                              ),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.3),
                                        Colors.black.withOpacity(0.85),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 12,
                                left: 16,
                                right: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isTravel
                                            ? const Color(0xFF0284C7)
                                            : isConcert
                                                ? AppColors.primary
                                                : AppColors.emerald,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isTravel
                                            ? 'NORTHEAST EXPEDITION'
                                            : isConcert
                                                ? 'CONCERT PASS'
                                                : 'CONFIRMED TABLE',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      booking.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Pass Details
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _infoColumn(context, 'DATE', dateFormatted),
                                  _infoColumn(context, 'TIME', DateFormat('hh:mm a').format(booking.dateTime)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _infoColumn(context, 'VENUE', '${booking.venue}, ${booking.city}'),
                              const SizedBox(height: 16),
                              if (isConcert && booking.concertTickets != null) ...[
                                Text(
                                  'TICKETS SELECTED',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textMuted(context),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ...booking.concertTickets!.map(
                                  (t) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${t.count}x ${t.tierName}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textPrimary(context),
                                          ),
                                        ),
                                        Text(
                                          '₹${(t.count * t.unitPrice).toInt()}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textSecondary(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ] else if (booking.dineInDetail != null) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _infoColumn(context, 'GUESTS', '${booking.dineInDetail!.partySize} Persons'),
                                    _infoColumn(context, 'SEATING', booking.dineInDetail!.seatingArea),
                                  ],
                                ),
                              ] else if (booking.travelDetail != null) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _infoColumn(context, 'TRAVELERS', '${booking.travelDetail!.travelersCount} Person(s)'),
                                    _infoColumn(context, 'STATE', booking.travelDetail!.state),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _infoColumn(context, 'DURATION', booking.travelDetail!.duration),
                                    _infoColumn(context, 'PICKUP', booking.travelDetail!.pickupLocation),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                _infoColumn(context, 'BATCH DATES', booking.travelDetail!.batchDate),
                              ],
                            ],
                          ),
                        ),

                        // Perforated Ticket Divider with Notches
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppTheme.bg(context),
                                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
                                  ),
                                ),
                                Expanded(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final count = (constraints.constrainWidth() / 10).floor();
                                      return Flex(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        direction: Axis.horizontal,
                                        children: List.generate(
                                          count,
                                          (_) => SizedBox(
                                            width: 5,
                                            height: 1.5,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(color: AppTheme.border(context)),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  width: 14,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppTheme.bg(context),
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // QR Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          child: Column(
                            children: [
                              Text(
                                'SCAN AT ENTRY GATE',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textSecondary(context),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                                child: QrImageView(
                                  data: booking.qrCodeData,
                                  version: QrVersions.auto,
                                  size: 170.0,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceElevated(context),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.border(context)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.confirmation_number, size: 16, color: AppColors.gold),
                                    const SizedBox(width: 8),
                                    Text(
                                      'PASS ID: ${booking.bookingReference}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textPrimary(context),
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Txn: ${booking.transactionId}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  color: AppTheme.textMuted(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Add to Wallet',
                          icon: Icons.account_balance_wallet,
                          isOutlined: true,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pass saved to Google / Apple Wallet!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AppButton(
                          text: 'Share Pass',
                          icon: Icons.share,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Booking reference ${booking.bookingReference} copied to clipboard!'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoColumn(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppTheme.textMuted(context),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary(context),
          ),
        ),
      ],
    );
  }
}
