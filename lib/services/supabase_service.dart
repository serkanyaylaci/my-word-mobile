import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/word_model.dart';
import '../models/category_model.dart';
import '../models/daily_stats_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;

  SupabaseClient? _client;
  bool _isInitialized = false;

  SupabaseService._internal();

  bool get isAvailable => _isInitialized && _client != null;

  Future<void> init() async {
    if (!SupabaseConfig.isConfigured()) {
      debugPrint('Supabase not configured with active keys. Running in offline/hybrid mode.');
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
      debugPrint('Supabase initialized successfully.');
    } catch (e) {
      debugPrint('Supabase initialization warning: ');
    }
  }

  // Words Sync
  Future<List<WordModel>?> fetchWords() async {
    if (!isAvailable) return null;
    try {
      final data = await _client!.from('words').select();
      return (data as List).map((e) => WordModel.fromSupabaseJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      debugPrint('Supabase fetch words error: $e');
      return null;
    }
  }

  Future<void> upsertWord(WordModel word) async {
    if (!isAvailable) return;
    try {
      await _client!.from('words').upsert(word.toSupabaseJson());
    } catch (e) {
      debugPrint('Supabase upsert word error: $e');
    }
  }

  Future<void> deleteWord(int id) async {
    if (!isAvailable) return;
    try {
      await _client!.from('words').delete().eq('id', id);
    } catch (e) {
      debugPrint('Supabase delete word error: $e');
    }
  }

  // Categories Sync
  Future<List<CategoryModel>?> fetchCategories() async {
    if (!isAvailable) return null;
    try {
      final data = await _client!.from('categories').select();
      return (data as List).map((e) => CategoryModel.fromSupabaseJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      debugPrint('Supabase fetch categories error: $e');
      return null;
    }
  }

  Future<void> upsertCategory(CategoryModel category) async {
    if (!isAvailable) return;
    try {
      await _client!.from('categories').upsert(category.toSupabaseJson());
    } catch (e) {
      debugPrint('Supabase upsert category error: $e');
    }
  }

  // Daily Stats Sync
  Future<void> saveDailyStats(DailyStatsModel stats) async {
    if (!isAvailable) return;
    try {
      await _client!.from('daily_stats').upsert(stats.toSupabaseJson());
    } catch (e) {
      debugPrint('Supabase save stats error: $e');
    }
  }
}
