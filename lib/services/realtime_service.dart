import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class RealtimeService extends GetxService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<RealtimeService> init() async {
    debugPrint('RealtimeService init called');
    return this;
  }

  Stream<List<Map<String, dynamic>>> streamMeals(String messId) {
    debugPrint('RealtimeService streamMeals called for messId: $messId');
    return _firestore.collection('meals')
        .where('mess_id', isEqualTo: messId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  Stream<List<Map<String, dynamic>>> streamExpenses(String messId) {
    debugPrint('RealtimeService streamExpenses called for messId: $messId');
    return _firestore.collection('expenses')
        .where('mess_id', isEqualTo: messId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  Stream<List<Map<String, dynamic>>> streamDeposits(String messId) {
    debugPrint('RealtimeService streamDeposits called for messId: $messId');
    return _firestore.collection('deposits')
        .where('mess_id', isEqualTo: messId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  Stream<List<Map<String, dynamic>>> streamMembers(String messId) {
    debugPrint('RealtimeService streamMembers called for messId: $messId');
    return _firestore.collection('mess_members')
        .where('mess_id', isEqualTo: messId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }
}
