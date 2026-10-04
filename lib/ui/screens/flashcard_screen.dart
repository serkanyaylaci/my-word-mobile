import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../services/srs_service.dart';
import '../components/flip_card_3d.dart';

class FlashcardScreen extends StatelessWidget {
  final VoidCallback onNavigateBack;

  const FlashcardScreen({super.key, required this.onNavigateBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final words = provider.flashcardWords;
    final currentIndex = provider.currentFlashcardIndex;
    final currentWord = words.isNotEmpty && currentIndex < words.length ? words[currentIndex] : null;

    final progressFraction = words.isNotEmpty ? (currentIndex + 1) / words.length : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flash Kartlar',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 21,
              ),
            ),
            if (words.isNotEmpty)
              Text(
                ' /  kelime',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
          ],
        ),
        leading: IconButton(
          onPressed: () {
            provider.stopAutoPlay();
            onNavigateBack();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () => provider.toggleAutoPlay(),
            icon: Icon(
              provider.isAutoPlaying ? Icons.pause_circle : Icons.play_circle,
              color: provider.isAutoPlaying ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          IconButton(
            onPressed: () => provider.setupFlashcards(shuffle: true),
            icon: const Icon(Icons.shuffle),
          ),
        ],
      ),
      body: currentWord != null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Progress Indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'İLERLEME',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              ' /  Kelime',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progressFraction,
                            minHeight: 8,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3D Flip Card
                  Expanded(
                    child: FlipCard3D(
                      word: currentWord,
                      isFlipped: provider.isCardFlipped,
                      onFlip: () => provider.flipCard(),
                      onSpeak: () => provider.ttsService.speak(currentWord.english),
                      onToggleFavorite: () => provider.toggleFavorite(currentWord),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // SRS Rating Buttons
                  Row(
                    children: [
                      // Zor
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => provider.rateCard(SrsRating.hard),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFFEF2F2),
                            side: const BorderSide(color: Color(0xFFFEE2E2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Column(
                            children: [
                              Text('👎', style: TextStyle(fontSize: 18)),
                              SizedBox(height: 2),
                              Text('Zor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFB91C1C))),
                              Text('Yarın', style: TextStyle(fontSize: 10, color: Color(0xFFDC2626))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Orta
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => provider.rateCard(SrsRating.good),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFBEB),
                            side: const BorderSide(color: Color(0xFFFEF3C7)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Column(
                            children: [
                              Text('😐', style: TextStyle(fontSize: 18)),
                              SizedBox(height: 2),
                              Text('Orta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFB45309))),
                              Text('2 gün', style: TextStyle(fontSize: 10, color: Color(0xFFD97706))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Kolay
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => provider.rateCard(SrsRating.easy),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFECFDF5),
                            side: const BorderSide(color: Color(0xFFD1FAE5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Column(
                            children: [
                              Text('👍', style: TextStyle(fontSize: 18)),
                              SizedBox(height: 2),
                              Text('Kolay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF047857))),
                              Text('4 gün', style: TextStyle(fontSize: 10, color: Color(0xFF059669))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Navigation Buttons (Önceki / Sonraki)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => provider.prevCard(),
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Önceki'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => provider.nextCard(),
                        label: const Text('Sonraki'),
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Bu kategoride henüz kelime yok.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => provider.setupFlashcards(),
                    child: const Text('Tüm Kelimeleri Yükle'),
                  ),
                ],
              ),
            ),
    );
  }
}
