import 'package:flutter/material.dart';
import 'categories_screen.dart';
import 'word_manager_screen.dart';

class ExploreScreen extends StatelessWidget {
  final Function(String) onNavigateToFlashcardsWithCategory;

  const ExploreScreen({
    super.key,
    required this.onNavigateToFlashcardsWithCategory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Keşfet',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 21,
            ),
          ),
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
            tabs: const [
              Tab(
                icon: Icon(Icons.category_outlined, size: 20),
                text: 'Kategoriler',
              ),
              Tab(
                icon: Icon(Icons.format_list_bulleted_rounded, size: 20),
                text: 'Kelime Havuzu',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CategoriesScreen(
              showAppBar: false,
              onNavigateToFlashcardsWithCategory: onNavigateToFlashcardsWithCategory,
            ),
            const WordManagerScreen(
              showAppBar: false,
            ),
          ],
        ),
      ),
    );
  }
}
