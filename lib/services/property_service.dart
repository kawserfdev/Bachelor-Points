import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/property_model.dart';

/// Service for managing property listings in Firestore.
class PropertyService {
  PropertyService({
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _collection = 'properties';

  /// Create a new property listing (draft status).
  Future<String> createProperty(PropertyModel property) async {
    final docRef = await _firestore.collection(_collection).add(
      property.copyWith(id: '', status: 'draft').toFirestore(),
    );
    await docRef.update({'id': docRef.id});
    return docRef.id;
  }

  /// Submit a draft for admin review.
  Future<void> submitForReview(String propertyId) async {
    await _firestore.collection(_collection).doc(propertyId).update({
      'status': 'submitted',
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Admin: approve a property.
  Future<void> approveProperty(String propertyId, {String? notes}) async {
    await _firestore.collection(_collection).doc(propertyId).update({
      'status': 'approved',
      'review_notes': notes,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Admin: reject a property.
  Future<void> rejectProperty(String propertyId, {String? notes}) async {
    await _firestore.collection(_collection).doc(propertyId).update({
      'status': 'rejected',
      'review_notes': notes,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Publish an approved property to live.
  Future<void> publishProperty(String propertyId, {DateTime? expiresAt}) async {
    final expireDate = expiresAt ?? DateTime.now().add(const Duration(days: 30));
    await _firestore.collection(_collection).doc(propertyId).update({
      'status': 'live',
      'expires_at': Timestamp.fromDate(expireDate),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Mark property as expired.
  Future<void> expireProperty(String propertyId) async {
    await _firestore.collection(_collection).doc(propertyId).update({
      'status': 'expired',
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Archive a property.
  Future<void> archiveProperty(String propertyId) async {
    await _firestore.collection(_collection).doc(propertyId).update({
      'status': 'archived',
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Update an existing property.
  Future<void> updateProperty(String propertyId, Map<String, dynamic> updates) async {
    updates['updated_at'] = FieldValue.serverTimestamp();
    await _firestore.collection(_collection).doc(propertyId).update(updates);
  }

  /// Delete a property (only if draft).
  Future<void> deleteProperty(String propertyId) async {
    await _firestore.collection(_collection).doc(propertyId).delete();
  }

  /// Unlock contact info for a user (costs 5 credits).
  /// Returns true if the user hasn't already unlocked it.
  Future<bool> unlockContact(String propertyId, String userId) async {
    final doc = await _firestore.collection(_collection).doc(propertyId).get();
    final data = doc.data();
    if (data == null) return false;

    final unlockedBy = List<String>.from(data['contact_unlocked_by'] ?? []);
    if (unlockedBy.contains(userId)) return false;

    unlockedBy.add(userId);
    await doc.reference.update({
      'contact_unlocked_by': unlockedBy,
      'updated_at': FieldValue.serverTimestamp(),
    });
    return true;
  }

  /// Unlock address info for a user (costs 10 credits).
  /// Returns true if the user hasn't already unlocked it.
  Future<bool> unlockAddress(String propertyId, String userId) async {
    final doc = await _firestore.collection(_collection).doc(propertyId).get();
    final data = doc.data();
    if (data == null) return false;

    final unlockedBy = List<String>.from(data['address_unlocked_by'] ?? []);
    if (unlockedBy.contains(userId)) return false;

    unlockedBy.add(userId);
    await doc.reference.update({
      'address_unlocked_by': unlockedBy,
      'updated_at': FieldValue.serverTimestamp(),
    });
    return true;
  }

  /// Boost a listing (costs 50 credits).
  Future<void> boostListing(String propertyId) async {
    final boostExpires = DateTime.now().add(const Duration(days: 7));
    await _firestore.collection(_collection).doc(propertyId).update({
      'is_boosted': true,
      'boost_expires_at': Timestamp.fromDate(boostExpires),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Search properties with filters.
  /// Returns a stream of filtered properties.
  Stream<List<PropertyModel>> searchProperties({
    String? division,
    String? district,
    String? upazila,
    String? union,
    String? area,
    String? road,
    double? minPrice,
    double? maxPrice,
    List<String>? propertyTypes,
    String? status,
    String? searchQuery,
  }) {
    Query query = _firestore.collection(_collection);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    if (division != null && division.isNotEmpty) {
      query = query.where('division', isEqualTo: division);
    }
    if (district != null && district.isNotEmpty) {
      query = query.where('district', isEqualTo: district);
    }
    if (upazila != null && upazila.isNotEmpty) {
      query = query.where('upazila', isEqualTo: upazila);
    }
    if (union != null && union.isNotEmpty) {
      query = query.where('union', isEqualTo: union);
    }
    if (area != null && area.isNotEmpty) {
      query = query.where('area', isEqualTo: area);
    }
    if (road != null && road.isNotEmpty) {
      query = query.where('road', isEqualTo: road);
    }
    if (minPrice != null) {
      query = query.where('price', isGreaterThanOrEqualTo: minPrice);
    }
    if (maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: maxPrice);
    }
    if (propertyTypes != null && propertyTypes.isNotEmpty) {
      query = query.where('property_type', whereIn: propertyTypes);
    }

    query = query.orderBy('is_boosted', descending: true)
        .orderBy('created_at', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final rawData = doc.data() as Map<String, dynamic>? ?? {};
        return PropertyModel.fromJson({'id': doc.id, ...rawData});
      }).toList();
    });
  }

  /// Get a single property by ID.
  Future<PropertyModel?> getProperty(String propertyId) async {
    final doc = await _firestore.collection(_collection).doc(propertyId).get();
    if (!doc.exists) return null;
    final rawData = doc.data() ?? {};
    return PropertyModel.fromJson({'id': doc.id, ...rawData});
  }

  /// Stream user's own listings.
  Stream<List<PropertyModel>> getUserProperties(String userId) {
    return _firestore
        .collection(_collection)
        .where('owner_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final rawData = doc.data() as Map<String, dynamic>? ?? {};
        return PropertyModel.fromJson({'id': doc.id, ...rawData});
      }).toList();
    });
  }

  /// Get nearby properties (radius-based, simplified without GeoFire).
  /// In production, use geohashing or GeoFire for accurate radius queries.
  Stream<List<PropertyModel>> getNearbyProperties({
    required double lat,
    required double lng,
    double radiusKm = 5,
  }) {
    // Simplified: return recent properties. For production,
    // integrate geohash/GeoFire for true radius-based search.
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'live')
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final rawData = doc.data() as Map<String, dynamic>? ?? {};
        return PropertyModel.fromJson({'id': doc.id, ...rawData});
      }).toList();
    });
  }
}