import 'dart:async';
import 'package:bachelorpoints/shared/helpers/firestore_helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/shopping_item_model.dart';
import '../../data/models/shopping_list_model.dart';
import '../../services/action_notification_service.dart';
import '../../services/auth_service.dart';
import '../../shared/helpers/navigation_helper.dart';
import '../mess/mess_controller.dart';

class ShoppingController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();
  final MessController _messController = Get.find<MessController>();

  // ── Observable state ──────────────────────────────────────────────────────
  final Rx<ShoppingListModel?> activeList = Rx<ShoppingListModel?>(null);
  final RxList<ShoppingItemModel> allItems = <ShoppingItemModel>[].obs;
  final RxList<ShoppingListModel> historyLists = <ShoppingListModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentUserRole = 'member'.obs;

  StreamSubscription? _listSub;
  StreamSubscription? _itemsSub;
  StreamSubscription? _historySub;

  // ── Derived getters ───────────────────────────────────────────────────────

  String? get currentUserId => _authService.currentUser.value?.uid;

  bool get isManager =>
      currentUserRole.value == 'admin' || currentUserRole.value == 'manager';

  /// Approved items sorted urgent-first, then normal.
  List<ShoppingItemModel> get approvedItems {
    final approved = allItems.where((i) => i.isApproved).toList();
    approved.sort((a, b) {
      if (a.isUrgent && !b.isUrgent) return -1;
      if (!a.isUrgent && b.isUrgent) return 1;
      return a.createdAt.compareTo(b.createdAt);
    });
    return approved;
  }

  /// Pending items — managers see all, members see only their own.
  List<ShoppingItemModel> get pendingItems {
    final uid = currentUserId;
    if (isManager) {
      return allItems.where((i) => i.isPending).toList();
    }
    return allItems
        .where((i) => i.isPending && i.requestedBy == uid)
        .toList();
  }

  /// Items visible in the "Requests" tab per user.
  /// Members see their own pending + approved + rejected items.
  /// Managers see ALL pending items (to approve/reject) and all approved/rejected.
  List<ShoppingItemModel> get visibleRequestItems {
    final uid = currentUserId;
    if (isManager) {
      // Managers see all items that are not just 'approved' on the shopping list
      // (they already see approved items on the shopping list tab).
      // On the requests tab, show all pending. Also show rejected for context.
      return allItems
          .where((i) => !i.isApproved)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    // Members see only their own items
    return allItems
        .where((i) => i.requestedBy == uid)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  int get purchasedCount => approvedItems.where((i) => i.isPurchased).length;
  int get totalApprovedCount => approvedItems.length;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    debugPrint('[ShoppingController] onInit');
    _fetchUserRole();

    // Re-subscribe when active mess changes
    ever(_messController.activeMess, (_) {
      debugPrint('[ShoppingController] activeMess changed, re-subscribing');
      _fetchUserRole();
      _listenToActiveList();
      _listenToHistoryLists();
    });

    _listenToActiveList();
    _listenToHistoryLists();
  }

  @override
  void onClose() {
    _listSub?.cancel();
    _itemsSub?.cancel();
    _historySub?.cancel();
    super.onClose();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _fetchUserRole() async {
    final uid = currentUserId;
    final messId = _messController.activeMess.value?.id;
    if (uid == null || messId == null) return;

    try {
      final snap = await _firestore
          .collection('mess_members')
          .where('mess_id', isEqualTo: messId)
          .where('user_id', isEqualTo: uid)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        final role = snap.docs.first.data()['role'] as String? ?? 'member';
        currentUserRole.value = role;
        debugPrint('[ShoppingController] currentUserRole: $role');
      }
    } catch (e) {
      debugPrint('[ShoppingController] _fetchUserRole error: $e');
    }
  }

  void _listenToActiveList() {
    final messId = _messController.activeMess.value?.id;
    if (messId == null) {
      activeList.value = null;
      allItems.clear();
      return;
    }

    _listSub?.cancel();
    isLoading.value = true;

    _listSub = _firestore
        .collection('shopping_lists')
        .where('mess_id', isEqualTo: messId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .snapshots()
        .listen(
      (snap) {
        if (snap.docs.isEmpty) {
          activeList.value = null;
          allItems.clear();
          _itemsSub?.cancel();
          isLoading.value = false;
          return;
        }

        final doc = snap.docs.first;
        activeList.value = ShoppingListModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });

        debugPrint('[ShoppingController] Active list: ${activeList.value?.title}');
        _listenToItems(doc.id);
        isLoading.value = false;
      },
      onError: (e) {
        debugPrint('[ShoppingController] _listenToActiveList error: $e');
        isLoading.value = false;
      },
    );
  }

  void _listenToHistoryLists() {
    final messId = _messController.activeMess.value?.id;
    if (messId == null) {
      historyLists.clear();
      _historySub?.cancel();
      return;
    }

    _historySub?.cancel();

    _historySub = _firestore
        .collection('shopping_lists')
        .where('mess_id', isEqualTo: messId)
        .snapshots()
        .listen(
      (snap) {
        final twoMonthsAgo = DateTime.now().subtract(const Duration(days: 60));
        final lists = snap.docs
            .map((doc) => ShoppingListModel.fromJson({'id': doc.id, ...doc.data()}))
            .where((list) => list.createdAt.isAfter(twoMonthsAgo))
            .toList();

        // Sort by createdAt descending
        lists.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        historyLists.assignAll(lists);
        debugPrint('[ShoppingController] History lists loaded: ${lists.length}');
      },
      onError: (e) {
        debugPrint('[ShoppingController] _listenToHistoryLists error: $e');
      },
    );
  }

  void _listenToItems(String listId) {
    _itemsSub?.cancel();

    _itemsSub = _firestore
        .collection('shopping_items')
        .where('list_id', isEqualTo: listId)
        .snapshots()
        .listen(
      (snap) {
        final items = snap.docs.map((doc) {
          return ShoppingItemModel.fromJson({'id': doc.id, ...doc.data()});
        }).toList();

        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        allItems.assignAll(items);
        debugPrint('[ShoppingController] Items loaded: ${items.length}');
      },
      onError: (e) {
        debugPrint('[ShoppingController] _listenToItems error: $e');
      },
    );
  }

  // ── Public Actions ────────────────────────────────────────────────────────

  /// Request a new item (any member can do this).
  Future<void> requestItem({
    required String name,
    required String quantity,
    required String priority,
    String? note,
  }) async {
    final uid = currentUserId;
    final messId = _messController.activeMess.value?.id;
    final listId = activeList.value?.id;

    if (uid == null || messId == null || listId == null) {
      AppNavigation.showSnackBar(
        'Error',
        'No active shopping list found.',
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    if (name.trim().isEmpty) {
      AppNavigation.showSnackBar(
        'Validation',
        'Item name is required.',
        backgroundColor: Colors.orangeAccent,
      );
      return;
    }

    try {
      // Resolve the requester's display name
      String requesterName = 'Unknown';
      for (final m in _messController.members) {
        if (m.userId == uid) {
          requesterName = m.fullName ?? m.email ?? 'Unknown';
          break;
        }
      }

      await _firestore.collection('shopping_items').add({
        'list_id': listId,
        'mess_id': messId,
        'item_name': name.trim(),
        'quantity': quantity.trim(),
        'priority': priority,
        'is_purchased': false,
        'status': 'pending',
        'requested_by': uid,
        'requested_by_name': requesterName,
        'approved_by': null,
        'note': note?.trim().isEmpty == true ? null : note?.trim(),
        'created_at': FirestoreTime.serverTimestamp,
      });

      AppNavigation.showSnackBar(
        'Requested!',
        '"${name.trim()}" has been submitted for approval.',
        backgroundColor: Colors.green,
      );

      // Notify all managers/owners about the new request (fire-and-forget)
      ActionNotificationService.notifyShoppingItemRequested(
        messId: messId,
        requesterName: requesterName,
        itemName: name.trim(),
        quantity: quantity.trim(),
        priority: priority,
        members: _messController.members,
        currentUserId: uid,
      );
    } catch (e) {
      debugPrint('[ShoppingController] requestItem error: $e');
      AppNavigation.showSnackBar(
        'Error',
        'Failed to request item: $e',
        backgroundColor: Colors.redAccent,
      );
    }
  }

  /// Approve a pending item (manager/admin only).
  Future<void> approveItem(String itemId) async {
    if (!isManager) {
      AppNavigation.showSnackBar(
        'Permission Denied',
        'Only managers/admins can approve items.',
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    final uid = currentUserId;
    if (uid == null) return;
    final messId = _messController.activeMess.value?.id;

    try {
      await _firestore.collection('shopping_items').doc(itemId).update({
        'status': 'approved',
        'approved_by': uid,
      });

      AppNavigation.showSnackBar(
        'Approved',
        'Item has been added to the shopping list.',
        backgroundColor: Colors.green,
      );

      // Notify the requester that their item was approved (fire-and-forget)
      final approvedItem = allItems.firstWhereOrNull((i) => i.id == itemId);
      if (approvedItem != null && messId != null) {
        ActionNotificationService.notifyShoppingItemApproved(
          targetUserId: approvedItem.requestedBy,
          messId: messId,
          itemName: approvedItem.itemName,
          quantity: approvedItem.quantity,
        );
      }
    } catch (e) {
      debugPrint('[ShoppingController] approveItem error: $e');
      AppNavigation.showSnackBar('Error', 'Failed to approve item.',
          backgroundColor: Colors.redAccent);
    }
  }

  /// Reject a pending item (manager/admin only).
  Future<void> rejectItem(String itemId) async {
    if (!isManager) {
      AppNavigation.showSnackBar(
        'Permission Denied',
        'Only managers/admins can reject items.',
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    final messId = _messController.activeMess.value?.id;
    // Find the item before updating so we can use its data in the notification
    final itemToReject = allItems.firstWhereOrNull((i) => i.id == itemId);

    try {
      await _firestore.collection('shopping_items').doc(itemId).update({
        'status': 'rejected',
      });

      AppNavigation.showSnackBar(
        'Rejected',
        'Item request has been rejected.',
        backgroundColor: Colors.orange,
      );

      // Notify the requester that their item was rejected (fire-and-forget)
      if (itemToReject != null && messId != null) {
        ActionNotificationService.notifyShoppingItemRejected(
          targetUserId: itemToReject.requestedBy,
          messId: messId,
          itemName: itemToReject.itemName,
        );
      }
    } catch (e) {
      debugPrint('[ShoppingController] rejectItem error: $e');
      AppNavigation.showSnackBar('Error', 'Failed to reject item.',
          backgroundColor: Colors.redAccent);
    }
  }

  /// Toggle the purchased state of an approved item.
  Future<void> togglePurchased(String itemId, bool currentValue) async {
    try {
      await _firestore.collection('shopping_items').doc(itemId).update({
        'is_purchased': !currentValue,
      });
    } catch (e) {
      debugPrint('[ShoppingController] togglePurchased error: $e');
      AppNavigation.showSnackBar('Error', 'Failed to update item.',
          backgroundColor: Colors.redAccent);
    }
  }

  /// Create a new shopping list (manager/admin only).
  /// Marks any existing active list as inactive first if status is 'active'.
  Future<void> createList({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required String status,
  }) async {
    if (!isManager) {
      AppNavigation.showSnackBar(
        'Permission Denied',
        'Only managers/admins can create shopping lists.',
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    final uid = currentUserId;
    final messId = _messController.activeMess.value?.id;
    if (uid == null || messId == null) return;

    if (title.trim().isEmpty) {
      AppNavigation.showSnackBar(
        'Validation',
        'List title is required.',
        backgroundColor: Colors.orangeAccent,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Inactivate any existing active list if the new list is active
      if (status == 'active' && activeList.value != null) {
        await _firestore
            .collection('shopping_lists')
            .doc(activeList.value!.id)
            .update({
          'status': 'inactive',
          'completed_at': FirestoreTime.serverTimestamp,
        });
      }

      // Create the new list
      await _firestore.collection('shopping_lists').add({
        'mess_id': messId,
        'title': title.trim(),
        'status': status,
        'start_date': Timestamp.fromDate(startDate),
        'end_date': Timestamp.fromDate(endDate),
        'created_by': uid,
        'created_at': FirestoreTime.serverTimestamp,
        'completed_at': null,
      });

      AppNavigation.showSnackBar(
        'Created!',
        'Shopping list "${title.trim()}" has been created.',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      debugPrint('[ShoppingController] createList error: $e');
      AppNavigation.showSnackBar('Error', 'Failed to create list: $e',
          backgroundColor: Colors.redAccent);
    } finally {
      isLoading.value = false;
    }
  }

  /// Mark the active shopping list as inactive.
  Future<void> completeList() async {
    if (!isManager) {
      AppNavigation.showSnackBar(
        'Permission Denied',
        'Only managers/admins can complete lists.',
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    final listId = activeList.value?.id;
    if (listId == null) return;

    try {
      await _firestore.collection('shopping_lists').doc(listId).update({
        'status': 'inactive',
        'completed_at': FirestoreTime.serverTimestamp,
      });

      AppNavigation.showSnackBar(
        'Completed',
        'Shopping list has been marked as inactive.',
        backgroundColor: Colors.indigo,
      );
    } catch (e) {
      debugPrint('[ShoppingController] completeList error: $e');
      AppNavigation.showSnackBar('Error', 'Failed to complete list.',
          backgroundColor: Colors.redAccent);
    }
  }

  /// Update the status of any list (Active / Inactive).
  /// If set to 'active', automatically deactivates other active lists in this mess.
  Future<void> updateListStatus(String listId, String newStatus) async {
    if (!isManager) {
      AppNavigation.showSnackBar(
        'Permission Denied',
        'Only managers/admins can update list status.',
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    final messId = _messController.activeMess.value?.id;
    if (messId == null) return;

    try {
      isLoading.value = true;

      if (newStatus == 'active') {
        // If activating a list, deactivate other lists
        final activeDoc = await _firestore
            .collection('shopping_lists')
            .where('mess_id', isEqualTo: messId)
            .where('status', isEqualTo: 'active')
            .get();

        for (final doc in activeDoc.docs) {
          if (doc.id != listId) {
            await doc.reference.update({
              'status': 'inactive',
              'completed_at': FirestoreTime.serverTimestamp,
            });
          }
        }
      }

      await _firestore.collection('shopping_lists').doc(listId).update({
        'status': newStatus,
        'completed_at': newStatus == 'inactive' ? FirestoreTime.serverTimestamp : null,
      });

      AppNavigation.showSnackBar(
        'Updated',
        'Shopping list is now $newStatus.',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      debugPrint('[ShoppingController] updateListStatus error: $e');
      AppNavigation.showSnackBar('Error', 'Failed to update status: $e',
          backgroundColor: Colors.redAccent);
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a shopping list and its associated items.
  Future<void> deleteList(String listId) async {
    if (!isManager) {
      AppNavigation.showSnackBar(
        'Permission Denied',
        'Only managers/admins can delete shopping lists.',
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Delete the list document
      await _firestore.collection('shopping_lists').doc(listId).delete();

      // Delete associated items
      final itemsSnap = await _firestore
          .collection('shopping_items')
          .where('list_id', isEqualTo: listId)
          .get();

      final batch = _firestore.batch();
      for (final doc in itemsSnap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      AppNavigation.showSnackBar(
        'Deleted',
        'Shopping list and its items have been deleted.',
        backgroundColor: Colors.red,
      );
    } catch (e) {
      debugPrint('[ShoppingController] deleteList error: $e');
      AppNavigation.showSnackBar('Error', 'Failed to delete list: $e',
          backgroundColor: Colors.redAccent);
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch all shopping items for a specific list.
  Future<List<ShoppingItemModel>> fetchItemsForList(String listId) async {
    try {
      final snap = await _firestore
          .collection('shopping_items')
          .where('list_id', isEqualTo: listId)
          .get();

      final items = snap.docs.map((doc) {
        return ShoppingItemModel.fromJson({'id': doc.id, ...doc.data()});
      }).toList();

      // Sort approved items first, then priority, then date
      items.sort((a, b) {
        if (a.isApproved && !b.isApproved) return -1;
        if (!a.isApproved && b.isApproved) return 1;
        if (a.isUrgent && !b.isUrgent) return -1;
        if (!a.isUrgent && b.isUrgent) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });
      return items;
    } catch (e) {
      debugPrint('[ShoppingController] fetchItemsForList error: $e');
      return [];
    }
  }
}
