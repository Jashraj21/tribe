import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/restaurant_card.dart';
import 'restaurant_detail_screen.dart';

class DineInListScreen extends StatefulWidget {
  const DineInListScreen({super.key});

  @override
  State<DineInListScreen> createState() => _DineInListScreenState();
}

class _DineInListScreenState extends State<DineInListScreen> {
  String _selectedFilter = 'All';
  final _searchController = TextEditingController();

  final List<String> _filters = [
    'All',
    'Rooftop Skydeck',
    'Speakeasy Bar',
    'Live Jazz Stage',
    'In-house Brewery',
    'White Courtyard',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final allRestaurants = bookingProvider.getFilteredRestaurants();

    final filtered = _selectedFilter == 'All'
        ? allRestaurants
        : allRestaurants.where((r) => r.features.contains(_selectedFilter)).toList();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: Text(
          'Dine-In & Lounges',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary(context),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => bookingProvider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search rooftop, cocktail bar, cuisine...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          bookingProvider.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Filters
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filters.length,
              itemBuilder: (context, i) {
                final filter = _filters[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryChip(
                    label: filter,
                    isSelected: _selectedFilter == filter,
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Restaurants List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant_menu, size: 52, color: AppTheme.textMuted(context)),
                        const SizedBox(height: 14),
                        Text(
                          'No restaurants found',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try changing city or search term',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppTheme.textMuted(context),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final restaurant = filtered[i];
                      return RestaurantCard(
                        restaurant: restaurant,
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
        ],
      ),
    );
  }
}
