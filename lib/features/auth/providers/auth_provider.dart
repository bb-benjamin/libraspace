// ═══════════════════════════════════════════════════
// FILE: lib/features/auth/providers/auth_provider.dart
//
// PURPOSE: The "whiteboard" for login state.
// Tracks: who is logged in, whether we are busy, any errors.
//
// "extends ChangeNotifier" = this class can ANNOUNCE changes.
// When we call notifyListeners(), every screen watching this
// provider automatically rebuilds with fresh data.

//═══════════════════════════════════════════════════
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/app_user_model.dart';
import '../../../core/services/firebase_service.dart';

// AuthStatus = the three possible login states.
// An enum is a fixed list of allowed values.
// The app can ONLY be in one of these three states at any time.
enum AuthStatus {
  loading, // App just opened — checking if someone was already logged in
  loggedIn, // Someone IS logged in right now
  loggedOut, // Nobody is logged in
}

class AuthProvider extends ChangeNotifier {
  // PRIVATE FIELDS — _ prefix means only THIS file can change these.
  // Other screens can only READ them through the getters below.
  final FirebaseService _service = FirebaseService();
  AuthStatus _status = AuthStatus.loading; // starts as loading
  AppUser? _currentUser; // logged-in user profile, or null
  bool _isBusy = false; // true while waiting for Firebase
  String? _errorText; // last error message, or null

  // PUBLIC GETTERS — read-only windows into the private fields above.
  // Screens read these but cannot change the private fields directly.
  AuthStatus get status => _status;
  AppUser? get currentUser => _currentUser;
  bool get isBusy => _isBusy;
  String? get errorText => _errorText;
  bool get isLoggedIn => _status == AuthStatus.loggedIn;

  // CONSTRUCTOR — runs once when AuthProvider is created at app startup.
  // Immediately starts listening to Firebase for login changes.
  AuthProvider() {
    _startListening();
  }

  void _startListening() {
    // .listen() subscribes to the auth stream.
    // Every time login state changes, this function runs automatically.
    _service.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        // Firebase says: nobody is logged in
        _status = AuthStatus.loggedOut;
        _currentUser = null;
      } else {
        // Firebase says: this user is logged in
        // Load their full profile (name, programme) from Firestore
        _currentUser = await _service.loadUserProfile(firebaseUser.uid);
        _status = AuthStatus.loggedIn;
        await _subscribeToNotifications();
      }

      // Tell ALL watching screens to rebuild
      notifyListeners();
    });
  }

  Future<void> _subscribeToNotifications() async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic('all_users');
      print('Subscribed to all_users notification topic');
    } catch (e) {
      print('Could not subscribe to notifications: $e');
    }
  }

  // REGISTER — called when student taps "Create Account"
  // Returns true if it worked, false if something went wrong.
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String programme,
    required String institution,
  }) async {
    _isBusy = true; // show loading spinner on button
    _errorText = null; // clear old errors
    notifyListeners(); // button becomes a spinner

    try {
      // Step 1: Create the Firebase Auth account
      final credential = await _service.registerWithEmail(
        email: email,
        password: password,
      );

      // Step 2: Build our AppUser profile
      final newUser = AppUser(
        uid: credential.user!.uid,
        // credential.user! = the Firebase User object
        // The ! says "I know this is not null"
        fullName: fullName,
        emailAddress: email,
        programme: programme,
        institution: institution,
      );

      // Step 3: Save profile to Firestore
      await _service.saveUserProfile(newUser);
      _currentUser = newUser;

      return true; // ✅ success
    } on FirebaseAuthException catch (error) {
      // Firebase gives us a short code for what went wrong.
      // We translate it to a friendly sentence.
      _errorText = _translateError(error.code);
      return false; // ❌ failed
    } catch (e) {
      _errorText = 'Something went wrong. Please try again.';
      return false;
    } finally {
      // "finally" runs ALWAYS — success or failure.
      // We always need to stop the loading spinner.
      _isBusy = false;
      notifyListeners(); // button goes back to normal
    }
  }

  // SIGN IN — called when student taps "Sign In"
  Future<bool> signIn({required String email, required String password}) async {
    _isBusy = true;
    _errorText = null;
    notifyListeners();

    try {
      await _service.signInWithEmail(email: email, password: password);
      // _startListening() detects the login automatically.
      // app.dart will switch to MainShell on its own.
      return true;
    } on FirebaseAuthException catch (error) {
      _errorText = _translateError(error.code);
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    await _service.signOut();

    // _startListening() detects logout automatically.
    // app.dart switches back to WelcomeScreen on its own.
  }

  Future<bool> deleteAccount() async {
    _isBusy = true;
    _errorText = null;
    notifyListeners();

    try {
      final String userId = _currentUser?.uid ?? '';
      if (userId.isEmpty) return false;

      await _service.deleteAccount(userId);
      _currentUser = null;
      _status = AuthStatus.loggedOut;
      return true;
    } catch (e) {
      _errorText =
          'Could not delete account. Please sign out and sign in again before deleting.';
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  // TRANSLATE FIREBASE ERROR CODES to friendly sentences.
  // Firebase sends codes like "wrong-password". We make them readable.
  // A "switch" checks a value against many possible cases.
  String _translateError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many failed attempts. Wait a few minutes.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
