// ═══════════════════════════════════════════════════
// FILE: lib/features/home/screens/library_detail_screen.dart
//
// PURPOSE: Full details for one selected library.
// Shows: photo, name, total/occupied/free seats,
// a large progress bar, and the QR check-in button.
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/models/library_model.dart';
import '../../../shared/theme/app_theme.dart';
import 'qr_scanner_screen.dart';
import '../widgets/announcement_banner.dart';
import '../widgets/crowd_prediction_widget.dart';

class LibraryDetailScreen extends StatelessWidget {
  // We receive the selected library from the Home Screen
  final LibraryModel library;
  const LibraryDetailScreen({required this.library, Key? key})
    : super(key: key);

  Color get _color {
    if (library.occupancyRate < 0.60) return AppColors.heatGreen;
    if (library.occupancyRate < 0.85) return AppColors.heatYellow;
    return AppColors.heatRed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(library.shortName)),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── PHOTO AREA ─────────────────────────────────
            Container(
              height: 200,
              width: double.infinity,
              color: AppColors.primary.withValues(alpha: 0.1),
              child: library.photoUrl.isNotEmpty
                  ? Image.network(library.photoUrl, fit: BoxFit.cover)
                  : const Center(
                      child: Icon(
                        Icons.local_library_rounded,
                        size: 80,
                        color: AppColors.primary,
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Library full name
                  Text(
                    library.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── THREE STAT BOXES ────────────────────────
                  // Total Seats | Occupied | Free Seats
                  Row(
                    children: [
                      _StatBox(
                        label: 'Total Seats',
                        value: '${library.totalSeats}',
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      _StatBox(
                        label: 'Occupied',
                        value: '${library.occupiedSeats}',
                        color: AppColors.heatRed,
                      ),
                      const SizedBox(width: 12),
                      _StatBox(
                        label: 'Free Seats',
                        value: '${library.freeSeats}',
                        color: AppColors.heatGreen,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── LARGE PROGRESS BAR ──────────────────────
                  Text(
                    '${(library.occupancyRate * 100).toStringAsFixed(0)}% occupied',
                    style: TextStyle(
                      color: _color,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: library.occupancyRate.clamp(0.0, 1.0),
                      backgroundColor: _color.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(_color),
                      minHeight: 16, // taller bar = more visible
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── QR CHECK-IN BUTTON ──────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan QR Code to Check In'),
                      // Button is DISABLED (grayed out) when library is full
                      onPressed: library.hasSpace
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QrScannerScreen(
                                    libraryId: library.libraryId,
                                    libraryName: library.title,
                                  ),
                                ),
                              );
                            }
                          : null,
                      // null = button disabled. Flutter grays it out automatically.
                    ),
                  ),

                  // Show "library is full" message when disabled
                  const SizedBox(height: 8),

                  // ── LIVE ANNOUNCEMENTS ──────────────────────
                  // Real-time notices from library staff
                  AnnouncementBanner(libraryId: library.libraryId),
                  const SizedBox(height: 8),

                  // ── CROWD PREDICTION PANEL ──────────────────
                  // YOUR SECOND UNIQUE FEATURE
                  // Shows typical busyness by hour for today.
                  CrowdPredictionWidget(libraryId: library.libraryId),

                  const SizedBox(height: 16),
                  if (!library.hasSpace) ...[
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'This library is currently full.',
                        style: TextStyle(
                          color: AppColors.heatRed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  // The "..." spread operator inserts a list of widgets inline.
                  // "if (!library.hasSpace) [...]" only adds these widgets when full.
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── HELPER WIDGET: Stat Box ──────────────────────────────
// A small coloured box showing one number (Total/Occupied/Free).
// We write it once and use it three times in a row above.
class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
