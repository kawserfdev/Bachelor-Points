import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class RealtimeService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<RealtimeService> init() async {
    debugPrint('RealtimeService init called');
    return this;
  }

  Stream<List<Map<String, dynamic>>> streamMeals(String messId) {
    debugPrint('RealtimeService streamMeals called for messId: $messId');
    return _supabase.from('meals').stream(primaryKey: ['id']).eq('mess_id', messId);
  }

  Stream<List<Map<String, dynamic>>> streamExpenses(String messId) {
    debugPrint('RealtimeService streamExpenses called for messId: $messId');
    return _supabase.from('expenses').stream(primaryKey: ['id']).eq('mess_id', messId);
  }

  Stream<List<Map<String, dynamic>>> streamMembers(String messId) {
    debugPrint('RealtimeService streamMembers called for messId: $messId');
    return _supabase.from('mess_members').stream(primaryKey: ['id']).eq('mess_id', messId);
  }
}
