import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class StudyScreen extends StatelessWidget {
  final Function(String?) onNavigateToFlashcards;
  final VoidCallback onNavigateToQuiz;
  final VoidCallback onNavigateToSpelling;
  final VoidCallback onNavigateToListening;
  final VoidCallback onNavigateToMatchGame;
  final VoidCallback onNavigateToSpeedGame;

  const StudyScreen({
    super.key,
    required this.onNavigateToFlashcards,
    required this.onNavigateToQuiz,
    required this.onNavigateToSpelling,
    required this.onNavigateToListening,
    required this.onNavigateToMatchGame,
    required this.onNavigateToSpeedGame,
  });

  void _startRandomMode(AppProvider provider) {
    final modes = [
      () {
        provider.setupFlashcards();
        onNavigateToFlashcards(null);
      },
      () {
        provider.startQuiz();
        onNavigateToQuiz();
      },
      () {
        provider.startSpellingMode();
        onNavigateToSpelling();
      },
      () {
        provider.startListeningMode();
        onNavigateToListening();
      },
      () {
        provider.startMatchGame();
        onNavigateToMatchGame();
      },
      () {
        provider.startSpeedGame();
        onNavigateToSpeedGame();
      },
    ];

    final randomIndex = Random().nextInt(modes.length);
    modes[randomIndex]();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final totalWords = provider.allWords.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Çalışma Merkezi',
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
          // Quick Start Hero Card (Play)
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: theme.colorScheme.primaryContainer,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Hızlı Çalışma Başlat',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: totalWords > 0
                          ? () => _startRandomMode(provider)
                          : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text(
                        'Şimdi Pratik Yap',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          Text(
            'Öğrenim Modları',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // 2-Column Square Grid of 6 Study Modes
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
            children: [
              _StudyModeCard(
                title: 'Flash Kart',
                icon: Icons.style_rounded,
                color: const Color(0xFF2563EB), // Mavi
                onTap: () {
                  provider.setupFlashcards();
                  onNavigateToFlashcards(null);
                },
              ),
              _StudyModeCard(
                title: 'Test',
                icon: Icons.quiz_rounded,
                color: const Color(0xFF0891B2), // Turkuaz / Okyanus
                onTap: () {
                  provider.startQuiz();
                  onNavigateToQuiz();
                },
              ),
              _StudyModeCard(
                title: 'Yazma',
                icon: Icons.edit_note_rounded,
                color: const Color(0xFF16A34A), // Zümrüt Yeşili
                onTap: () {
                  provider.startSpellingMode();
                  onNavigateToSpelling();
                },
              ),
              _StudyModeCard(
                title: 'Dinleme',
                icon: Icons.headphones_rounded,
                color: const Color(0xFF9333EA), // Canlı Mor
                onTap: () {
                  provider.startListeningMode();
                  onNavigateToListening();
                },
              ),
              _StudyModeCard(
                title: 'Eşleştirme',
                icon: Icons.extension_rounded,
                color: const Color(0xFFEA580C), // Sıcak Turuncu
                onTap: () {
                  provider.startMatchGame();
                  onNavigateToMatchGame();
                },
              ),
              _StudyModeCard(
                title: 'Zamana Karşı',
                icon: Icons.bolt_rounded,
                color: const Color(0xFFE11D48), // Canlı Kırmızı / Gül
                onTap: () {
                  provider.startSpeedGame();
                  onNavigateToSpeedGame();
                },
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StudyModeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StudyModeCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        splashColor: color.withOpacity(0.15),
        highlightColor: color.withOpacity(0.08),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.35)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: color.withOpacity(isDark ? 0.28 : 0.16),
              width: 1.5,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(isDark ? 0.20 : 0.08),
                isDark
                    ? theme.colorScheme.surface.withOpacity(0.7)
                    : theme.colorScheme.surface,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(isDark ? 0.12 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
