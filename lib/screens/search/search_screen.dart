import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/mock_data.dart';
import '../../models/concert_model.dart';
import '../../models/restaurant_model.dart';
import '../../models/travel_package_model.dart';
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
import '../travel/travel_list_screen.dart';
import '../travel/travel_package_detail_screen.dart';
import '../../widgets/location_search_modal.dart';

class SearchScreen extends StatefulWidget {
  final Function(int)? onTabChange;

  const SearchScreen({super.key, this.onTabChange});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All'; // 'All', 'Concerts', 'Dine-In', 'Travel'
  String _query = '';

  final List<String> _categories = ['All', 'Live Shows', 'Standup Comedy', 'Musical Nights', 'Dine-In', 'Travel Tours'];

  final List<Map<String, dynamic>> _trendingKeywords = [
    {'label': 'Standup Comedy', 'icon': Icons.mic, 'type': 'concert'},
    {'label': 'Zakir Khan Live', 'icon': Icons.mic_external_on, 'type': 'concert'},
    {'label': 'Sufi & Acoustic Night', 'icon': Icons.nightlife, 'type': 'concert'},
    {'label': 'Ziro Festival', 'icon': Icons.music_note, 'type': 'concert'},
    {'label': 'Terra Maya Rooftop', 'icon': Icons.restaurant, 'type': 'dine_in'},
    {'label': 'Shillong Autumn Rock', 'icon': Icons.speaker, 'type': 'concert'},
    {'label': 'Illusion & Mentalism', 'icon': Icons.auto_awesome, 'type': 'concert'},
    {'label': 'Meghalaya Living Bridges', 'icon': Icons.landscape, 'type': 'travel'},
    {'label': 'Kaziranga Rhino Safari', 'icon': Icons.pets, 'type': 'travel'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchKeywordTapped(String keyword) {
    setState(() {
      _searchController.text = keyword;
      _query = keyword.trim().toLowerCase();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final selectedCity = bookingProvider.selectedCity;
    final isDark = AppTheme.isDark(context);

    // Filter concerts
    final allConcerts = MockData.concerts;
    final filteredConcerts = allConcerts.where((c) {
      final matchesCity = selectedCity == 'All Northeast' ||
          c.city.toLowerCase().contains(selectedCity.toLowerCase()) ||
          selectedCity.toLowerCase().contains(c.city.toLowerCase()) ||
          c.venue.toLowerCase().contains(selectedCity.toLowerCase());

      if (_query.isEmpty) return matchesCity;

      final matchesQuery = c.title.toLowerCase().contains(_query) ||
          c.artist.toLowerCase().contains(_query) ||
          c.genre.toLowerCase().contains(_query) ||
          c.eventType.toLowerCase().contains(_query) ||
          c.venue.toLowerCase().contains(_query) ||
          c.city.toLowerCase().contains(_query);
      return matchesQuery;
    }).toList();

    // Filter restaurants
    final allRestaurants = MockData.restaurants;
    final filteredRestaurants = allRestaurants.where((r) {
      final matchesCity = selectedCity == 'All Northeast' ||
          r.city.toLowerCase().contains(selectedCity.toLowerCase()) ||
          selectedCity.toLowerCase().contains(r.city.toLowerCase()) ||
          r.venue.toLowerCase().contains(selectedCity.toLowerCase());

      if (_query.isEmpty) return matchesCity;

      final matchesQuery = r.name.toLowerCase().contains(_query) ||
          r.cuisine.toLowerCase().contains(_query) ||
          r.venue.toLowerCase().contains(_query) ||
          r.city.toLowerCase().contains(_query);
      return matchesQuery;
    }).toList();

    // Filter travel packages
    final allTravel = MockData.travelPackages;
    final filteredTravel = allTravel.where((t) {
      final matchesCity = selectedCity == 'All Northeast' ||
          t.state.toLowerCase().contains(selectedCity.toLowerCase()) ||
          selectedCity.toLowerCase().contains(t.state.toLowerCase()) ||
          t.pickupCity.toLowerCase().contains(selectedCity.toLowerCase());

      if (_query.isEmpty) return matchesCity;

      final matchesQuery = t.title.toLowerCase().contains(_query) ||
          t.state.toLowerCase().contains(_query) ||
          t.overview.toLowerCase().contains(_query) ||
          t.tripStyle.toLowerCase().contains(_query) ||
          t.highlights.any((h) => h.toLowerCase().contains(_query));
      return matchesQuery;
    }).toList();

    final showConcerts = _selectedCategory == 'All' ||
        _selectedCategory == 'Live Shows' ||
        _selectedCategory == 'Standup Comedy' ||
        _selectedCategory == 'Musical Nights';
    final showRestaurants = _selectedCategory == 'All' || _selectedCategory == 'Dine-In';
    final showTravel = _selectedCategory == 'All' || _selectedCategory == 'Travel Tours' || _selectedCategory == 'Travel';

    final displayedConcerts = _selectedCategory == 'Standup Comedy'
        ? filteredConcerts.where((c) => c.eventType == 'Standup Comedy' || c.genre.toLowerCase().contains('standup') || c.genre.toLowerCase().contains('comedy')).toList()
        : _selectedCategory == 'Musical Nights'
            ? filteredConcerts.where((c) => c.eventType == 'Musical Night' || c.genre.toLowerCase().contains('acoustic') || c.genre.toLowerCase().contains('sufi')).toList()
            : filteredConcerts;

    final totalResults = (showConcerts ? displayedConcerts.length : 0) +
        (showRestaurants ? filteredRestaurants.length : 0) +
        (showTravel ? filteredTravel.length : 0);

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: Text(
          'Search & Discover',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary(context),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => LocationSearchModal.show(context),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border(context)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppColors.accent),
                  const SizedBox(width: 4),
                  Text(
                    selectedCity,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
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
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Search Bar Input
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface(context),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black38 : const Color(0x0A000000),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _query = val.trim().toLowerCase();
                    });
                  },
                  autofocus: false,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary(context),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search concerts, dining, Northeast tours, artists...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppTheme.textMuted(context),
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.cancel, color: AppTheme.textMuted(context), size: 20),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppTheme.border(context)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppTheme.border(context)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    filled: true,
                    fillColor: AppTheme.surface(context),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            // 2. Category Filter Pills
            SizedBox(
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CategoryChip(
                      label: cat,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // 3. Search Body: Results or Trending / Discovery mode
            Expanded(
              child: _query.isEmpty
                  ? _buildDiscoveryView(context, selectedCity)
                  : _buildResultsView(
                      context,
                      showConcerts: showConcerts,
                      showRestaurants: showRestaurants,
                      showTravel: showTravel,
                      concerts: displayedConcerts,
                      restaurants: filteredRestaurants,
                      travel: filteredTravel,
                      totalResults: totalResults,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- DISCOVERY VIEW (when search query is empty) ---
  Widget _buildDiscoveryView(BuildContext context, String city) {
    final isDark = AppTheme.isDark(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trending / Popular Searches
          Row(
            children: [
              const Icon(Icons.trending_up, size: 18, color: AppColors.accent),
              const SizedBox(width: 6),
              Text(
                'Trending Searches',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _trendingKeywords.map((item) {
              return ActionChip(
                onPressed: () => _onSearchKeywordTapped(item['label'] as String),
                avatar: Icon(
                  item['icon'] as IconData,
                  size: 15,
                  color: AppColors.primary,
                ),
                label: Text(
                  item['label'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                backgroundColor: AppTheme.surface(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: AppTheme.border(context)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Explore Categories Cards
          Text(
            'Explore by Category',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: 12),

          _buildCategoryBannerCard(
            context,
            title: 'Live Shows, Comedy & Music',
            subtitle: 'Standup specials, acoustic nights, festivals & theatre',
            icon: Icons.theater_comedy_rounded,
            badge: '${MockData.concerts.length} Shows',
            color: const Color(0xFF6366F1),
            bgGradient: isDark
                ? const LinearGradient(
                    colors: [Color(0xFF1E1B4B), Color(0xFF2A206A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConcertListScreen()),
              );
            },
          ),
          const SizedBox(height: 10),

          _buildCategoryBannerCard(
            context,
            title: 'Dine-In & Rooftop Lounges',
            subtitle: 'Exclusive tables, craft bars & Michelin chefs',
            icon: Icons.restaurant_rounded,
            badge: '${MockData.restaurants.length} Spots',
            color: const Color(0xFFF97316),
            bgGradient: isDark
                ? const LinearGradient(
                    colors: [Color(0xFF431407), Color(0xFF4A1F0D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DineInListScreen()),
              );
            },
          ),
          const SizedBox(height: 10),

          _buildCategoryBannerCard(
            context,
            title: 'Northeast Expeditions',
            subtitle: 'Meghalaya, Kaziranga, Tawang & Nagaland packages',
            icon: Icons.landscape_rounded,
            badge: '${MockData.travelPackages.length} Packages',
            color: const Color(0xFF10B981),
            bgGradient: isDark
                ? const LinearGradient(
                    colors: [Color(0xFF064E3B), Color(0xFF0A5844)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TravelListScreen()),
              );
            },
          ),

          const SizedBox(height: 24),

          // Top Pick in City
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Picks in $city',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary(context),
                ),
              ),
              Text(
                'Curated',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal list of top concerts
          SizedBox(
            height: 245,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: MockData.concerts.length,
              itemBuilder: (context, i) {
                final concert = MockData.concerts[i];
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
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildCategoryBannerCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String badge,
    required Color color,
    required LinearGradient bgGradient,
    required VoidCallback onTap,
  }) {
    final isDark = AppTheme.isDark(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: bgGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surface(context) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 24),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.surface(context) : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppTheme.textSecondary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  // --- RESULTS VIEW (when search query is present) ---
  Widget _buildResultsView(
    BuildContext context, {
    required bool showConcerts,
    required bool showRestaurants,
    required bool showTravel,
    required List<ConcertModel> concerts,
    required List<RestaurantModel> restaurants,
    required List<TravelPackageModel> travel,
    required int totalResults,
  }) {
    if (totalResults == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.search_off_rounded, size: 48, color: AppTheme.textMuted(context)),
              ),
              const SizedBox(height: 16),
              Text(
                'No results found for "$_query"',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary(context),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Try searching for another keyword or switch category filters',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppTheme.textSecondary(context),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _clearSearch,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Clear Search'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        // Results Count Header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Found $totalResults result${totalResults == 1 ? '' : 's'}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary(context),
            ),
          ),
        ),

        // 1. Concerts Section
        if (showConcerts && concerts.isNotEmpty) ...[
          _buildSectionHeader(context, 'Live Concerts (${concerts.length})', Icons.music_note),
          const SizedBox(height: 8),
          ...concerts.map((concert) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: ConcertCard(
                  concert: concert,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConcertDetailScreen(concert: concert),
                      ),
                    );
                  },
                ),
              )),
          const SizedBox(height: 12),
        ],

        // 2. Restaurants Section
        if (showRestaurants && restaurants.isNotEmpty) ...[
          _buildSectionHeader(context, 'Dine-In & Lounges (${restaurants.length})', Icons.restaurant),
          const SizedBox(height: 8),
          ...restaurants.map((restaurant) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: RestaurantCard(
                  restaurant: restaurant,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestaurantDetailScreen(restaurant: restaurant),
                      ),
                    );
                  },
                ),
              )),
          const SizedBox(height: 12),
        ],

        // 3. Travel Packages Section
        if (showTravel && travel.isNotEmpty) ...[
          _buildSectionHeader(context, 'Northeast Travel Expeditions (${travel.length})', Icons.landscape),
          const SizedBox(height: 8),
          ...travel.map((pkg) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: TravelPackageCard(
                  package: pkg,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TravelPackageDetailScreen(package: pkg),
                      ),
                    );
                  },
                ),
              )),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary(context),
          ),
        ),
      ],
    );
  }
}
