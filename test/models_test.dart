import 'package:flutter_test/flutter_test.dart';
import 'package:district_app/data/mock_data.dart';
import 'package:district_app/models/booking_model.dart';
import 'package:district_app/models/user_model.dart';

void main() {
  group('District Models & Mock Data', () {
    test('Mock concerts are valid and populated', () {
      expect(MockData.concerts, isNotEmpty);
      final first = MockData.concerts.first;
      expect(first.artist, contains('Lucky Ali'));
      expect(first.title, contains('Ziro Festival'));
      expect(first.ticketTiers, isNotEmpty);
      expect(first.addOns, isNotEmpty);
      expect(first.startingPrice, greaterThan(0));
    });

    test('Mock restaurants are valid and populated', () {
      expect(MockData.restaurants, isNotEmpty);
      final first = MockData.restaurants.first;
      expect(first.name, contains('Terra Maya'));
      expect(first.seatingAreas, isNotEmpty);
      expect(first.timeSlots, isNotEmpty);
      expect(first.menuSpecials, isNotEmpty);
    });

    test('BookingModel serialization works roundtrip', () {
      final booking = BookingModel(
        id: 'bk_test_1',
        bookingReference: 'TRB-1234-5678',
        type: BookingType.concert,
        itemId: 'c1',
        title: 'Ziro Festival Live',
        subtitle: '2 Tickets',
        venue: 'Ziro Valley Arena',
        city: 'Itanagar',
        dateTime: DateTime(2026, 10, 20),
        imageUrl: 'https://example.com/image.jpg',
        totalAmount: 7000.0,
        baseAmount: 6800.0,
        taxAmount: 36.0,
        discountAmount: 0.0,
        convenienceFee: 164.0,
        status: 'CONFIRMED',
        qrCodeData: 'TRIBE_PASS::TEST',
        paymentMethod: 'UPI',
        transactionId: 'TXN_TEST',
      );

      final json = booking.toJson();
      final restored = BookingModel.fromJson(json);

      expect(restored.id, booking.id);
      expect(restored.bookingReference, booking.bookingReference);
      expect(restored.totalAmount, booking.totalAmount);
      expect(restored.type, BookingType.concert);
    });

    test('UserModel serialization works roundtrip', () {
      final user = UserModel(
        id: 'u1',
        name: 'Aryan Sharma',
        email: 'aryan@tribe.live',
        phone: '+91 98765 43210',
        avatarUrl: 'https://example.com/avatar.jpg',
        isGuest: false,
      );

      final json = user.toJson();
      final restored = UserModel.fromJson(json);

      expect(restored.id, user.id);
      expect(restored.name, user.name);
      expect(restored.email, user.email);
      expect(restored.isGuest, false);
    });
  });
}
