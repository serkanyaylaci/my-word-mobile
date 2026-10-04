import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/daily_stats_model.dart';
import '../../services/srs_service.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<DailyStatsModel> recentStats;

  const WeeklyBarChart({super.key, required this.recentStats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labels = DateUtilsHelper.getLast7DaysLabels();
    final keys = DateUtilsHelper.getLast7DaysKeys();

    final dataCounts = keys.map((key) {
      final stat = recentStats.where((s) => s.dateString == key).firstOrNull;
      return stat?.wordsReviewed ?? 0;
    }).toList();

    final totalWeek = dataCounts.fold<int>(0, (sum, count) => sum + count);
    final maxCount = max(dataCounts.fold<int>(10, (currMax, count) => max(currMax, count)), 10);

    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    final surfaceVariant = theme.colorScheme.surfaceContainerHighest;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📊 Son 7 Günlük Çalışma',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Toplam: $totalWeek kelime',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(dataCounts.length, (index) {
                  final count = dataCounts[index];
                  final fraction = (count / maxCount).clamp(0.05, 1.0);
                  final isToday = index == labels.length - 1;

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          count > 0 ? '' : '-',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: count > 0
                                ? primaryColor
                                : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 22,
                          height: 85,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: surfaceVariant.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0.05, end: fraction),
                                duration: Duration(milliseconds: 600 + index * 80),
                                curve: Curves.easeOutCubic,
                                builder: (context, val, child) {
                                  return FractionallySizedBox(
                                    heightFactor: val,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [primaryColor, secondaryColor],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          labels[index],
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday ? primaryColor : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
