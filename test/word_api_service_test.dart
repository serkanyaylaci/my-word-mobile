import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kelime_ogren/config/api_config.dart';
import 'package:kelime_ogren/models/word_model.dart';
import 'package:kelime_ogren/services/word_api_service.dart';

void main() {
  group('ApiConfig Tests', () {
    test('ApiConfig produces correct base URLs and endpoints', () {
      ApiConfig.setCustomBaseUrl('http://192.168.1.100:3000');
      expect(ApiConfig.baseUrl, 'http://192.168.1.100:3000');
      expect(ApiConfig.wordsUri.toString(), 'http://192.168.1.100:3000/api/words');
      expect(ApiConfig.wordUri(42).toString(), 'http://192.168.1.100:3000/api/words/42');
      expect(ApiConfig.healthUri.toString(), 'http://192.168.1.100:3000/health');
      expect(ApiConfig.categoriesUri.toString(), 'http://192.168.1.100:3000/api/categories');
      expect(ApiConfig.categoryUri(5).toString(), 'http://192.168.1.100:3000/api/categories/5');
      expect(ApiConfig.statsUri.toString(), 'http://192.168.1.100:3000/api/stats');

      // Reset
      ApiConfig.setCustomBaseUrl(null);
    });
  });

  group('WordApiService Unit Tests with MockClient', () {
    test('checkHealth returns true when backend responds OK', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/health') {
          return http.Response(jsonEncode({'status': 'OK'}), 200, headers: {'content-type': 'application/json'});
        }
        return http.Response('Not Found', 404);
      });

      final service = WordApiService.withClient(mockClient);
      final isHealthy = await service.checkHealth();
      expect(isHealthy, true);
    });

    test('getWords parses JSON response into WordModel list', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/words') {
          final words = [
            {
              'id': 1,
              'english': 'Accomplish',
              'turkish': 'Başarmak',
              'category': 'Fiiller',
              'isFavorite': true,
              'isLearned': false,
            },
            {
              'id': 2,
              'english': 'Challenge',
              'turkish': 'Meydan okuma',
              'category': 'Temel',
              'isFavorite': false,
              'isLearned': true,
            }
          ];
          return http.Response(jsonEncode(words), 200, headers: {'content-type': 'application/json'});
        }
        return http.Response('Error', 500);
      });

      final service = WordApiService.withClient(mockClient);
      final words = await service.getWords();

      expect(words, isNotNull);
      expect(words!.length, 2);
      expect(words[0].english, 'Accomplish');
      expect(words[0].isFavorite, true);
      expect(words[1].english, 'Challenge');
      expect(words[1].isLearned, true);
    });

    test('saveWord posts JSON data correctly', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/words' && request.method == 'POST') {
          final body = jsonDecode(request.body);
          if (body['english'] == 'Innovative') {
            return http.Response(jsonEncode({'success': true}), 200);
          }
        }
        return http.Response('Bad Request', 400);
      });

      final service = WordApiService.withClient(mockClient);
      final success = await service.saveWord(
        WordModel(id: 10, english: 'Innovative', turkish: 'Yenilikçi'),
      );

      expect(success, true);
    });

    test('deleteWord deletes by id', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/words/10' && request.method == 'DELETE') {
          return http.Response(jsonEncode({'success': true, 'deletedId': 10}), 200);
        }
        return http.Response('Not Found', 404);
      });

      final service = WordApiService.withClient(mockClient);
      final success = await service.deleteWord(10);

      expect(success, true);
    });
  });
}
