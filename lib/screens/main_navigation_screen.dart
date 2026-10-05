import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../theme/app_theme.dart';
import 'bookings/my_bookings_screen.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final activePassesCount = bookingProvider.activeBookings.length;
    final isDark = AppTheme.isDark(context);

    final screens = [
      HomeScreen(onTabChange: _onTabTapped),
      SearchScreen(onTabChange: _onTabTapped),
      const MyBookingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          border: Border(
            top: BorderSide(color: AppTheme.border(context), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black38 : const Color(0x0A000000),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
                _navItem(1, Icons.search_rounded, Icons.search_outlined, 'Search'),
                _navItem(
                  2,
                  Icons.confirmation_number_rounded,
                  Icons.confirmation_number_outlined,
                  'Passes',
                  badgeCount: activePassesCount,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label, {
    int badgeCount = 0,
  }) {
    final isSelected = _currentIndex == index;
    final isDark = AppTheme.isDark(context);
    final unselectedColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isSelected ? activeIcon : inactiveIcon,
                    size: 24,
                    color: isSelected ? AppColors.primary : unselectedColor,
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      top: -4,
                      right: -10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$badgeCount',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : unselectedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
