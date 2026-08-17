// ═══════════════════════════════════════════════════
// FILE: lib/core/services/firebase_service.dart
//
// PURPOSE: The ONLY file that talks directly to Firebase.
// All screens and providers use THIS file.
// This is called the "Service Layer" pattern.
//
// If Firebase breaks, you only look HERE to fix it.
// ═══════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/library_model.dart';
import '../models/app_user_model.dart';
import '../models/visit_record_model.dart';

class FirebaseService {
  // Our two Firebase connections.
  // _ prefix = private. Only THIS file can use these directly.
  // .instance = the one shared connection to this service.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ══════════════════════════════════════════
  // SECTION 1: AUTHENTICATION
  // ══════════════════════════════════════════

  // Who is logged in right now? null if nobody.
  User? get currentUser => _auth.currentUser;

  // A STREAM that keeps broadcasting login/logout changes.
  //
  // WHAT IS A STREAM?
  // A stream is like a live TV channel that keeps broadcasting.
  // When you "listen" to it, you receive data continuously.
  // This stream broadcasts:
  //   → A User object when someone logs in
  //   → null when someone logs out
  // Our app.dart listens to this and switches screens automatically.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register a NEW user.
  //
  // WHAT IS Future? A value that does not exist YET but WILL exist later.
  // Like ordering food — you don't have it now, but you will.
  //
  // WHAT IS async? Marks a function that will do things that take time.
  //
  // WHAT IS await? "Pause here and wait for this to finish."
  // Without await, code would try to use results before Firebase responds.
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign in an existing user.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ══════════════════════════════════════════
  // SECTION 2: USER PROFILES
  // ══════════════════════════════════════════

  // Save a user's profile to Firestore after registration.
  //
  // HOW FIRESTORE WORKS:
  // Database → Collection (folder) → Document (file inside folder) → Fields (data)
  //
  // _db.collection('users')  = go to the "users" folder
  // .doc(user.uid)            = go to the document named by user's ID
  // .set(data)                = write this data (creates or replaces)
  Future<void> saveUserProfile(AppUser user) async {
    await _db.collection('users').doc(user.uid).set(user.toFirestore());
  }

