import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/word_model.dart';
import '../../providers/app_provider.dart';

class WordManagerScreen extends StatefulWidget {
  final bool showAppBar;
  const WordManagerScreen({super.key, this.showAppBar = true});

  @override
  State<WordManagerScreen> createState() => _WordManagerScreenState();
}

class _WordManagerScreenState extends State<WordManagerScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final filteredWords = provider.filteredWords;
    final categories = provider.allCategories;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(
                'Kelime Yönetimi',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                ),
              ),
            )
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showWordFormDialog(context, provider),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              onChanged: (val) => provider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Kelime ara (Türkçe veya İngilizce)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: provider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => provider.setSearchQuery(''),
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),

            const SizedBox(height: 10),

            // Filter Chips Horizontal Row
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    selected: provider.selectedCategoryFilter == 'Tümü',
                    onSelected: (_) => provider.setSelectedCategoryFilter('Tümü'),
                    label: const Text('Tümü'),
                  ),
                  const SizedBox(width: 8),
                  ...categories.map((cat) {
                    final isSel = provider.selectedCategoryFilter == cat.name;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: isSel,
                        onSelected: (_) => provider.setSelectedCategoryFilter(cat.name),
                        label: Text(cat.name),
                      ),
                    );
                  }),
                  FilterChip(
                    selected: provider.onlyFavoritesFilter,
                    onSelected: (_) => provider.toggleFavoritesFilter(),
                    label: const Text('❤️ Favoriler'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    selected: provider.onlyLearnedFilter,
                    onSelected: (_) => provider.toggleLearnedFilter(),
                    label: const Text('✓ Öğrenildi'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Text(
              ' kelime listeleniyor',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 8),

            // Words List
            Expanded(
              child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 96),
                itemCount: filteredWords.length,
                itemBuilder: (context, index) {
                  final word = filteredWords[index];
                  return _WordItemCard(
                    word: word,
                    onSpeak: () => provider.ttsService.speak(word.english),
                    onToggleFavorite: () => provider.toggleFavorite(word),
                    onEdit: () => _showWordFormDialog(context, provider, existingWord: word),
                    onDelete: () => _showDeleteConfirmDialog(context, provider, word),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWordFormDialog(BuildContext context, AppProvider provider, {WordModel? existingWord}) {
    final isEditing = existingWord != null;
    final enController = TextEditingController(text: existingWord?.english ?? '');
    final trController = TextEditingController(text: existingWord?.turkish ?? '');
    final catController = TextEditingController(text: existingWord?.category ?? 'Temel Seviye');
    final exController = TextEditingController(text: existingWord?.exampleSentence ?? '');
    final exTrController = TextEditingController(text: existingWord?.exampleSentenceTr ?? '');
    final defController = TextEditingController(text: existingWord?.definition ?? '');

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(
            isEditing ? 'Kelimeyi Düzenle' : 'Yeni Kelime Ekle',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: enController,
                  decoration: const InputDecoration(labelText: 'İngilizce Kelime *'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: trController,
                  decoration: const InputDecoration(labelText: 'Türkçe Anlamı *'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: catController,
                  decoration: const InputDecoration(labelText: 'Kategori (örn: Temel Seviye, Fiiller)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: exController,
                  decoration: const InputDecoration(labelText: 'Örnek Cümle (İngilizce)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: exTrController,
                  decoration: const InputDecoration(labelText: 'Örnek Cümle (Türkçe Çeviri)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: defController,
                  decoration: const InputDecoration(labelText: 'Tanım / Eş Anlamlılar'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                final en = enController.text.trim();
                final tr = trController.text.trim();
                if (en.isEmpty || tr.isEmpty) return;

                if (isEditing) {
                  final updated = existingWord.copyWith(
                    english: en,
                    turkish: tr,
                    category: catController.text.trim().isNotEmpty ? catController.text.trim() : 'Temel Seviye',
                    exampleSentence: exController.text.trim(),
                    exampleSentenceTr: exTrController.text.trim(),
                    definition: defController.text.trim(),
                  );
                  provider.updateWord(updated);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kelime güncellendi!')),
                  );
                } else {
                  provider.addWord(
                    english: en,
                    turkish: tr,
                    category: catController.text.trim(),
                    example: exController.text.trim(),
                    exampleTr: exTrController.text.trim(),
                    definition: defController.text.trim(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kelime başarıyla eklendi!')),
                  );
                }
                Navigator.pop(dialogCtx);
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, AppProvider provider, WordModel word) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Kelimeyi Sil'),
          content: Text('  kelimesini silmek istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF43F5E), foregroundColor: Colors.white),
              onPressed: () {
                provider.deleteWord(word.id);
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kelime silindi')),
                );
              },
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }
}

class _WordItemCard extends StatelessWidget {
  final WordModel word;
  final VoidCallback onSpeak;
  final VoidCallback onToggleFavorite;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WordItemCard({
    required this.word,
    required this.onSpeak,
    required this.onToggleFavorite,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              word.english,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (word.phonetic.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text(
                                word.phonetic,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '🇹🇷 ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: onSpeak,
                        icon: Icon(Icons.volume_up, color: theme.colorScheme.primary),
                      ),
                      IconButton(
                        onPressed: onToggleFavorite,
                        icon: Icon(
                          word.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: word.isFavorite ? const Color(0xFFEF4444) : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (word.exampleSentence.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '📝 ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      word.category,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: onEdit,
                        child: const Text('Düzenle', style: TextStyle(fontSize: 12)),
                      ),
                      TextButton(
                        onPressed: onDelete,
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFFF43F5E)),
                        child: const Text('Sil', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
