import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/word_model.dart';
import '../models/category_model.dart';
import '../models/daily_stats_model.dart';
import '../services/local_storage_service.dart';
import '../services/word_api_service.dart';
import '../services/supabase_service.dart';
import 'initial_seed_data.dart';

/// Offline-First Word & Study Repository
///
/// Priority Architecture:
/// 1. Immediately serves and persists data via [LocalStorageService] (Cache / Offline).
/// 2. Synchronizes seamlessly with Express REST API via [WordApiService].
/// 3. Backs up to Supabase via [SupabaseService] if configured.
/// 4. If remote is unreachable, continues gracefully with cached offline data.
class WordRepository {
  final LocalStorageService _local = LocalStorageService();
  final WordApiService _api = WordApiService();
  final SupabaseService _supabase = SupabaseService();

  List<WordModel> _words = [];
  List<CategoryModel> _categories = [];
  List<DailyStatsModel> _dailyStats = [];

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  List<WordModel> get words => List.unmodifiable(_words);
  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<DailyStatsModel> get dailyStats => List.unmodifiable(_dailyStats);

  /// Initializes local cache first, then attempts background remote synchronization
  Future<void> init() async {
    await _local.init();
    await _supabase.init();

    // 1. Load Local Cached Data (Instant UI availability)
    _words = await _local.loadWords();
    _categories = await _local.loadCategories();
    _dailyStats = await _local.loadDailyStats();

    // 2. If local store is empty on first install, seed default dataset
    if (_words.isEmpty) {
      _words = List.from(InitialSeedData.words);
      await _local.saveWords(_words);
    }
    if (_categories.isEmpty) {
      _categories = List.from(InitialSeedData.categories);
      await _local.saveCategories(_categories);
    }

    // 3. Perform Remote Synchronization in Background
    syncWithRemote();
  }

  /// Attempts synchronization with Express REST API and Supabase
  Future<bool> syncWithRemote() async {
    try {
      // 1. Try Express REST API first
      final remoteWords = await _api.getWords();
      if (remoteWords != null && remoteWords.isNotEmpty) {
        _isOnline = true;
        _words = remoteWords;
        await _local.saveWords(_words);

        final remoteCats = await _api.getCategories();
        if (remoteCats != null && remoteCats.isNotEmpty) {
          _categories = remoteCats;
          await _local.saveCategories(_categories);
        }

        final remoteStats = await _api.getStats();
        if (remoteStats != null && remoteStats.isNotEmpty) {
          _dailyStats = remoteStats;
          await _local.saveDailyStats(_dailyStats);
        }

        debugPrint('WordRepository: Synced successfully with Express REST API.');
        return true;
      }

      // 2. Fallback to Supabase if Express API is unreachable
      if (_supabase.isAvailable) {
        final supaWords = await _supabase.fetchWords();
        if (supaWords != null && supaWords.isNotEmpty) {
          _isOnline = true;
          _words = supaWords;
          await _local.saveWords(_words);

          final supaCats = await _supabase.fetchCategories();
          if (supaCats != null && supaCats.isNotEmpty) {
            _categories = supaCats;
            await _local.saveCategories(_categories);
          }

          debugPrint('WordRepository: Synced successfully with Supabase Cloud.');
          return true;
        }
      }

      // 3. If remote is unreachable, retain local cache smoothly
      _isOnline = false;
      debugPrint('WordRepository: Operating in Offline-First mode with local storage.');
      return false;
    } catch (e) {
      _isOnline = false;
      debugPrint('WordRepository syncWithRemote note: $e');
      return false;
    }
  }

  // ===========================================================================
  // WORD MUTATIONS (Local-First + Background Remote Sync)
  // ===========================================================================

  Future<void> insertWord(WordModel word) async {
    // 1. Immediate local persistence
    _words.add(word);
    await _local.saveWords(_words);

    // 2. Remote sync
    _api.saveWord(word);
    if (_supabase.isAvailable) {
      _supabase.upsertWord(word);
    }
  }

