import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant_model.dart';
import '../../providers/booking_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import 'table_reservation_screen.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final isFav = bookingProvider.isFavorite(restaurant.id);

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
                            content: Text('Share link for ${restaurant.name} copied!'),
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
                      onPressed: () => bookingProvider.toggleFavorite(restaurant.id),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    restaurant.bannerUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppTheme.surfaceElevated(context),
                      child: const Icon(Icons.restaurant, size: 64, color: AppColors.primary),
                    ),
                  ),
                ),
              ),

              // Content Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (restaurant.offerTag.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.emerald,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            restaurant.offerTag,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      Text(
                        restaurant.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        restaurant.cuisine,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Rating & Highlights Bar
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
                                  '${restaurant.rating}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary(context),
                                  ),
                                ),
                                Text(
                                  ' (${restaurant.reviewsCount} reviews)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '₹${NumberFormat('#,##,###').format(restaurant.costForTwo.toInt())} for two',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary(context),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Location & Hours Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor(context),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.border(context)),
                        ),
                        child: Column(
                          children: [
                            _buildMetaRow(
                              context,
                              Icons.location_on,
                              AppColors.accent,
                              'Location & Address',
                              '${restaurant.venue}, ${restaurant.city}',
                              restaurant.address,
                            ),
                            Divider(height: 20, color: AppTheme.border(context)),
                            _buildMetaRow(
                              context,
                              Icons.access_time_filled,
                              AppColors.cyan,
                              'Operating Hours',
                              restaurant.openingHours,
                              'Dinner service starts 7:00 PM',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Features & Ambience
                      Text(
                        'Ambience & Features',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: restaurant.features.map((feat) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceElevated(context),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.border(context)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check, size: 14, color: AppColors.emerald),
                                const SizedBox(width: 6),
                                Text(
                                  feat,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary(context),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // About Restaurant
                      Text(
                        'About The Experience',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        restaurant.description,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          height: 1.6,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Chef's Specials Menu Preview
                      Text(
                        'Chef\'s Tasting Highlights',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Popular signature dishes can be pre-ordered while reserving',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppTheme.textMuted(context),
                        ),
                      ),
                      const SizedBox(height: 14),

                      ...restaurant.menuSpecials.map((item) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.border(context)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Veg / Non Veg Indicator
                              Container(
                                margin: const EdgeInsets.only(top: 3),
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: item.isVeg ? Colors.green : Colors.red,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: CircleAvatar(
                                  radius: 4,
                                  backgroundColor: item.isVeg ? Colors.green : Colors.red,
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
                                          item.name,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textPrimary(context),
                                          ),
                                        ),
                                        if (item.isChefSpecial) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.gold.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'SIGNATURE',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.gold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      item.description,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: AppTheme.textMuted(context),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '₹${item.price.toInt()}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
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
                          'Table Cover Charge',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppTheme.textMuted(context),
                          ),
                        ),
                        Text(
                          '₹${restaurant.tableCoverCharge.toInt()} (Adjustable)',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.emerald,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: AppButton(
                        text: 'Reserve Table',
                        icon: Icons.table_restaurant,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00C853), Color(0xFF009688)],
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TableReservationScreen(restaurant: restaurant),
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

  Widget _buildMetaRow(
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
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
