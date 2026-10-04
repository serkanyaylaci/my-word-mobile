import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../models/category_model.dart';
import '../models/daily_stats_model.dart';
import '../models/achievement_model.dart';
import '../models/match_card_model.dart';
import '../repositories/word_repository.dart';
import '../repositories/initial_seed_data.dart';
import '../services/local_storage_service.dart';
import '../services/tts_service.dart';
import '../services/srs_service.dart';

class AppProvider extends ChangeNotifier {
  final WordRepository repository = WordRepository();
  final LocalStorageService _local = LocalStorageService();
  final TtsService ttsService = TtsService();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Profile & Preferences
  String _username = 'Öğrenci';
  String get username => _username;

  int _totalPoints = 150;
  int get totalPoints => _totalPoints;

  int _streakDays = 3;
  int get streakDays => _streakDays;

  int _dailyGoal = 20;
  int get dailyGoal => _dailyGoal;

  double _speechRate = 0.95;
  double get speechRate => _speechRate;

  bool _isDarkTheme = false;
  bool get isDarkTheme => _isDarkTheme;

  // Words & Categories
  List<WordModel> get allWords => repository.words;
  List<CategoryModel> get allCategories => repository.categories;
  List<DailyStatsModel> get recentStats => repository.dailyStats;

  // Filter & Search
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedCategoryFilter = 'Tümü';
  String get selectedCategoryFilter => _selectedCategoryFilter;

  bool _onlyFavoritesFilter = false;
  bool get onlyFavoritesFilter => _onlyFavoritesFilter;

  bool _onlyLearnedFilter = false;
  bool get onlyLearnedFilter => _onlyLearnedFilter;

  List<WordModel> get filteredWords {
    return allWords.filter((word) {
      final matchesQuery = _searchQuery.trim().isEmpty ||
          word.english.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          word.turkish.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategoryFilter == 'Tümü' ||
          word.category.toLowerCase() == _selectedCategoryFilter.toLowerCase();
      final matchesFav = !_onlyFavoritesFilter || word.isFavorite;
      final matchesLearned = !_onlyLearnedFilter || word.isLearned;
      return matchesQuery && matchesCategory && matchesFav && matchesLearned;
    }).toList();
  }

  // Category Progress
  List<CategoryProgressModel> get categoryProgressList {
    return allCategories.map((cat) {
      final catWords = allWords.where((w) => w.category.toLowerCase() == cat.name.toLowerCase()).toList();
      final total = catWords.length;
      final learned = catWords.where((w) => w.isLearned).length;
      final percent = total > 0 ? ((learned * 100) ~/ total) : 0;
      return CategoryProgressModel(
        category: cat,
        totalWords: total,
        learnedWords: learned,
        progressPercent: percent,
      );
    }).toList();
  }

  // Today Reviewed
  int get todayReviewedCount {
    final todayStr = DateUtilsHelper.getTodayString();
    final stat = recentStats.firstWhere(
      (s) => s.dateString == todayStr,
      orElse: () => DailyStatsModel(dateString: todayStr),
    );
    return stat.wordsReviewed;
  }

  // Flashcard State
  List<WordModel> _flashcardWords = [];
  List<WordModel> get flashcardWords => _flashcardWords;

  int _currentFlashcardIndex = 0;
  int get currentFlashcardIndex => _currentFlashcardIndex;

  bool _isCardFlipped = false;
  bool get isCardFlipped => _isCardFlipped;

  bool _isAutoPlaying = false;
  bool get isAutoPlaying => _isAutoPlaying;

  Timer? _autoPlayTimer;

  // Quiz State
  List<QuizQuestionModel> _quizQuestions = [];
  List<QuizQuestionModel> get quizQuestions => _quizQuestions;

  int _currentQuizIndex = 0;
  int get currentQuizIndex => _currentQuizIndex;

  String? _selectedQuizAnswer;
  String? get selectedQuizAnswer => _selectedQuizAnswer;

  int _quizScore = 0;
  int get quizScore => _quizScore;

