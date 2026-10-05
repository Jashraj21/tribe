import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/mock_data.dart';
import '../models/booking_model.dart';
import '../models/concert_model.dart';
import '../models/restaurant_model.dart';
import '../models/travel_package_model.dart';

class BookingProvider extends ChangeNotifier {
  static const String _bookingsStorageKey = 'district_saved_bookings';
  static const String _favoritesKey = 'district_saved_favorites';
  static const String _cityKey = 'district_selected_city';

  List<BookingModel> _bookings = [];
  final Set<String> _favoriteIds = {};
  String _selectedCity = 'Guwahati / Dispur';
  String _searchQuery = '';
  String _activeCategory = 'All'; // All, Concerts, Dine-In, Travel, Nightlife

  List<BookingModel> get bookings => List.unmodifiable(_bookings);
  List<BookingModel> get activeBookings =>
      _bookings.where((b) => b.status == 'CONFIRMED').toList();
  List<BookingModel> get pastBookings =>
      _bookings.where((b) => b.status != 'CONFIRMED').toList();

  Set<String> get favoriteIds => _favoriteIds;
  String get selectedCity => _selectedCity;
  String get searchQuery => _searchQuery;
  String get activeCategory => _activeCategory;

  BookingProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load city
    final savedCity = prefs.getString(_cityKey);
    if (savedCity != null && savedCity.isNotEmpty) {
      _selectedCity = savedCity;
    } else {
      _selectedCity = 'Guwahati / Dispur';
    }

    // Load favorites
    final favList = prefs.getStringList(_favoritesKey);
    if (favList != null) {
      _favoriteIds.addAll(favList);
    }

    // Load bookings
    final bookingsJson = prefs.getString(_bookingsStorageKey);
    if (bookingsJson != null) {
      try {
        final List<dynamic> list = jsonDecode(bookingsJson);
        _bookings = list.map((e) => BookingModel.fromJson(e)).toList();
      } catch (e) {
        _loadDefaultSampleBooking();
      }
    } else {
      _loadDefaultSampleBooking();
    }

