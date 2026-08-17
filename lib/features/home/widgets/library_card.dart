// ═══════════════════════════════════════════════════
// FILE: lib/features/home/widgets/library_card.dart
//
// PURPOSE: Shows ONE library as a card in the list.
// Contains:
//   - A photo (or placeholder icon if no photo)
//   - Library name and distance from student
//   - A coloured status dot + label (Available / Filling Up / Full)
//   - Seat count (e.g. "20 free / 50 total")
//   - A thin coloured progress bar showing occupancy
//
// This is a WIDGET, not a Screen.
// It is used inside the Home Screen's list.
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/library_model.dart';
import '../../../shared/theme/app_theme.dart';

class LibraryCard extends StatelessWidget {
  // INPUTS this widget needs:
  final LibraryModel library; // the library data to display
  final String distanceLabel; // pre-formatted string, e.g. "1.2 km"
  final VoidCallback onTap; // what happens when the card is tapped
  // VoidCallback = a function that takes no inputs and returns nothing

  const LibraryCard({
    required this.library,
    required this.distanceLabel,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  // Returns a colour based on how full the library is
  Color get _statusColor {
    if (library.occupancyRate < 0.60) return AppColors.heatGreen;
    if (library.occupancyRate < 0.85) return AppColors.heatYellow;
    return AppColors.heatRed;
  }

  // Returns a text label for the status
  String get _statusLabel {
    if (!library.hasSpace) return 'Full';
    if (library.occupancyRate >= 0.85) return 'Almost Full';
    if (library.occupancyRate >= 0.60) return 'Filling Up';
    return 'Available';
  }

  @override
  Widget build(BuildContext context) {
    // GestureDetector detects when the user taps this widget
    return GestureDetector(
      onTap: onTap, // calls the function passed in by the Home Screen

      child: Card(
        // Card = white box with rounded corners and a small shadow.
        // Style comes from cardTheme in app_theme.dart.
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        // EdgeInsets.symmetric(horizontal: 16, vertical: 8) =
        // 16px space on left and right, 8px space on top and bottom
        child: Padding(
          padding: const EdgeInsets.all(16), // space inside the card
          child: Column(
            children: [
              // ── TOP ROW: Photo + Info + Arrow ──────────────
              Row(
                // Row places widgets SIDE BY SIDE (horizontally)
                children: [
                  // PHOTO — or placeholder if no photo URL
                  ClipRRect(
                    // ClipRRect clips its child into a rounded rectangle
                    borderRadius: BorderRadius.circular(12),
                    child: library.photoUrl.isNotEmpty
                        // If we have a URL, load the image from the internet
                        ? CachedNetworkImage(
                            imageUrl: library.photoUrl,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            // BoxFit.cover = fill the space without stretching
                          )
                        // If no URL, show a coloured box with an icon
                        : Container(
                            width: 72,
                            height: 72,
                            color: AppColors.primary.withOpacity(0.1),
                            // .withOpacity(0.1) = 10% opacity = very light blue
                            child: const Icon(
                              Icons.local_library_rounded,
                              color: AppColors.primary,
                              size: 36,
                            ),
                          ),
                  ),

                  const SizedBox(width: 16), // gap between photo and text
                  // INFO COLUMN
                  Expanded(
                    // Expanded fills all remaining horizontal space in the Row.
                    // Without Expanded, the text might overflow the screen.
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Library name
                        Text(
                          library.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1, // only show 1 line
                          overflow: TextOverflow.ellipsis,
                          // ellipsis = adds "..." if text is too long
                        ),

                        const SizedBox(height: 4),

                        // Distance row (location pin icon + distance)
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.textGrey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              distanceLabel, // e.g. "1.2 km"
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Status row: coloured dot + label + seat count
                        Row(
                          children: [
                            // The coloured circle dot
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _statusColor,
                                shape: BoxShape.circle, // makes it a circle
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Status label (Available / Filling Up / Full)
                            Text(
                              _statusLabel,
                              style: TextStyle(
                                color: _statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),

                            const Spacer(),
                            // Spacer() pushes the next widget to the far right

                            // Seat count
                            Text(
                              '${library.freeSeats} / ${library.totalSeats} free',
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Arrow pointing right (hints: tap for more)
                  const Icon(Icons.chevron_right, color: AppColors.textGrey),
                ],
              ),

              const SizedBox(height: 12),

              // ── PROGRESS BAR ───────────────────────────────
              // A thin bar showing occupancy visually.
              // Filled portion matches the occupancy percentage.
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: library.occupancyRate.clamp(0.0, 1.0),
                  // .clamp(0.0, 1.0) ensures value is never below 0 or above 1
                  // Even if data is wrong, the bar stays in bounds.
                  backgroundColor: _statusColor.withOpacity(0.2),
                  // background = light version of the colour (the empty part)
                  valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
                  // AlwaysStoppedAnimation = keeps the colour fixed (not animated)
                  minHeight: 6, // bar is 6 pixels tall
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