  int _quizCorrectCount = 0;
  int get quizCorrectCount => _quizCorrectCount;

  int _quizWrongCount = 0;
  int get quizWrongCount => _quizWrongCount;

  bool _isQuizCompleted = false;
  bool get isQuizCompleted => _isQuizCompleted;

  // Spelling State
  List<WordModel> _spellingWords = [];
  List<WordModel> get spellingWords => _spellingWords;

  int _currentSpellingIndex = 0;
  int get currentSpellingIndex => _currentSpellingIndex;

  String _spellingInput = '';
  String get spellingInput => _spellingInput;

  int _spellingHintCount = 0;
  int get spellingHintCount => _spellingHintCount;

  bool _isSpellingChecked = false;
  bool get isSpellingChecked => _isSpellingChecked;

  bool _isSpellingCorrect = false;
  bool get isSpellingCorrect => _isSpellingCorrect;

  // Listening State
  List<QuizQuestionModel> _listeningQuestions = [];
  List<QuizQuestionModel> get listeningQuestions => _listeningQuestions;

  int _currentListeningIndex = 0;
  int get currentListeningIndex => _currentListeningIndex;

  String? _selectedListeningAnswer;
  String? get selectedListeningAnswer => _selectedListeningAnswer;

  int _listeningScore = 0;
  int get listeningScore => _listeningScore;

  // Match Game State
  List<MatchCardModel> _matchCards = [];
  List<MatchCardModel> get matchCards => _matchCards;

  List<MatchCardModel> _selectedMatchCards = [];
  List<MatchCardModel> get selectedMatchCards => _selectedMatchCards;

  int _matchGameScore = 0;
  int get matchGameScore => _matchGameScore;

  int _matchGameSeconds = 0;
  int get matchGameSeconds => _matchGameSeconds;

  bool _isMatchGameWon = false;
  bool get isMatchGameWon => _isMatchGameWon;

  Timer? _matchTimer;

  // Speed Game State
  SpeedChallengeModel? _speedChallenge;
  SpeedChallengeModel? get speedChallenge => _speedChallenge;

  int _speedTimeRemaining = 45;
  int get speedTimeRemaining => _speedTimeRemaining;

  int _speedScore = 0;
  int get speedScore => _speedScore;

  int _speedStreak = 0;
  int get speedStreak => _speedStreak;

  bool _isSpeedGameOver = false;
  bool get isSpeedGameOver => _isSpeedGameOver;

  Timer? _speedTimer;

  // Achievements
  List<AchievementModel> get achievements {
    final learnedCount = allWords.where((w) => w.isLearned).length;
    return [
      AchievementModel(
        id: 'first_step',
        title: 'İlk Adım',
        description: 'İlk kelimeni öğren ve puan kazan',
        icon: '🌱',
        isUnlocked: learnedCount >= 1,
        progress: learnedCount.clamp(0, 1),
        maxProgress: 1,
      ),
      AchievementModel(
        id: 'vocab_explorer',
        title: 'Kelime Kâşifi',
        description: '10 farklı kelimeyi başarıyla öğren',
        icon: '🧭',
        isUnlocked: learnedCount >= 10,
        progress: learnedCount.clamp(0, 10),
        maxProgress: 10,
      ),
      AchievementModel(
        id: 'point_master',
        title: 'Puan Avcısı',
        description: '500 toplam çalışma puanına ulaş',
        icon: '⭐',
        isUnlocked: _totalPoints >= 500,
        progress: _totalPoints.clamp(0, 500),
        maxProgress: 500,
      ),
      AchievementModel(
        id: 'streak_fire',
        title: 'Ateşli Seri',
        description: '3 gün arka arkaya kesintisiz çalış',
        icon: '🔥',
        isUnlocked: _streakDays >= 3,
        progress: _streakDays.clamp(0, 3),
        maxProgress: 3,
      ),
      AchievementModel(
        id: 'vocab_master',
        title: 'Kelime Dehası',
        description: '25 kelimeyi tamamen öğren ve uzmanlaş',
        icon: '👑',
        isUnlocked: learnedCount >= 25,
        progress: learnedCount.clamp(0, 25),
        maxProgress: 25,
      ),
    ];
  }

