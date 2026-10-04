import 'package:flutter_test/flutter_test.dart';
import 'package:kelime_ogren/models/word_model.dart';
import 'package:kelime_ogren/models/category_model.dart';
import 'package:kelime_ogren/models/daily_stats_model.dart';

void main() {
  group('Supabase Schema & Model Mapping Tests', () {
    test('WordModel toSupabaseJson generates snake_case columns', () {
      final word = WordModel(
        id: 101,
        english: 'Resilient',
        turkish: 'Dirençli, esnek',
        category: 'Kişilik & Sıfatlar',
        exampleSentence: 'She is very resilient under pressure.',
        exampleSentenceTr: 'Baskı altında çok dirençlidir.',
        isFavorite: true,
        isLearned: true,
        learningProgress: 85,
        reviewCount: 4,
        srsIntervalDays: 6,
        srsEaseFactor: 2.65,
        lastReviewedAt: 1727184000000,
        nextReviewAt: 1727702400000,
      );

      final supabaseJson = word.toSupabaseJson();

      expect(supabaseJson['id'], 101);
      expect(supabaseJson['english'], 'Resilient');
      expect(supabaseJson['turkish'], 'Dirençli, esnek');
      expect(supabaseJson['example_sentence'], 'She is very resilient under pressure.');
      expect(supabaseJson['example_sentence_tr'], 'Baskı altında çok dirençlidir.');
      expect(supabaseJson['is_favorite'], true);
      expect(supabaseJson['is_learned'], true);
      expect(supabaseJson['learning_progress'], 85);
      expect(supabaseJson['repetition_count'], 4);
      expect(supabaseJson['interval_days'], 6);
      expect(supabaseJson['ease_factor'], 2.65);
      expect(supabaseJson.containsKey('last_reviewed_date'), true);
      expect(supabaseJson.containsKey('next_review_date'), true);
    });

    test('WordModel fromSupabaseJson successfully parses snake_case Postgres rows', () {
      final postgresRow = {
        'id': 102,
        'english': 'Persevere',
        'turkish': 'Sebat etmek',
        'category': 'Eylemler',
        'example_sentence': 'He persevered despite difficulties.',
        'example_sentence_tr': 'Zorluklara rağmen sebat etti.',
        'is_favorite': true,
        'is_learned': false,
        'learning_progress': 60,
        'repetition_count': 3,
        'interval_days': 4,
        'ease_factor': 2.45,
        'last_reviewed_date': '2026-09-24',
        'next_review_date': '2026-09-28',
      };

      final word = WordModel.fromSupabaseJson(postgresRow);

      expect(word.id, 102);
      expect(word.english, 'Persevere');
      expect(word.turkish, 'Sebat etmek');
      expect(word.exampleSentence, 'He persevered despite difficulties.');
      expect(word.exampleSentenceTr, 'Zorluklara rağmen sebat etti.');
      expect(word.isFavorite, true);
      expect(word.isLearned, false);
      expect(word.learningProgress, 60);
      expect(word.reviewCount, 3);
      expect(word.srsIntervalDays, 4);
      expect(word.srsEaseFactor, 2.45);
      expect(word.lastReviewedAt, greaterThan(0));
      expect(word.nextReviewAt, greaterThan(0));
    });

    test('CategoryModel and DailyStatsModel Supabase mappings', () {
      final cat = CategoryModel(
        id: 1,
        name: 'Seyahat',
        description: 'Havalimanı ve otel',
        colorHex: '#10B981',
      );
      final catSupa = cat.toSupabaseJson();
      expect(catSupa['color_hex'], '#10B981');

      final parsedCat = CategoryModel.fromSupabaseJson(catSupa);
      expect(parsedCat.colorHex, '#10B981');

      final stat = DailyStatsModel(
        dateString: '2026-09-24',
        wordsReviewed: 15,
        wordsLearned: 5,
        correctCount: 12,
        wrongCount: 3,
        pointsEarned: 120,
      );
      final statSupa = stat.toSupabaseJson();
      expect(statSupa['date_string'], '2026-09-24');
      expect(statSupa['correct_answers'], 12);

      final parsedStat = DailyStatsModel.fromSupabaseJson(statSupa);
      expect(parsedStat.dateString, '2026-09-24');
      expect(parsedStat.correctCount, 12);
    });
  });
}
