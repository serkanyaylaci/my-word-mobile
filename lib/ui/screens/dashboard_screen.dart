import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../components/progress_ring.dart';

class DashboardScreen extends StatelessWidget {
  final Function(String?) onNavigateToFlashcards;
  final VoidCallback? onNavigateToQuiz;
  final VoidCallback? onNavigateToSpelling;
  final VoidCallback? onNavigateToListening;
  final VoidCallback? onNavigateToMatchGame;
  final VoidCallback? onNavigateToSpeedGame;
  final VoidCallback? onNavigateToWordManager;
  final VoidCallback onNavigateToCategories;

  const DashboardScreen({
    super.key,
    required this.onNavigateToFlashcards,
    this.onNavigateToQuiz,
    this.onNavigateToSpelling,
    this.onNavigateToListening,
    this.onNavigateToMatchGame,
    this.onNavigateToSpeedGame,
    this.onNavigateToWordManager,
    required this.onNavigateToCategories,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();

    final allWords = provider.allWords;
    final randomWord = allWords.isNotEmpty ? allWords.first : null;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu_book, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kelime Kartları',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 21,
                      ),
                    ),
                    Text(
                      'Merhaba, ${provider.username} 👋',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Streak Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    '${provider.streakDays} Gün',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onPrimaryContainer,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 96.0),
        children: [
          // Daily Goal Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🎯 Günlük Hedef',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider.todayReviewedCount >= provider.dailyGoal
                              ? 'Tebrikler! Günlük hedefini tamamladın 🎉'
                              : 'Hedefine ulaşmak için ${(provider.dailyGoal - provider.todayReviewedCount).clamp(0, provider.dailyGoal)} kelime kaldı.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.tonal(
                          onPressed: () {
                            provider.setupFlashcards();
                            onNavigateToFlashcards(null);
                          },
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Hemen Başla ▶', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ProgressRing(
                    progress: provider.dailyGoal > 0 ? provider.todayReviewedCount / provider.dailyGoal : 0,
                    current: provider.todayReviewedCount,
                    target: provider.dailyGoal,
                    size: 86,
                    strokeWidth: 8,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Word of the Day Card
          if (randomWord != null) ...[
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: theme.colorScheme.primaryContainer.withOpacity(0.5),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '💡 Günün Kelimesi',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => provider.ttsService.speak(randomWord.english),
                          icon: Icon(Icons.volume_up, color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      randomWord.english,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '🇹🇷 ${randomWord.turkish}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (randomWord.exampleSentence.isNotEmpty) ...[
                       const SizedBox(height: 6),
                       Text(
                        '"${randomWord.exampleSentence}"',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Categories Overview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📌 Kategoriler',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: onNavigateToCategories,
                child: const Text('Tümünü Gör', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),

          const SizedBox(height: 6),

          ...provider.categoryProgressList.take(3).map((catProgress) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 1,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    provider.setupFlashcards(categoryName: catProgress.category.name);
                    onNavigateToFlashcards(catProgress.category.name);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                catProgress.category.name,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${catProgress.learnedWords} / ${catProgress.totalWords} kelime öğrenildi',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: catProgress.totalWords > 0
                                      ? catProgress.learnedWords / catProgress.totalWords
                                      : 0,
                                  minHeight: 6,
                                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.arrow_forward,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}