  // Initialization
  Future<void> init() async {
    try {
      await repository.init().timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('Repository init error: $e');
    }

    try {
      await ttsService.init().timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('TTS init error: $e');
    }

    _username = _local.username;
    _totalPoints = _local.totalPoints;
    _streakDays = _local.streakDays;
    _dailyGoal = _local.dailyGoal;
    _speechRate = _local.speechRate;
    _isDarkTheme = _local.isDarkTheme;

    try {
      await ttsService.setSpeechRate(_speechRate).timeout(const Duration(seconds: 1));
    } catch (_) {}

    _isInitialized = true;
    notifyListeners();
  }

  // ==========================================
  // 1. FLASHCARD LOGIC
  // ==========================================
  void setupFlashcards({String? categoryName, bool onlyFavorites = false, bool shuffle = false}) {
    List<WordModel> list = allWords.where((word) {
      final matchCat = categoryName == null || categoryName == 'Tümü' || word.category.toLowerCase() == categoryName.toLowerCase();
      final matchFav = !onlyFavorites || word.isFavorite;
      return matchCat && matchFav;
    }).toList();

    if (shuffle) list.shuffle();
    _flashcardWords = list.isNotEmpty ? list : List.from(allWords);
    _currentFlashcardIndex = 0;
    _isCardFlipped = false;
    stopAutoPlay();
    notifyListeners();
  }

  void flipCard() {
    _isCardFlipped = !_isCardFlipped;
    notifyListeners();
  }

  void nextCard() {
    if (_flashcardWords.isEmpty) return;
    _isCardFlipped = false;
    if (_currentFlashcardIndex < _flashcardWords.length - 1) {
      _currentFlashcardIndex++;
    } else {
      _currentFlashcardIndex = 0;
    }
    notifyListeners();
  }

  void prevCard() {
    if (_flashcardWords.isEmpty) return;
    _isCardFlipped = false;
    if (_currentFlashcardIndex > 0) {
      _currentFlashcardIndex--;
    } else {
      _currentFlashcardIndex = _flashcardWords.length - 1;
    }
    notifyListeners();
  }

  void rateCard(SrsRating rating) {
    if (_flashcardWords.isEmpty || _currentFlashcardIndex >= _flashcardWords.length) return;
    final currentWord = _flashcardWords[_currentFlashcardIndex];
    final updatedWord = SrsService.calculateNextReview(currentWord, rating);

    repository.updateWord(updatedWord);

    final pointsEarned = switch (rating) {
      SrsRating.easy => 15,
      SrsRating.good => 10,
      SrsRating.hard => 5,
    };

    addPoints(pointsEarned);
    repository.recordStudySession(
      dateString: DateUtilsHelper.getTodayString(),
      reviewedCount: 1,
      learnedCount: (updatedWord.isLearned && !currentWord.isLearned) ? 1 : 0,
      correct: rating != SrsRating.hard ? 1 : 0,
      wrong: rating == SrsRating.hard ? 1 : 0,
      points: pointsEarned,
    );

    nextCard();
  }

  void toggleAutoPlay({int secondsInterval = 4}) {
    if (_isAutoPlaying) {
      stopAutoPlay();
    } else {
      _isAutoPlaying = true;
      notifyListeners();

      _autoPlayTimer = Timer.periodic(Duration(seconds: secondsInterval), (timer) {
        if (!_isAutoPlaying || _flashcardWords.isEmpty) {
          timer.cancel();
          return;
        }
        final currentWord = _flashcardWords.elementAtOrNull(_currentFlashcardIndex);
        if (currentWord != null) {
          ttsService.speak(currentWord.english);
        }
        _isCardFlipped = true;
        notifyListeners();

        Future.delayed(Duration(seconds: (secondsInterval / 2).round()), () {
          if (_isAutoPlaying) {
            nextCard();
          }
        });
      });
    }
  }

