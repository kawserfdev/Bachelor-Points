import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Plain Dart Auth service — decoupled from GetX.
/// Exposes a [authStateChanges] stream for Riverpod to consume.
/// The old GetX-dependent [AuthService] in services/ will be replaced
/// once all controllers migrate to Riverpod.
class AppAuthService {
  AppAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  /// Stream of Firebase auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current logged-in user (or null)
  User? get currentUser => _auth.currentUser;

  /// Whether a user is currently logged in
  bool get isLoggedIn => currentUser != null;

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    debugPrint('AppAuthService.signInWithEmail: $email');
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // If the user's email is not yet verified, send a new verification email
    // and let GoRouter redirect them to the verify-email screen.
    if (credential.user != null && !credential.user!.emailVerified) {
      await credential.user!.sendEmailVerification();
      debugPrint('Verification email re-sent to unverified user: $email');
    }

    return credential;
  }

  /// Create a new account with email and password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    debugPrint('AppAuthService.signUpWithEmail: $email');
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (displayName != null && credential.user != null) {
      await credential.user!.updateDisplayName(displayName);
    }

    // Send verification email
    if (credential.user != null && !credential.user!.emailVerified) {
      await credential.user!.sendEmailVerification();
      debugPrint('Verification email sent to: $email');
    }

    return credential;
  }

  /// Send a password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    debugPrint('AppAuthService.sendPasswordResetEmail: $email');
    return _auth.sendPasswordResetEmail(email: email);
  }

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    debugPrint('AppAuthService.signInWithGoogle');

    try {
      if (kIsWeb) {
        // Use Firebase Auth signInWithPopup on web
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        return await _auth.signInWithPopup(googleProvider);
      } else {
        // Ensure the Google Sign-In native plugin is initialized
        await _googleSignIn.initialize();

        // Prompt the user to select/authenticate a Google account
        final googleUser = await _googleSignIn.authenticate();
        final googleAuth = googleUser.authentication;

        // Create a Firebase credential from the Google auth tokens.
        // google_sign_in >= 7.0.0 only exposes idToken on
        // GoogleSignInAuthentication; the idToken is sufficient for
        // Firebase sign-in.
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } on GoogleSignInException catch (e) {
      debugPrint('Google Sign-In Error: ${e.code} - ${e.description}');
      throw Exception(e.description ?? 'Google Sign-In failed');
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      throw Exception(e.message ?? 'Firebase authentication failed');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    debugPrint('AppAuthService.signOut');
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// Check whether a user profile exists in Firestore
  Future<bool> hasProfile(String uid) async {
    final doc = await _firestore.collection('profiles').doc(uid).get();
    return doc.exists;
  }
}