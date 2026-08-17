// ═══════════════════════════════════════════════════
// FILE: lib/features/heatmap/screens/heatmap_screen.dart
//
// PURPOSE: YOUR FIRST UNIQUE ADDED FEATURE.
//
// Shows ALL libraries as colour-coded animated progress bars.
// Sorted from most full (red at top) to most empty (green at bottom).
// Updates in real time from Firebase — same stream as the Home Screen.
//
// WHY THIS IS BETTER THAN A LIST:
// The Home Screen shows numbers: "30 occupied, 20 free."
// Numbers require reading and calculating.
// The Heatmap shows COLOUR and BAR LENGTH.
// The human brain processes visual patterns in milliseconds.
// A student glances at this screen and immediately knows
// exactly which library to go to — without reading a single number.
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../../core/models/library_model.dart';
import '../../../features/home/providers/library_provider.dart';
import '../../../shared/theme/app_theme.dart';

class HeatmapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Heatmap')),

      body: Consumer<LibraryProvider>(
        builder: (context, provider, child) {
          // Show spinner while loading
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading live library data...',
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                ],
              ),
            );
          }

          final List<LibraryModel> libraries = provider.displayLibraries;

          if (libraries.isEmpty) {
            return const Center(
              child: Text(
                'No libraries found.',
                style: TextStyle(color: AppColors.textGrey),
              ),
            );
          }

          // Sort for heatmap: most occupied FIRST (red at top, green at bottom)
          // This is different from the Home Screen which sorts by distance.
          // On the Heatmap, it makes sense to see the busiest libraries first
          // so students know which ones to AVOID.
          final List<LibraryModel> sortedByOccupancy = List.from(libraries)
            ..sort((a, b) => b.occupancyRate.compareTo(a.occupancyRate));
          // List.from() makes a copy so we do not change the original list.
          // ..sort() is the cascade operator — calls sort ON the new list.
          // b.compareTo(a) = descending (highest occupancy first).

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── COLOUR LEGEND ─────────────────────────────
                // Explains what each colour means.
                // Always show this so the screen is self-explanatory.
                _ColourLegend(),
                const SizedBox(height: 16),

                // ── SUMMARY CARDS ─────────────────────────────
                // Two cards: "X libraries have space" and "X are full"
                _SummaryRow(libraries: libraries),
                const SizedBox(height: 20),

                // ── SECTION HEADING ───────────────────────────
                const Text(
                  'All Libraries',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sorted by current occupancy — most full at top',
                      style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                    ),
                    Text(
                      '${libraries.length} total',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── THE HEATMAP BARS ──────────────────────────
                // One _HeatmapBar widget per library.
                // "..." is the spread operator — it inserts a list of widgets
                // directly into the Column's children list.
                ...sortedByOccupancy
                    .map((lib) => _HeatmapBar(library: lib))
                    .toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// WIDGET: _ColourLegend
// Shows the three colours and what they mean.
// ══════════════════════════════════════════════════════
class _ColourLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
            // Offset(0, 2) = shadow goes 2 pixels DOWN
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Colour Guide',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _LegendItem(
                color: AppColors.heatGreen,
                label: 'Available',
                sublabel: 'Under 60% full',
              ),
              _LegendItem(
                color: AppColors.heatYellow,
                label: 'Filling Up',
                sublabel: '60 – 85% full',
              ),
              _LegendItem(
                color: AppColors.heatRed,
                label: 'Almost Full',
                sublabel: 'Over 85% full',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// One item in the legend (coloured square + label + sublabel)
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String sublabel;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Coloured square
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        Text(
          sublabel,
          style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════
// WIDGET: _SummaryRow
// Shows 2 summary cards: "X have space" and "X full"
// ══════════════════════════════════════════════════════
class _SummaryRow extends StatelessWidget {
  final List<LibraryModel> libraries;
  const _SummaryRow({required this.libraries});

  @override
  Widget build(BuildContext context) {
    // Count how many libraries have space vs are full
    final int withSpace = libraries.where((l) => l.hasSpace).length;
    // .where() keeps only items matching the condition
    // .length = how many items are in the resulting list
    final int full = libraries.length - withSpace;

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.check_circle_outline,
            count: withSpace,
            label: 'Have Space',
            color: AppColors.heatGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            icon: Icons.cancel_outlined,
            count: full,
            label: 'Full',
            color: AppColors.heatRed,
          ),
        ),
      ],
    );
  }
}

// One summary card (icon + big number + label)
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// WIDGET: _HeatmapBar
// Shows ONE library as a coloured animated progress bar.
// This is the main visual element of the Heatmap screen.
// ══════════════════════════════════════════════════════
class _HeatmapBar extends StatefulWidget {
  final LibraryModel library;
  const _HeatmapBar({required this.library});

  @override
  State<_HeatmapBar> createState() => _HeatmapBarState();
}

class _HeatmapBarState extends State<_HeatmapBar> {
  Color get _barColor {
    if (widget.library.occupancyRate < 0.60) return AppColors.heatGreen;
    if (widget.library.occupancyRate < 0.85) return AppColors.heatYellow;
    return AppColors.heatRed;
  }

  @override
  Widget build(BuildContext context) {
    final String pct =
        '${(widget.library.occupancyRate * 100).toStringAsFixed(0)}%';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.library.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _barColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$pct full',
                  style: TextStyle(
                    color: _barColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            lineHeight: 20,
            percent: widget.library.occupancyRate.clamp(0.0, 1.0),
            progressColor: _barColor,
            backgroundColor: _barColor.withValues(alpha: 0.15),
            barRadius: const Radius.circular(8),
            padding: EdgeInsets.zero,
            animation: true,
            animationDuration: 1500,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.library.freeSeats} seats free',
                style: TextStyle(
                  color: _barColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              Text(
                '${widget.library.occupiedSeats} of ${widget.library.totalSeats} occupied',
                style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
