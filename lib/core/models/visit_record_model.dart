// ═══════════════════════════════════════════════════
// FILE: lib/core/models/visit_record_model.dart
//
// PURPOSE: Records ONE library visit (check-in/check-out).
// Created when student checks in. Updated when they leave.
// The History screen shows a list of these.
// ═══════════════════════════════════════════════════

class VisitRecord {
  final String recordId; // Unique ID we generate for each visit
  final String userId; // Which student
  final String libraryId; // Which library
  final String libraryName; // Library name AT TIME of visit
  // Stored here so renaming library later
  // does not change old history records
  final DateTime checkInTime; // When they entered (date + time)
  final DateTime? checkOutTime; // When they left. ? means can be null.
  // IS null while still inside the library.

  VisitRecord({
    required this.recordId,
    required this.userId,
    required this.libraryId,
    required this.libraryName,
    required this.checkInTime,
    this.checkOutTime, // optional, starts as null
  });

  // Have they left yet?
  bool get hasCheckedOut => checkOutTime != null;

  // How long did they stay? Only works after checkout.
  // Returns null if still inside.
  Duration? get duration {
    if (checkOutTime == null) return null;
    return checkOutTime!.difference(checkInTime);
    // .difference() calculates the gap between two DateTimes
    // The ! says "I know checkOutTime is not null here"
  }

  // FROM FIREBASE
  factory VisitRecord.fromFirestore(Map<String, dynamic> data, String id) {
    return VisitRecord(
      recordId: id,
      userId: data['userId'] ?? '',
      libraryId: data['libraryId'] ?? '',
      libraryName: data['libraryName'] ?? '',
      checkInTime: DateTime.parse(data['checkInTime']),
      // DateTime.parse() converts "2024-06-15T10:30:00" to a DateTime object
      checkOutTime: data['checkOutTime'] != null
          ? DateTime.parse(data['checkOutTime'])
          : null,
    );
  }

  // TO FIREBASE
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'libraryId': libraryId,
      'libraryName': libraryName,
      'checkInTime': checkInTime.toIso8601String(),
      // toIso8601String() converts DateTime to "2024-06-15T10:30:00.000"
      'checkOutTime': checkOutTime?.toIso8601String(),
      // ?. means: call this only if checkOutTime is not null
    };
  }
}
