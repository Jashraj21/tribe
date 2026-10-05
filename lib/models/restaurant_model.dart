class TimeSlotModel {
  final String id;
  final String time;
  final String period; // "Lunch", "Dinner", "Nightlife"
  final bool isAvailable;
  final String? discountTag;

  TimeSlotModel({
    required this.id,
    required this.time,
    required this.period,
    this.isAvailable = true,
    this.discountTag,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'time': time,
    'period': period,
    'isAvailable': isAvailable,
    'discountTag': discountTag,
  };

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) => TimeSlotModel(
    id: json['id'] as String,
    time: json['time'] as String,
    period: json['period'] as String,
    isAvailable: json['isAvailable'] as bool? ?? true,
    discountTag: json['discountTag'] as String?,
  );
}

class MenuItemModel {
  final String id;
  final String name;
  final String category; // Appetizer, Mains, Cocktails, Desserts
  final double price;
  final bool isVeg;
  final bool isChefSpecial;
  final String description;
  final String? imageUrl;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.isVeg = true,
    this.isChefSpecial = false,
    required this.description,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'price': price,
    'isVeg': isVeg,
    'isChefSpecial': isChefSpecial,
    'description': description,
    'imageUrl': imageUrl,
  };

  factory MenuItemModel.fromJson(Map<String, dynamic> json) => MenuItemModel(
    id: json['id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    price: (json['price'] as num).toDouble(),
    isVeg: json['isVeg'] as bool? ?? true,
    isChefSpecial: json['isChefSpecial'] as bool? ?? false,
    description: json['description'] as String,
    imageUrl: json['imageUrl'] as String?,
  );
}

class RestaurantModel {
  final String id;
  final String name;
  final String cuisine;
  final String tagline;
  final String bannerUrl;
  final List<String> images;
  final String venue;
  final String city;
  final String address;
  final double costForTwo;
  final double rating;
  final int reviewsCount;
  final bool isTrending;
  final bool isFeatured;
  final String offerTag;
  final double tableCoverCharge;
  final List<String> features; // Rooftop, Live DJ, Outdoor, Valet
  final String description;
  final String openingHours;
  final List<String> seatingAreas; // Rooftop Skydeck, Indoor Fine Dine, Patio
  final List<TimeSlotModel> timeSlots;
  final List<MenuItemModel> menuSpecials;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.tagline,
    required this.bannerUrl,
    required this.images,
    required this.venue,
    required this.city,
    required this.address,
    required this.costForTwo,
    required this.rating,
    required this.reviewsCount,
    this.isTrending = false,
    this.isFeatured = false,
    this.offerTag = '',
    this.tableCoverCharge = 500.0,
    required this.features,
    required this.description,
    required this.openingHours,
    required this.seatingAreas,
    required this.timeSlots,
    required this.menuSpecials,
  });
}
