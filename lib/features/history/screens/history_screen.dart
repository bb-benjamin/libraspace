// ═══════════════════════════════════════════════════
// FILE: lib/features/history/screens/history_screen.dart
//
// PURPOSE: Shows the logged-in student's complete visit history.
// Every library check-in appears here as a card.
// Shows: library name, date and time, duration of stay.
// Uses a StreamBuilder that rebuilds automatically
// whenever a new visit is added to Firebase.
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// intl package lets us format dates nicely, e.g. "Mon, Jun 15 · 10:30 AM"
import 'package:provider/provider.dart';
import '../../../core/models/visit_record_model.dart';
import '../../../core/services/firebase_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  final FirebaseService _service = FirebaseService();

  // Formats a DateTime into a readable string.
  // Example: Mon, Jun 15 · 10:30 AM
  String _formatDate(DateTime dt) {
    return DateFormat('EEE, MMM d · h:mm a').format(dt);
    // 'EEE' = short day name (Mon, Tue, Wed...)
    // 'MMM d' = short month + day number (Jun 15)
    // 'h:mm a' = 12-hour time with AM/PM (10:30 AM)
  }

  // Formats a Duration into a readable string.
  // Example: "1h 23m" or "45m" or "Currently inside"
  String _formatDuration(Duration? d) {
    if (d == null) return 'Currently inside';
    // null duration means they are still checked in (no check-out time)

    final int hours = d.inHours;
    final int minutes = d.inMinutes.remainder(60);
    // .inMinutes gives total minutes. .remainder(60) gives the minutes
    // that are left over after removing the full hours.
    // Example: 83 minutes → 1 hour 23 minutes
    //   d.inHours = 1, d.inMinutes.remainder(60) = 23

    if (hours == 0) return '${minutes}m'; // e.g. "45m"
    return '${hours}h ${minutes}m'; // e.g. "1h 23m"
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user's ID so we only load THEIR history
    final String userId = context.read<AuthProvider>().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Visit History')),

      // ── STREAM BUILDER ────────────────────────────────────
      // StreamBuilder is a special Flutter widget that:
      //   1. Listens to a Stream
      //   2. Rebuilds the UI every time the Stream emits new data
      //
      // We use it here to listen to the user's visit history Stream.
      // When a new visit record is saved to Firebase (after a check-in),
      // this screen automatically shows the new record without refreshing.
      body: StreamBuilder<List<VisitRecord>>(
        stream: _service.watchUserHistory(userId),

        // builder runs every time the stream emits new data.
        // snapshot = the latest data from the stream.
        builder: (context, snapshot) {
          // While waiting for the very first data to arrive
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If the stream produced an error
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Could not load history',
                style: TextStyle(color: AppColors.textGrey),
              ),
            );
          }

          // Get the list of records (or empty list if null)
          final List<VisitRecord> records = snapshot.data ?? [];

          // ── EMPTY STATE ──────────────────────────────────
          // Show a friendly message when no visits yet
          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.history, size: 72, color: AppColors.textGrey),
                  SizedBox(height: 16),
                  Text(
                    'No visits yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Check into a library to see\nyour history here',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                ],
              ),
            );
          }

          // ── VISIT LIST ───────────────────────────────────
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final VisitRecord record = records[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Library icon in a coloured circle
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_library_rounded,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Library name and date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.libraryName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(record.checkInTime),
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Duration badge on the right
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          // Green badge if checked out, yellow if still inside
                          color: record.hasCheckedOut
                              ? AppColors.secondary.withValues(alpha: 0.1)
                              : AppColors.heatYellow.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _formatDuration(record.duration),
                          style: TextStyle(
                            color: record.hasCheckedOut
                                ? AppColors.secondary
                                : AppColors.heatYellow,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
