class WordModel {
  final int id;
  final String english;
  final String turkish;
  final String category;
  final String phonetic;
  final String definition;
  final String exampleSentence;
  final String exampleSentenceTr;
  final int difficulty;
  final bool isFavorite;
  final bool isLearned;
  final int learningProgress; // 0 to 100
  final int reviewCount;
  final int correctCount;
  final int wrongCount;
  final int lastReviewedAt;
  final int nextReviewAt;
  final int srsIntervalDays;
  final double srsEaseFactor;
  final int createdAt;

  WordModel({
    required this.id,
    required this.english,
    required this.turkish,
    this.category = 'Temel Seviye',
    this.phonetic = '',
    this.definition = '',
    this.exampleSentence = '',
    this.exampleSentenceTr = '',
    this.difficulty = 1,
    this.isFavorite = false,
    this.isLearned = false,
    this.learningProgress = 0,
    this.reviewCount = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.lastReviewedAt = 0,
    this.nextReviewAt = 0,
    this.srsIntervalDays = 1,
    this.srsEaseFactor = 2.5,
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  WordModel copyWith({
    int? id,
    String? english,
    String? turkish,
    String? category,
    String? phonetic,
    String? definition,
    String? exampleSentence,
    String? exampleSentenceTr,
    int? difficulty,
    bool? isFavorite,
    bool? isLearned,
    int? learningProgress,
    int? reviewCount,
    int? correctCount,
    int? wrongCount,
    int? lastReviewedAt,
    int? nextReviewAt,
    int? srsIntervalDays,
    double? srsEaseFactor,
    int? createdAt,
  }) {
    return WordModel(
      id: id ?? this.id,
      english: english ?? this.english,
      turkish: turkish ?? this.turkish,
      category: category ?? this.category,
      phonetic: phonetic ?? this.phonetic,
      definition: definition ?? this.definition,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      exampleSentenceTr: exampleSentenceTr ?? this.exampleSentenceTr,
      difficulty: difficulty ?? this.difficulty,
      isFavorite: isFavorite ?? this.isFavorite,
      isLearned: isLearned ?? this.isLearned,
      learningProgress: learningProgress ?? this.learningProgress,
      reviewCount: reviewCount ?? this.reviewCount,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      srsIntervalDays: srsIntervalDays ?? this.srsIntervalDays,
      srsEaseFactor: srsEaseFactor ?? this.srsEaseFactor,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'english': english,
      'turkish': turkish,
      'category': category,
      'phonetic': phonetic,
      'definition': definition,
      'exampleSentence': exampleSentence,
      'exampleSentenceTr': exampleSentenceTr,
      'difficulty': difficulty,
      'isFavorite': isFavorite,
      'isLearned': isLearned,
      'learningProgress': learningProgress,
      'reviewCount': reviewCount,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'lastReviewedAt': lastReviewedAt,
      'nextReviewAt': nextReviewAt,
      'srsIntervalDays': srsIntervalDays,
      'srsEaseFactor': srsEaseFactor,
      'createdAt': createdAt,
    };
  }

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      english: json['english']?.toString() ?? '',
      turkish: json['turkish']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Temel Seviye',
      phonetic: json['phonetic']?.toString() ?? '',
      definition: json['definition']?.toString() ?? '',
      exampleSentence: json['exampleSentence']?.toString() ?? '',
      exampleSentenceTr: json['exampleSentenceTr']?.toString() ?? '',
      difficulty: json['difficulty'] is int ? json['difficulty'] : int.tryParse(json['difficulty']?.toString() ?? '1') ?? 1,
      isFavorite: json['isFavorite'] == true || json['isFavorite'] == 1,
      isLearned: json['isLearned'] == true || json['isLearned'] == 1,
      learningProgress: json['learningProgress'] is int ? json['learningProgress'] : int.tryParse(json['learningProgress']?.toString() ?? '0') ?? 0,
      reviewCount: json['reviewCount'] is int ? json['reviewCount'] : int.tryParse(json['reviewCount']?.toString() ?? '0') ?? 0,
      correctCount: json['correctCount'] is int ? json['correctCount'] : int.tryParse(json['correctCount']?.toString() ?? '0') ?? 0,
      wrongCount: json['wrongCount'] is int ? json['wrongCount'] : int.tryParse(json['wrongCount']?.toString() ?? '0') ?? 0,
      lastReviewedAt: json['lastReviewedAt'] is int ? json['lastReviewedAt'] : int.tryParse(json['lastReviewedAt']?.toString() ?? '0') ?? 0,
      nextReviewAt: json['nextReviewAt'] is int ? json['nextReviewAt'] : int.tryParse(json['nextReviewAt']?.toString() ?? '0') ?? 0,
      srsIntervalDays: json['srsIntervalDays'] is int ? json['srsIntervalDays'] : int.tryParse(json['srsIntervalDays']?.toString() ?? '1') ?? 1,
      srsEaseFactor: json['srsEaseFactor'] is num ? (json['srsEaseFactor'] as num).toDouble() : double.tryParse(json['srsEaseFactor']?.toString() ?? '2.5') ?? 2.5,
      createdAt: json['createdAt'] is int ? json['createdAt'] : int.tryParse(json['createdAt']?.toString() ?? '0') ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Converts model to Supabase PostgreSQL schema with snake_case columns
  Map<String, dynamic> toSupabaseJson() {
    final map = <String, dynamic>{
      'id': id,
      'english': english,
      'turkish': turkish,
      'category': category,
      'phonetic': phonetic,
      'definition': definition,
      'example_sentence': exampleSentence,
      'example_sentence_tr': exampleSentenceTr,
      'is_favorite': isFavorite,
      'is_learned': isLearned,
      'learning_progress': learningProgress,
      'repetition_count': reviewCount,
      'interval_days': srsIntervalDays,
      'ease_factor': srsEaseFactor,
    };
    if (lastReviewedAt > 0) {
      map['last_reviewed_date'] = DateTime.fromMillisecondsSinceEpoch(lastReviewedAt).toIso8601String().split('T').first;
    }
    if (nextReviewAt > 0) {
      map['next_review_date'] = DateTime.fromMillisecondsSinceEpoch(nextReviewAt).toIso8601String().split('T').first;
    }
    return map;
  }

  /// Factory constructor to parse Supabase PostgreSQL snake_case rows
  factory WordModel.fromSupabaseJson(Map<String, dynamic> json) {
    int parseDate(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is String && val.isNotEmpty) {
        final parsed = DateTime.tryParse(val);
        return parsed != null ? parsed.millisecondsSinceEpoch : 0;
      }
      return 0;
    }

    return WordModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      english: json['english']?.toString() ?? '',
      turkish: json['turkish']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Temel Seviye',
      phonetic: json['phonetic']?.toString() ?? '',
      definition: json['definition']?.toString() ?? '',
      exampleSentence: (json['example_sentence'] ?? json['exampleSentence'])?.toString() ?? '',
      exampleSentenceTr: (json['example_sentence_tr'] ?? json['exampleSentenceTr'])?.toString() ?? '',
      difficulty: json['difficulty'] is int ? json['difficulty'] : int.tryParse(json['difficulty']?.toString() ?? '1') ?? 1,
      isFavorite: (json['is_favorite'] ?? json['isFavorite']) == true,
      isLearned: (json['is_learned'] ?? json['isLearned']) == true,
      learningProgress: (json['learning_progress'] ?? json['learningProgress']) is int
          ? (json['learning_progress'] ?? json['learningProgress'])
          : int.tryParse((json['learning_progress'] ?? json['learningProgress'])?.toString() ?? '0') ?? 0,
      reviewCount: (json['repetition_count'] ?? json['review_count'] ?? json['reviewCount']) is int
          ? (json['repetition_count'] ?? json['review_count'] ?? json['reviewCount'])
          : int.tryParse((json['repetition_count'] ?? json['review_count'] ?? json['reviewCount'])?.toString() ?? '0') ?? 0,
      correctCount: (json['correct_count'] ?? json['correctCount']) is int
          ? (json['correct_count'] ?? json['correctCount'])
          : int.tryParse((json['correct_count'] ?? json['correctCount'])?.toString() ?? '0') ?? 0,
      wrongCount: (json['wrong_count'] ?? json['wrongCount']) is int
          ? (json['wrong_count'] ?? json['wrongCount'])
          : int.tryParse((json['wrong_count'] ?? json['wrongCount'])?.toString() ?? '0') ?? 0,
      lastReviewedAt: parseDate(json['last_reviewed_date'] ?? json['last_reviewed_at'] ?? json['lastReviewedAt']),
      nextReviewAt: parseDate(json['next_review_date'] ?? json['next_review_at'] ?? json['nextReviewAt']),
      srsIntervalDays: (json['interval_days'] ?? json['srsIntervalDays']) is int
          ? (json['interval_days'] ?? json['srsIntervalDays'])
          : int.tryParse((json['interval_days'] ?? json['srsIntervalDays'])?.toString() ?? '1') ?? 1,
      srsEaseFactor: (json['ease_factor'] ?? json['srsEaseFactor']) is num
          ? ((json['ease_factor'] ?? json['srsEaseFactor']) as num).toDouble()
          : double.tryParse((json['ease_factor'] ?? json['srsEaseFactor'])?.toString() ?? '2.5') ?? 2.5,
      createdAt: parseDate(json['created_at'] ?? json['createdAt']) > 0
          ? parseDate(json['created_at'] ?? json['createdAt'])
          : DateTime.now().millisecondsSinceEpoch,
    );
  }
}
