import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class SpellingScreen extends StatefulWidget {
  final VoidCallback onNavigateBack;

  const SpellingScreen({super.key, required this.onNavigateBack});

  @override
  State<SpellingScreen> createState() => _SpellingScreenState();
}

class _SpellingScreenState extends State<SpellingScreen> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final words = provider.spellingWords;
    final currentIndex = provider.currentSpellingIndex;
    final currentWord = words.isNotEmpty && currentIndex < words.length ? words[currentIndex] : null;

    // Sync controller with provider hint
    if (_textController.text != provider.spellingInput) {
      _textController.text = provider.spellingInput;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yazma',
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
          onPressed: widget.onNavigateBack,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: currentWord != null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ListView(
                      physics: const ClampingScrollPhysics(),
                      children: [
                        // Prompt Card
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    currentWord.category,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  currentWord.turkish,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26,
                                  ),
                                ),
                                if (currentWord.exampleSentenceTr.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    ' ',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Letter slots / Length hint
                        Center(
                          child: Text(
                            'Uzunluk:  harf',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Text Field
                        TextField(
                          controller: _textController,
                          onChanged: (val) => provider.updateSpellingInput(val),
                          onSubmitted: (_) => provider.checkSpelling(),
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'İngilizce karşılığını yaz',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Hint & Audio Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () => provider.useSpellingHint(),
                              icon: const Icon(Icons.lightbulb, color: Color(0xFFF59E0B)),
                              label: const Text(
                                'Harf İpucu Al',
                                style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (provider.isSpellingChecked)
                              IconButton(
                                onPressed: () => provider.ttsService.speak(currentWord.english),
                                icon: Icon(Icons.volume_up, color: theme.colorScheme.primary),
                              ),
                          ],
                        ),

                        // Result Banner
                        if (provider.isSpellingChecked) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: provider.isSpellingCorrect
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFFE4E6),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  provider.isSpellingCorrect ? Icons.check_circle : Icons.cancel,
                                  color: provider.isSpellingCorrect
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFF43F5E),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        provider.isSpellingCorrect
                                            ? 'Harika! Doğru Yazdın (+25 P)'
                                            : 'Doğru Cevap: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: provider.isSpellingCorrect
                                              ? const Color(0xFF065F46)
                                              : const Color(0xFF9F1239),
                                        ),
                                      ),
                                      if (currentWord.phonetic.isNotEmpty)
                                        Text(
                                          currentWord.phonetic,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: provider.isSpellingCorrect
                                                ? const Color(0xFF047857)
                                                : const Color(0xFFBE123C),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Bottom Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!provider.isSpellingChecked) {
                          if (provider.spellingInput.isNotEmpty) {
                            provider.checkSpelling();
                          }
                        } else {
                          provider.nextSpellingWord();
                          _textController.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        !provider.isSpellingChecked ? 'Kontrol Et ✓' : 'Sonraki Kelime ▶',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
