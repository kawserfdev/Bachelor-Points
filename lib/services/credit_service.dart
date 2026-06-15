import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../data/models/credit_model.dart';

/// Service for managing user credit balances and transactions.
class CreditService {
  CreditService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _collection = 'credits';

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  /// Credit costs for different actions.
  static const int unlockContactCost = 5;
  static const int unlockAddressCost = 10;
  static const int propertyPostCost = 20;
  static const int boostListingCost = 50;

  /// Get or create credit account for a user.
  Future<CreditModel> getOrCreateCreditAccount(String userId) async {
    final doc = await _firestore.collection(_collection).doc(userId).get();
    if (doc.exists) {
      return CreditModel.fromJson({'id': doc.id, ...doc.data()!});
    }

    // Create a new credit account with 0 balance
    final newAccount = CreditModel(id: userId, userId: userId, balance: 0);
    await _firestore.collection(_collection).doc(userId).set(
      newAccount.toFirestore(),
    );
    return newAccount;
  }

  /// Get current credit balance for a user.
  Future<int> getBalance(String userId) async {
    final account = await getOrCreateCreditAccount(userId);
    return account.balance;
  }

  /// Get current user's balance.
  Future<int> getMyBalance() async {
    return getBalance(_currentUserId);
  }

  /// Stream credit balance for real-time updates.
  Stream<int> balanceStream(String userId) {
    return _firestore.collection(_collection).doc(userId).snapshots().map((doc) {
      if (!doc.exists) return 0;
      return (doc.data()?['balance'] as num?)?.toInt() ?? 0;
    });
  }

  /// Add credits to a user (e.g., purchase or referral bonus).
  Future<bool> addCredits({
    required String userId,
    required int amount,
    required String reason,
    String? referenceId,
  }) async {
    final account = await getOrCreateCreditAccount(userId);
    final newBalance = account.balance + amount;

    final transaction = CreditTransaction(
      id: _firestore.collection('_transactions').doc().id,
      type: 'credit',
      amount: amount,
      reason: reason,
      referenceId: referenceId,
      createdAt: DateTime.now(),
    );

    final transactions = [...account.transactions, transaction];

    await _firestore.collection(_collection).doc(userId).update({
      'balance': newBalance,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    });

    return true;
  }

  /// Deduct credits from a user (e.g., unlocking contact, posting property).
  /// Returns true if sufficient balance, false otherwise.
  Future<bool> deductCredits({
    required String userId,
    required int amount,
    required String reason,
    String? referenceId,
  }) async {
    final account = await getOrCreateCreditAccount(userId);

    if (account.balance < amount) {
      debugPrint('Insufficient credits: has ${account.balance}, needs $amount');
      return false;
    }

    final newBalance = account.balance - amount;

    final transaction = CreditTransaction(
      id: _firestore.collection('_transactions').doc().id,
      type: 'debit',
      amount: amount,
      reason: reason,
      referenceId: referenceId,
      createdAt: DateTime.now(),
    );

    final transactions = [...account.transactions, transaction];

    await _firestore.collection(_collection).doc(userId).update({
      'balance': newBalance,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    });

    return true;
  }

  /// Check if user has enough credits for an action.
  Future<bool> hasEnoughCredits(String userId, int requiredAmount) async {
    final balance = await getBalance(userId);
    return balance >= requiredAmount;
  }

  /// Get transaction history for a user.
  Stream<List<CreditTransaction>> transactionStream(String userId) {
    return _firestore.collection(_collection).doc(userId).snapshots().map((doc) {
      if (!doc.exists) return [];
      final data = doc.data()!;
      final transactionList = data['transactions'] as List<dynamic>? ?? [];
      return transactionList
          .map((t) => CreditTransaction.fromJson(t as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // newest first
    });
  }
}