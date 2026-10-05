import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../models/restaurant_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../checkout/checkout_screen.dart';

class TableReservationScreen extends StatefulWidget {
  final RestaurantModel restaurant;

  const TableReservationScreen({super.key, required this.restaurant});

  @override
  State<TableReservationScreen> createState() => _TableReservationScreenState();
}

class _TableReservationScreenState extends State<TableReservationScreen> {
  late DateTime _selectedDate;
  int _partySize = 2;
  late String _selectedSeating;
  late String _selectedTimeSlot;

  // Pre-order menu item counters (itemId -> quantity)
  final Map<String, int> _menuOrderCounts = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedSeating = widget.restaurant.seatingAreas.isNotEmpty
        ? widget.restaurant.seatingAreas.first
        : 'Main Dining Hall';
    _selectedTimeSlot = widget.restaurant.timeSlots.isNotEmpty
        ? widget.restaurant.timeSlots.first.time
        : '08:00 PM';
  }

  double get _menuTotal {
    double total = 0.0;
    for (final item in widget.restaurant.menuSpecials) {
      final qty = _menuOrderCounts[item.id] ?? 0;
      total += qty * item.price;
    }
    return total;
  }

  double get _totalBaseAmount {
    return widget.restaurant.tableCoverCharge + _menuTotal;
  }

  void _proceedToCheckout() {
    final dineInDetail = BookingDineInDetail(
      partySize: _partySize,
      seatingArea: _selectedSeating,
      timeSlot: _selectedTimeSlot,
      date: _selectedDate,
      preOrderedMenuCounts: Map.from(_menuOrderCounts)..removeWhere((k, v) => v == 0),
    );

    final dateFormatted = DateFormat('EEE, MMM d').format(_selectedDate);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          bookingType: BookingType.dineIn,
          itemId: widget.restaurant.id,
          title: widget.restaurant.name,
          subtitle: '$_partySize Guests • $_selectedTimeSlot ($dateFormatted)',
          venue: widget.restaurant.venue,
          city: widget.restaurant.city,
          dateTime: _selectedDate,
          imageUrl: widget.restaurant.bannerUrl,
          baseAmount: _totalBaseAmount,
          dineInDetail: dineInDetail,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: Text(
          'Reserve Table',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary(context),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant Mini Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor(context),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.border(context)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.restaurant.bannerUrl,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 52,
                            height: 52,
                            color: AppTheme.surfaceElevated(context),
                            child: const Icon(Icons.restaurant, color: AppColors.gold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.restaurant.name,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                            Text(
                              '${widget.restaurant.cuisine} • ${widget.restaurant.city}',
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

                const SizedBox(height: 24),

                // 1. SELECT DATE
                Text(
                  '1. Select Date',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(4, (index) {
                    final date = DateTime.now().add(Duration(days: index));
                    final isSelected = DateFormat('yyyyMMdd').format(_selectedDate) ==
                        DateFormat('yyyyMMdd').format(date);
                    final label = index == 0
                        ? 'Today'
                        : index == 1
                            ? 'Tomorrow'
                            : DateFormat('E, d MMM').format(date);

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppTheme.cardColor(context),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryLight : AppTheme.border(context),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                DateFormat('MMM').format(date).toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white70 : AppTheme.textMuted(context),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${date.day}',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? Colors.white : AppTheme.textPrimary(context),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppTheme.textSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // 2. PARTY SIZE GUESTS
                Text(
                  '2. Number of Guests',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 8,
                    itemBuilder: (context, i) {
                      final count = i + 1;
                      final isSelected = _partySize == count;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _partySize = count;
                          });
                        },
                        child: Container(
                          width: 48,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppTheme.cardColor(context),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryLight : AppTheme.border(context),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$count',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? Colors.white : AppTheme.textPrimary(context),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // 3. SEATING PREFERENCE
                Text(
                  '3. Seating Area',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: widget.restaurant.seatingAreas.map((area) {
                    final isSelected = _selectedSeating == area;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSeating = area;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withOpacity(0.12) : AppTheme.cardColor(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppTheme.border(context),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              size: 16,
                              color: isSelected ? AppColors.primary : AppTheme.textMuted(context),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              area,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? AppColors.primary : AppTheme.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // 4. TIME SLOT
                Text(
                  '4. Select Time Slot',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: widget.restaurant.timeSlots.map((slot) {
                    final isSelected = _selectedTimeSlot == slot.time;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTimeSlot = slot.time;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppTheme.cardColor(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryLight : AppTheme.border(context),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              slot.time,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : AppTheme.textPrimary(context),
                              ),
                            ),
                            if (slot.discountTag != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                slot.discountTag!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? AppColors.gold : AppColors.emerald,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),

                // 5. OPTIONAL PRE-ORDER MENU
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pre-Order Chef Specials',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated(context),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'OPTIONAL',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textMuted(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Pre-order to ensure your food is prepared fresh right when you sit',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppTheme.textMuted(context),
                  ),
                ),
                const SizedBox(height: 14),

                ...widget.restaurant.menuSpecials.map((dish) {
                  final qty = _menuOrderCounts[dish.id] ?? 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: qty > 0 ? AppColors.emerald : AppTheme.border(context),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: dish.isVeg ? Colors.green : Colors.red,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: CircleAvatar(
                            radius: 3,
                            backgroundColor: dish.isVeg ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dish.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary(context),
                                ),
                              ),
                              Text(
                                '₹${dish.price.toInt()}',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Item Counter
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated(context),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.border(context)),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.remove,
                                  size: 16,
                                  color: qty > 0 ? AppTheme.textPrimary(context) : AppTheme.textMuted(context),
                                ),
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                padding: EdgeInsets.zero,
                                onPressed: qty > 0
                                    ? () {
                                        setState(() {
                                          _menuOrderCounts[dish.id] = qty - 1;
                                        });
                                      }
                                    : null,
                              ),
                              Text(
                                '$qty',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: qty > 0 ? AppTheme.textPrimary(context) : AppTheme.textMuted(context),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add, size: 16, color: AppTheme.textPrimary(context)),
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  setState(() {
                                    _menuOrderCounts[dish.id] = qty + 1;
                                  });
                                },
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

          // Bottom Fixed Bar
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
                    blurRadius: 10,
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
                          'Cover + Pre-Order',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppTheme.textMuted(context),
                          ),
                        ),
                        Text(
                          '₹${NumberFormat('#,##,###').format(_totalBaseAmount.toInt())}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: AppButton(
                        text: 'Confirm Booking',
                        icon: Icons.check_circle_outline,
                        onPressed: _proceedToCheckout,
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
}
