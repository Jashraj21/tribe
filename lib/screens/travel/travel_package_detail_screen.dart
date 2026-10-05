import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/travel_package_model.dart';
import '../../providers/booking_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../checkout/checkout_screen.dart';

class TravelPackageDetailScreen extends StatefulWidget {
  final TravelPackageModel package;

  const TravelPackageDetailScreen({super.key, required this.package});

  @override
  State<TravelPackageDetailScreen> createState() => _TravelPackageDetailScreenState();
}

class _TravelPackageDetailScreenState extends State<TravelPackageDetailScreen> {
  int _travelersCount = 2;
  late TravelBatchModel _selectedBatch;

  @override
  void initState() {
    super.initState();
    _selectedBatch = widget.package.batches.first;
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final isFav = bookingProvider.isFavorite(widget.package.id);
    final totalAmount = widget.package.pricePerPerson * _travelersCount;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero App Bar
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
                            content: Text('Trip link for ${widget.package.title} copied!'),
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
                      onPressed: () => bookingProvider.toggleFavorite(widget.package.id),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    widget.package.bannerUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppTheme.surfaceElevated(context),
                      child: const Icon(Icons.terrain, size: 64, color: AppColors.primary),
                    ),
                  ),
                ),
              ),

              // Content Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // State & Duration Badges
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.package.state.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor(context),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppTheme.border(context)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time, size: 12, color: AppTheme.textSecondary(context)),
                                const SizedBox(width: 4),
                                Text(
                                  widget.package.duration,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.package.offerTag.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.package.offerTag,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF047857),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Package Title
                      Text(
                        widget.package.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.package.tagline,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Rating & Price per person
                      Row(
                        children: [
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
                                  '${widget.package.rating}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary(context),
                                  ),
                                ),
                                Text(
                                  ' (${widget.package.reviewsCount} reviews)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${NumberFormat('#,##,###').format(widget.package.pricePerPerson.toInt())}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary(context),
                                ),
                              ),
                              Text(
                                'per traveler',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppTheme.textMuted(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Key Trip Facts Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor(context),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.border(context)),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(context, Icons.flight_takeoff, AppColors.primary, 'Pickup & Drop', widget.package.pickupCity, 'Airport assistance included'),
                            Divider(height: 20, color: AppTheme.border(context)),
                            _buildInfoRow(context, Icons.group, AppColors.emerald, 'Group Size', widget.package.groupSize, 'Solo, couples & friends welcome'),
                            Divider(height: 20, color: AppTheme.border(context)),
                            _buildInfoRow(context, Icons.hiking, AppColors.accent, 'Trip Style & Level', '${widget.package.tripStyle} • ${widget.package.difficulty}', 'Comfortable SUV hill journeys'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Trip Overview
                      Text(
                        'Trip Overview',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.package.overview,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          height: 1.5,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Trip Highlights
                      Text(
                        'Tour Highlights',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...widget.package.highlights.map(
                        (h) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle, size: 16, color: Color(0xFF10B981)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  h,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: AppTheme.textPrimary(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Step 1: Select Departure Batch
                      Text(
                        '1. Select Departure Batch',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: widget.package.batches.map((batch) {
                          final isSelected = _selectedBatch.id == batch.id;
                          final dateStr =
                              '${DateFormat('dd MMM').format(batch.departureDate)} – ${DateFormat('dd MMM yyyy').format(batch.endDate)}';

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedBatch = batch;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary.withOpacity(0.08) : AppTheme.cardColor(context),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppTheme.border(context),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                    size: 18,
                                    color: isSelected ? AppColors.primary : AppTheme.textMuted(context),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dateStr,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textPrimary(context),
                                          ),
                                        ),
                                        Text(
                                          '${batch.availableSlots} seats available',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: batch.status == 'Filling Fast'
                                          ? AppColors.accent.withOpacity(0.12)
                                          : const Color(0xFF10B981).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      batch.status,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: batch.status == 'Filling Fast'
                                            ? AppColors.accent
                                            : const Color(0xFF047857),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // Step 2: Number of Travelers
                      Text(
                        '2. Number of Travelers',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border(context)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$_travelersCount ${_travelersCount == 1 ? "Traveler" : "Travelers"}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary(context),
                                  ),
                                ),
                                Text(
                                  '₹${NumberFormat('#,##,###').format(widget.package.pricePerPerson.toInt())} × $_travelersCount',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppTheme.textMuted(context),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _counterBtn(
                                  context: context,
                                  icon: Icons.remove,
                                  onTap: _travelersCount > 1
                                      ? () {
                                          setState(() {
                                            _travelersCount--;
                                          });
                                        }
                                      : null,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    '$_travelersCount',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary(context),
                                    ),
                                  ),
                                ),
                                _counterBtn(
                                  context: context,
                                  icon: Icons.add,
                                  onTap: _travelersCount < 10
                                      ? () {
                                          setState(() {
                                            _travelersCount++;
                                          });
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Day by Day Itinerary
                      Text(
                        'Day-by-Day Itinerary',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...widget.package.itinerary.map((day) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.border(context)),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'D${day.dayNumber}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              title: Text(
                                day.title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary(context),
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        day.description,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          height: 1.5,
                                          color: AppTheme.textSecondary(context),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: day.highlights.map((h) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppTheme.surfaceElevated(context),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '• $h',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 11,
                                                color: AppTheme.textSecondary(context),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(Icons.hotel, size: 14, color: AppTheme.textMuted(context)),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'Stay: ${day.stay}',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 11,
                                                color: AppTheme.textMuted(context),
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
                      }),

                      const SizedBox(height: 24),

                      // Inclusions & Exclusions
                      Text(
                        'What\'s Included',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border(context)),
                        ),
                        child: Column(
                          children: widget.package.inclusions.map((inc) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check, size: 16, color: Color(0xFF10B981)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      inc,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: AppTheme.textPrimary(context),
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

          // Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                border: Border(top: BorderSide(color: AppTheme.border(context), width: 1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(AppTheme.isDark(context) ? 0.3 : 0.08),
                    blurRadius: 8,
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
                          'Total Package Price',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppTheme.textMuted(context),
                          ),
                        ),
                        Text(
                          '₹${NumberFormat('#,##,###').format(totalAmount.toInt())}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppButton(
                        text: 'Book Package',
                        icon: Icons.card_travel,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutScreen(
                                travelPackage: widget.package,
                                travelBatch: _selectedBatch,
                                travelersCount: _travelersCount,
                              ),
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
    Color color,
    String title,
    String primary,
    String secondary,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
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
                primary,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                secondary,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppTheme.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _counterBtn({required BuildContext context, required IconData icon, required VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: onTap != null ? AppTheme.surfaceElevated(context) : AppTheme.surfaceElevated(context).withOpacity(0.4),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.border(context)),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? AppTheme.textPrimary(context) : AppTheme.textMuted(context),
        ),
      ),
    );
  }
}
