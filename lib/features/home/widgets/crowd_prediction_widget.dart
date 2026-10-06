// ═══════════════════════════════════════════════════
// FILE: lib/features/home/widgets/crowd_prediction_widget.dart
//
// PURPOSE: YOUR SECOND UNIQUE ADDED FEATURE.
//
// Shows a "Best Time to Visit" panel for any library.
// Displays an hourly bar chart showing typical busyness
// for the current day of the week.
//
// This moves LibraSpace from REACTIVE (seats are full NOW)
// to PREDICTIVE (seats are usually free at THIS time).
//
// Your boss's app has nothing like this.
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/services/firebase_service.dart';
import '../../../shared/theme/app_theme.dart';

class CrowdPredictionWidget extends StatefulWidget {
  final String libraryId;

  const CrowdPredictionWidget({required this.libraryId, Key? key})
    : super(key: key);

  @override
  State<CrowdPredictionWidget> createState() => _CrowdPredictionWidgetState();
}

class _CrowdPredictionWidgetState extends State<CrowdPredictionWidget> {
  final FirebaseService _service = FirebaseService();

  Map<int, int> _hourlyData = {};
  // Map<int, int> = dictionary where key=hour (0-23), value=visit count

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final int today = DateTime.now().weekday;

      final data = await _service.getCrowdData(
        libraryId: widget.libraryId,
        dayOfWeek: today,
      );

      if (!mounted) return;

      setState(() {
        _hourlyData = data;
        _loading = false;
      });
    } catch (e) {
      debugPrint('CROWD DEBUG ERROR: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // Convert a day number to a short name
  String _dayName(int weekday) {
    const names = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[weekday];
  }

  // Convert a 24-hour number to 12-hour AM/PM format
  // e.g. 14 → "2 PM", 9 → "9 AM"
  String _hourLabel(int h) {
    if (h == 0) return '12 AM';
    if (h == 12) return '12 PM';
    return h < 12 ? '$h AM' : '${h - 12} PM';
  }

  // Returns a recommendation based on current hour's busyness
  String _getRecommendation(int currentHour, Map<int, int> data) {
    if (data.isEmpty) return 'Not enough data yet';

    // Find the maximum visit count across all hours
    final int maxVisits = data.values.reduce((a, b) => a > b ? a : b);
    if (maxVisits == 0) return 'Usually quiet at this time';

    final int nowVisits = data[currentHour] ?? 0;
    // ?? 0 = if there is no data for this hour, assume 0 visits

    // Calculate what fraction of the max this hour is
    final double ratio = nowVisits / maxVisits;

    if (ratio < 0.3) return '🟢 Usually quiet — great time to visit!';
    if (ratio < 0.7) return '🟡 Moderate busyness — some seats expected';
    return '🔴 Usually busy — consider going earlier or later';
  }

  int? _getBestHour(Map<int, int> data) {
    if (data.isEmpty) return null;

    int? bestHour;
    int? lowestVisits;

    for (int hour = 6; hour <= 22; hour++) {
      if (!data.containsKey(hour)) continue;

      final int visits = data[hour]!;

      if (lowestVisits == null || visits < lowestVisits) {
        lowestVisits = visits;
        bestHour = hour;
      }
    }

    return bestHour;
  }

  @override
  Widget build(BuildContext context) {
    final int today = DateTime.now().weekday;
    final int currentHour = DateTime.now().hour;
    final int? bestHour = _getBestHour(_hourlyData);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ─────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.query_stats, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Crowd Prediction — ${_dayName(today)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Historical insight',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          const Text(
            'Based on historical student check-ins for this day.',
            style: TextStyle(fontSize: 11, color: AppColors.textGrey),
          ),

          const SizedBox(height: 12),
          // ── LOADING STATE ───────────────────────────────
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ),
            )
          // ── NO DATA YET ─────────────────────────────────
          else if (_hourlyData.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  '📊 Prediction data builds up as students use the app.\n'
                  'Check back after a few days of use!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
              ),
            )
          // ── PREDICTION DATA ─────────────────────────────
          else ...[
            // Recommendation for RIGHT NOW
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getRecommendation(currentHour, _hourlyData),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16),

            if (bestHour != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Best time today',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${_hourLabel(bestHour)} – ${_hourLabel(bestHour + 1)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Historically one of the quieter recorded times to visit.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── HOURLY BAR CHART ──────────────────────────
            // Shows bars for typical busy hours during the day.
            // We only show daytime hours: 6 AM to 10 PM (6 to 22).
            const Text(
              'Typical busyness by hour:',
              style: TextStyle(fontSize: 12, color: AppColors.textGrey),
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 80,
              // Fixed height container for the chart
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                // CrossAxisAlignment.end = bars grow from the BOTTOM up
                children: List.generate(17, (index) {
                  // Generate 17 bars: hours 6 through 22 (6AM to 10PM)
                  final int hour = index + 6;

                  // Find the maximum visits across all shown hours
                  // so we can scale the bars proportionally
                  final int maxCount = _hourlyData.values.fold(
                    1,
                    (max, v) => v > max ? v : max,
                  );
                  // fold starts with 1 (not 0) to avoid division by zero

                  final int count = _hourlyData[hour] ?? 0;
                  // How many visits happened at this hour today
                  // ?? 0 = assume 0 if no data for this hour

                  final double heightFraction = count / maxCount;
                  // What fraction of the tallest bar this bar should be
                  // e.g. if max is 20 and this hour had 10 visits → 0.5

                  // Highlight the CURRENT hour with a darker colour
                  final bool isCurrent = hour == currentHour;

                  return Expanded(
                    // Expanded = each bar takes equal horizontal space
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // The bar itself
                          Container(
                            height: (heightFraction * 60).clamp(2.0, 60.0),
                            // Multiply by 60 to get pixels. Min 2px (always visible).
                            // .clamp(2.0, 60.0) = never below 2, never above 60.
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? AppColors.primary
                                  // Current hour = solid primary blue
                                  : AppColors.primary.withValues(alpha: 0.25),
                              // Other hours = light blue
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(3),
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Hour label below the bar (every 4 hours to avoid crowding)
                          Text(
                            hour % 4 == 0 ? _hourLabel(hour) : '',
                            // Only show label for hours 6, 10, 14, 18, 22
                            style: TextStyle(
                              fontSize: 8,
                              color: isCurrent
                                  ? AppColors.primary
                                  : AppColors.textGrey,
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 8),

            // Caption explaining the chart
            const Text(
              'Higher bar = more students usually visit at that hour',
              style: TextStyle(fontSize: 11, color: AppColors.textGrey),
            ),
          ],
        ],
      ),
    );
  }
}
