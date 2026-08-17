// ═══════════════════════════════════════════════════
// FILE: lib/core/models/app_user_model.dart
//
// PURPOSE: The blueprint for a logged-in student.
// Called AppUser (not User) because Firebase already
// has a class called User — same name would confuse Dart.
// ═══════════════════════════════════════════════════

class AppUser {
  final String uid; // Firebase's unique ID for this user
  final String fullName; // e.g. "Kofi Mensah"
  final String emailAddress; // e.g. "kofi@gmail.com"
  final String programme; // e.g. "BSc Computer Science"
  final String institution; // e.g. "University of Ghana"
  final String deviceToken; // Phone code for push notifications
  final String? currentLibraryId; // Library they are checked into now
  // ? means it CAN be null (not checked in)

  AppUser({
    required this.uid,
    required this.fullName,
    required this.emailAddress,
    required this.programme,
    required this.institution,
    this.deviceToken = '', // default: empty string
    this.currentLibraryId, // default: null
  });

  // FROM FIREBASE
  factory AppUser.fromFirestore(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      fullName: data['fullName'] ?? '',
      emailAddress: data['emailAddress'] ?? '',
      programme: data['programme'] ?? '',
      institution: data['institution'] ?? '',
      deviceToken: data['deviceToken'] ?? '',
      currentLibraryId: data['currentLibraryId'],
    );
  }

  // TO FIREBASE
  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'emailAddress': emailAddress,
      'programme': programme,
      'institution': institution,
      'deviceToken': deviceToken,
      'currentLibraryId': currentLibraryId,
    };
  }
}
