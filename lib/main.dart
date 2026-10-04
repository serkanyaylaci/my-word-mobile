import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'ui/components/app_bottom_nav_bar.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/flashcard_screen.dart';
import 'ui/screens/quiz_screen.dart';
import 'ui/screens/spelling_screen.dart';
import 'ui/screens/listening_screen.dart';
import 'ui/screens/match_game_screen.dart';
import 'ui/screens/speed_game_screen.dart';
import 'ui/screens/explore_screen.dart';
import 'ui/screens/study_screen.dart';
import 'ui/screens/stats_screen.dart';
import 'ui/screens/profile_settings_screen.dart';
import 'ui/components/floating_draggable_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appProvider = AppProvider();

  runApp(
    ChangeNotifierProvider.value(
      value: appProvider,
      child: const KelimeOgrenApp(),
    ),
  );

  // Initialize data asynchronously in parallel with splash animation
  appProvider.init();
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}

class KelimeOgrenApp extends StatelessWidget {
  const KelimeOgrenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return MaterialApp(
      title: 'Kelime Öğren',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const AppScrollBehavior(),
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: provider.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: const AppRootNavigation(),
    );
  }
}

class AppRootNavigation extends StatefulWidget {
  const AppRootNavigation({super.key});

  @override
  State<AppRootNavigation> createState() => _AppRootNavigationState();
}

class _AppRootNavigationState extends State<AppRootNavigation> {
  bool _showSplash = true;
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(
        onFinish: () {
          setState(() {
            _showSplash = false;
          });
        },
      );
    }

    final pages = [
      DashboardScreen(
        onNavigateToFlashcards: (cat) => _pushScreen(context, FlashcardScreen(onNavigateBack: () => Navigator.pop(context))),
        onNavigateToQuiz: () => _pushScreen(context, QuizScreen(onNavigateBack: () => Navigator.pop(context))),
        onNavigateToSpelling: () => _pushScreen(context, SpellingScreen(onNavigateBack: () => Navigator.pop(context))),
        onNavigateToListening: () => _pushScreen(context, ListeningScreen(onNavigateBack: () => Navigator.pop(context))),
        onNavigateToMatchGame: () => _pushScreen(context, MatchGameScreen(onNavigateBack: () => Navigator.pop(context))),
        onNavigateToSpeedGame: () => _pushScreen(context, SpeedGameScreen(onNavigateBack: () => Navigator.pop(context))),
        onNavigateToWordManager: () => setState(() => _currentTabIndex = 1),
        onNavigateToCategories: () => setState(() => _currentTabIndex = 1),
      ),
      ExploreScreen(
        onNavigateToFlashcardsWithCategory: (cat) => _pushScreen(context, FlashcardScreen(onNavigateBack: () => Navigator.pop(context))),
      ),
      StudyScreen(
        onNavigateToFlashcards: (cat) => _pushScreen(context, FlashcardScreen(onNavigateBack: () => Navigator.pop(context))),
        onNavigateToQuiz: () => _pushScreen(context, QuizScreen(onNavigateBack: () => Navigator.pop(context))),
        onNavigateToSpelling: () => _pushScreen(context, SpellingScreen(onNavigateBack: () => Navigator.pop(context))),
        onNavigateToListening: () => _pushScreen(context, ListeningScreen(onNavigateBack: () => Navigator.pop(context))),
        onNavigateToMatchGame: () => _pushScreen(context, MatchGameScreen(onNavigateBack: () => Navigator.pop(context))),
        onNavigateToSpeedGame: () => _pushScreen(context, SpeedGameScreen(onNavigateBack: () => Navigator.pop(context))),
      ),
      const StatsScreen(),
      const ProfileSettingsScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentTabIndex,
            children: pages,
          ),
          const FloatingDraggableButton(),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentTabIndex,
        onTabSelected: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
      ),
    );
  }

  void _pushScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
