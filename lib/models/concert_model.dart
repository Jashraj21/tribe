import 'package:flutter/material.dart';

class TicketTierModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final int availableCount;
  final List<String> benefits;
  final Color? accentColor;

  TicketTierModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.availableCount,
    required this.benefits,
    this.accentColor,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'description': description,
    'availableCount': availableCount,
    'benefits': benefits,
  };

  factory TicketTierModel.fromJson(Map<String, dynamic> json) => TicketTierModel(
    id: json['id'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
    description: json['description'] as String,
    availableCount: json['availableCount'] as int? ?? 100,
    benefits: (json['benefits'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
  );
}

class AddOnItem {
  final String id;
  final String name;
  final double price;
  final String description;
  final String icon;

  AddOnItem({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'description': description,
    'icon': icon,
  };

  factory AddOnItem.fromJson(Map<String, dynamic> json) => AddOnItem(
    id: json['id'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
    description: json['description'] as String,
    icon: json['icon'] as String,
  );
}

class ConcertModel {
  final String id;
  final String title;
  final String artist;
  final String genre;
  final String tagline;
  final String bannerUrl;
  final String thumbnailUrl;
  final String venue;
  final String city;
  final DateTime date;
  final String time;
  final String duration;
  final String ageLimit;
  final String description;
  final List<String> highlights;
  final List<String> rules;
  final List<TicketTierModel> ticketTiers;
  final List<AddOnItem> addOns;
  final double startingPrice;
  final double rating;
  final int reviewsCount;
  final bool isSoldOut;
  final bool isFastFilling;
  final bool isFeatured;
  final String eventType; // e.g. 'Standup Comedy', 'Musical Night', 'Live Concert', 'Magic & Illusion', 'Theatre & Misc'

  ConcertModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.genre,
    required this.tagline,
    required this.bannerUrl,
    required this.thumbnailUrl,
    required this.venue,
    required this.city,
    required this.date,
    required this.time,
    required this.duration,
    required this.ageLimit,
    required this.description,
    required this.highlights,
    required this.rules,
    required this.ticketTiers,
    required this.addOns,
    required this.startingPrice,
    required this.rating,
    required this.reviewsCount,
    this.isSoldOut = false,
    this.isFastFilling = false,
    this.isFeatured = false,
    this.eventType = 'Live Concert',
  });
}
