class MatchCardModel {
  final String id;
  final int wordId;
  final String text;
  final bool isEnglish;
  final bool isMatched;
  final bool isSelected;
  final bool isError;

  MatchCardModel({
    required this.id,
    required this.wordId,
    required this.text,
    required this.isEnglish,
    this.isMatched = false,
    this.isSelected = false,
    this.isError = false,
  });

  MatchCardModel copyWith({
    String? id,
    int? wordId,
    String? text,
    bool? isEnglish,
    bool? isMatched,
    bool? isSelected,
    bool? isError,
  }) {
    return MatchCardModel(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      text: text ?? this.text,
      isEnglish: isEnglish ?? this.isEnglish,
      isMatched: isMatched ?? this.isMatched,
      isSelected: isSelected ?? this.isSelected,
      isError: isError ?? this.isError,
    );
  }
}

class QuizQuestionModel {
  final dynamic word; // WordModel
  final List<String> options;
  final String correctOption;
  final bool isEngToTr;

  QuizQuestionModel({
    required this.word,
    required this.options,
    required this.correctOption,
    this.isEngToTr = true,
  });
}

class SpeedChallengeModel {
  final String english;
  final String displayedTurkish;
  final bool isCorrectMatch;

  SpeedChallengeModel({
    required this.english,
    required this.displayedTurkish,
    required this.isCorrectMatch,
  });
}