    notifyListeners();
  }

  void _loadDefaultSampleBooking() {
    // Provide initial active sample passes so user can view QR passes immediately
    final dineIn = MockData.restaurants.first;
    final dineInBooking = BookingModel(
      id: 'bk_sample_dinein',
      bookingReference: 'TRB-1827-5161',
      type: BookingType.dineIn,
      itemId: dineIn.id,
      title: dineIn.name,
      subtitle: '2 Guests • 01:00 PM (Today)',
      venue: dineIn.venue,
      city: dineIn.city,
      dateTime: DateTime.now(),
      imageUrl: dineIn.bannerUrl,
      totalAmount: 1180.0,
      baseAmount: 1000.0,
      taxAmount: 30.0,
      discountAmount: 0.0,
      convenienceFee: 150.0,
      status: 'CONFIRMED',
      qrCodeData: 'TRIBE_PASS::TRB-1827-5161::TXN_TRB_855229::₹1180',
      paymentMethod: 'UPI (Google Pay)',
      transactionId: 'TXN_TRB_855229_689221',
      dineInDetail: BookingDineInDetail(
        partySize: 2,
        seatingArea: 'Rooftop Skydeck',
        timeSlot: '01:00 PM',
        date: DateTime.now(),
      ),
    );

    final travel = MockData.travelPackages.first;
    final travelBooking = BookingModel(
      id: 'bk_sample_meghalaya',
      bookingReference: 'TRB-8831-2041',
      type: BookingType.travel,
      itemId: travel.id,
      title: travel.title,
      subtitle: '${travel.durationDays}D/${travel.durationNights}N • ${travel.state} • 2 Travelers',
      venue: travel.pickupLocation,
      city: travel.state,
      dateTime: DateTime.now().add(const Duration(days: 20)),
      imageUrl: travel.imageUrl,
      totalAmount: 39860.0,
      baseAmount: 37998.0,
      taxAmount: 171.0,
      discountAmount: 1000.0,
      convenienceFee: 950.0,
      status: 'CONFIRMED',
      qrCodeData: 'TRIBE_PASS::TRB-8831-2041::TXN_TRB_9921_TRAVEL::₹39860',
      paymentMethod: 'UPI (PhonePe)',
      transactionId: 'TXN_TRB_552194_EXP',
      travelDetail: BookingTravelDetail(
        packageId: travel.id,
        packageName: travel.title,
        state: travel.state,
        duration: '${travel.durationDays}D / ${travel.durationNights}N',
        pickupLocation: travel.pickupLocation,
        batchDate: 'Oct 25, 2026 - Oct 30, 2026',
        travelersCount: 2,
        pricePerPerson: travel.pricePerPerson,
      ),
    );

    final concert = MockData.concerts.first;
    final concertBooking = BookingModel(
      id: 'bk_sample_ziro',
      bookingReference: 'TRB-7821-4920',
      type: BookingType.concert,
      itemId: concert.id,
      title: concert.title,
      subtitle: '${concert.artist} • 2 Tickets',
      venue: concert.venue,
      city: concert.city,
      dateTime: concert.date,
      imageUrl: concert.thumbnailUrl,
      totalAmount: 7334.0,
      baseAmount: 6998.0,
      taxAmount: 31.5,
      discountAmount: 0.0,
      convenienceFee: 175.0,
      status: 'CONFIRMED',
      qrCodeData: 'TRIBE_PASS::TRB-7821-4920::TXN_MOCK_INIT::₹7334',
      paymentMethod: 'UPI (Google Pay)',
      transactionId: 'TXN_TRB_491823_VIP',
      concertTickets: [
        BookingTicketItem(
          tierName: '4-Day Festival Pass',
          count: 2,
          unitPrice: 3499.0,
        ),
      ],
    );

    _bookings = [dineInBooking, travelBooking, concertBooking];
  }

  Future<void> _persistBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _bookings.map((b) => b.toJson()).toList();
    await prefs.setString(_bookingsStorageKey, jsonEncode(jsonList));
  }

  Future<void> _persistFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, _favoriteIds.toList());
  }

  void setSelectedCity(String city) async {
    _selectedCity = city;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cityKey, city);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setActiveCategory(String category) {
    _activeCategory = category;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
    _persistFavorites();
  }

  bool isFavorite(String id) => _favoriteIds.contains(id);

  Future<void> addBooking(BookingModel booking) async {
    _bookings.insert(0, booking);
    notifyListeners();
    await _persistBookings();
  }

  // Filtered Concerts
  List<ConcertModel> getFilteredConcerts() {
    final selected = _selectedCity.toLowerCase();
    return MockData.concerts.where((concert) {
      final matchesCity = selected == 'all' ||
          concert.city.toLowerCase().contains(selected) ||
          selected.contains(concert.city.toLowerCase()) ||
          concert.venue.toLowerCase().contains(selected);

      final matchesSearch = _searchQuery.isEmpty ||
          concert.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          concert.artist.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          concert.genre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          concert.venue.toLowerCase().contains(_searchQuery.toLowerCase());

      return (matchesCity || _selectedCity == 'All Northeast') && matchesSearch;
    }).toList();
  }

  // Filtered Restaurants
  List<RestaurantModel> getFilteredRestaurants() {
    final selected = _selectedCity.toLowerCase();
    return MockData.restaurants.where((rest) {
      final matchesCity = selected == 'all' ||
          rest.city.toLowerCase().contains(selected) ||
          selected.contains(rest.city.toLowerCase()) ||
          rest.venue.toLowerCase().contains(selected) ||
          rest.address.toLowerCase().contains(selected);

      final matchesSearch = _searchQuery.isEmpty ||
          rest.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          rest.cuisine.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          rest.venue.toLowerCase().contains(_searchQuery.toLowerCase());

      return (matchesCity || _selectedCity == 'All Northeast') && matchesSearch;
    }).toList();
  }

  // Filtered Travel Packages
  List<TravelPackageModel> getFilteredTravelPackages() {
    final selected = _selectedCity.toLowerCase();
    return MockData.travelPackages.where((pkg) {
      final matchesLocation = selected == 'all' ||
          pkg.state.toLowerCase().contains(selected) ||
          selected.contains(pkg.state.toLowerCase()) ||
          pkg.pickupCity.toLowerCase().contains(selected) ||
          pkg.title.toLowerCase().contains(selected);

      final matchesSearch = _searchQuery.isEmpty ||
          pkg.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pkg.state.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pkg.tripStyle.toLowerCase().contains(_searchQuery.toLowerCase());

      return (matchesLocation || _selectedCity == 'All Northeast') && matchesSearch;
    }).toList();
  }
}
