import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/mock_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/concert_card.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/travel_package_card.dart';
import '../concerts/concert_detail_screen.dart';
import '../concerts/concert_list_screen.dart';
import '../dine_in/dine_in_list_screen.dart';
import '../dine_in/restaurant_detail_screen.dart';
import '../profile/profile_screen.dart';
import '../travel/travel_list_screen.dart';
import '../travel/travel_package_detail_screen.dart';
import '../../widgets/location_search_modal.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onTabChange;

  const HomeScreen({super.key, required this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _heroPageController;
  int _currentHeroIndex = 0;
  Timer? _carouselTimer;

  final List<Map<String, dynamic>> _heroPromos = [
    {
      'title': 'Ziro Festival of Music 2026',
      'subtitle': 'Ziro Valley, Arunachal • Passes Live',
      'image': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1200&q=80',
      'tag': 'ICONIC FESTIVAL',
      'type': 'concert',
      'id': 'c1',
    },
    {
      'title': 'Meghalaya Living Root Bridges',
      'subtitle': 'Cherrapunji & Dawki • 6D / 5N All-Inclusive',
      'image': 'https://images.unsplash.com/photo-1518495973542-4542c06a5843?auto=format&fit=crop&w=1200&q=80',
      'tag': 'NORTHEAST EXPEDITION',
      'type': 'travel',
      'id': 'tp1',
    },
    {
      'title': 'Terra Maya Rooftop Lounge',
      'subtitle': 'Guwahati / Dispur • Flat 20% OFF Total Bill',
      'image': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1200&q=80',
      'tag': 'PREMIER DINING',
      'type': 'restaurant',
      'id': 'r1',
    },
    {
      'title': 'Shillong Autumn Rock & Blues',
      'subtitle': 'Polo Grounds, Shillong • Soulmate & GATC',
      'image': 'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?auto=format&fit=crop&w=1200&q=80',
      'tag': 'ROCK CAPITAL',
      'type': 'concert',
      'id': 'c2',
    },
    {
      'title': 'Hornbill Music & Metal Fest',
      'subtitle': 'Kisama, Kohima • Nagaland Rock Arena',
      'image': 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=1200&q=80',
      'tag': 'FESTIVAL OF FESTIVALS',
      'type': 'concert',
      'id': 'c3',
    },
  ];

  @override
  void initState() {
    super.initState();
    _heroPageController = PageController();
    _startCarouselTimer();
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      if (_heroPageController.hasClients) {
        final nextPage = (_currentHeroIndex + 1) % _heroPromos.length;
        _heroPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _heroPageController.dispose();
    super.dispose();
  }

  void _showCityPicker(BuildContext context) {
    LocationSearchModal.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final filteredConcerts = bookingProvider.getFilteredConcerts();
    final filteredRestaurants = bookingProvider.getFilteredRestaurants();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Top Header (Pinned at top, Logo fixed in exact center)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.bg(context),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.border(context).withOpacity(0.4),
                    width: 0.5,
                  ),
                ),
              ),
              child: SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Brand Logo - Fixed in the Exact Center of Screen
                    Center(
                      child: Text(
                        'TRIBE',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3.5,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                    ),

                    // Left: City Picker Dropdown (Compact, sleek District style)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => _showCityPicker(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.surface(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.border(context)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on, size: 14, color: AppColors.accent),
                              const SizedBox(width: 4),
                              Text(
                                bookingProvider.selectedCity.split('/').first.trim(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary(context),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(Icons.keyboard_arrow_down, size: 14, color: AppTheme.textSecondary(context)),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Right: User Avatar or Login
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileScreen()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 1.5),
                          ),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.surfaceElevated(context),
                            backgroundImage: auth.user?.avatarUrl != null
                                ? NetworkImage(auth.user!.avatarUrl!)
                                : null,
                            child: auth.user?.avatarUrl == null
                                ? const Icon(Icons.person, size: 18, color: AppColors.primary)
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                // Top 3 Quick Booking Cards (Concerts, Dine-In, Travel Booking)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildTopCategoryCard(
                        title: 'Live Shows',
                        subtitle: 'Comedy & Music',
                        badge: 'TICKETS',
                        icon: Icons.theater_comedy_rounded,
                        color: const Color(0xFF6366F1),
                        bgColor: const Color(0xFFEEF2FF),
                        onTap: () {
                          bookingProvider.setActiveCategory('Concerts');
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ConcertListScreen()),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildTopCategoryCard(
                        title: 'Dine-In',
                        subtitle: 'Book Table',
                        badge: 'OFFERS',
                        icon: Icons.restaurant_rounded,
                        color: const Color(0xFFF97316),
                        bgColor: const Color(0xFFFFF7ED),
                        onTap: () {
                          bookingProvider.setActiveCategory('Dine-In');
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DineInListScreen()),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildTopCategoryCard(
                        title: 'Travel',
                        subtitle: 'Northeast',
                        badge: 'TOURS',
                        icon: Icons.landscape_rounded,
                        color: const Color(0xFF10B981),
                        bgColor: const Color(0xFFECFDF5),
                        onTap: () {
                          bookingProvider.setActiveCategory('Travel');
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TravelListScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Category Filter Chips
                SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      CategoryChip(
                        label: 'All Experiences',
                        icon: Icons.explore,
                        isSelected: bookingProvider.activeCategory == 'All',
                        onTap: () => bookingProvider.setActiveCategory('All'),
                      ),
                      const SizedBox(width: 8),
                      CategoryChip(
                        label: 'Live Shows & Comedy',
                        icon: Icons.theater_comedy,
                        isSelected: bookingProvider.activeCategory == 'Concerts',
                        onTap: () {
                          bookingProvider.setActiveCategory('Concerts');
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ConcertListScreen()),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      CategoryChip(
                        label: 'Northeast Travel',
                        icon: Icons.landscape,
                        isSelected: bookingProvider.activeCategory == 'Travel',
                        onTap: () {
                          bookingProvider.setActiveCategory('Travel');
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TravelListScreen()),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      CategoryChip(
                        label: 'Dine-In & Lounges',
                        icon: Icons.restaurant,
                        isSelected: bookingProvider.activeCategory == 'Dine-In',
                        onTap: () {
                          bookingProvider.setActiveCategory('Dine-In');
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DineInListScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 4. Hero Carousel
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _heroPageController,
                    onPageChanged: (i) {
                      setState(() {
                        _currentHeroIndex = i;
                      });
                    },
                    itemCount: _heroPromos.length,
                    itemBuilder: (context, i) {
                      final promo = _heroPromos[i];
                      return GestureDetector(
                        onTap: () {
                          if (promo['type'] == 'concert') {
                            final concert = MockData.concerts.firstWhere((c) => c.id == promo['id']);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ConcertDetailScreen(concert: concert)),
                            );
                          } else if (promo['type'] == 'travel') {
                            final pkg = MockData.travelPackages.firstWhere((p) => p.id == promo['id']);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TravelPackageDetailScreen(package: pkg)),
                            );
                          } else {
                            final rest = MockData.restaurants.firstWhere((r) => r.id == promo['id']);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RestaurantDetailScreen(restaurant: rest)),
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  promo['image'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Color(0xFF1E3A2F), Color(0xFF0F1E19)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.landscape, size: 48, color: Colors.white24),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.3),
                                      Colors.black.withOpacity(0.8),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    promo['tag'],
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 14,
                                left: 14,
                                right: 14,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            promo['title'],
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            promo['subtitle'],
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Book Now',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Carousel Dots indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_heroPromos.length, (i) {
                    final isSelected = _currentHeroIndex == i;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isSelected ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.borderHighlight,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // 5. Section: Trending Concerts (Horizontal Carousel)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live Shows & Standup Comedy',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                            Text(
                              'Standup comedy, musical nights, rock & theatre in ${bookingProvider.selectedCity}',
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
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ConcertListScreen()),
                          );
                        },
                        child: Text(
                          'See All',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 255,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredConcerts.length,
                    itemBuilder: (context, i) {
                      final concert = filteredConcerts[i];
                      return ConcertCard(
                        concert: concert,
                        isHorizontal: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConcertDetailScreen(concert: concert),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // 6. Section: Top Dine-In & Nightlife Lounges
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Curated Dine-In & Rooftops',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                            Text(
                              'Exclusive tables, craft cocktails and nightlife lounges',
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
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DineInListScreen()),
                          );
                        },
                        child: Text(
                          'See All',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 255,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredRestaurants.length,
                    itemBuilder: (context, i) {
                      final restaurant = filteredRestaurants[i];
                      return RestaurantCard(
                        restaurant: restaurant,
                        isHorizontal: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestaurantDetailScreen(restaurant: restaurant),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // 7. Section: Northeast India Expeditions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Northeast India Expeditions',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                            Text(
                              'Meghalaya, Kaziranga, Tawang, Nagaland & Sikkim Packages',
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
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TravelListScreen()),
                          );
                        },
                        child: Text(
                          'See All',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 295,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: MockData.travelPackages.length,
                    itemBuilder: (context, i) {
                      final pkg = MockData.travelPackages[i];
                      return TravelPackageCard(
                        package: pkg,
                        isHorizontal: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TravelPackageDetailScreen(package: pkg),
                            ),
                          );
                        },
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
),
    );
  }

  Widget _buildTopCategoryCard({
    required String title,
    required String subtitle,
    required String badge,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    final isDark = AppTheme.isDark(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.cardColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border(context), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black38 : const Color(0x08000000),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isDark ? color.withOpacity(0.2) : bgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
