import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _userKey = 'district_user_session';
  static const Uuid _uuid = Uuid();

  // Load existing session from storage
  Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_userKey);
    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return UserModel.fromJson(map);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Save session
  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // Clear session
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700)); // realistic network latency

    if (email.trim().isEmpty || !email.contains('@')) {
      throw Exception('Please enter a valid email address');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    final user = UserModel(
      id: 'usr_${_uuid.v4().substring(0, 8)}',
      name: email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z]'), ' ').trim().toUpperCase(),
      email: email.trim().toLowerCase(),
      phone: '+91 98765 43210',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
      isGuest: false,
    );

    await _saveUser(user);
    return user;
  }

  // Sign up with full details
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (name.trim().isEmpty) {
      throw Exception('Please enter your full name');
    }
    if (email.trim().isEmpty || !email.contains('@')) {
      throw Exception('Please enter a valid email address');
    }
    if (phone.trim().length < 10) {
      throw Exception('Please enter a valid 10-digit phone number');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    final user = UserModel(
      id: 'usr_${_uuid.v4().substring(0, 8)}',
      name: name.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
      isGuest: false,
    );

    await _saveUser(user);
    return user;
  }

  // Quick Demo One-Tap Login (Pre-populated for instant testing)
  Future<UserModel> signInWithDemoUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final demoUser = UserModel(
      id: 'usr_tribe_vip',
      name: 'Aryan Sharma',
      email: 'aryan.sharma@tribe.live',
      phone: '+91 98200 12345',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      isGuest: false,
    );
    await _saveUser(demoUser);
    return demoUser;
  }

  // Continue as Guest
  Future<UserModel> signInAsGuest() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final guest = UserModel(
      id: 'guest_${_uuid.v4().substring(0, 6)}',
      name: 'Tribe Explorer',
      email: 'guest@tribe.app',
      phone: '',
      isGuest: true,
    );
    await _saveUser(guest);
    return guest;
  }

  // Social Login Simulation
  Future<UserModel> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final user = UserModel(
      id: 'usr_g_${_uuid.v4().substring(0, 8)}',
      name: 'Kabir Singhania',
      email: 'kabir.singhania@gmail.com',
      phone: '+91 99100 88221',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      isGuest: false,
    );
    await _saveUser(user);
    return user;
  }
}
