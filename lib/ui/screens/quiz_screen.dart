import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class QuizScreen extends StatelessWidget {
  final VoidCallback onNavigateBack;

  const QuizScreen({super.key, required this.onNavigateBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final questions = provider.quizQuestions;
    final currentIndex = provider.currentQuizIndex;
    final selectedAnswer = provider.selectedQuizAnswer;
    final isCompleted = provider.isQuizCompleted;
    final currentQ = questions.isNotEmpty && currentIndex < questions.length ? questions[currentIndex] : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Test',
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
      body: isCompleted
          ? _buildResults(context, provider)
          : (currentQ != null
              ? _buildQuizContent(context, provider, currentQ, currentIndex, questions.length, selectedAnswer)
              : const Center(child: CircularProgressIndicator())),
    );
  }

  Widget _buildResults(BuildContext context, AppProvider provider) {
    final theme = Theme.of(context);
    final correct = provider.quizCorrectCount;
    final wrong = provider.quizWrongCount;
    final score = provider.quizScore;

    String headerText = '💪 Pratik Yapmaya Devam!';
    if (correct >= 8) {
      headerText = '🏆 Mükemmel Sonuç!';
    } else if (correct >= 5) {
      headerText = '👏 Tebrikler!';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  headerText,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          '$correct',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                        ),
                        Text('Doğru', style: theme.textTheme.bodySmall),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '$wrong',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFF43F5E)),
                        ),
                        Text('Yanlış', style: theme.textTheme.bodySmall),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '+$score',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                        ),
                        Text('Puan', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => provider.startQuiz(),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Tekrar Çöz 🔄', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onNavigateBack,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Ana Sayfaya Dön'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizContent(
    BuildContext context,
    AppProvider provider,
    dynamic currentQ,
    int index,
    int total,
    String? selectedAnswer,
  ) {
    final theme = Theme.of(context);
    final isAnswered = selectedAnswer != null;

    return Padding(
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
                    value: (index + 1) / total,
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Soru  / ',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '✓   ✗ ',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Question Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          currentQ.isEngToTr
                              ? 'Bu kelimenin Türkçe karşılığı nedir?'
                              : 'Bu Türkçe ifadenin İngilizcesi nedir?',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          currentQ.isEngToTr ? currentQ.word.english : currentQ.word.turkish,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        IconButton(
                          onPressed: () => provider.ttsService.speak(currentQ.word.english),
                          icon: Icon(Icons.volume_up, color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Options List
                ...List.generate(currentQ.options.length, (optIndex) {
                  final optionText = currentQ.options[optIndex];
                  final isSelected = selectedAnswer == optionText;
                  final isCorrectOption = optionText == currentQ.correctOption;

                  Color containerColor = theme.colorScheme.surface;
                  Color borderColor = theme.colorScheme.outline.withOpacity(0.25);

                  if (isAnswered) {
                    if (isCorrectOption) {
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
                        onTap: isAnswered ? null : () => provider.submitQuizAnswer(optionText),
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
                                    color: (isAnswered && isCorrectOption)
                                        ? const Color(0xFF065F46)
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              if (isAnswered) ...[
                                if (isCorrectOption)
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
                onPressed: () => provider.nextQuizQuestion(),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  index < total - 1 ? 'Sonraki Soru ▶' : 'Sonuçları Gör 🏆',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
