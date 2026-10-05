import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/mock_data.dart';
import '../../models/travel_package_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/travel_package_card.dart';

class TravelListScreen extends StatefulWidget {
  const TravelListScreen({super.key});

  @override
  State<TravelListScreen> createState() => _TravelListScreenState();
}

class _TravelListScreenState extends State<TravelListScreen> {
  String _selectedState = 'All Northeast';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  List<TravelPackageModel> get _filteredPackages {
    return MockData.travelPackages.where((p) {
      final matchesState = _selectedState == 'All Northeast' || p.state == _selectedState;
      final matchesSearch = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.state.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.overview.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.tripStyle.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesState && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packages = _filteredPackages;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: Text(
          'Northeast Travel Packages',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary(context),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter header
          Container(
            color: AppTheme.surface(context),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.border(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 20, color: AppTheme.textMuted(context)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(color: AppTheme.textPrimary(context)),
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val.trim();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search Meghalaya, Kaziranga, Tawang...',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppTheme.textMuted(context),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          child: Icon(Icons.clear, size: 18, color: AppTheme.textMuted(context)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // State Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: MockData.travelStates.map((state) {
                      final isSelected = _selectedState == state;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(state),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedState = state;
                            });
                          },
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppTheme.textSecondary(context),
                          ),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppTheme.cardColor(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppTheme.border(context),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Packages List
          Expanded(
            child: packages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.terrain_outlined, size: 54, color: AppTheme.textMuted(context)),
                        const SizedBox(height: 12),
                        Text(
                          'No travel packages found',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try clearing filters or search for another state',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppTheme.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: packages.length,
                    itemBuilder: (context, index) {
                      return TravelPackageCard(package: packages[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