  void stopAutoPlay() {
    _isAutoPlaying = false;
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    notifyListeners();
  }

  // ==========================================
  // 2. QUIZ LOGIC
  // ==========================================
  void startQuiz({String? categoryName, int questionCount = 10}) {
    final pool = allWords.where((w) {
      return categoryName == null || categoryName == 'Tümü' || w.category.toLowerCase() == categoryName.toLowerCase();
    }).toList();

    final targetPool = pool.isNotEmpty ? pool : List<WordModel>.from(allWords);
    final shuffled = List<WordModel>.from(targetPool)..shuffle();
    final selectedWords = shuffled.take(questionCount).toList();

    final random = Random();
    _quizQuestions = selectedWords.map((targetWord) {
      final isEngToTr = random.nextBool();
      final correctAnswer = isEngToTr ? targetWord.turkish : targetWord.english;

      final distractors = targetPool
          .where((w) => w.id != targetWord.id)
          .toList()
        ..shuffle();
      final distractorTexts = distractors
          .take(3)
          .map((w) => isEngToTr ? w.turkish : w.english)
          .toList();

      final options = ([...distractorTexts, correctAnswer])..shuffle();
      return QuizQuestionModel(
        word: targetWord,
        options: options,
        correctOption: correctAnswer,
        isEngToTr: isEngToTr,
      );
    }).toList();

    _currentQuizIndex = 0;
    _selectedQuizAnswer = null;
    _quizScore = 0;
    _quizCorrectCount = 0;
    _quizWrongCount = 0;
    _isQuizCompleted = false;
    notifyListeners();
  }

  void submitQuizAnswer(String answer) {
    if (_selectedQuizAnswer != null || _currentQuizIndex >= _quizQuestions.length) return;
    _selectedQuizAnswer = answer;
    final currentQ = _quizQuestions[_currentQuizIndex];
    final isCorrect = answer == currentQ.correctOption;

    if (isCorrect) {
      _quizScore += 20;
      _quizCorrectCount += 1;
      addPoints(20);
      ttsService.speak(currentQ.word.english);
    } else {
      _quizWrongCount += 1;
    }

    final rating = isCorrect ? SrsRating.good : SrsRating.hard;
    final updatedWord = SrsService.calculateNextReview(currentQ.word, rating);
    repository.updateWord(updatedWord);

    repository.recordStudySession(
      dateString: DateUtilsHelper.getTodayString(),
      reviewedCount: 1,
      learnedCount: (updatedWord.isLearned && !currentQ.word.isLearned) ? 1 : 0,
      correct: isCorrect ? 1 : 0,
      wrong: isCorrect ? 0 : 1,
      points: isCorrect ? 20 : 0,
    );

    notifyListeners();
  }

  void nextQuizQuestion() {
    if (_currentQuizIndex < _quizQuestions.length - 1) {
      _currentQuizIndex++;
      _selectedQuizAnswer = null;
    } else {
      _isQuizCompleted = true;
    }
    notifyListeners();
  }

  // ==========================================
  // 3. SPELLING LOGIC
  // ==========================================
  void startSpellingMode({String? categoryName}) {
    final pool = allWords.where((w) {
      return categoryName == null || categoryName == 'Tümü' || w.category.toLowerCase() == categoryName.toLowerCase();
    }).toList();

    final targetPool = (pool.isNotEmpty ? pool : List<WordModel>.from(allWords))..shuffle();
    _spellingWords = targetPool;
    _currentSpellingIndex = 0;
    _spellingInput = '';
    _spellingHintCount = 0;
    _isSpellingChecked = false;
    _isSpellingCorrect = false;
    notifyListeners();
  }

  void updateSpellingInput(String input) {
    _spellingInput = input;
    _isSpellingChecked = false;
    notifyListeners();
  }

