import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../models/concert_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../checkout/checkout_screen.dart';

class TicketSelectionScreen extends StatefulWidget {
  final ConcertModel concert;

  const TicketSelectionScreen({super.key, required this.concert});

  @override
  State<TicketSelectionScreen> createState() => _TicketSelectionScreenState();
}

class _TicketSelectionScreenState extends State<TicketSelectionScreen> {
  // Tier ID -> Selected Count
  final Map<String, int> _selectedCounts = {};
  // Add-on ID -> isSelected
  final Map<String, bool> _selectedAddOns = {};

  @override
  void initState() {
    super.initState();
    // Default select 1 General or first tier
    if (widget.concert.ticketTiers.isNotEmpty) {
      _selectedCounts[widget.concert.ticketTiers.first.id] = 1;
    }
  }

  int get _totalTicketCount {
    return _selectedCounts.values.fold(0, (sum, count) => sum + count);
  }

  double get _subtotal {
    double total = 0.0;
    for (final tier in widget.concert.ticketTiers) {
      final count = _selectedCounts[tier.id] ?? 0;
      total += count * tier.price;
    }
    for (final addon in widget.concert.addOns) {
      if (_selectedAddOns[addon.id] == true) {
        total += addon.price;
      }
    }
    return total;
  }

  void _proceedToCheckout() {
    if (_totalTicketCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 1 ticket to continue'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final ticketItems = <BookingTicketItem>[];
    for (final tier in widget.concert.ticketTiers) {
      final count = _selectedCounts[tier.id] ?? 0;
      if (count > 0) {
        ticketItems.add(
          BookingTicketItem(
            tierName: tier.name,
            count: count,
            unitPrice: tier.price,
          ),
        );
      }
    }

    final chosenAddOns = <String>[];
    for (final addon in widget.concert.addOns) {
      if (_selectedAddOns[addon.id] == true) {
        chosenAddOns.add('${addon.name} (₹${addon.price.toInt()})');
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          bookingType: BookingType.concert,
          itemId: widget.concert.id,
          title: widget.concert.title,
          subtitle: '${widget.concert.artist} • $_totalTicketCount ${Intl.plural(_totalTicketCount, one: 'Ticket', other: 'Tickets')}',
          venue: widget.concert.venue,
          city: widget.concert.city,
          dateTime: widget.concert.date,
          imageUrl: widget.concert.thumbnailUrl,
          baseAmount: _subtotal,
          concertTickets: ticketItems,
          concertAddOns: chosenAddOns,
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
          'Select Tickets',
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
                // Header Mini Summary
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border(context)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.concert.thumbnailUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 50,
                            height: 50,
                            color: AppTheme.surfaceElevated(context),
                            child: const Icon(Icons.music_note, color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.concert.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                            Text(
                              '${widget.concert.artist} • ${widget.concert.venue}',
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

                const SizedBox(height: 24),

                Text(
                  'Choose Ticket Tier',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Maximum 8 tickets allowed per booking',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppTheme.textMuted(context),
                  ),
                ),

                const SizedBox(height: 16),

                // Ticket Tiers List
                ...widget.concert.ticketTiers.map((tier) {
                  final count = _selectedCounts[tier.id] ?? 0;
                  final isSelected = count > 0;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.surfaceElevated(context)
                          : AppTheme.cardColor(context),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppTheme.border(context),
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.15),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tier.name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary(context),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tier.description,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary(context),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '₹${NumberFormat('#,##,###').format(tier.price.toInt())}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected ? AppColors.primaryLight : AppTheme.textPrimary(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Quantity Selector
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.surface(context),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppTheme.border(context)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove,
                                      size: 18,
                                      color: count > 0 ? AppTheme.textPrimary(context) : AppTheme.textMuted(context),
                                    ),
                                    onPressed: count > 0
                                        ? () {
                                            setState(() {
                                              _selectedCounts[tier.id] = count - 1;
                                            });
                                          }
                                        : null,
                                  ),
                                  SizedBox(
                                    width: 24,
                                    child: Text(
                                      '$count',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textPrimary(context),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.add,
                                      size: 18,
                                      color: _totalTicketCount < 8 ? AppTheme.textPrimary(context) : AppTheme.textMuted(context),
                                    ),
                                    onPressed: _totalTicketCount < 8
                                        ? () {
                                            setState(() {
                                              _selectedCounts[tier.id] = count + 1;
                                            });
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Benefits tags
                        const SizedBox(height: 12),
                        Divider(height: 1, color: AppTheme.border(context)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: tier.benefits.map((b) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle, size: 13, color: AppColors.emerald),
                                const SizedBox(width: 4),
                                Text(
                                  b,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary(context),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // Add-Ons Section
                if (widget.concert.addOns.isNotEmpty) ...[
                  Text(
                    'Exclusive Tour Add-Ons',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enhance your concert night with merch and passes',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppTheme.textMuted(context),
                    ),
                  ),
                  const SizedBox(height: 14),

                  ...widget.concert.addOns.map((addon) {
                    final isChecked = _selectedAddOns[addon.id] ?? false;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isChecked ? AppColors.accent : AppTheme.border(context),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceElevated(context),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.redeem, color: AppColors.accentLight, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  addon.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary(context),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  addon.description,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppTheme.textMuted(context),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '+ ₹${addon.price.toInt()}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: isChecked,
                            activeColor: AppColors.accent,
                            onChanged: (val) {
                              setState(() {
                                _selectedAddOns[addon.id] = val ?? false;
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
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
                          '$_totalTicketCount ${Intl.plural(_totalTicketCount, one: 'Ticket', other: 'Tickets')}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppTheme.textMuted(context),
                          ),
                        ),
                        Text(
                          '₹${NumberFormat('#,##,###').format(_subtotal.toInt())}',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: AppButton(
                        text: 'Proceed to Pay',
                        icon: Icons.lock_outline,
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
