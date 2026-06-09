import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/routes/app_routes.dart';

class AuthService extends GetxService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  
  final Rx<User?> currentUser = Rx<User?>(null);

  Future<AuthService> init() async {
    debugPrint('AuthService init called');
    currentUser.value = _auth.currentUser;
    
    _auth.authStateChanges().listen((User? user) async {
      currentUser.value = user;
      
      if (user != null) {
        await _handleSignIn(user);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    });
    
    return this;
  }

  Future<void> _handleSignIn(User user) async {
    try {
      debugPrint('Checking profile for user: ${user.uid}');
      final doc = await _firestore
          .collection('profiles')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
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
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Authentication failed';
    } catch (e) {
      throw 'An unexpected error occurred.';
    }
  }

  Future<void> signUp(String email, String password, {String? name}) async {
    debugPrint('AuthService signUp called for email: $email');
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (name != null && credential.user != null) {
        await credential.user!.updateDisplayName(name);
        // Do not create profile here, it will be done in CreateProfileController
      }
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Sign up failed';
    } catch (e) {
      debugPrint('Error during sign up: $e');
      throw 'An unexpected error occurred. ';
    }
  }

  Future<void> resetPassword(String email) async {
    debugPrint('AuthService resetPassword called for email: $email');
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Reset password failed';
    } catch (e) {
      throw 'An unexpected error occurred.';
    }
  }

  Future<void> signOut() async {
    debugPrint('AuthService signOut called');
    await _auth.signOut();
  }
  
  bool get isLoggedIn => currentUser.value != null;
}
