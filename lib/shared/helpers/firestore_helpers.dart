import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTime {
  /// Use this when WRITING data to Firestore
  static FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  /// Use this when READING data from Firestore.
  /// Prevents crashes by handling null/cache states gracefully.
  static DateTime parse(dynamic timestampField) {
    if (timestampField is Timestamp) {
      return timestampField.toDate();
    }
    // Fallback if Firestore hasn't resolved the server timestamp yet (local cache)
    return DateTime.now();
  }
}