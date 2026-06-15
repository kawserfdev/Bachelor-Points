import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/need_based_post_model.dart';
import '../data/models/referral_model.dart';
import '../data/models/verification_model.dart';

/// Service for need-based posts (tenant posts, landlord contacts).
class NeedBasedPostService {
  NeedBasedPostService({
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _collection = 'need_based_posts';

  /// Create a new need-based post.
  Future<String> createPost(NeedBasedPostModel post) async {
    final docRef = await _firestore.collection(_collection).add(post.toFirestore());
    await docRef.update({'id': docRef.id});
    return docRef.id;
  }

  /// Close a post (mark as inactive).
  Future<void> closePost(String postId) async {
    await _firestore.collection(_collection).doc(postId).update({
      'status': 'closed',
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Get all active need-based posts.
  Stream<List<NeedBasedPostModel>> getActivePosts({
    String? division,
    String? district,
    String? propertyType,
  }) {
    Query query = _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'active');

    if (division != null && division.isNotEmpty) {
      query = query.where('division', isEqualTo: division);
    }
    if (district != null && district.isNotEmpty) {
      query = query.where('district', isEqualTo: district);
    }
    if (propertyType != null && propertyType.isNotEmpty) {
      query = query.where('property_type', isEqualTo: propertyType);
    }

    query = query.orderBy('created_at', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final rawData = doc.data() as Map<String, dynamic>? ?? {};
        return NeedBasedPostModel.fromJson({'id': doc.id, ...rawData});
      }).toList();
    });
  }

  /// Get user's own posts.
  Stream<List<NeedBasedPostModel>> getUserPosts(String userId) {
    return _firestore
        .collection(_collection)
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final rawData = doc.data() as Map<String, dynamic>? ?? {};
        return NeedBasedPostModel.fromJson({'id': doc.id, ...rawData});
      }).toList();
    });
  }
}

/// Service for referral system.
class ReferralService {
  ReferralService({
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _collection = 'referrals';

  /// Generate a referral link for a user.
  String generateReferralLink(String userId) {
    return 'https://bachelorpoints.app/ref/$userId';
  }

  /// Track a new referral.
  Future<void> trackReferral({
    required String referrerId,
    required String referredUserId,
  }) async {
    final docRef = _firestore.collection(_collection).doc();
    final referral = ReferralModel(
      id: docRef.id,
      referrerId: referrerId,
      referredUserId: referredUserId,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    await docRef.set(referral.toFirestore());
  }

  /// Mark referral as completed (referred user made a credit purchase).
  Future<void> completeReferral(String referralId, int commissionAmount) async {
    await _firestore.collection(_collection).doc(referralId).update({
      'status': 'completed',
      'commission_amount': commissionAmount,
      'completed_at': FieldValue.serverTimestamp(),
    });
  }

  /// Mark commission as withdrawn.
  Future<void> withdrawCommission(String referralId) async {
    await _firestore.collection(_collection).doc(referralId).update({
      'is_withdrawn': true,
      'withdrawn_at': FieldValue.serverTimestamp(),
    });
  }

  /// Get user's referrals.
  Stream<List<ReferralModel>> getUserReferrals(String userId) {
    return _firestore
        .collection(_collection)
        .where('referrer_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final rawData = doc.data() as Map<String, dynamic>? ?? {};
        return ReferralModel.fromJson({'id': doc.id, ...rawData});
      }).toList();
    });
  }

  /// Get pending commission total for a user.
  Future<int> getPendingCommission(String userId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('referrer_id', isEqualTo: userId)
        .where('status', isEqualTo: 'completed')
        .where('is_withdrawn', isEqualTo: false)
        .get();

    return snapshot.docs.fold<int>(0, (sum, doc) {
      return sum + ((doc.data()['commission_amount'] as num?)?.toInt() ?? 0);
    });
  }
}

