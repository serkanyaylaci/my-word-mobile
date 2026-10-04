import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/word_model.dart';
import '../../theme/app_colors.dart';

class FlipCard3D extends StatelessWidget {
  final WordModel word;
  final bool isFlipped;
  final VoidCallback onFlip;
  final VoidCallback onSpeak;
  final VoidCallback onToggleFavorite;

  const FlipCard3D({
    super.key,
    required this.word,
    required this.isFlipped,
    required this.onFlip,
    required this.onSpeak,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: SizedBox(
          height: 390,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Stacked Depth Layer 1 (-1.5 deg)
              Transform.rotate(
                angle: -1.5 * pi / 180,
                child: FractionallySizedBox(
                  widthFactor: 0.92,
                  child: Container(
                    height: 380,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPolish.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(36),
                    ),
                  ),
                ),
              ),

              // Stacked Depth Layer 2 (+2.0 deg)
              Transform.rotate(
                angle: 2.0 * pi / 180,
                child: FractionallySizedBox(
                  widthFactor: 0.96,
                  child: Container(
                    height: 380,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPolish.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(36),
                    ),
                  ),
                ),
              ),

              // Main 3D Card
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: isFlipped ? 180 : 0),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeInOutCubic,
                builder: (context, val, child) {
                  final angle = val * pi / 180;
                  final isUnder = val > 90;

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0012)
                      ..rotateY(angle),
                    child: GestureDetector(
                      onTap: onFlip,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(36),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
                          ),
                        ),
                        elevation: 6,
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          child: isUnder
                              ? Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()..rotateY(pi),
                                  child: _buildBackContent(context),
                                )
                              : _buildFrontContent(context),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrontContent(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        // Top Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainerPolish,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                word.category,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.onPrimaryContainerPolish,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: onToggleFavorite,
              icon: Icon(
                word.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: word.isFavorite ? const Color(0xFFEF4444) : theme.colorScheme.onSurfaceVariant,
              ),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
              ),
            ),
          ],
        ),

        // Center Content
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                word.english.toUpperCase(),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                  letterSpacing: 1.0,
                ),
              ),
              if (word.phonetic.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  word.phonetic,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              // Pronounce Button Hero
              Material(
                color: AppColors.primaryContainerPolish,
                shape: const CircleBorder(),
                elevation: 3,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onSpeak,
                  child: const Padding(
                    padding: EdgeInsets.all(14.0),
                    child: Icon(
                      Icons.volume_up,
                      size: 28,
                      color: AppColors.onPrimaryContainerPolish,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom Tap Hint
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '💡 Türkçe anlamını görmek için dokunun',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackContent(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        // Top Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainerPolish,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Türkçe Anlamı',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.onPrimaryContainerPolish,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: onToggleFavorite,
              icon: Icon(
                word.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: word.isFavorite ? const Color(0xFFEF4444) : theme.colorScheme.onSurfaceVariant,
              ),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
              ),
            ),
          ],
        ),

        // Center Content
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                word.turkish,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: AppColors.primaryPolish,
                ),
              ),
              if (word.exampleSentence.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📝  ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (word.exampleSentenceTr.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '🇹🇷 ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              if (word.definition.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '📖 ',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Bottom Tap Hint
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '🔄 Ön yüze dönmek için dokunun',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
