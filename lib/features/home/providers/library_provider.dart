// ═══════════════════════════════════════════════════
// FILE: lib/features/home/providers/library_provider.dart
//
// PURPOSE: Manages all library-related data for the app.
// It does 4 things:
//   1. Listens to Firebase for real-time library updates
//   2. Gets the student's GPS location
//   3. Sorts libraries by distance (using the Haversine formula)
//      OR by most available seats — student can toggle this
//   4. Filters to only show libraries with free seats if toggled
//
// The Home Screen and Heatmap Screen both read from this provider.
// ═══════════════════════════════════════════════════
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math' as math;
// dart:math gives us mathematical functions:
// math.sin, math.cos, math.sqrt, math.atan2, math.pi
// We need these for the Haversine distance formula.

import '../../../core/models/library_model.dart';
import '../../../core/services/firebase_service.dart';

// SortMode = the two ways the student can sort the library list.
// An enum is a fixed list of allowed values.
enum SortMode {
  byDistance, // sort by nearest library first
  byMostSpace, // sort by most free seats first
}

class LibraryProvider extends ChangeNotifier {
  final FirebaseService _service = FirebaseService();

  StreamSubscription<List<LibraryModel>>? _librarySubscription;

  // PRIVATE STATE
  List<LibraryModel> _allLibraries = []; // raw list from Firebase (unsorted)
  Position? _userPosition; // student's GPS location, null until known
  SortMode _sortMode = SortMode.byDistance; // start sorted by distance
  bool _showOnlyAvailable = false; // filter toggle (off by default)
  bool _isLoading = true; // true until first Firebase data arrives
  String? _errorMessage; // any error message, or null

  // PUBLIC GETTERS — screens read these
  SortMode get sortMode => _sortMode;
  bool get showOnlyAvailable => _showOnlyAvailable;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Position? get userPosition => _userPosition;

  // ── displayLibraries ────────────────────────────────
  // This is what the Home Screen and Heatmap ACTUALLY display.
  // Every time notifyListeners() is called, screens re-read this getter.
  // It takes the raw list, applies filters, then sorts.
  List<LibraryModel> get displayLibraries {
    List<LibraryModel> result = List.from(_allLibraries);
    // List.from() makes a COPY so we don't change the original

    // STEP 1: Filter — if toggle is ON, keep only libraries with space
    if (_showOnlyAvailable) {
      result = result.where((lib) => lib.hasSpace).toList();
      // .where() keeps only items where the condition is true
      // lib.hasSpace is our getter: freeSeats > 0
    }

    // STEP 2: Sort the filtered list
    if (_sortMode == SortMode.byDistance && _userPosition != null) {
      result.sort((a, b) {
        // .sort() rearranges the list using a comparison function.
        // For each pair (a, b): negative = a comes first, positive = b comes first
        final double distA = _haversineKm(a.latitude, a.longitude);
        final double distB = _haversineKm(b.latitude, b.longitude);
        return distA.compareTo(distB); // smallest distance first
      });
    } else if (_sortMode == SortMode.byMostSpace) {
      result.sort((a, b) => b.freeSeats.compareTo(a.freeSeats));
      // b.compareTo(a) instead of a.compareTo(b) gives DESCENDING order
      // (most free seats appears at the top)
    }

    return result;
  }

  // ── startListening() ────────────────────────────────
  // Called ONCE from MainShell when the app first loads.
  // Kicks off both Firebase listening and GPS location fetching.
  // ── SMART RECOMMENDATION ───────────────────────────
  // Chooses the best library based on:
  // 1. It must have free seats
  // 2. More free seats is better
  // 3. Shorter distance is better
  LibraryModel? get recommendedLibrary {
    // Keep only libraries that still have space
    final availableLibraries = _allLibraries
        .where((library) => library.hasSpace)
        .toList();

    if (availableLibraries.isEmpty) {
      return null;
    }

    // If GPS is not available yet, simply recommend
    // the library with the most free seats.
    if (_userPosition == null) {
      availableLibraries.sort((a, b) => b.freeSeats.compareTo(a.freeSeats));

      return availableLibraries.first;
    }

    LibraryModel bestLibrary = availableLibraries.first;
    double bestScore = double.negativeInfinity;

    for (final library in availableLibraries) {
      final double distanceKm = _haversineKm(
        library.latitude,
        library.longitude,
      );

      // Availability percentage:
      // Example: 80 free out of 100 = 0.80
      final double availabilityRatio = library.totalSeats > 0
          ? library.freeSeats / library.totalSeats
          : 0.0;

      // Distance score:
      // Closer libraries get a higher value.
      final double distanceScore = 1 / (1 + distanceKm);

      // Final score:
      // Availability matters slightly more than distance.
      final double score = (availabilityRatio * 0.65) + (distanceScore * 0.35);

      if (score > bestScore) {
        bestScore = score;
        bestLibrary = library;
      }
    }

    return bestLibrary;
  }

