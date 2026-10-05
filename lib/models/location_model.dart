import 'package:flutter/material.dart';

class NortheastDistrict {
  final String id;
  final String name; // e.g. "Guwahati / Dispur", "Shillong", "Tawang"
  final String districtName; // e.g. "Kamrup Metropolitan", "East Khasi Hills"
  final String state; // e.g. "Assam", "Meghalaya"
  final String stateCapital; // e.g. "Dispur", "Shillong"
  final bool isCapital;
  final String tagline;
  final IconData icon;
  final String heroImageUrl;

  const NortheastDistrict({
    required this.id,
    required this.name,
    required this.districtName,
    required this.state,
    required this.stateCapital,
    this.isCapital = false,
    required this.tagline,
    this.icon = Icons.location_on_rounded,
    this.heroImageUrl = '',
  });

  String get displayName => name;
  String get subTitle => isCapital ? '★ State Capital • $districtName' : '$districtName, $state';
}
