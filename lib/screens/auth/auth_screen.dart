import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback? onAuthSuccess;

  const AuthScreen({super.key, this.onAuthSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers
  final _loginEmailController = TextEditingController(text: 'aryan@tribe.live');
  final _loginPasswordController = TextEditingController(text: 'secret123');

  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regPasswordController = TextEditingController();

  final _loginFormKey = GlobalKey<FormState>();
  final _regFormKey = GlobalKey<FormState>();

  bool _obscureLoginPassword = true;
  bool _obscureRegPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPhoneController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(
      email: _loginEmailController.text.trim(),
      password: _loginPasswordController.text,
    );
    if (success && mounted) {
      if (widget.onAuthSuccess != null) {
        widget.onAuthSuccess!();
      } else {
        Navigator.pop(context);
      }
    } else if (mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleRegister() async {
    if (!_regFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(
      name: _regNameController.text.trim(),
      email: _regEmailController.text.trim(),
      phone: _regPhoneController.text.trim(),
      password: _regPasswordController.text,
    );
    if (success && mounted) {
      if (widget.onAuthSuccess != null) {
        widget.onAuthSuccess!();
      } else {
        Navigator.pop(context);
      }
    } else if (mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleDemoLogin() async {
    final auth = context.read<AuthProvider>();
    await auth.signInDemo();
    if (mounted) {
      if (widget.onAuthSuccess != null) {
        widget.onAuthSuccess!();
      } else {
        Navigator.pop(context);
      }
    }
  }

  void _handleGuest() async {
    final auth = context.read<AuthProvider>();
    await auth.continueAsGuest();
    if (mounted) {
      if (widget.onAuthSuccess != null) {
        widget.onAuthSuccess!();
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo & Brand Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.confirmation_number, size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TRIBE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Concerts, Dine-Ins & Northeast Tours',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Simple Quick Demo Login Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.isDark(context) ? AppColors.primary.withOpacity(0.12) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.isDark(context) ? AppColors.primary.withOpacity(0.3) : const Color(0xFFBFDBFE),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt, color: AppColors.primary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Demo Login',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary(context),
                            ),
                          ),
                          Text(
                            'Tap to login instantly as a test user',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppTheme.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: auth.isLoading ? null : _handleDemoLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Demo Login', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tab Switcher (Sign In vs Register)
              Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor(context),
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
                  tabs: const [
                    Tab(text: 'Sign In'),
                    Tab(text: 'Create Account'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tab Views
              SizedBox(
                height: 400,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // --- SIGN IN FORM ---
                    Form(
                      key: _loginFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _loginEmailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: AppTheme.textPrimary(context)),
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (val) {
                              if (val == null || !val.contains('@')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _loginPasswordController,
                            obscureText: _obscureLoginPassword,
                            style: TextStyle(color: AppTheme.textPrimary(context)),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureLoginPassword ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureLoginPassword = !_obscureLoginPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Password reset link sent to registered email!'),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            text: 'Sign In',
                            isLoading: auth.isLoading,
                            onPressed: _handleLogin,
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton(
                              onPressed: _handleGuest,
                              child: Text(
                                'Continue as Guest →',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- REGISTER FORM ---
                    Form(
                      key: _regFormKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _regNameController,
                              style: TextStyle(color: AppTheme.textPrimary(context)),
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (val) =>
                                  (val == null || val.trim().isEmpty) ? 'Enter your name' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _regEmailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(color: AppTheme.textPrimary(context)),
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (val) =>
                                  (val == null || !val.contains('@')) ? 'Enter a valid email' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _regPhoneController,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(color: AppTheme.textPrimary(context)),
                              decoration: const InputDecoration(
                                labelText: 'Phone Number (10 digits)',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                              validator: (val) =>
                                  (val == null || val.trim().length < 10) ? 'Enter 10 digit number' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _regPasswordController,
                              obscureText: _obscureRegPassword,
                              style: TextStyle(color: AppTheme.textPrimary(context)),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureRegPassword ? Icons.visibility_off : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureRegPassword = !_obscureRegPassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (val) =>
                                  (val == null || val.length < 6) ? 'Min 6 characters' : null,
                            ),
                            const SizedBox(height: 16),
                            AppButton(
                              text: 'Create Account',
                              isLoading: auth.isLoading,
                              onPressed: _handleRegister,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Social Buttons
              Row(
                children: [
                  Expanded(child: Divider(color: AppTheme.border(context))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'OR',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textMuted(context),
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppTheme.border(context))),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => auth.signInWithGoogle(),
                      icon: Icon(Icons.g_mobiledata, size: 24, color: AppTheme.textPrimary(context)),
                      label: Text(
                        'Google',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => auth.signInWithGoogle(),
                      icon: Icon(Icons.apple, size: 20, color: AppTheme.textPrimary(context)),
                      label: Text(
                        'Apple',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