  void startListening() {
    _fetchGpsLocation();
    _listenToLibraries();
  }

  void _listenToLibraries() {
    // Cancel any old listener before starting a new one.
    _librarySubscription?.cancel();

    _librarySubscription = _service.watchAllLibraries().listen(
      (List<LibraryModel> freshList) {
        _allLibraries = freshList;

        // Clear any old permission/network error after data loads again.
        _errorMessage = null;

        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _errorMessage = 'Could not load libraries. Check your connection.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _librarySubscription?.cancel();
    _librarySubscription = null;
  }

  Future<void> _fetchGpsLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _userPosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
          ),
        ).timeout(const Duration(seconds: 5));

        notifyListeners();
      }
    } catch (e) {
      debugPrint('LIBRASPACE GPS ERROR: $e');

      // DEBUG/EMULATOR FALLBACK ONLY.
      // This is never used in a release build.
      if (kDebugMode) {
        _userPosition = Position(
          latitude: 6.67450,
          longitude: -1.57120,
          timestamp: DateTime.now(),
          accuracy: 5.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );

        debugPrint(
          'LIBRASPACE DEBUG: Using KNUST fallback location 6.67450, -1.57120',
        );

        notifyListeners();
      }
    }
  }

  // ── Toggle actions — called when student taps buttons ──

  void toggleSortMode() {
    _sortMode = _sortMode == SortMode.byDistance
        ? SortMode.byMostSpace
        : SortMode.byDistance;
    notifyListeners();
  }

  void toggleAvailableFilter() {
    _showOnlyAvailable = !_showOnlyAvailable;
    notifyListeners();
  }

  // ── THE HAVERSINE FORMULA ────────────────────────────
  //
  // This calculates the REAL distance between two GPS points.
  //
  // WHY NOT just subtract coordinates?
  // GPS coordinates are angles on a SPHERE (the Earth).
  // The Earth curves. A degree of longitude near the equator
  // is much wider than near the poles.
  // Simple subtraction gives completely wrong distances.
  //
  // The Haversine formula accounts for Earth's spherical shape.
  // It is used in Google Maps, aviation, and navigation systems.
  // Returns the distance in kilometres.
  //
  // The formula uses trigonometry (sin, cos, atan2) from dart:math.
  // You do not need to memorise it — just know WHY we use it.
  double _haversineKm(double targetLat, double targetLon) {
    if (_userPosition == null) return double.infinity;
    // double.infinity = "infinitely far" → goes to the end of sorted list

    const double earthRadiusKm = 6371.0; // Earth's average radius in km

    // Convert degrees to radians
    // Math functions (sin, cos) work in radians, not degrees.
    // Conversion: radians = degrees × π / 180
    final double lat1 = _userPosition!.latitude * math.pi / 180;
    final double lat2 = targetLat * math.pi / 180;
    final double dLat = (targetLat - _userPosition!.latitude) * math.pi / 180;
    final double dLon = (targetLon - _userPosition!.longitude) * math.pi / 180;

    // The Haversine calculation:
    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c; // distance in km
  }

  // Returns a nicely formatted distance string for display on cards.
  // e.g. "350 m" if under 1km, or "1.2 km" if 1km or more.
  // "--" if location is not yet known.
  String getDistanceLabel(LibraryModel library) {
    if (_userPosition == null) return '--';
    final double km = _haversineKm(library.latitude, library.longitude);
    if (km < 1.0) {
      // Under 1km — show in metres
      return '${(km * 1000).toStringAsFixed(0)} m';
      // .toStringAsFixed(0) = no decimal places
    }
    return '${km.toStringAsFixed(1)} km';
    // .toStringAsFixed(1) = one decimal place, e.g. "1.2 km"
  }
}