  void useSpellingHint() {
    if (_currentSpellingIndex >= _spellingWords.length) return;
    final target = _spellingWords[_currentSpellingIndex].english.trim();
    if (_spellingHintCount < target.length) {
      _spellingHintCount++;
      _spellingInput = target.substring(0, _spellingHintCount);
      notifyListeners();
    }
  }

  void checkSpelling() {
    if (_currentSpellingIndex >= _spellingWords.length) return;
    final currentWord = _spellingWords[_currentSpellingIndex];
    final target = currentWord.english.trim().toLowerCase();
    final user = _spellingInput.trim().toLowerCase();

    final isMatch = target == user;
    _isSpellingCorrect = isMatch;
    _isSpellingChecked = true;

    if (isMatch) {
      ttsService.speak(currentWord.english);
      addPoints(25);
      final updatedWord = SrsService.calculateNextReview(currentWord, SrsRating.easy);
      repository.updateWord(updatedWord);
      repository.recordStudySession(
        dateString: DateUtilsHelper.getTodayString(),
        reviewedCount: 1,
        learnedCount: (updatedWord.isLearned && !currentWord.isLearned) ? 1 : 0,
        correct: 1,
        wrong: 0,
        points: 25,
      );
    }
    notifyListeners();
  }

  void nextSpellingWord() {
    if (_currentSpellingIndex < _spellingWords.length - 1) {
      _currentSpellingIndex++;
    } else {
      _currentSpellingIndex = 0;
    }
    _spellingInput = '';
    _spellingHintCount = 0;
    _isSpellingChecked = false;
    _isSpellingCorrect = false;
    notifyListeners();
  }

  // ==========================================
  // 4. LISTENING LOGIC
  // ==========================================
  void startListeningMode({String? categoryName}) {
    final pool = allWords.where((w) {
      return categoryName == null || categoryName == 'Tümü' || w.category.toLowerCase() == categoryName.toLowerCase();
    }).toList();

    final targetPool = pool.isNotEmpty ? pool : List<WordModel>.from(allWords);
    final shuffled = List<WordModel>.from(targetPool)..shuffle();
    final selectedWords = shuffled.take(10).toList();

    _listeningQuestions = selectedWords.map((targetWord) {
      final correctAnswer = targetWord.turkish;
      final distractors = targetPool
          .where((w) => w.id != targetWord.id)
          .toList()
        ..shuffle();
      final distractorTexts = distractors.take(3).map((w) => w.turkish).toList();
      final options = ([...distractorTexts, correctAnswer])..shuffle();

      return QuizQuestionModel(
        word: targetWord,
        options: options,
        correctOption: correctAnswer,
        isEngToTr: true,
      );
    }).toList();

    _currentListeningIndex = 0;
    _selectedListeningAnswer = null;
    _listeningScore = 0;

    if (_listeningQuestions.isNotEmpty) {
      ttsService.speak(_listeningQuestions.first.word.english);
    }
    notifyListeners();
  }

  void playCurrentListeningAudio() {
    if (_currentListeningIndex < _listeningQuestions.length) {
      ttsService.speak(_listeningQuestions[_currentListeningIndex].word.english);
    }
  }

  void submitListeningAnswer(String answer) {
    if (_selectedListeningAnswer != null || _currentListeningIndex >= _listeningQuestions.length) return;
    _selectedListeningAnswer = answer;
    final currentQ = _listeningQuestions[_currentListeningIndex];
    final isCorrect = answer == currentQ.correctOption;

    if (isCorrect) {
      _listeningScore += 20;
      addPoints(20);
    }

    final rating = isCorrect ? SrsRating.good : SrsRating.hard;
    final updatedWord = SrsService.calculateNextReview(currentQ.word, rating);
    repository.updateWord(updatedWord);

    repository.recordStudySession(
      dateString: DateUtilsHelper.getTodayString(),
      reviewedCount: 1,
      learnedCount: (updatedWord.isLearned && !currentQ.word.isLearned) ? 1 : 0,
      correct: isCorrect ? 1 : 0,
      wrong: isCorrect ? 0 : 1,
      points: isCorrect ? 20 : 0,
    );

    notifyListeners();
  }

