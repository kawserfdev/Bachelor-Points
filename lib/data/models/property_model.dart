import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a property/rental listing in the tolet marketplace.
class PropertyModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final String ownerPhone;

  // Location
  final String division;
  final String district;
  final String upazila;
  final String union;
  final String area;
  final String road;
  final String? mapLat;
  final String? mapLng;

  // Pricing
  final double price;
  final double? minPrice;
  final double? maxPrice;

  // Type
  final String propertyType; // family, bachelor, hostel, mess, office, shop, land

  // Details
  final int bedrooms;
  final int bathrooms;
  final int floor;
  final double areaSqft;
  final String title;
  final String description;

  // Media
  final List<String> images;
  final List<String> videos;
  final bool has360View;

  // Status
  final String status; // draft, submitted, under_review, approved, live, rejected, expired, archived
  final String? reviewNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;

  // Contact unlock tracking
  final List<String> contactUnlockedBy;
  final List<String> addressUnlockedBy;

  // Boost
  final bool isBoosted;
  final DateTime? boostExpiresAt;

  PropertyModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.ownerPhone,
    required this.division,
    required this.district,
    required this.upazila,
    this.union = '',
    required this.area,
    this.road = '',
    this.mapLat,
    this.mapLng,
    required this.price,
    this.minPrice,
    this.maxPrice,
    required this.propertyType,
    this.bedrooms = 1,
    this.bathrooms = 1,
    this.floor = 1,
    this.areaSqft = 0,
    required this.title,
    this.description = '',
    this.images = const [],
    this.videos = const [],
    this.has360View = false,
    this.status = 'draft',
    this.reviewNotes,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
    this.contactUnlockedBy = const [],
    this.addressUnlockedBy = const [],
    this.isBoosted = false,
    this.boostExpiresAt,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      ownerName: json['owner_name'] as String? ?? '',
      ownerPhone: json['owner_phone'] as String? ?? '',
      division: json['division'] as String? ?? '',
      district: json['district'] as String? ?? '',
      upazila: json['upazila'] as String? ?? '',
      union: json['union'] as String? ?? '',
      area: json['area'] as String? ?? '',
      road: json['road'] as String? ?? '',
      mapLat: json['map_lat'] as String?,
      mapLng: json['map_lng'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      minPrice: (json['min_price'] as num?)?.toDouble(),
      maxPrice: (json['max_price'] as num?)?.toDouble(),
      propertyType: json['property_type'] as String? ?? 'bachelor',
      bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 1,
      bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 1,
      floor: (json['floor'] as num?)?.toInt() ?? 1,
      areaSqft: (json['area_sqft'] as num?)?.toDouble() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      videos: (json['videos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      has360View: json['has_360_view'] as bool? ?? false,
      status: json['status'] as String? ?? 'draft',
      reviewNotes: json['review_notes'] as String?,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      expiresAt: json['expires_at'] != null ? _parseDateTime(json['expires_at']) : null,
      contactUnlockedBy: (json['contact_unlocked_by'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      addressUnlockedBy: (json['address_unlocked_by'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isBoosted: json['is_boosted'] as bool? ?? false,
      boostExpiresAt: json['boost_expires_at'] != null ? _parseDateTime(json['boost_expires_at']) : null,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      if (value.isEmpty) return DateTime.now();
      return DateTime.parse(value);
    }
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'owner_id': ownerId,
      'owner_name': ownerName,
      'owner_phone': ownerPhone,
      'division': division,
      'district': district,
      'upazila': upazila,
      'union': union,
      'area': area,
      'road': road,
      'map_lat': mapLat,
      'map_lng': mapLng,
      'price': price,
      'min_price': minPrice,
      'max_price': maxPrice,
      'property_type': propertyType,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'floor': floor,
      'area_sqft': areaSqft,
      'title': title,
      'description': description,
      'images': images,
      'videos': videos,
      'has_360_view': has360View,
      'status': status,
      'review_notes': reviewNotes,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'expires_at': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'contact_unlocked_by': contactUnlockedBy,
      'address_unlocked_by': addressUnlockedBy,
      'is_boosted': isBoosted,
      'boost_expires_at': boostExpiresAt != null ? Timestamp.fromDate(boostExpiresAt!) : null,
    };
  }

  PropertyModel copyWith({
    String? id,
    String? ownerId,
    String? ownerName,
    String? ownerPhone,
    String? division,
    String? district,
    String? upazila,
    String? union,
    String? area,
    String? road,
    String? mapLat,
    String? mapLng,
    double? price,
    double? minPrice,
    double? maxPrice,
    String? propertyType,
    int? bedrooms,
    int? bathrooms,
    int? floor,
    double? areaSqft,
    String? title,
    String? description,
    List<String>? images,
    List<String>? videos,
    bool? has360View,
    String? status,
    String? reviewNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
    List<String>? contactUnlockedBy,
    List<String>? addressUnlockedBy,
    bool? isBoosted,
    DateTime? boostExpiresAt,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      division: division ?? this.division,
      district: district ?? this.district,
      upazila: upazila ?? this.upazila,
      union: union ?? this.union,
      area: area ?? this.area,
      road: road ?? this.road,
      mapLat: mapLat ?? this.mapLat,
      mapLng: mapLng ?? this.mapLng,
      price: price ?? this.price,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      propertyType: propertyType ?? this.propertyType,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      floor: floor ?? this.floor,
      areaSqft: areaSqft ?? this.areaSqft,
      title: title ?? this.title,
      description: description ?? this.description,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      has360View: has360View ?? this.has360View,
      status: status ?? this.status,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      contactUnlockedBy: contactUnlockedBy ?? this.contactUnlockedBy,
      addressUnlockedBy: addressUnlockedBy ?? this.addressUnlockedBy,
      isBoosted: isBoosted ?? this.isBoosted,
      boostExpiresAt: boostExpiresAt ?? this.boostExpiresAt,
    );
  }
}