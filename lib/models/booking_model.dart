enum BookingType {
  concert,
  dineIn,
  travel,
}

class BookingTicketItem {
  final String tierName;
  final int count;
  final double unitPrice;

  BookingTicketItem({
    required this.tierName,
    required this.count,
    required this.unitPrice,
  });

  Map<String, dynamic> toJson() => {
    'tierName': tierName,
    'count': count,
    'unitPrice': unitPrice,
  };

  factory BookingTicketItem.fromJson(Map<String, dynamic> json) => BookingTicketItem(
    tierName: json['tierName'] as String,
    count: json['count'] as int,
    unitPrice: (json['unitPrice'] as num).toDouble(),
  );
}

class BookingDineInDetail {
  final int partySize;
  final String seatingArea;
  final String timeSlot;
  final DateTime date;
  final Map<String, int> preOrderedMenuCounts; // itemId -> count

  BookingDineInDetail({
    required this.partySize,
    required this.seatingArea,
    required this.timeSlot,
    required this.date,
    this.preOrderedMenuCounts = const {},
  });

  Map<String, dynamic> toJson() => {
    'partySize': partySize,
    'seatingArea': seatingArea,
    'timeSlot': timeSlot,
    'date': date.toIso8601String(),
    'preOrderedMenuCounts': preOrderedMenuCounts,
  };

  factory BookingDineInDetail.fromJson(Map<String, dynamic> json) => BookingDineInDetail(
    partySize: json['partySize'] as int,
    seatingArea: json['seatingArea'] as String,
    timeSlot: json['timeSlot'] as String,
    date: DateTime.parse(json['date'] as String),
    preOrderedMenuCounts: (json['preOrderedMenuCounts'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v as int),
        ) ??
        {},
  );
}

class BookingTravelDetail {
  final String packageId;
  final String packageName;
  final String state;
  final String duration;
  final String pickupLocation;
  final String batchDate;
  final int travelersCount;
  final double pricePerPerson;

  BookingTravelDetail({
    required this.packageId,
    required this.packageName,
    required this.state,
    required this.duration,
    required this.pickupLocation,
    required this.batchDate,
    required this.travelersCount,
    required this.pricePerPerson,
  });

  Map<String, dynamic> toJson() => {
    'packageId': packageId,
    'packageName': packageName,
    'state': state,
    'duration': duration,
    'pickupLocation': pickupLocation,
    'batchDate': batchDate,
    'travelersCount': travelersCount,
    'pricePerPerson': pricePerPerson,
  };

  factory BookingTravelDetail.fromJson(Map<String, dynamic> json) => BookingTravelDetail(
    packageId: json['packageId'] as String,
    packageName: json['packageName'] as String,
    state: json['state'] as String,
    duration: json['duration'] as String,
    pickupLocation: json['pickupLocation'] as String,
    batchDate: json['batchDate'] as String,
    travelersCount: json['travelersCount'] as int,
    pricePerPerson: (json['pricePerPerson'] as num).toDouble(),
  );
}

class BookingModel {
  final String id;
  final String bookingReference;
  final BookingType type;
  final String itemId; // concertId, restaurantId, or travelPackageId
  final String title;
  final String subtitle;
  final String venue;
  final String city;
  final DateTime dateTime;
  final String imageUrl;
  final double totalAmount;
  final double baseAmount;
  final double taxAmount;
  final double discountAmount;
  final double convenienceFee;
  final String status; // "CONFIRMED", "COMPLETED", "CANCELLED"
  final DateTime createdAt;
  final String qrCodeData;
  final String paymentMethod;
  final String transactionId;

  // Type specific details
  final List<BookingTicketItem>? concertTickets;
  final List<String>? concertAddOns;
  final BookingDineInDetail? dineInDetail;
  final BookingTravelDetail? travelDetail;

  BookingModel({
    required this.id,
    required this.bookingReference,
    required this.type,
    required this.itemId,
    required this.title,
    required this.subtitle,
    required this.venue,
    required this.city,
    required this.dateTime,
    required this.imageUrl,
    required this.totalAmount,
    required this.baseAmount,
    required this.taxAmount,
    required this.discountAmount,
    required this.convenienceFee,
    this.status = 'CONFIRMED',
    DateTime? createdAt,
    required this.qrCodeData,
    required this.paymentMethod,
    required this.transactionId,
    this.concertTickets,
    this.concertAddOns,
    this.dineInDetail,
    this.travelDetail,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookingReference': bookingReference,
    'type': type.name,
    'itemId': itemId,
    'title': title,
    'subtitle': subtitle,
    'venue': venue,
    'city': city,
    'dateTime': dateTime.toIso8601String(),
    'imageUrl': imageUrl,
    'totalAmount': totalAmount,
    'baseAmount': baseAmount,
    'taxAmount': taxAmount,
    'discountAmount': discountAmount,
    'convenienceFee': convenienceFee,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'qrCodeData': qrCodeData,
    'paymentMethod': paymentMethod,
    'transactionId': transactionId,
    'concertTickets': concertTickets?.map((e) => e.toJson()).toList(),
    'concertAddOns': concertAddOns,
    'dineInDetail': dineInDetail?.toJson(),
    'travelDetail': travelDetail?.toJson(),
  };

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    BookingType parsedType;
    final typeStr = json['type'] as String?;
    if (typeStr == 'concert') {
      parsedType = BookingType.concert;
    } else if (typeStr == 'travel') {
      parsedType = BookingType.travel;
    } else {
      parsedType = BookingType.dineIn;
    }

    return BookingModel(
      id: json['id'] as String,
      bookingReference: json['bookingReference'] as String,
      type: parsedType,
      itemId: json['itemId'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      venue: json['venue'] as String,
      city: json['city'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      imageUrl: json['imageUrl'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      baseAmount: (json['baseAmount'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      convenienceFee: (json['convenienceFee'] as num).toDouble(),
      status: json['status'] as String? ?? 'CONFIRMED',
      createdAt: DateTime.parse(json['createdAt'] as String),
      qrCodeData: json['qrCodeData'] as String,
      paymentMethod: json['paymentMethod'] as String,
      transactionId: json['transactionId'] as String,
      concertTickets: (json['concertTickets'] as List<dynamic>?)
          ?.map((e) => BookingTicketItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      concertAddOns: (json['concertAddOns'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      dineInDetail: json['dineInDetail'] != null
          ? BookingDineInDetail.fromJson(json['dineInDetail'] as Map<String, dynamic>)
          : null,
      travelDetail: json['travelDetail'] != null
          ? BookingTravelDetail.fromJson(json['travelDetail'] as Map<String, dynamic>)
          : null,
    );
  }
}
