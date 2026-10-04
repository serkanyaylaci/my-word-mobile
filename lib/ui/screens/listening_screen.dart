import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class ListeningScreen extends StatelessWidget {
  final VoidCallback onNavigateBack;

  const ListeningScreen({super.key, required this.onNavigateBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final questions = provider.listeningQuestions;
    final currentIndex = provider.currentListeningIndex;
    final selectedAnswer = provider.selectedListeningAnswer;
    final currentQ = questions.isNotEmpty && currentIndex < questions.length ? questions[currentIndex] : null;

    final isAnswered = selectedAnswer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dinleme',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        leading: IconButton(
          onPressed: onNavigateBack,
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '⭐  P',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
      body: currentQ != null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ListView(
                      physics: const ClampingScrollPhysics(),
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: (currentIndex + 1) / questions.length,
                            minHeight: 6,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Soru  / ',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Big Speaker Button
                        Center(
                          child: Material(
                            color: theme.colorScheme.primary,
                            shape: const CircleBorder(),
                            elevation: 8,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => provider.playCurrentListeningAudio(),
                              child: const Padding(
                                padding: EdgeInsets.all(28.0),
                                child: Icon(Icons.volume_up, size: 50, color: Colors.white),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'Tekrar dinlemek için dokunun 🔊',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),

                        if (isAnswered) ...[
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              'Kelime:  ',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // 4 Options
                        ...List.generate(currentQ.options.length, (optIndex) {
                          final optionText = currentQ.options[optIndex];
                          final isSelected = selectedAnswer == optionText;
                          final isCorrect = optionText == currentQ.correctOption;

                          Color containerColor = theme.colorScheme.surface;
                          Color borderColor = theme.colorScheme.outline.withOpacity(0.2);

                          if (isAnswered) {
                            if (isCorrect) {
                              containerColor = const Color(0xFFDCFCE7);
                              borderColor = const Color(0xFF10B981);
                            } else if (isSelected) {
                              containerColor = const Color(0xFFFFE4E6);
                              borderColor = const Color(0xFFF43F5E);
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: borderColor, width: 1.5),
                              ),
                              color: containerColor,
                              elevation: 1,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: isAnswered ? null : () => provider.submitListeningAnswer(optionText),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          optionText,
                                          style: theme.textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: (isAnswered && isCorrect)
                                                ? const Color(0xFF065F46)
                                                : theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      if (isAnswered) ...[
                                        if (isCorrect)
                                          const Icon(Icons.check_circle, color: Color(0xFF10B981))
                                        else if (isSelected)
                                          const Icon(Icons.cancel, color: Color(0xFFF43F5E)),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  if (isAnswered) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => provider.nextListeningQuestion(),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          currentIndex < questions.length - 1 ? 'Sonraki Soru ▶' : 'Tamamla 🏆',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
