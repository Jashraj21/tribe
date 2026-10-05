import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../auth/auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = auth.user;
    final isGuest = auth.isGuest || user == null;
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // User Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.border(context)),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black45 : const Color(0x0A000000),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.primary,
                        backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                        child: user?.avatarUrl == null
                            ? const Icon(Icons.person, size: 34, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user?.name ?? 'Tribe Guest',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary(context),
                                  ),
                                ),
                                if (!isGuest) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.verified, size: 16, color: AppColors.cyan),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              user?.email ?? 'guest@tribe.app',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppTheme.textSecondary(context),
                              ),
                            ),
                            if (!isGuest && user.phone.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                user.phone,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppTheme.textMuted(context),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Guest banner CTA
                  if (isGuest) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primaryLight.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 20, color: AppColors.gold),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Sign in to sync your tickets & reservations across devices',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppTheme.textSecondary(context),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AuthScreen()),
                              );
                            },
                            child: Text(
                              'Login',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Theme Selector Quick Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        themeProvider.themeModeIcon,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Appearance / Theme',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        themeProvider.themeModeName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Segmented choice buttons
                  Row(
                    children: [
                      _buildThemeOptionButton(
                        context,
                        label: 'Light',
                        icon: Icons.light_mode_rounded,
                        mode: ThemeMode.light,
                        currentMode: themeProvider.themeMode,
                        onSelect: () => themeProvider.setThemeMode(ThemeMode.light),
                      ),
                      const SizedBox(width: 8),
                      _buildThemeOptionButton(
                        context,
                        label: 'Dark',
                        icon: Icons.dark_mode_rounded,
                        mode: ThemeMode.dark,
                        currentMode: themeProvider.themeMode,
                        onSelect: () => themeProvider.setThemeMode(ThemeMode.dark),
                      ),
                      const SizedBox(width: 8),
                      _buildThemeOptionButton(
                        context,
                        label: 'System',
                        icon: Icons.settings_brightness_rounded,
                        mode: ThemeMode.system,
                        currentMode: themeProvider.themeMode,
                        onSelect: () => themeProvider.setThemeMode(ThemeMode.system),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tribe VIP Club Perks Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3B2A10) : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.workspace_premium, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tribe Explorer Club',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Early access to Northeast tours, concerts & dining perks',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Settings & Preferences List
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border(context)),
              ),
              child: Column(
                children: [
                  _settingTile(
                    context,
                    Icons.credit_card,
                    AppColors.cyan,
                    'Saved Payment Methods',
                    'Manage saved cards, UPI IDs & wallets',
                    () => _showPaymentMethodsDialog(context),
                  ),
                  Divider(height: 1, color: AppTheme.border(context)),
                  _settingTile(
                    context,
                    Icons.palette_outlined,
                    AppColors.primary,
                    'Theme Settings',
                    'Choose Light, Dark, or System mode',
                    () => _showThemeBottomSheet(context, themeProvider),
                  ),
                  Divider(height: 1, color: AppTheme.border(context)),
                  _settingTile(
                    context,
                    Icons.notifications_outlined,
                    AppColors.accent,
                    'Concert & Event Alerts',
                    'Tour announcements & fast filling alerts',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Push notifications are enabled for artist drops!'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, color: AppTheme.border(context)),
                  _settingTile(
                    context,
                    Icons.support_agent,
                    AppColors.emerald,
                    '24/7 Tribe Concierge',
                    'Live support for bookings, tours and tickets',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tribe support connected: How can we help today?'),
                          backgroundColor: AppColors.emerald,
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, color: AppTheme.border(context)),
                  _settingTile(
                    context,
                    Icons.help_outline,
                    AppColors.gold,
                    'Cancellation & Entry Policy',
                    'FAQs regarding event entry & refunds',
                    () => _showPolicyDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Auth Action Button
            if (isGuest)
              AppButton(
                text: 'Sign In / Register',
                icon: Icons.login,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                  );
                },
              )
            else
              AppButton(
                text: 'Log Out',
                icon: Icons.logout,
                isSecondary: true,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppTheme.surface(context),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: Text(
                        'Log Out',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      content: Text(
                        'Are you sure you want to log out of your Tribe account?',
                        style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary(context)),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            auth.signOut();
                          },
                          child: const Text('Log Out', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 20),

            Text(
              'Tribe v1.0.0 (Build 42) • Northeast Travel & Experiences',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppTheme.textMuted(context),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOptionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required VoidCallback onSelect,
  }) {
    final isSelected = mode == currentMode;
    final isDark = AppTheme.isDark(context);

    return Expanded(
      child: GestureDetector(
        onTap: onSelect,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppTheme.border(context),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingTile(
    BuildContext context,
    IconData icon,
    Color color,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary(context),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: AppTheme.textMuted(context),
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted(context)),
      ),
    );
  }

  void _showThemeBottomSheet(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Choose Theme',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Select your preferred appearance for Tribe',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildThemeChoiceTile(
                      context,
                      title: 'System Default',
                      subtitle: 'Matches your device display settings',
                      icon: Icons.settings_brightness_rounded,
                      mode: ThemeMode.system,
                      isSelected: themeProvider.themeMode == ThemeMode.system,
                      onTap: () {
                        themeProvider.setThemeMode(ThemeMode.system);
                        setModalState(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildThemeChoiceTile(
                      context,
                      title: 'Light Mode',
                      subtitle: 'Crisp, high-contrast bright theme',
                      icon: Icons.light_mode_rounded,
                      mode: ThemeMode.light,
                      isSelected: themeProvider.themeMode == ThemeMode.light,
                      onTap: () {
                        themeProvider.setThemeMode(ThemeMode.light);
                        setModalState(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildThemeChoiceTile(
                      context,
                      title: 'Dark Mode',
                      subtitle: 'Sleek dark slate theme, easier on the eyes',
                      icon: Icons.dark_mode_rounded,
                      mode: ThemeMode.dark,
                      isSelected: themeProvider.themeMode == ThemeMode.dark,
                      onTap: () {
                        themeProvider.setThemeMode(ThemeMode.dark);
                        setModalState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeChoiceTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppTheme.surface(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.primary
                          : AppTheme.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 22)
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.border(context), width: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Saved Payment Methods',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary(context),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.credit_card, color: AppColors.cyan),
              title: Text('HDFC Regalia Visa (•••• 6789)', style: TextStyle(color: AppTheme.textPrimary(context))),
              subtitle: Text('Expires 12/28', style: TextStyle(color: AppTheme.textSecondary(context))),
            ),
            ListTile(
              leading: const Icon(Icons.phone_android, color: AppColors.emerald),
              title: Text('Google Pay UPI', style: TextStyle(color: AppTheme.textPrimary(context))),
              subtitle: Text('aryan@okaxis', style: TextStyle(color: AppTheme.textSecondary(context))),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Entry & Booking Rules',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary(context),
          ),
        ),
        content: Text(
          '• Digital QR passes must be presented at the venue gates for entry.\n'
          '• Concert tickets are non-refundable once transaction is completed.\n'
          '• Dine-in table reservations are held for 15 minutes past booked time slot.\n'
          '• Pre-ordered food charges are adjusted against final restaurant bill.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            height: 1.6,
            color: AppTheme.textSecondary(context),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got It')),
        ],
      ),
    );
  }
}
