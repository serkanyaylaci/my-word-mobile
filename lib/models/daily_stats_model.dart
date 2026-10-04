class DailyStatsModel {
  final String dateString; // YYYY-MM-DD
  final int wordsReviewed;
  final int wordsLearned;
  final int correctCount;
  final int wrongCount;
  final int pointsEarned;
  final int timestamp;

  DailyStatsModel({
    required this.dateString,
    this.wordsReviewed = 0,
    this.wordsLearned = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.pointsEarned = 0,
    int? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  DailyStatsModel copyWith({
    String? dateString,
    int? wordsReviewed,
    int? wordsLearned,
    int? correctCount,
    int? wrongCount,
    int? pointsEarned,
    int? timestamp,
  }) {
    return DailyStatsModel(
      dateString: dateString ?? this.dateString,
      wordsReviewed: wordsReviewed ?? this.wordsReviewed,
      wordsLearned: wordsLearned ?? this.wordsLearned,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateString': dateString,
      'wordsReviewed': wordsReviewed,
      'wordsLearned': wordsLearned,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'pointsEarned': pointsEarned,
      'timestamp': timestamp,
    };
  }

  factory DailyStatsModel.fromJson(Map<String, dynamic> json) {
    return DailyStatsModel(
      dateString: json['dateString']?.toString() ?? '',
      wordsReviewed: json['wordsReviewed'] is int ? json['wordsReviewed'] : int.tryParse(json['wordsReviewed']?.toString() ?? '0') ?? 0,
      wordsLearned: json['wordsLearned'] is int ? json['wordsLearned'] : int.tryParse(json['wordsLearned']?.toString() ?? '0') ?? 0,
      correctCount: json['correctCount'] is int ? json['correctCount'] : int.tryParse(json['correctCount']?.toString() ?? '0') ?? 0,
      wrongCount: json['wrongCount'] is int ? json['wrongCount'] : int.tryParse(json['wrongCount']?.toString() ?? '0') ?? 0,
      pointsEarned: json['pointsEarned'] is int ? json['pointsEarned'] : int.tryParse(json['pointsEarned']?.toString() ?? '0') ?? 0,
      timestamp: json['timestamp'] is int ? json['timestamp'] : int.tryParse(json['timestamp']?.toString() ?? '0') ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      'date_string': dateString,
      'words_reviewed': wordsReviewed,
      'words_learned': wordsLearned,
      'correct_answers': correctCount,
      'wrong_answers': wrongCount,
      'points_earned': pointsEarned,
    };
  }

  factory DailyStatsModel.fromSupabaseJson(Map<String, dynamic> json) {
    return DailyStatsModel(
      dateString: (json['date_string'] ?? json['dateString'])?.toString() ?? '',
      wordsReviewed: (json['words_reviewed'] ?? json['wordsReviewed']) is int
          ? (json['words_reviewed'] ?? json['wordsReviewed'])
          : int.tryParse((json['words_reviewed'] ?? json['wordsReviewed'])?.toString() ?? '0') ?? 0,
      wordsLearned: (json['words_learned'] ?? json['wordsLearned']) is int
          ? (json['words_learned'] ?? json['wordsLearned'])
          : int.tryParse((json['words_learned'] ?? json['wordsLearned'])?.toString() ?? '0') ?? 0,
      correctCount: (json['correct_answers'] ?? json['correctCount']) is int
          ? (json['correct_answers'] ?? json['correctCount'])
          : int.tryParse((json['correct_answers'] ?? json['correctCount'])?.toString() ?? '0') ?? 0,
      wrongCount: (json['wrong_answers'] ?? json['wrongCount']) is int
          ? (json['wrong_answers'] ?? json['wrongCount'])
          : int.tryParse((json['wrong_answers'] ?? json['wrongCount'])?.toString() ?? '0') ?? 0,
      pointsEarned: (json['points_earned'] ?? json['pointsEarned']) is int
          ? (json['points_earned'] ?? json['pointsEarned'])
          : int.tryParse((json['points_earned'] ?? json['pointsEarned'])?.toString() ?? '0') ?? 0,
    );
  }
}
