import 'package:intl/intl.dart';
import '../models/word_model.dart';

enum SrsRating { hard, good, easy }

class DateUtilsHelper {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _dayFormat = DateFormat('EEE', 'tr_TR');

  static String getTodayString() {
    return _dateFormat.format(DateTime.now());
  }

  static String getFormattedDate(int timestamp) {
    return _dateFormat.format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  }

  static List<String> getLast7DaysLabels() {
    final list = <String>[];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      try {
        list.add(_dayFormat.format(d));
      } catch (_) {
        const trDays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
        list.add(trDays[d.weekday - 1]);
      }
    }
    return list;
  }

  static List<String> getLast7DaysKeys() {
    final list = <String>[];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      list.add(_dateFormat.format(d));
    }
    return list;
  }
}

class SrsService {
  static const int oneDayMs = 24 * 60 * 60 * 1000;

  static WordModel calculateNextReview(WordModel word, SrsRating rating) {
    final now = DateTime.now().millisecondsSinceEpoch;
    int intervalDays = word.srsIntervalDays;
    double easeFactor = word.srsEaseFactor;
    int progress = word.learningProgress;
    int correctCount = word.correctCount;
    int wrongCount = word.wrongCount;

    switch (rating) {
      case SrsRating.hard:
        intervalDays = 1;
        easeFactor = (easeFactor - 0.2).clamp(1.3, 3.0);
        progress = (progress - 15).clamp(0, 100);
        wrongCount += 1;
        break;
      case SrsRating.good:
        intervalDays = intervalDays <= 1 ? 2 : (intervalDays * easeFactor).toInt();
        progress = (progress + 20).clamp(0, 100);
        correctCount += 1;
        break;
      case SrsRating.easy:
        intervalDays = intervalDays <= 1 ? 4 : ((intervalDays + 2) * easeFactor * 1.2).toInt();
        easeFactor = (easeFactor + 0.15).clamp(1.3, 3.0);
        progress = (progress + 35).clamp(0, 100);
        correctCount += 1;
        break;
    }

    final isLearned = progress >= 80;
    final nextReviewAt = now + (intervalDays * oneDayMs);

    return word.copyWith(
      learningProgress: progress,
      isLearned: isLearned,
      reviewCount: word.reviewCount + 1,
      correctCount: correctCount,
      wrongCount: wrongCount,
      lastReviewedAt: now,
      nextReviewAt: nextReviewAt,
      srsIntervalDays: intervalDays,
      srsEaseFactor: easeFactor,
    );
  }
}
