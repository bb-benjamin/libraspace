// ═══════════════════════════════════════════════════
// FILE: lib/core/models/library_model.dart
//
// PURPOSE: The blueprint for ONE library in our app.
// Lists every piece of info we store about a library.
// Knows how to read from Firebase and write back to Firebase.
// ═══════════════════════════════════════════════════

class LibraryModel {
  // FIELDS — pieces of information stored for each library.
  // "final" = once created, fields cannot be changed.
  // To update data, we create a NEW object with new values.

  final String libraryId; // Unique ID Firebase assigns, e.g. "xK9mP2..."
  final String title; // Full name, e.g. "Science Library"
  final String shortName; // Short code, e.g. "SCI LIB"
  final int totalSeats; // How many seats exist total, e.g. 50
  final int occupiedSeats; // How many are taken right now, e.g. 30
  final double latitude; // GPS north-south coordinate, e.g. 5.6037
  final double longitude; // GPS east-west coordinate, e.g. -0.1870
  final String photoUrl; // Web link to a photo of this library
  final String qrImageUrl; // Web link to this library's QR code image
  final List<String> checkedInUsers; // IDs of everyone currently inside

  // CONSTRUCTOR — how you CREATE a LibraryModel object.
  // You give it all values, it packages them into one object.
  // "required" = you MUST provide this value. No leaving blank.
  LibraryModel({
    required this.libraryId,
    required this.title,
    required this.shortName,
    required this.totalSeats,
    required this.occupiedSeats,
    required this.latitude,
    required this.longitude,
    required this.photoUrl,
    required this.qrImageUrl,
    required this.checkedInUsers,
  });

  // GETTERS — values CALCULATED automatically. Not stored in Firebase.
  // Use them like fields: library.freeSeats (no parentheses needed).

  // Free seats = total minus occupied. Example: 50 - 30 = 20
  int get freeSeats => totalSeats - occupiedSeats;

  // What fraction is occupied? 0.0 = empty. 1.0 = completely full.
  // Example: 30 / 50 = 0.60 = 60% full.
  // THE HEATMAP uses this: below 0.60 → green, 0.60-0.85 → yellow, above 0.85 → red
  double get occupancyRate {
    if (totalSeats == 0) return 0.0; // never divide by zero!
    return occupiedSeats / totalSeats;
  }

  // Is there at least one free seat?
  bool get hasSpace => freeSeats > 0;

  // FROM FIREBASE — reads raw Firebase data and creates a LibraryModel.
  // Firebase sends data as a Map (dictionary): {'title': 'Science Library', ...}
  // "factory" = a special constructor for creating objects.
  // ?? means "if this value is missing from Firebase, use this default instead"
  factory LibraryModel.fromFirestore(Map<String, dynamic> data, String id) {
    return LibraryModel(
      libraryId: id,
      title: data['title'] ?? '',
      shortName: data['shortName'] ?? '',
      totalSeats: (data['totalSeats'] ?? 0) as int,
      occupiedSeats: (data['occupiedSeats'] ?? 0) as int,
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      photoUrl: data['photoUrl'] ?? '',
      qrImageUrl: data['qrImageUrl'] ?? '',
      checkedInUsers: List<String>.from(data['checkedInUsers'] ?? []),
    );
  }

  // TO FIREBASE — converts LibraryModel back into a Map to save to Firebase.
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'shortName': shortName,
      'totalSeats': totalSeats,
      'occupiedSeats': occupiedSeats,
      'latitude': latitude,
      'longitude': longitude,
      'photoUrl': photoUrl,
      'qrImageUrl': qrImageUrl,
      'checkedInUsers': checkedInUsers,
    };
  }
}
