import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/concert_model.dart';
import '../../providers/booking_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import 'ticket_selection_screen.dart';

class ConcertDetailScreen extends StatelessWidget {
  final ConcertModel concert;

  const ConcertDetailScreen({super.key, required this.concert});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final isFav = bookingProvider.isFavorite(concert.id);
    final dateFormatted = DateFormat('EEEE, MMMM d, yyyy').format(concert.date);

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            slivers: [
              // Hero Image App Bar
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: AppTheme.bg(context),
                leading: Container(
                  margin: const EdgeInsets.only(left: 14, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8, right: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.share, color: Colors.white, size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Share link for ${concert.title} copied!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8, right: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? AppColors.accent : Colors.white,
                        size: 20,
                      ),
                      onPressed: () => bookingProvider.toggleFavorite(concert.id),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    concert.bannerUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppTheme.surfaceElevated(context),
                      child: const Icon(Icons.music_note, size: 64, color: AppColors.primary),
                    ),
                  ),
                ),
              ),

              // Details Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Genre and fast filling tags
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              concert.genre,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (concert.isFastFilling) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.local_fire_department, size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'FILLING FAST',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        concert.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Artist row
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(concert.thumbnailUrl),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    concert.artist,
                                    style: GoogleFonts.outfit(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary(context),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.verified, size: 16, color: AppColors.primary),
                                ],
                              ),
                              Text(
                                'Headlining Artist',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppTheme.textMuted(context),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor(context),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.border(context)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, size: 16, color: AppColors.gold),
                                const SizedBox(width: 4),
                                Text(
                                  '${concert.rating}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Quick Info Grid
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor(context),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.border(context)),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              context,
                              Icons.calendar_today,
                              AppColors.cyan,
                              'Date & Time',
                              dateFormatted,
                              concert.time,
                            ),
                            Divider(height: 20, color: AppTheme.border(context)),
                            _buildInfoRow(
                              context,
                              Icons.location_on,
                              AppColors.accent,
                              'Venue Location',
                              concert.venue,
                              concert.city,
                            ),
                            Divider(height: 20, color: AppTheme.border(context)),
                            _buildInfoRow(
                              context,
                              Icons.timer,
                              AppColors.emerald,
                              'Show Details',
                              'Duration: ${concert.duration}',
                              'Age Limit: ${concert.ageLimit}',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // About Event
                      Text(
                        'About The Event',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        concert.description,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          height: 1.6,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Event Highlights
                      Text(
                        'Tour Highlights',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...concert.highlights.map(
                        (h) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, size: 14, color: AppColors.primaryLight),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  h,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    height: 1.4,
                                    color: AppTheme.textSecondary(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Important Guidelines
                      Text(
                        'Important Guidelines',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated(context),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.border(context)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: concert.rules.map((rule) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(color: AppColors.warning, fontSize: 16)),
                                  Expanded(
                                    child: Text(
                                      rule,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        height: 1.4,
                                        color: AppTheme.textSecondary(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Fixed Booking Bar
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
                    blurRadius: 20,
                    offset: const Offset(0, -6),
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
                          'Starting From',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppTheme.textMuted(context),
                          ),
                        ),
                        Text(
                          '₹${NumberFormat('#,##,###').format(concert.startingPrice.toInt())}',
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
                        text: 'Select Tickets',
                        icon: Icons.confirmation_number_outlined,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TicketSelectionScreen(concert: concert),
                            ),
                          );
                        },
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

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    Color iconColor,
    String title,
    String primaryText,
    String secondaryText,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted(context),
                ),
              ),
              Text(
                primaryText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary(context),
                ),
              ),
              Text(
                secondaryText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppTheme.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
