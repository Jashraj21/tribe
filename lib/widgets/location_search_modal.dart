import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../data/northeast_locations.dart';
import '../models/concert_model.dart';
import '../models/restaurant_model.dart';
import '../models/travel_package_model.dart';
import '../providers/booking_provider.dart';
import '../theme/app_theme.dart';
import '../screens/concerts/concert_detail_screen.dart';
import '../screens/dine_in/restaurant_detail_screen.dart';
import '../screens/travel/travel_package_detail_screen.dart';

class LocationSearchModal extends StatefulWidget {
  const LocationSearchModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LocationSearchModal(),
    );
  }

  @override
  State<LocationSearchModal> createState() => _LocationSearchModalState();
}

class _LocationSearchModalState extends State<LocationSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStateFilter = 'All';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _getConcertsCountFor(String locationName, String stateName) {
    return MockData.concerts.where((c) {
      final loc = locationName.toLowerCase();
      final st = stateName.toLowerCase();
      return c.city.toLowerCase().contains(loc) ||
          c.venue.toLowerCase().contains(loc) ||
          c.description.toLowerCase().contains(loc) ||
          c.city.toLowerCase().contains(st);
    }).length;
  }

  int _getRestaurantsCountFor(String locationName, String stateName) {
    return MockData.restaurants.where((r) {
      final loc = locationName.toLowerCase();
      final st = stateName.toLowerCase();
      return r.city.toLowerCase().contains(loc) ||
          r.venue.toLowerCase().contains(loc) ||
          r.address.toLowerCase().contains(loc) ||
          r.city.toLowerCase().contains(st);
    }).length;
  }

  int _getTravelCountFor(String locationName, String stateName) {
    return MockData.travelPackages.where((t) {
      final loc = locationName.toLowerCase();
      final st = stateName.toLowerCase();
      return t.state.toLowerCase().contains(st) ||
          t.title.toLowerCase().contains(loc) ||
          t.overview.toLowerCase().contains(loc) ||
          t.pickupCity.toLowerCase().contains(loc);
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final isDark = AppTheme.isDark(context);
    final query = _searchQuery.trim().toLowerCase();

    // Filter districts
    final filteredDistricts = NortheastLocationData.allDistricts.where((d) {
      final matchesState = _selectedStateFilter == 'All' ||
          d.state.toLowerCase() == _selectedStateFilter.toLowerCase();

      if (query.isEmpty) return matchesState;

      final matchesQuery = d.name.toLowerCase().contains(query) ||
          d.districtName.toLowerCase().contains(query) ||
          d.state.toLowerCase().contains(query) ||
          d.tagline.toLowerCase().contains(query);

      return matchesState && matchesQuery;
    }).toList();

    // Match experiences if query entered
    List<ConcertModel> matchingConcerts = [];
    List<RestaurantModel> matchingRestaurants = [];
    List<TravelPackageModel> matchingTravel = [];

    if (query.isNotEmpty) {
      matchingConcerts = MockData.concerts.where((c) {
        return c.title.toLowerCase().contains(query) ||
            c.artist.toLowerCase().contains(query) ||
            c.city.toLowerCase().contains(query) ||
            c.venue.toLowerCase().contains(query) ||
            c.genre.toLowerCase().contains(query) ||
            c.eventType.toLowerCase().contains(query);
      }).toList();

      matchingRestaurants = MockData.restaurants.where((r) {
        return r.name.toLowerCase().contains(query) ||
            r.city.toLowerCase().contains(query) ||
            r.venue.toLowerCase().contains(query) ||
            r.cuisine.toLowerCase().contains(query);
      }).toList();

      matchingTravel = MockData.travelPackages.where((t) {
        return t.title.toLowerCase().contains(query) ||
            t.state.toLowerCase().contains(query) ||
            t.tripStyle.toLowerCase().contains(query) ||
            t.pickupCity.toLowerCase().contains(query);
      }).toList();
    }

    final hasExperienceMatches = query.isNotEmpty &&
        (matchingConcerts.isNotEmpty ||
            matchingRestaurants.isNotEmpty ||
            matchingTravel.isNotEmpty);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.explore_rounded, color: AppColors.primary, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Northeast Locations',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '8 State Capitals & All Districts of Northeast India',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: AppTheme.textMuted(context)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border(context)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppTheme.textPrimary(context),
                ),
                decoration: InputDecoration(
                  hintText: 'Search capital, district, concert, dine-in, trek...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppTheme.textMuted(context),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, size: 18, color: AppTheme.textMuted(context)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),

          // State Filter Horizontal Chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildStateChip('All', 'All 8 States'),
                ...NortheastLocationData.states.map((st) => _buildStateChip(st, st)),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Main Scrollable Area
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                // If experiences found matching search query, display them first
                if (hasExperienceMatches) ...[
                  Text(
                    'Experiences Matching "$_searchQuery"',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Matching Concerts
                  if (matchingConcerts.isNotEmpty) ...[
                    ...matchingConcerts.map((c) {
                      final isComedy = c.eventType.toLowerCase().contains('standup') || c.genre.toLowerCase().contains('comedy');
                      final isMagic = c.eventType.toLowerCase().contains('magic') || c.genre.toLowerCase().contains('mentalism');
                      final isTheatre = c.eventType.toLowerCase().contains('theatre') || c.genre.toLowerCase().contains('poetry');
                      final isMusic = c.eventType.toLowerCase().contains('musical');

                      final icon = isComedy
                          ? Icons.mic_rounded
                          : isMagic
                              ? Icons.auto_awesome_rounded
                              : isTheatre
                                  ? Icons.theater_comedy_rounded
                                  : Icons.music_note_rounded;

                      final color = isComedy
                          ? const Color(0xFFF59E0B)
                          : isMagic
                              ? const Color(0xFF8B5CF6)
                              : isTheatre
                                  ? const Color(0xFFEC4899)
                                  : isMusic
                                      ? const Color(0xFF10B981)
                                      : AppColors.primary;

                      return _buildExperienceTile(
                        context,
                        title: c.title,
                        subtitle: '${c.artist} • ${c.venue}, ${c.city}',
                        tag: c.eventType.toUpperCase(),
                        tagColor: color,
                        price: 'Starts ₹${c.startingPrice.toInt()}',
                        icon: icon,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConcertDetailScreen(concert: c),
                            ),
                          );
                        },
                      );
                    }),
                    const SizedBox(height: 10),
                  ],

                  // Matching Restaurants
                  if (matchingRestaurants.isNotEmpty) ...[
                    ...matchingRestaurants.map((r) => _buildExperienceTile(
                          context,
                          title: r.name,
                          subtitle: '${r.cuisine} • ${r.venue}, ${r.city}',
                          tag: 'DINE-IN',
                          tagColor: AppColors.gold,
                          price: '₹${r.costForTwo.toInt()} for two',
                          icon: Icons.restaurant_rounded,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RestaurantDetailScreen(restaurant: r),
                              ),
                            );
                          },
                        )),
                    const SizedBox(height: 10),
                  ],

                  // Matching Travel Packages
                  if (matchingTravel.isNotEmpty) ...[
                    ...matchingTravel.map((t) => _buildExperienceTile(
                          context,
                          title: t.title,
                          subtitle: '${t.duration} • ${t.state} (${t.tripStyle})',
                          tag: 'EXPEDITION',
                          tagColor: AppColors.emerald,
                          price: '₹${t.pricePerPerson.toInt()}/person',
                          icon: Icons.terrain_rounded,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TravelPackageDetailScreen(package: t),
                              ),
                            );
                          },
                        )),
                    const SizedBox(height: 16),
                  ],
                ],

                // 8 State Capitals Section (when no search query or when state matches)
                if (query.isEmpty && _selectedStateFilter == 'All') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '8 State Capitals',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '8 States',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Capitals Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.1,
                    ),
                    itemCount: NortheastLocationData.stateCapitals.length,
                    itemBuilder: (context, index) {
                      final cap = NortheastLocationData.stateCapitals[index];
                      final isSelected = bookingProvider.selectedCity.toLowerCase() == cap.name.toLowerCase();

                      return GestureDetector(
                        onTap: () {
                          bookingProvider.setSelectedCity(cap.name);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.12)
                                : AppTheme.surfaceElevated(context),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppTheme.border(context),
                              width: isSelected ? 1.8 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark ? const Color(0xFF1E293B) : Colors.white),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  cap.icon,
                                  size: 16,
                                  color: isSelected ? Colors.white : AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      cap.name,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppTheme.textPrimary(context),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      cap.state,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textSecondary(context),
                                      ),
                                      maxLines: 1,
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
                  const SizedBox(height: 20),
                ],

                // All Districts Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedStateFilter == 'All'
                          ? (query.isEmpty ? 'All Districts & Hubs' : 'Districts Found (${filteredDistricts.length})')
                          : '$_selectedStateFilter Districts (${filteredDistricts.length})',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    Text(
                      'Tap to Switch Region',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppTheme.textMuted(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (filteredDistricts.isEmpty && !hasExperienceMatches)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.location_off_rounded, size: 40, color: AppTheme.textMuted(context)),
                          const SizedBox(height: 10),
                          Text(
                            'No locations found for "$_searchQuery"',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: AppTheme.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...filteredDistricts.map((district) {
                    final isSelected = bookingProvider.selectedCity.toLowerCase() == district.name.toLowerCase();
                    final concertsCount = _getConcertsCountFor(district.name, district.state);
                    final restCount = _getRestaurantsCountFor(district.name, district.state);
                    final travelCount = _getTravelCountFor(district.name, district.state);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.12)
                            : AppTheme.surfaceElevated(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppTheme.border(context),
                          width: isSelected ? 1.6 : 1,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          bookingProvider.setSelectedCity(district.name);
                          Navigator.pop(context);
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppTheme.surface(context),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            district.icon,
                            color: isSelected ? Colors.white : AppColors.primary,
                            size: 20,
                          ),
                        ),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                district.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? AppColors.primary : AppTheme.textPrimary(context),
                                ),
                              ),
                            ),
                            if (district.isCapital) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'CAPITAL',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(
                              '${district.districtName}, ${district.state}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textSecondary(context),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              district.tagline,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppTheme.textMuted(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            // Micro Badges
                            Wrap(
                              spacing: 6,
                              children: [
                                if (concertsCount > 0)
                                  _buildMicroBadge(context, '$concertsCount Concerts', Icons.music_note, AppColors.primary),
                                if (restCount > 0)
                                  _buildMicroBadge(context, '$restCount Dine-In', Icons.restaurant, AppColors.gold),
                                if (travelCount > 0)
                                  _buildMicroBadge(context, '$travelCount Expeditions', Icons.terrain, AppColors.emerald),
                              ],
                            ),
                          ],
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: AppColors.primary, size: 22)
                            : Icon(Icons.chevron_right, color: AppTheme.textMuted(context), size: 20),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateChip(String stateKey, String label) {
    final isSelected = _selectedStateFilter == stateKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStateFilter = stateKey;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppTheme.surfaceElevated(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppTheme.border(context),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textSecondary(context),
          ),
        ),
      ),
    );
  }

  Widget _buildMicroBadge(BuildContext context, String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String tag,
    required Color tagColor,
    required String price,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border(context)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tagColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: tagColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: tagColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
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
            const SizedBox(width: 8),
            Text(
              price,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
