import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:district_app/providers/auth_provider.dart';
import 'package:district_app/providers/booking_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('District Providers Test', () {
    test('AuthProvider sign in demo user works correctly', () async {
      final auth = AuthProvider();
      await auth.signInDemo();

      expect(auth.isAuthenticated, true);
      expect(auth.user?.name, 'Aryan Sharma');
      expect(auth.user?.email, 'aryan.sharma@tribe.live');

      await auth.signOut();
      expect(auth.isAuthenticated, false);
      expect(auth.user, isNull);
    });

    test('BookingProvider handles city filtering and active bookings', () async {
      final bookingProvider = BookingProvider();

      expect(bookingProvider.selectedCity, 'Guwahati / Dispur');
      final guwahatiConcerts = bookingProvider.getFilteredConcerts();
      expect(guwahatiConcerts, isNotEmpty);

      // Change city to Shillong
      bookingProvider.setSelectedCity('Shillong');
      expect(bookingProvider.selectedCity, 'Shillong');
      final shillongConcerts = bookingProvider.getFilteredConcerts();
      expect(shillongConcerts.any((c) => c.artist.contains('Soulmate')), true);

      // Toggle favorite
      expect(bookingProvider.isFavorite('c1'), false);
      bookingProvider.toggleFavorite('c1');
      expect(bookingProvider.isFavorite('c1'), true);
      bookingProvider.toggleFavorite('c1');
      expect(bookingProvider.isFavorite('c1'), false);
    });
  });
}
