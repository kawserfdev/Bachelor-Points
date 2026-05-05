import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/routes/app_routes.dart';

class AuthService extends GetxService {
  final _supabase = Supabase.instance.client;
  
  final Rx<User?> currentUser = Rx<User?>(null);

  Future<AuthService> init() async {
    currentUser.value = _supabase.auth.currentUser;
    
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      currentUser.value = session?.user;
      
      if (event == AuthChangeEvent.signedIn) {
        Get.offAllNamed(AppRoutes.home);
      } else if (event == AuthChangeEvent.signedOut) {
        Get.offAllNamed(AppRoutes.login);
      }
    });
    
    return this;
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred.';
    }
  }

  Future<void> signUp(String email, String password, {String? name}) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'full_name': name} : null,
      );
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred.';
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred.';
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
  
  bool get isLoggedIn => currentUser.value != null;
}
