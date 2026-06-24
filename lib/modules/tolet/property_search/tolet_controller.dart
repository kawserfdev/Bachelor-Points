import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/models/property_model.dart';

class ToletController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Filter state
  final RxString selectedToletFilter = 'All'.obs;
  final RxString searchQuery = ''.obs;

  // Listings
  final RxList<PropertyModel> allListings = <PropertyModel>[].obs;
  final RxList<PropertyModel> boostedListings = <PropertyModel>[].obs;
  final RxBool isLoadingListings = false.obs;
  final RxString error = ''.obs;

  StreamSubscription<QuerySnapshot>? _listingsSubscription;

  /// Filtered listings based on selectedToletFilter and searchQuery.
  List<PropertyModel> get filteredListings {
    var list = allListings.toList();

    // Filter by property type pill
    final filter = selectedToletFilter.value;
    if (filter != 'All') {
      list = list.where((p) => _matchesTypeFilter(p.propertyType, filter)).toList();
    }

    // Filter by search query
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((p) {
        return p.title.toLowerCase().contains(query) ||
            p.area.toLowerCase().contains(query) ||
            p.district.toLowerCase().contains(query) ||
            p.upazila.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query);
      }).toList();
    }

    return list;
  }

  bool _matchesTypeFilter(String propertyType, String filter) {
    switch (filter) {
      case 'Seat':
        return propertyType == 'hostel' || propertyType == 'mess';
      case 'Full Flat':
        return propertyType == 'family' || propertyType == 'bachelor';
      case 'Office':
        return propertyType == 'office';
      case 'Shop':
        return propertyType == 'shop';
      default:
        return true;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchListings();
  }

  @override
  void onClose() {
    _listingsSubscription?.cancel();
    super.onClose();
  }

  /// Starts a real-time Firestore stream for live property listings.
  void fetchListings() {
    isLoadingListings.value = true;
    error.value = '';

    _listingsSubscription?.cancel();

    _listingsSubscription = _firestore
        .collection('properties')
        .where('status', isEqualTo: 'live')
        .orderBy('is_boosted', descending: true)
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        final all = snapshot.docs.map((doc) {
          return PropertyModel.fromJson({'id': doc.id, ...doc.data()});
        }).toList();

        allListings.assignAll(all);
        boostedListings.assignAll(all.where((p) => p.isBoosted).toList());
        isLoadingListings.value = false;

        debugPrint('[ToletController] Loaded ${all.length} live listings, ${boostedListings.length} boosted');
      },
      onError: (e) {
        error.value = e.toString();
        isLoadingListings.value = false;
        debugPrint('[ToletController] Error loading listings: $e');
      },
    );
  }
}