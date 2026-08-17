// ═══════════════════════════════════════════════════
// FILE: lib/features/home/screens/home_screen.dart
//
// PURPOSE: The main screen after login.
// Shows a scrollable list of library cards.
// Has a sort button (distance / most space) in the top bar.
// Has a filter chip (available only) below the top bar.
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../providers/library_provider.dart';
import '../widgets/library_card.dart';
import 'library_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── TOP BAR ─────────────────────────────────────
      appBar: AppBar(
        title: const Text('LibraSpace'),
        actions: [
          // The sort toggle button — shows different icon based on current mode
          Consumer<LibraryProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(
                  provider.sortMode == SortMode.byDistance
                      ? Icons
                            .near_me_outlined // compass icon = by distance
                      : Icons.event_seat_outlined, // seat icon = by most space
                ),
                tooltip: 'Toggle sort: distance or most space',
                onPressed: () => provider.toggleSortMode(),
              );
            },
          ),

          // NEW: Refresh button
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              // Show a quick snackbar to confirm the refresh
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshing library data...'),
                  duration: Duration(seconds: 1),
                ),
              );
              // The Firebase stream refreshes automatically,
              // so this just shows a visual confirmation to the student.
              // The data is already live — this is a UX reassurance.
            },
          ),
        ],
      ),

      // ── BODY ────────────────────────────────────────
      body: Consumer<LibraryProvider>(
        // Consumer watches LibraryProvider and rebuilds when it changes
        builder: (context, provider, child) {
          // Show loading spinner while Firebase data is loading
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error message if something went wrong
          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      size: 64,
                      color: AppColors.textGrey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
            );
          }

          // Get the processed library list (filtered and sorted)
          final libraries = provider.displayLibraries;

          return Column(
            children: [
              // ── FILTER BAR ─────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: AppColors.cardWhite,
                child: Row(
                  children: [
                    // Shows what the current sort is
                    Text(
                      provider.sortMode == SortMode.byDistance
                          ? '📍 Sorted by distance'
                          : '💺 Sorted by most space',
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    // FilterChip = a small pill-shaped toggle button
                    FilterChip(
                      label: const Text('Available only'),
                      selected: provider.showOnlyAvailable,
                      onSelected: (_) => provider.toggleAvailableFilter(),
                      selectedColor: AppColors.primary.withOpacity(0.15),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: provider.showOnlyAvailable
                            ? AppColors.primary
                            : AppColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Library count
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${libraries.length} ${libraries.length == 1 ? "library" : "libraries"} found',
                    // Shows "1 library" or "3 libraries" (correct grammar)
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              // ── LIBRARY LIST ────────────────────────────
              Expanded(
                // Expanded fills all remaining space on the screen
                child: libraries.isEmpty
                    ? const Center(
                        child: Text(
                          'No libraries found.\nTry removing the filter.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                      )
                    : ListView.builder(
                        // ListView.builder is efficient — only builds cards
                        // that are currently VISIBLE on screen.
                        // If you have 100 libraries, it only builds ~8 at a time.
                        itemCount: libraries.length,
                        itemBuilder: (context, index) {
                          final library = libraries[index];
                          return LibraryCard(
                            library: library,
                            distanceLabel: provider.getDistanceLabel(library),
                            onTap: () {
                              // Navigate to the detail screen for this library
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      LibraryDetailScreen(library: library),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
