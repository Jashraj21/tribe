class TravelItineraryDay {
  final int dayNumber;
  final String title;
  final String description;
  final List<String> highlights;
  final String mealsIncluded;
  final String stay;

  TravelItineraryDay({
    required this.dayNumber,
    required this.title,
    required this.description,
    required this.highlights,
    required this.mealsIncluded,
    required this.stay,
  });

  Map<String, dynamic> toJson() => {
    'dayNumber': dayNumber,
    'title': title,
    'description': description,
    'highlights': highlights,
    'mealsIncluded': mealsIncluded,
    'stay': stay,
  };

  factory TravelItineraryDay.fromJson(Map<String, dynamic> json) => TravelItineraryDay(
    dayNumber: json['dayNumber'] as int,
    title: json['title'] as String,
    description: json['description'] as String,
    highlights: List<String>.from(json['highlights'] as List),
    mealsIncluded: json['mealsIncluded'] as String,
    stay: json['stay'] as String,
  );
}

class TravelBatchModel {
  final String id;
  final DateTime departureDate;
  final DateTime endDate;
  final int availableSlots;
  final String status; // "Available", "Filling Fast", "Few Seats Left"

  TravelBatchModel({
    required this.id,
    required this.departureDate,
    required this.endDate,
    required this.availableSlots,
    this.status = 'Available',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'departureDate': departureDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'availableSlots': availableSlots,
    'status': status,
  };

  factory TravelBatchModel.fromJson(Map<String, dynamic> json) => TravelBatchModel(
    id: json['id'] as String,
    departureDate: DateTime.parse(json['departureDate'] as String),
    endDate: DateTime.parse(json['endDate'] as String),
    availableSlots: json['availableSlots'] as int,
    status: json['status'] as String? ?? 'Available',
  );

  DateTime get startDate => departureDate;
}

class TravelPackageModel {
  final String id;
  final String title;
  final String tagline;
  final String state; // Meghalaya, Assam, Arunachal Pradesh, Nagaland, Sikkim
  final String pickupCity; // Guwahati Airport (GHY), Bagdogra (IXB), etc.
  final String duration; // e.g. "6 Days / 5 Nights"
  final double pricePerPerson;
  final double originalPricePerPerson;
  final double rating;
  final int reviewsCount;
  final String bannerUrl;
  final List<String> images;
  final String overview;
  final String tripStyle; // Nature & Adventure, Wildlife Safari, High Altitude, Cultural Trek
  final String difficulty; // Easy to Moderate, Moderate Trek, High Altitude
  final String groupSize; // Small Group (Max 12), Private / Family
  final List<String> inclusions;
  final List<String> exclusions;
  final List<String> highlights;
  final List<TravelItineraryDay> itinerary;
  final List<TravelBatchModel> batches;
  final bool isFeatured;
  final bool isFastFilling;
  final String offerTag;

  TravelPackageModel({
    required this.id,
    required this.title,
    required this.tagline,
    required this.state,
    required this.pickupCity,
    required this.duration,
    required this.pricePerPerson,
    required this.originalPricePerPerson,
    required this.rating,
    required this.reviewsCount,
    required this.bannerUrl,
    required this.images,
    required this.overview,
    required this.tripStyle,
    this.difficulty = 'Easy to Moderate',
    this.groupSize = 'Small Group (Max 12)',
    required this.inclusions,
    required this.exclusions,
    required this.highlights,
    required this.itinerary,
    required this.batches,
    this.isFeatured = false,
    this.isFastFilling = false,
    this.offerTag = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'tagline': tagline,
    'state': state,
    'pickupCity': pickupCity,
    'duration': duration,
    'pricePerPerson': pricePerPerson,
    'originalPricePerPerson': originalPricePerPerson,
    'rating': rating,
    'reviewsCount': reviewsCount,
    'bannerUrl': bannerUrl,
    'images': images,
    'overview': overview,
    'tripStyle': tripStyle,
    'difficulty': difficulty,
    'groupSize': groupSize,
    'inclusions': inclusions,
    'exclusions': exclusions,
    'highlights': highlights,
    'itinerary': itinerary.map((i) => i.toJson()).toList(),
    'batches': batches.map((b) => b.toJson()).toList(),
    'isFeatured': isFeatured,
    'isFastFilling': isFastFilling,
    'offerTag': offerTag,
  };

  factory TravelPackageModel.fromJson(Map<String, dynamic> json) => TravelPackageModel(
    id: json['id'] as String,
    title: json['title'] as String,
    tagline: json['tagline'] as String,
    state: json['state'] as String,
    pickupCity: json['pickupCity'] as String,
    duration: json['duration'] as String,
    pricePerPerson: (json['pricePerPerson'] as num).toDouble(),
    originalPricePerPerson: (json['originalPricePerPerson'] as num).toDouble(),
    rating: (json['rating'] as num).toDouble(),
    reviewsCount: json['reviewsCount'] as int,
    bannerUrl: json['bannerUrl'] as String,
    images: List<String>.from(json['images'] as List),
    overview: json['overview'] as String,
    tripStyle: json['tripStyle'] as String,
    difficulty: json['difficulty'] as String? ?? 'Easy to Moderate',
    groupSize: json['groupSize'] as String? ?? 'Small Group (Max 12)',
    inclusions: List<String>.from(json['inclusions'] as List),
    exclusions: List<String>.from(json['exclusions'] as List),
    highlights: List<String>.from(json['highlights'] as List),
    itinerary: (json['itinerary'] as List)
        .map((i) => TravelItineraryDay.fromJson(i as Map<String, dynamic>))
        .toList(),
    batches: (json['batches'] as List)
        .map((b) => TravelBatchModel.fromJson(b as Map<String, dynamic>))
        .toList(),
    isFeatured: json['isFeatured'] as bool? ?? false,
    isFastFilling: json['isFastFilling'] as bool? ?? false,
    offerTag: json['offerTag'] as String? ?? '',
  );

  String get imageUrl => bannerUrl;
  String get pickupLocation => pickupCity;

  int get durationDays {
    final match = RegExp(r'(\d+)\s*D').firstMatch(duration);
    return match != null ? int.parse(match.group(1)!) : 5;
  }

  int get durationNights {
    final match = RegExp(r'(\d+)\s*N').firstMatch(duration);
    return match != null ? int.parse(match.group(1)!) : 4;
  }
}
