import 'package:bachelorpoints/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../shared/helpers/navigation_helper.dart';

class AuthService extends GetxService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  final Rx<User?> currentUser = Rx<User?>(null);

  Future<AuthService> init() async {
    debugPrint('AuthService init called');
    currentUser.value = _auth.currentUser;

    // Keep auth state listener to update currentUser for backward
    // compatibility with existing GetX controllers that read it.
    // Navigation is handled by GoRouter (see go_router_config.dart).
    _auth.authStateChanges().listen((User? user) {
      currentUser.value = user;
    });

    return this;
  }

  /// Exposed for GoRouter redirect to check profile existence during migration.
  Future<bool> hasProfile(String uid) async {
    try {
      final doc = await _firestore.collection('profiles').doc(uid).get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking profile: $e');
      return false;
    }
  }

  Future<void> signIn(String email, String password) async {
    debugPrint('AuthService signIn called for email: $email');
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If the user's email is not yet verified, send a new verification email
      // and let GoRouter redirect them to the verify-email screen.
      if (credential.user != null && !credential.user!.emailVerified) {
        await credential.user!.sendEmailVerification();
        debugPrint('Verification email re-sent to unverified user: $email');
      }else{
        
        debugPrint('User signed in successfully: $email');
      }
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

      // Send verification email
      if (credential.user != null && !credential.user!.emailVerified) {
        await credential.user!.sendEmailVerification();
        debugPrint('Verification email sent to: $email');
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

  Future<void> signInWithGoogle() async {
    debugPrint('AuthService signInWithGoogle called');

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      // Initialize Google Sign-In
      await googleSignIn.initialize();

      // Authenticate user
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      // Get authentication tokens
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      await _auth.signInWithCredential(credential);

      debugPrint('Google Sign-In successful');
    } on GoogleSignInException catch (e) {
      debugPrint('Google Sign-In Error: ${e.code} - ${e.description}');
      throw e.description ?? 'Google Sign-In failed';
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      throw e.message ?? 'Firebase authentication failed';
    } catch (e) {
      debugPrint('Unexpected Error: $e');
      rethrow;
    }
  }

  /// Signs out the current user and wipes ALL local state:
  ///   - Firebase Auth session
  ///   - Google Sign-In session
  ///   - GetStorage (GetX local storage)
  ///   - GetX controllers & dependencies
  ///   - Navigation stack (redirect to login)
  Future<void> signOut() async {
    debugPrint('AuthService signOut called — wiping all local state');

    // 1. Clear GetStorage (local key-value storage)
    await Get.find<StorageService>().clearAll();

    // 2. Sign out of Google (no-op if not signed in via Google)
    try {
      await GoogleSignIn.instance.signOut();
      debugPrint('Google Sign-In session cleared');
    } catch (e) {
      debugPrint('Google Sign-In clear error (non-fatal): $e');
    }

    // 3. Sign out of Firebase Auth
    await _auth.signOut();

    // 4. Reset current user observable in this service
    currentUser.value = null;

    // 5. Delete all non-permanent GetX controllers
    //    Lazy controllers (mess, balance, profile, etc.) are destroyed;
    //    permanent services (auth, storage, theme, etc.) survive.
    Get.deleteAll();

    // 6. Navigate to login and clear the entire navigation stack
    //    Use GoRouter.go() so the redirect guard sends the user to login
    AppNavigation.go('/login');

    debugPrint('AuthService signOut — all state wiped, redirected to login');
  }

  bool get isLoggedIn => currentUser.value != null;
}
