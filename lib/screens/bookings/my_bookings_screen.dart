import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/qr_ticket_modal.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final activeBookings = bookingProvider.activeBookings;
    final pastBookings = bookingProvider.pastBookings;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: Text(
          'My Passes & Bookings',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary(context),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            height: 46,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border(context)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(7),
              ),
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textSecondary(context),
              labelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              tabs: [
                Tab(
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    child: Text('Active Passes (${activeBookings.length})'),
                  ),
                ),
                Tab(
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    child: Text('Past Events (${pastBookings.length})'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active Passes Tab
          activeBookings.isEmpty
              ? _buildEmptyState(
                  icon: Icons.confirmation_number_outlined,
                  title: 'No Active Passes Yet',
                  subtitle: 'Explore live concerts, reserve rooftop dine-ins, or book Northeast travel expeditions',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: activeBookings.length,
                  itemBuilder: (context, i) {
                    final booking = activeBookings[i];
                    return _buildPassCard(booking);
                  },
                ),

          // Past Events Tab
          pastBookings.isEmpty
              ? _buildEmptyState(
                  icon: Icons.history,
                  title: 'No Past History',
                  subtitle: 'Completed bookings, past tours, and concert events will appear here',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: pastBookings.length,
                  itemBuilder: (context, i) {
                    final booking = pastBookings[i];
                    return _buildPassCard(booking, isPast: true);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildPassCard(BookingModel booking, {bool isPast = false}) {
    final dateFormatted = DateFormat('EEE, MMM d, yyyy').format(booking.dateTime);
    final isConcert = booking.type == BookingType.concert;
    final isTravel = booking.type == BookingType.travel;
    final isDark = AppTheme.isDark(context);

    return GestureDetector(
      onTap: () => QrTicketModal.show(context, booking),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border(context)),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black45 : Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      booking.imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 70,
                        height: 70,
                        color: AppTheme.surfaceElevated(context),
                        child: Icon(
                          isTravel
                              ? Icons.landscape
                              : isConcert
                                  ? Icons.music_note
                                  : Icons.restaurant,
                          color: isTravel
                              ? const Color(0xFF0284C7)
                              : isConcert
                                  ? AppColors.primary
                                  : AppColors.gold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isTravel
                                    ? const Color(0xFF0284C7)
                                    : isConcert
                                        ? AppColors.primary
                                        : AppColors.emerald,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isTravel
                                    ? 'NORTHEAST TRAVEL'
                                    : isConcert
                                        ? 'CONCERT'
                                        : 'DINE-IN',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceElevated(context),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '#${booking.bookingReference}',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          booking.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                        Text(
                          booking.subtitle,
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
                ],
              ),
            ),

            // Perforated divider
            Row(
              children: [
                Container(
                  width: 10,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppTheme.bg(context),
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final count = (constraints.constrainWidth() / 10).floor();
                      return Flex(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        direction: Axis.horizontal,
                        children: List.generate(
                          count,
                          (_) => SizedBox(
                            width: 5,
                            height: 1,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.borderHighlightDark : AppColors.borderHighlight,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  width: 10,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppTheme.bg(context),
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                  ),
                ),
              ],
            ),

            // Bottom Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: AppTheme.textMuted(context)),
                          const SizedBox(width: 4),
                          Text(
                            dateFormatted,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: AppColors.accent),
                          const SizedBox(width: 4),
                          Text(
                            '${booking.venue}, ${booking.city}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppTheme.textMuted(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Show Pass',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated(context),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.border(context)),
              ),
              child: Icon(icon, size: 48, color: AppTheme.textMuted(context)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
