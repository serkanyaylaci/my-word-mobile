import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  TtsService._internal();

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await Future.any([
        Future.wait([
          _flutterTts.setLanguage('en-US'),
          _flutterTts.setSpeechRate(0.5),
          _flutterTts.setVolume(1.0),
          _flutterTts.setPitch(1.0),
        ]),
        Future.delayed(const Duration(seconds: 2)),
      ]);
      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS Init Error: $e');
    }
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      if (!_isInitialized) await init();
      await _flutterTts.stop();
      await _flutterTts.speak(text).timeout(const Duration(seconds: 3), onTimeout: () => null);
    } catch (e) {
      debugPrint('TTS Speak Error: $e');
    }
  }

  Future<void> setSpeechRate(double rate) async {
    try {
      if (!_isInitialized) await init();
      // Map rate (0.5 to 1.5) to Flutter TTS scale (0.25 to 0.75)
      double scaled = (rate * 0.5).clamp(0.1, 1.0);
      await _flutterTts.setSpeechRate(scaled).timeout(const Duration(seconds: 1), onTimeout: () => null);
    } catch (e) {
      debugPrint('TTS Rate Error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TTS Stop Error: ');
    }
  }
}
