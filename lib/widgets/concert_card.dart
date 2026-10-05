import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/concert_model.dart';
import '../providers/booking_provider.dart';
import '../theme/app_theme.dart';

class ConcertCard extends StatelessWidget {
  final ConcertModel concert;
  final VoidCallback onTap;
  final bool isHorizontal;

  const ConcertCard({
    super.key,
    required this.concert,
    required this.onTap,
    this.isHorizontal = false,
  });

  IconData _getEventIcon() {
    final e = concert.eventType.toLowerCase();
    final g = concert.genre.toLowerCase();
    if (e.contains('standup') || g.contains('standup') || g.contains('comedy') || g.contains('improv')) {
      return Icons.mic;
    }
    if (e.contains('magic') || g.contains('magic') || g.contains('mentalism')) {
      return Icons.auto_awesome;
    }
    if (e.contains('theatre') || g.contains('theatre') || g.contains('drama')) {
      return Icons.theater_comedy;
    }
    if (e.contains('poetry') || g.contains('poetry') || g.contains('open mic') || g.contains('spoken word')) {
      return Icons.record_voice_over;
    }
    return Icons.music_note;
  }

  Color _getEventBadgeColor() {
    final e = concert.eventType.toLowerCase();
    final g = concert.genre.toLowerCase();
    if (e.contains('standup') || g.contains('comedy')) {
      return const Color(0xFFF59E0B);
    }
    if (e.contains('magic') || g.contains('mentalism')) {
      return const Color(0xFF8B5CF6);
    }
    if (e.contains('theatre') || g.contains('drama') || g.contains('poetry')) {
      return const Color(0xFFEC4899);
    }
    if (e.contains('musical') || g.contains('acoustic') || g.contains('sufi')) {
      return const Color(0xFF10B981);
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final isFav = bookingProvider.isFavorite(concert.id);
    final dateFormatted = DateFormat('EEE, MMM d').format(concert.date);
    final isDark = AppTheme.isDark(context);

    if (isHorizontal) {
      // Horizontal compact card for home carousel
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 250,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            color: AppTheme.cardColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border(context), width: 1),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black38 : Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      concert.thumbnailUrl,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 130,
                        color: AppTheme.surfaceElevated(context),
                        child: Icon(_getEventIcon(), size: 40, color: AppColors.primary),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: concert.isFastFilling ? AppColors.accent : _getEventBadgeColor(),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getEventIcon(), size: 10, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            concert.isFastFilling ? 'FAST FILLING' : concert.eventType.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => bookingProvider.toggleFavorite(concert.id),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppTheme.surface(context),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isFav ? AppColors.error : AppTheme.textMuted(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      concert.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      concert.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: AppTheme.textMuted(context)),
                        const SizedBox(width: 4),
                        Text(
                          dateFormatted,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppTheme.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${NumberFormat('#,##,###').format(concert.startingPrice.toInt())}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Book',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
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
      );
    }

    // Standard Vertical Card
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border(context), width: 1),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black38 : Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    concert.bannerUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160,
                      color: AppTheme.surfaceElevated(context),
                      child: Icon(_getEventIcon(), size: 48, color: AppColors.primary),
                    ),
                  ),
                ),
                if (concert.isFastFilling)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'FILLING FAST',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => bookingProvider.toggleFavorite(concert.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.surface(context),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFav ? AppColors.error : AppTheme.textMuted(context),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getEventBadgeColor(),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_getEventIcon(), size: 11, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              concert.eventType.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.surface(context).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.border(context)),
                        ),
                        child: Text(
                          concert.genre,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.surface(context),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppTheme.border(context)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: AppColors.gold),
                        const SizedBox(width: 3),
                        Text(
                          '${concert.rating}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    concert.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    concert.artist,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 13, color: AppTheme.textMuted(context)),
                      const SizedBox(width: 6),
                      Text(
                        '$dateFormatted • ${concert.time}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 13, color: AppTheme.textMuted(context)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${concert.venue}, ${concert.city}',
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
                  const SizedBox(height: 12),
                  Divider(height: 1, color: AppTheme.border(context)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tickets from',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppTheme.textMuted(context),
                            ),
                          ),
                          Text(
                            '₹${NumberFormat('#,##,###').format(concert.startingPrice.toInt())}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Book Now',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
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
    );
  }
}