/// Service for KYC verification.
class VerificationService {
  VerificationService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _verificationCollection = 'verifications';
  static const String _badgeCollection = 'verification_badges';

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  /// Submit a verification request.
  Future<String> submitVerification({
    required String type,
    required String documentUrl,
    String? documentNumber,
    String? referencePropertyId,
    String? referenceAgencyId,
  }) async {
    final docRef = _firestore.collection(_verificationCollection).doc();
    final verification = VerificationModel(
      id: docRef.id,
      userId: _currentUserId,
      type: type,
      documentUrl: documentUrl,
      documentNumber: documentNumber,
      referencePropertyId: referencePropertyId,
      referenceAgencyId: referenceAgencyId,
      createdAt: DateTime.now(),
    );
    await docRef.set(verification.toFirestore());
    return docRef.id;
  }

  /// Admin: approve a verification.
  Future<void> approveVerification(String verificationId, {String? reviewedBy}) async {
    await _firestore.collection(_verificationCollection).doc(verificationId).update({
      'status': 'approved',
      'reviewed_by': reviewedBy,
      'reviewed_at': FieldValue.serverTimestamp(),
    });

    // Award badge based on verification type
    final doc = await _firestore.collection(_verificationCollection).doc(verificationId).get();
    final data = doc.data();
    if (data != null) {
      final userId = data['user_id'] as String;
      final type = data['type'] as String;
      String badgeType;
      if (type == 'user_nid') {
        badgeType = 'verified_user';
      } else if (type.startsWith('property_')) {
        badgeType = 'verified_property';
      } else if (type == 'agency_trade_license') {
        badgeType = 'verified_agency';
      } else {
        badgeType = 'verified_user';
      }
      await _awardBadge(userId, badgeType);
    }
  }

  /// Admin: reject a verification.
  Future<void> rejectVerification(String verificationId, String notes, {String? reviewedBy}) async {
    await _firestore.collection(_verificationCollection).doc(verificationId).update({
      'status': 'rejected',
      'notes': notes,
      'reviewed_by': reviewedBy,
      'reviewed_at': FieldValue.serverTimestamp(),
    });
  }

  /// Check if a user has a specific badge.
  Future<bool> hasBadge(String userId, String badgeType) async {
    final snapshot = await _firestore
        .collection(_badgeCollection)
        .where('user_id', isEqualTo: userId)
        .where('badge_type', isEqualTo: badgeType)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// Check if user is KYC verified (has verified_user badge).
  Future<bool> isKycVerified(String userId) async {
    return hasBadge(userId, 'verified_user');
  }

  /// Get all badges for a user.
  Stream<List<VerificationBadge>> getUserBadges(String userId) {
    return _firestore
        .collection(_badgeCollection)
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final rawData = doc.data() as Map<String, dynamic>? ?? {};
        return VerificationBadge.fromJson({'id': doc.id, ...rawData});
      }).toList();
    });
  }

  /// Get pending verifications (admin).
  Stream<List<VerificationModel>> getPendingVerifications() {
    return _firestore
        .collection(_verificationCollection)
        .where('status', isEqualTo: 'pending')
        .orderBy('created_at', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final rawData = doc.data() as Map<String, dynamic>? ?? {};
        return VerificationModel.fromJson({'id': doc.id, ...rawData});
      }).toList();
    });
  }

  /// Get user's verification requests.
  Stream<List<VerificationModel>> getUserVerifications(String userId) {
    return _firestore
        .collection(_verificationCollection)
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final rawData = doc.data() as Map<String, dynamic>? ?? {};
        return VerificationModel.fromJson({'id': doc.id, ...rawData});
      }).toList();
    });
  }

  /// Award a badge to a user (deduplicates).
  Future<void> _awardBadge(String userId, String badgeType) async {
    final existing = await _firestore
        .collection(_badgeCollection)
        .where('user_id', isEqualTo: userId)
        .where('badge_type', isEqualTo: badgeType)
        .get();

    if (existing.docs.isNotEmpty) return; // already has badge

    final docRef = _firestore.collection(_badgeCollection).doc();
    final badge = VerificationBadge(
      id: docRef.id,
      userId: userId,
      badgeType: badgeType,
      awardedAt: DateTime.now(),
    );
    await docRef.set(badge.toFirestore());
  }
}