  void nextListeningQuestion() {
    if (_currentListeningIndex < _listeningQuestions.length - 1) {
      _currentListeningIndex++;
      _selectedListeningAnswer = null;
      playCurrentListeningAudio();
    }
    notifyListeners();
  }

  // ==========================================
  // 5. MATCH GAME LOGIC
  // ==========================================
  void startMatchGame({int pairCount = 5}) {
    final shuffledWords = (List<WordModel>.from(allWords)..shuffle()).take(pairCount).toList();
    final selectedWords = shuffledWords.isNotEmpty ? shuffledWords : InitialSeedData.words.take(pairCount).toList();

    final cards = <MatchCardModel>[];
    for (final word in selectedWords) {
      cards.add(MatchCardModel(
        id: 'word__en',
        wordId: word.id,
        text: word.english,
        isEnglish: true,
      ));
      cards.add(MatchCardModel(
        id: 'word__tr',
        wordId: word.id,
        text: word.turkish,
        isEnglish: false,
      ));
    }

    _matchCards = cards..shuffle();
    _selectedMatchCards = [];
    _matchGameScore = 0;
    _matchGameSeconds = 0;
    _isMatchGameWon = false;

    _matchTimer?.cancel();
    _matchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isMatchGameWon) {
        _matchGameSeconds++;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });

    notifyListeners();
  }

  void onMatchCardClicked(MatchCardModel clickedCard) {
    if (clickedCard.isMatched || clickedCard.isSelected || _selectedMatchCards.length >= 2) return;

    final currentSelected = [..._selectedMatchCards, clickedCard];
    _selectedMatchCards = currentSelected;

    _matchCards = _matchCards.map((c) {
      return c.id == clickedCard.id ? c.copyWith(isSelected: true) : c;
    }).toList();

    notifyListeners();

    if (currentSelected.length == 2) {
      final first = currentSelected[0];
      final second = currentSelected[1];

      if (first.wordId == second.wordId && first.isEnglish != second.isEnglish) {
        // MATCH!
        ttsService.speak(first.isEnglish ? first.text : second.text);
        _matchGameScore += 30;
        addPoints(30);

        _matchCards = _matchCards.map((c) {
          return c.wordId == first.wordId ? c.copyWith(isMatched: true, isSelected: false) : c;
        }).toList();
        _selectedMatchCards = [];

        if (_matchCards.every((c) => c.isMatched)) {
          _isMatchGameWon = true;
          _matchTimer?.cancel();
          addPoints(100); // Bonus
        }
        notifyListeners();
      } else {
        // WRONG MATCH
        _matchCards = _matchCards.map((c) {
          return (c.id == first.id || c.id == second.id) ? c.copyWith(isError: true) : c;
        }).toList();
        notifyListeners();

        Future.delayed(const Duration(milliseconds: 700), () {
          _matchCards = _matchCards.map((c) {
            return (c.id == first.id || c.id == second.id)
                ? c.copyWith(isSelected: false, isError: false)
                : c;
          }).toList();
          _selectedMatchCards = [];
          notifyListeners();
        });
      }
    }
  }

  // ==========================================
  // 6. SPEED GAME LOGIC
  // ==========================================
  void startSpeedGame() {
    _speedScore = 0;
    _speedStreak = 0;
    _speedTimeRemaining = 45;
    _isSpeedGameOver = false;
    _generateNextSpeedChallenge();

    _speedTimer?.cancel();
    _speedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_speedTimeRemaining > 0) {
        _speedTimeRemaining--;
        notifyListeners();
      } else {
        _isSpeedGameOver = true;
        timer.cancel();
        addPoints(_speedScore);
        notifyListeners();
      }
    });

    notifyListeners();
  }

  void _generateNextSpeedChallenge() {
    final words = allWords.isNotEmpty ? allWords : InitialSeedData.words;
    final random = Random();
    final target = words[random.nextInt(words.length)];
    final isCorrect = random.nextBool();

    String displayedTr = target.turkish;
    if (!isCorrect) {
      final others = words.where((w) => w.id != target.id).toList();
      if (others.isNotEmpty) {
        displayedTr = others[random.nextInt(others.length)].turkish;
      }
    }

    _speedChallenge = SpeedChallengeModel(
      english: target.english,
      displayedTurkish: displayedTr,
      isCorrectMatch: isCorrect,
    );
    notifyListeners();
  }

  void answerSpeedGame(bool userSaysCorrect) {
    if (_isSpeedGameOver || _speedChallenge == null) return;
    final isAnswerRight = userSaysCorrect == _speedChallenge!.isCorrectMatch;

    if (isAnswerRight) {
      _speedStreak++;
      final multiplier = (_speedStreak ~/ 3) + 1;
      _speedScore += 10 * multiplier;
    } else {
      _speedStreak = 0;
    }

    _generateNextSpeedChallenge();
  }

  // ==========================================
  // 7. CRUD & DATA MANAGEMENT
  // ==========================================
  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setSelectedCategoryFilter(String c) {
    _selectedCategoryFilter = c;
    notifyListeners();
  }

  void toggleFavoritesFilter() {
    _onlyFavoritesFilter = !_onlyFavoritesFilter;
    notifyListeners();
  }

  void toggleLearnedFilter() {
    _onlyLearnedFilter = !_onlyLearnedFilter;
    notifyListeners();
  }

  void toggleFavorite(WordModel word) {
    final updated = word.copyWith(isFavorite: !word.isFavorite);
    repository.updateWord(updated);
    notifyListeners();
  }

  void addWord({
    required String english,
    required String turkish,
    required String category,
    String example = '',
    String exampleTr = '',
    String definition = '',
  }) {
    final maxId = allWords.fold<int>(0, (max, w) => w.id > max ? w.id : max);
    final newWord = WordModel(
      id: maxId + 1,
      english: english.trim(),
      turkish: turkish.trim(),
      category: category.trim().isNotEmpty ? category.trim() : 'Temel Seviye',
      exampleSentence: example.trim(),
      exampleSentenceTr: exampleTr.trim(),
      definition: definition.trim(),
    );
    repository.insertWord(newWord);
    notifyListeners();
  }

  void updateWord(WordModel word) {
    repository.updateWord(word);
    notifyListeners();
  }

  void deleteWord(int id) {
    repository.deleteWord(id);
    notifyListeners();
  }

  void addCategory({required String name, required String description, String colorHex = '#4F46E5'}) {
    final maxId = allCategories.fold<int>(0, (max, c) => c.id > max ? c.id : max);
    final newCat = CategoryModel(
      id: maxId + 1,
      name: name.trim(),
      description: description.trim(),
      colorHex: colorHex,
    );
    repository.insertCategory(newCat);
    notifyListeners();
  }

  void deleteCategory(int id) {
    repository.deleteCategory(id);
    notifyListeners();
  }

  void resetAllDataToDefault() {
    repository.resetToDefault();
    notifyListeners();
  }

  // ==========================================
  // 8. PROFILE & SETTINGS
  // ==========================================
  void setUsername(String name) {
    _username = name;
    _local.setUsername(name);
    notifyListeners();
  }

  void setDailyGoal(int goal) {
    _dailyGoal = goal;
    _local.setDailyGoal(goal);
    notifyListeners();
  }

  void setSpeechRate(double rate) {
    _speechRate = rate;
    _local.setSpeechRate(rate);
    ttsService.setSpeechRate(rate);
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    _local.setDarkTheme(_isDarkTheme);
    notifyListeners();
  }

  void addPoints(int points) {
    _totalPoints += points;
    _local.setTotalPoints(_totalPoints);
    notifyListeners();
  }

  @override
  void dispose() {
    stopAutoPlay();
    _matchTimer?.cancel();
    _speedTimer?.cancel();
    super.dispose();
  }
}

extension IterableFilterExtension<E> on Iterable<E> {
  Iterable<E> filter(bool Function(E element) test) => where(test);
}