  Future<void> updateWord(WordModel word) async {
    // 1. Immediate local persistence
    final idx = _words.indexWhere((w) => w.id == word.id);
    if (idx != -1) {
      _words[idx] = word;
      await _local.saveWords(_words);
    }

    // 2. Remote sync
    _api.saveWord(word);
    if (_supabase.isAvailable) {
      _supabase.upsertWord(word);
    }
  }

  Future<void> deleteWord(int id) async {
    // 1. Immediate local persistence
    _words.removeWhere((w) => w.id == id);
    await _local.saveWords(_words);

    // 2. Remote sync
    _api.deleteWord(id);
    if (_supabase.isAvailable) {
      _supabase.deleteWord(id);
    }
  }

  // ===========================================================================
  // CATEGORY MUTATIONS
  // ===========================================================================

  Future<void> insertCategory(CategoryModel category) async {
    _categories.add(category);
    await _local.saveCategories(_categories);

    _api.saveCategory(category);
    if (_supabase.isAvailable) {
      _supabase.upsertCategory(category);
    }
  }

  Future<void> deleteCategory(int id) async {
    _categories.removeWhere((c) => c.id == id);
    await _local.saveCategories(_categories);

    _api.deleteCategory(id);
  }

  // ===========================================================================
  // DAILY STATS MUTATIONS
  // ===========================================================================

  Future<void> recordStudySession({
    required String dateString,
    required int reviewedCount,
    required int learnedCount,
    required int correct,
    required int wrong,
    required int points,
  }) async {
    final idx = _dailyStats.indexWhere((s) => s.dateString == dateString);
    DailyStatsModel updated;
    if (idx != -1) {
      final current = _dailyStats[idx];
      updated = current.copyWith(
        wordsReviewed: current.wordsReviewed + reviewedCount,
        wordsLearned: current.wordsLearned + learnedCount,
        correctCount: current.correctCount + correct,
        wrongCount: current.wrongCount + wrong,
        pointsEarned: current.pointsEarned + points,
      );
      _dailyStats[idx] = updated;
    } else {
      updated = DailyStatsModel(
        dateString: dateString,
        wordsReviewed: reviewedCount,
        wordsLearned: learnedCount,
        correctCount: correct,
        wrongCount: wrong,
        pointsEarned: points,
      );
      _dailyStats.add(updated);
    }

    // 1. Save local
    await _local.saveDailyStats(_dailyStats);

    // 2. Save remote
    _api.saveDailyStats(updated);
    if (_supabase.isAvailable) {
      _supabase.saveDailyStats(updated);
    }
  }

  // ===========================================================================
  // BULK & RESET OPERATIONS
  // ===========================================================================

  Future<void> resetToDefault() async {
    _words = List.from(InitialSeedData.words);
    _categories = List.from(InitialSeedData.categories);
    _dailyStats.clear();
    await _local.saveWords(_words);
    await _local.saveCategories(_categories);
    await _local.saveDailyStats(_dailyStats);

    // Sync seed to remote
    for (final cat in _categories) {
      _api.saveCategory(cat);
      if (_supabase.isAvailable) _supabase.upsertCategory(cat);
    }
    for (final word in _words) {
      _api.saveWord(word);
      if (_supabase.isAvailable) _supabase.upsertWord(word);
    }
  }

  Future<void> importWords(List<WordModel> importedList) async {
    final existingIds = _words.map((w) => w.id).toSet();
    int nextId = (_words.map((w) => w.id).fold<int>(0, (max, id) => id > max ? id : max)) + 1;

    for (final word in importedList) {
      final toAdd = word.copyWith(id: existingIds.contains(word.id) || word.id == 0 ? nextId++ : word.id);
      _words.add(toAdd);
      _api.saveWord(toAdd);
      if (_supabase.isAvailable) _supabase.upsertWord(toAdd);
    }
    await _local.saveWords(_words);
  }
}
