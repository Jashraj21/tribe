import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/concert_model.dart';
import '../../providers/booking_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/concert_card.dart';
import 'concert_detail_screen.dart';

class ConcertListScreen extends StatefulWidget {
  const ConcertListScreen({super.key});

  @override
  State<ConcertListScreen> createState() => _ConcertListScreenState();
}

class _ConcertListScreenState extends State<ConcertListScreen> {
  String _selectedCategory = 'All Shows';
  final _searchController = TextEditingController();

  bool _showSearch = false;

  final List<String> _categories = [
    'All Shows',
    'Standup Comedy',
    'Musical Nights',
    'Rock & Festivals',
    'Theatre & Misc',
    'Classical & Folk',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesCategory(ConcertModel c, String category) {
    if (category == 'All Shows' || category == 'All') return true;
    final g = c.genre.toLowerCase();
    final e = c.eventType.toLowerCase();
    final t = c.title.toLowerCase();

    if (category == 'Standup Comedy') {
      return e.contains('standup') || g.contains('standup') || g.contains('comedy') || g.contains('improv') || t.contains('comedy') || t.contains('standup');
    }
    if (category == 'Musical Nights') {
      return e.contains('musical') || g.contains('acoustic') || g.contains('sufi') || g.contains('choral') || g.contains('gospel') || g.contains('fusion') || t.contains('acoustic') || t.contains('sufi');
    }
    if (category == 'Rock & Festivals') {
      return e.contains('rock') || e.contains('festival') || g.contains('rock') || g.contains('metal') || g.contains('edm') || g.contains('bass') || g.contains('tribal');
    }
    if (category == 'Theatre & Misc') {
      return e.contains('theatre') || e.contains('misc') || g.contains('magic') || g.contains('mentalism') || g.contains('theatre') || g.contains('drama') || g.contains('poetry') || g.contains('open mic') || g.contains('spoken word');
    }
    if (category == 'Classical & Folk') {
      return g.contains('classical') || g.contains('folk') || g.contains('sattriya') || g.contains('instrumental') || g.contains('bihu');
    }
    return e.contains(category.toLowerCase()) || g.contains(category.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final allConcerts = bookingProvider.getFilteredConcerts();

    final filteredByGenre = allConcerts.where((c) => _matchesCategory(c, _selectedCategory)).toList();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.textPrimary(context),
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Search standup, music, shows...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: AppTheme.textMuted(context),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (val) => bookingProvider.setSearchQuery(val),
              )
            : Text(
                'Live Shows & Events',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary(context),
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close : Icons.search,
              color: AppTheme.textPrimary(context),
            ),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  bookingProvider.setSearchQuery('');
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),

          // Category Chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              itemBuilder: (context, i) {
                final category = _categories[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryChip(
                    label: category,
                    isSelected: _selectedCategory == category,
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // List of concerts
          Expanded(
            child: filteredByGenre.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.theater_comedy, size: 52, color: AppTheme.textMuted(context)),
                        const SizedBox(height: 14),
                        Text(
                          'No live shows found',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try switching categories or searching a different term',
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
                    itemCount: filteredByGenre.length,
                    itemBuilder: (context, i) {
                      final concert = filteredByGenre[i];
                      return ConcertCard(
                        concert: concert,
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
        ],
      ),
    );
  }
}
