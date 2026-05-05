import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<RealtimeService> init() async {
    return this;
  }

  Stream<List<Map<String, dynamic>>> streamMeals(String messId) {
    return _supabase.from('meals').stream(primaryKey: ['id']).eq('mess_id', messId);
  }

  Stream<List<Map<String, dynamic>>> streamExpenses(String messId) {
    return _supabase.from('expenses').stream(primaryKey: ['id']).eq('mess_id', messId);
  }

  Stream<List<Map<String, dynamic>>> streamMembers(String messId) {
    return _supabase.from('mess_members').stream(primaryKey: ['id']).eq('mess_id', messId);
  }
}
