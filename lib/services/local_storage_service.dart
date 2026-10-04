import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word_model.dart';
import '../models/category_model.dart';
import '../models/daily_stats_model.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;

  SharedPreferences? _prefs;

  LocalStorageService._internal();

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Preferences
  String get username => _prefs?.getString('username') ?? 'Öğrenci';
  Future<void> setUsername(String value) async => await _prefs?.setString('username', value);

  int get totalPoints => _prefs?.getInt('total_points') ?? 150;
  Future<void> setTotalPoints(int value) async => await _prefs?.setInt('total_points', value);

  int get streakDays => _prefs?.getInt('streak_days') ?? 3;
  Future<void> setStreakDays(int value) async => await _prefs?.setInt('streak_days', value);

  int get dailyGoal => _prefs?.getInt('daily_goal') ?? 20;
  Future<void> setDailyGoal(int value) async => await _prefs?.setInt('daily_goal', value);

  double get speechRate => _prefs?.getDouble('speech_rate') ?? 0.95;
  Future<void> setSpeechRate(double value) async => await _prefs?.setDouble('speech_rate', value);

  bool get isDarkTheme => _prefs?.getBool('dark_theme') ?? false;
  Future<void> setDarkTheme(bool value) async => await _prefs?.setBool('dark_theme', value);

  // Words Store
  Future<List<WordModel>> loadWords() async {
    await init();
    final jsonStr = _prefs?.getString('cached_words');
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        return decoded.map((e) => WordModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } catch (_) {}
    }
    return [];
  }

  Future<void> saveWords(List<WordModel> words) async {
    await init();
    final encoded = jsonEncode(words.map((e) => e.toJson()).toList());
    await _prefs?.setString('cached_words', encoded);
  }

  // Categories Store
  Future<List<CategoryModel>> loadCategories() async {
    await init();
    final jsonStr = _prefs?.getString('cached_categories');
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        return decoded.map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } catch (_) {}
    }
    return [];
  }

  Future<void> saveCategories(List<CategoryModel> categories) async {
    await init();
    final encoded = jsonEncode(categories.map((e) => e.toJson()).toList());
    await _prefs?.setString('cached_categories', encoded);
  }

  // Daily Stats Store
  Future<List<DailyStatsModel>> loadDailyStats() async {
    await init();
    final jsonStr = _prefs?.getString('cached_daily_stats');
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        return decoded.map((e) => DailyStatsModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } catch (_) {}
    }
    return [];
  }

  Future<void> saveDailyStats(List<DailyStatsModel> stats) async {
    await init();
    final encoded = jsonEncode(stats.map((e) => e.toJson()).toList());
    await _prefs?.setString('cached_daily_stats', encoded);
  }

  Future<void> clearAll() async {
    await init();
    await _prefs?.remove('cached_words');
    await _prefs?.remove('cached_categories');
    await _prefs?.remove('cached_daily_stats');
  }
}
