import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/word_model.dart';
import '../models/category_model.dart';
import '../models/daily_stats_model.dart';

/// Clean REST API client for communicating with the Express.js Backend Server
class WordApiService {
  static final WordApiService _instance = WordApiService._internal();
  factory WordApiService() => _instance;

  final http.Client _client;

  WordApiService._internal({http.Client? client}) : _client = client ?? http.Client();

  /// For unit testing with mock client
  @visibleForTesting
  WordApiService.withClient(http.Client client) : _client = client;

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  /// Checks if the backend REST server is reachable and database is connected
  Future<bool> checkHealth() async {
    try {
      final res = await _client.get(ApiConfig.healthUri).timeout(ApiConfig.requestTimeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['status'] == 'OK';
      }
      return false;
    } catch (e) {
      debugPrint('WordApiService health check note: $e');
      return false;
    }
  }

  // ===========================================================================
  // WORDS ENDPOINTS
  // ===========================================================================

  /// Fetches all words from REST API. Returns null on connection error.
  Future<List<WordModel>?> getWords() async {
    try {
      final res = await _client.get(ApiConfig.wordsUri).timeout(ApiConfig.requestTimeout);
      if (res.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(res.body);
        return decoded
            .map((item) => WordModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      debugPrint('WordApiService getWords failed with HTTP ${res.statusCode}: ${res.body}');
      return null;
    } on SocketException catch (e) {
      debugPrint('WordApiService getWords network offline: $e');
      return null;
    } on TimeoutException catch (e) {
      debugPrint('WordApiService getWords timeout: $e');
      return null;
    } catch (e) {
      debugPrint('WordApiService getWords error: $e');
      return null;
    }
  }

  /// Creates or updates a word on REST API
  Future<bool> saveWord(WordModel word) async {
    try {
      final res = await _client
          .post(
            ApiConfig.wordsUri,
            headers: _headers,
            body: jsonEncode(word.toJson()),
          )
          .timeout(ApiConfig.requestTimeout);
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      debugPrint('WordApiService saveWord error: $e');
      return false;
    }
  }

  /// Deletes a word by id from REST API
  Future<bool> deleteWord(int id) async {
    try {
      final res = await _client
          .delete(ApiConfig.wordUri(id), headers: _headers)
          .timeout(ApiConfig.requestTimeout);
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      debugPrint('WordApiService deleteWord error: $e');
      return false;
    }
  }

  // ===========================================================================
  // CATEGORIES ENDPOINTS
  // ===========================================================================

  /// Fetches all categories from REST API. Returns null on error.
  Future<List<CategoryModel>?> getCategories() async {
    try {
      final res = await _client.get(ApiConfig.categoriesUri).timeout(ApiConfig.requestTimeout);
      if (res.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(res.body);
        return decoded
            .map((item) => CategoryModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      debugPrint('WordApiService getCategories HTTP ${res.statusCode}');
      return null;
    } catch (e) {
      debugPrint('WordApiService getCategories error: $e');
      return null;
    }
  }

  /// Creates or updates a category on REST API
  Future<bool> saveCategory(CategoryModel category) async {
    try {
      final res = await _client
          .post(
            ApiConfig.categoriesUri,
            headers: _headers,
            body: jsonEncode(category.toJson()),
          )
          .timeout(ApiConfig.requestTimeout);
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      debugPrint('WordApiService saveCategory error: $e');
      return false;
    }
  }

  /// Deletes a category by id from REST API
  Future<bool> deleteCategory(int id) async {
    try {
      final res = await _client
          .delete(ApiConfig.categoryUri(id), headers: _headers)
          .timeout(ApiConfig.requestTimeout);
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      debugPrint('WordApiService deleteCategory error: $e');
      return false;
    }
  }

  // ===========================================================================
  // DAILY STATS ENDPOINTS
  // ===========================================================================

  /// Fetches daily stats from REST API. Returns null on error.
  Future<List<DailyStatsModel>?> getStats() async {
    try {
      final res = await _client.get(ApiConfig.statsUri).timeout(ApiConfig.requestTimeout);
      if (res.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(res.body);
        return decoded
            .map((item) => DailyStatsModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      return null;
    } catch (e) {
      debugPrint('WordApiService getStats error: $e');
      return null;
    }
  }

  /// Records or updates daily stats on REST API
  Future<bool> saveDailyStats(DailyStatsModel stats) async {
    try {
      final res = await _client
          .post(
            ApiConfig.statsUri,
            headers: _headers,
            body: jsonEncode(stats.toJson()),
          )
          .timeout(ApiConfig.requestTimeout);
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      debugPrint('WordApiService saveDailyStats error: $e');
      return false;
    }
  }
}
