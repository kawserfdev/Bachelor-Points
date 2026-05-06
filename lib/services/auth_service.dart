import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/routes/app_routes.dart';

class AuthService extends GetxService {
  final _supabase = Supabase.instance.client;
  
  final Rx<User?> currentUser = Rx<User?>(null);

  Future<AuthService> init() async {
    debugPrint('AuthService init called');
    currentUser.value = _supabase.auth.currentUser;
    
    _supabase.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      currentUser.value = session?.user;
      
      if (event == AuthChangeEvent.signedIn) {
        if (session?.user != null) {
          await _handleSignIn(session!.user);
        }
      } else if (event == AuthChangeEvent.signedOut) {
        Get.offAllNamed(AppRoutes.login);
      }
    });
    
    return this;
  }

  Future<void> _handleSignIn(User user) async {
    try {
      debugPrint('Checking profile for user: ${user.id}');
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        debugPrint('No profile found, routing to createProfile');
        Get.offAllNamed(AppRoutes.createProfile);
      } else {
        debugPrint('Profile found, routing to home');
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      debugPrint('Error checking profile during sign in: $e');
      Get.offAllNamed(AppRoutes.home); 
    }
  }

  Future<void> signIn(String email, String password) async {
    debugPrint('AuthService signIn called for email: $email');
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred.';
    }
  }

  Future<void> signUp(String email, String password, {String? name}) async {
    debugPrint('AuthService signUp called for email: $email');
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
    debugPrint('AuthService resetPassword called for email: $email');
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred.';
    }
  }

  Future<void> signOut() async {
    debugPrint('AuthService signOut called');
    await _supabase.auth.signOut();
  }
  
  bool get isLoggedIn => currentUser.value != null;
}
