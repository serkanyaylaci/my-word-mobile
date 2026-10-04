import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/achievement_model.dart';
import '../components/weekly_bar_chart.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final allWords = provider.allWords;
    final totalWordsCount = allWords.length;
    final learnedCount = allWords.where((w) => w.isLearned).length;
    final learningCount = allWords.where((w) => w.learningProgress >= 1 && w.learningProgress < 80).length;
    final newCount = allWords.where((w) => w.learningProgress == 0).length;
    final achievements = provider.achievements;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'İstatistikler & Başarılar',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
      ),
      body: ListView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 96.0),
        children: [
          // 4 Metric Highlights
          Row(
            children: [
              Expanded(
                child: _StatMetricCard(
                  title: 'Toplam Kelime',
                  value: '',
                  icon: '📖',
                  color: const Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatMetricCard(
                  title: 'Öğrenilen',
                  value: '',
                  icon: '✅',
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatMetricCard(
                  title: 'Günlük Seri',
                  value: ' gün',
                  icon: '🔥',
                  color: const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatMetricCard(
                  title: 'Toplam Puan',
                  value: '',
                  icon: '⭐',
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 7-day Weekly Bar Chart
          WeeklyBarChart(recentStats: provider.recentStats),

          const SizedBox(height: 16),

          // SRS Stages Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🧠 Öğrenim Durumu Dağılımı',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  _SrsStageRow(
                    title: 'Tamamen Öğrenildi',
                    count: learnedCount,
                    total: totalWordsCount,
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 10),
                  _SrsStageRow(
                    title: 'Öğrenilme Aşamasında',
                    count: learningCount,
                    total: totalWordsCount,
                    color: const Color(0xFF0EA5E9),
                  ),
                  const SizedBox(height: 10),
                  _SrsStageRow(
                    title: 'Yeni / Başlanmadı',
                    count: newCount,
                    total: totalWordsCount,
                    color: const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Achievements Section
          Text(
            '🏆 Rozetler ve Başarılar',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...achievements.map((a) => _AchievementCard(achievement: a)),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StatMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String icon;
  final Color color;

  const _StatMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SrsStageRow extends StatelessWidget {
  final String title;
  final int count;
  final int total;
  final Color color;

  const _SrsStageRow({
    required this.title,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
    final percent = (fraction * 100).toInt();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            Text('$count kelime (%$percent)', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final AchievementModel achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: achievement.isUnlocked
            ? theme.colorScheme.surface
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        elevation: achievement.isUnlocked ? 2 : 0,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? const Color(0xFFFEF3C7)
                      : theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(achievement.icon, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          achievement.title,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (achievement.isUnlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Kazanıldı ✓',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF065F46),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      achievement.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (!achievement.isUnlocked) ...[
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: achievement.maxProgress > 0
                              ? achievement.progress / achievement.maxProgress
                              : 0,
                          minHeight: 5,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ' / ',
                        style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