  // Load a user's profile from Firestore.
  Future<AppUser?> loadUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null; // not found → return null
    return AppUser.fromFirestore(doc.data()!, uid);
    // doc.data()! — the ! means "I know this is not null because doc.exists is true"
  }

  // ══════════════════════════════════════════
  // SECTION 3: LIBRARIES
  // ══════════════════════════════════════════

  // Get ALL libraries as a REAL-TIME STREAM.
  //
  // .snapshots() stays open and automatically sends fresh data
  // every time ANY library document changes in Firestore.
  //
  // When Student A checks in → Firestore document updates →
  // this stream fires → every phone gets the updated list instantly.
  // No button needed. No refresh. Truly real-time.
  //
  // .map() transforms each raw snapshot into a List<LibraryModel>.
  Stream<List<LibraryModel>> watchAllLibraries() {
    return _db.collection('libraries').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return LibraryModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // ══════════════════════════════════════════
  // SECTION 4: CHECK IN AND OUT
  // ══════════════════════════════════════════

  // Check a student INTO a library.
  //
  // WHY WE USE A TRANSACTION:
  // Two students scan at the EXACT same moment.
  //
  // WITHOUT transaction:
  //   Both phones read occupiedSeats = 30
  //   Both calculate 30 + 1 = 31
  //   Both write 31 → WRONG! Should be 32!
  //
  // WITH transaction:
  //   Read and write happen as ONE unbreakable step.
  //   Firebase queues them. One finishes before the other starts.
  //   Phone A: reads 30, writes 31. Phone B: reads 31, writes 32. ✅
  //   Count is ALWAYS accurate.
  Future<void> checkIn({
    required String userId,
    required String libraryId,
  }) async {
    await _db.runTransaction((transaction) async {
      final libraryRef = _db.collection('libraries').doc(libraryId);
      final libraryDoc = await transaction.get(libraryRef);
      // We read INSIDE the transaction — part of the atomic operation

      if (!libraryDoc.exists) {
        throw Exception('Library not found');
        // "throw Exception" = stop and report an error
      }

      final data = libraryDoc.data()!;
      final int currentOccupied = data['occupiedSeats'] as int;
      final int total = data['totalSeats'] as int;

      if (currentOccupied >= total) {
        throw Exception('Library is full');
      }

      transaction.update(libraryRef, {
        'occupiedSeats': currentOccupied + 1,
        'checkedInUsers': FieldValue.arrayUnion([userId]),
        // arrayUnion adds userId WITHOUT creating duplicates
      });
    });
  }

  // Check a student OUT.
  Future<void> checkOut({
    required String userId,
    required String libraryId,
  }) async {
    await _db.runTransaction((transaction) async {
      final libraryRef = _db.collection('libraries').doc(libraryId);
      final libraryDoc = await transaction.get(libraryRef);
      if (!libraryDoc.exists) throw Exception('Library not found');

      final data = libraryDoc.data()!;
      final int currentOccupied = data['occupiedSeats'] as int;

      transaction.update(libraryRef, {
        'occupiedSeats': currentOccupied > 0 ? currentOccupied - 1 : 0,
        // Never go below 0. The ? : is a shortcut for if/else:
        // "if currentOccupied > 0, subtract 1. Otherwise keep 0."
        'checkedInUsers': FieldValue.arrayRemove([userId]),
        // arrayRemove removes userId from the array
      });
    });
  }

  // ══════════════════════════════════════════
  // SECTION 5: VISIT HISTORY
  // ══════════════════════════════════════════

  Future<void> saveVisitRecord(VisitRecord record) async {
    await _db
        .collection('visitHistory')
        .doc(record.recordId)
        .set(record.toFirestore());
  }

  // ── CROWD PREDICTION DATA ────────────────────────────────
  // Every time someone checks in, we record which hour and day it was.
  // This builds up a pattern over time.
  // libraryId = which library, hour = 0-23, dayOfWeek = 1 (Mon) to 7 (Sun)
  Future<void> recordVisitForPrediction({
    required String libraryId,
    required int hour,
    required int dayOfWeek,
  }) async {
    // The document path includes libraryId + dayOfWeek so each library
    // has separate stats for each day of the week.
    final String docId = '${libraryId}_day${dayOfWeek}';

    // FieldValue.increment(1) adds 1 to a number in Firestore.
    // If the field does not exist yet, it creates it with value 1.
    // We use the hour number as the field name, e.g. 'h14' = 2pm.
    await _db.collection('crowdData').doc(docId).set(
      {'h$hour': FieldValue.increment(1), 'libraryId': libraryId},
      SetOptions(merge: true),
      // SetOptions(merge: true) = update existing fields, do NOT replace the doc.
      // Without merge: true, the whole document would be replaced, losing old data.
    );
  }

  // Get crowd prediction data for a specific library and day of week
  // Returns a Map where key = hour (0-23), value = visit count
  Future<Map<int, int>> getCrowdData({
    required String libraryId,
    required int dayOfWeek,
  }) async {
    final String docId = '${libraryId}_day${dayOfWeek}';
    final doc = await _db.collection('crowdData').doc(docId).get();

    if (!doc.exists) return {}; // no data yet — return empty map

    final data = doc.data()!;
    final Map<int, int> hourlyVisits = {};

    // Loop through hours 0 to 23 and read the visit count for each
    for (int h = 0; h < 24; h++) {
      final value = data['h$h'];
      if (value != null) {
        hourlyVisits[h] = value as int;
      }
    }
    return hourlyVisits;
  }

  Future<void> recordCheckOut(String recordId, DateTime checkOutTime) async {
    await _db.collection('visitHistory').doc(recordId).update({
      'checkOutTime': checkOutTime.toIso8601String(),
      // .update() changes ONLY the fields you specify.
      // Unlike .set() which replaces the whole document.
    });
  }

  Future<void> deleteAccount(String userId) async {
    // Delete user profile from Firestore
    await _db.collection('users').doc(userId).delete();

    // Delete the Firebase Auth account
    await _auth.currentUser?.delete();
  }

  // Get one user's visit history as a live stream (newest first).
  Stream<List<VisitRecord>> watchUserHistory(String userId) {
    return _db
        .collection('visitHistory')
        .where('userId', isEqualTo: userId) // only THIS user's records
        .orderBy('checkInTime', descending: true) // newest first
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => VisitRecord.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }
}
