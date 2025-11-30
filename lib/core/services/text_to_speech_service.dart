import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-Speech servisi
class TextToSpeechService {
  static final TextToSpeechService _instance = TextToSpeechService._internal();
  factory TextToSpeechService() => _instance;
  TextToSpeechService._internal();

  late FlutterTts _flutterTts;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  double _speechRate = 0.5;
  double _volume = 1.0;
  double _pitch = 1.0;
  String _language = 'tr-TR';

  /// Servisi başlat
  Future<void> init() async {
    if (_isInitialized) return;

    _flutterTts = FlutterTts();
    
    // Platform ayarları
    await _flutterTts.setLanguage(_language);
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setVolume(_volume);
    await _flutterTts.setPitch(_pitch);
    
    // Event listener'lar
    _flutterTts.setStartHandler(() {
      _isPlaying = true;
      _isPaused = false;
    });
    
    _flutterTts.setCompletionHandler(() {
      _isPlaying = false;
      _isPaused = false;
    });
    
    _flutterTts.setErrorHandler((msg) {
      print('💥 TTS hatası: $msg');
      _isPlaying = false;
      _isPaused = false;
    });
    
    _isInitialized = true;
  }

  /// Metni konuş
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('💥 Konuşma hatası: $e');
    }
  }

  /// Duraklat
  Future<void> pause() async {
    if (!_isInitialized) return;

    try {
      await _flutterTts.pause();
      _isPaused = true;
    } catch (e) {
      print('💥 Duraklatma hatası: $e');
    }
  }

  /// Devam ettir
  Future<void> resume() async {
    if (!_isInitialized) return;

    try {
      await _flutterTts.speak(''); // Resume için boş metin
      _isPaused = false;
    } catch (e) {
      print('💥 Devam ettirme hatası: $e');
    }
  }

  /// Durdur
  Future<void> stop() async {
    if (!_isInitialized) return;

    try {
      await _flutterTts.stop();
      _isPlaying = false;
      _isPaused = false;
    } catch (e) {
      print('💥 Durdurma hatası: $e');
    }
  }

  /// Konuşma hızını ayarla (0.0 - 1.0)
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.0, 1.0);
    if (_isInitialized) {
      await _flutterTts.setSpeechRate(_speechRate);
    }
  }

  /// Ses seviyesini ayarla (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    if (_isInitialized) {
      await _flutterTts.setVolume(_volume);
    }
  }

  /// Ses tonunu ayarla (0.5 - 2.0)
  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    if (_isInitialized) {
      await _flutterTts.setPitch(_pitch);
    }
  }

  /// Dil ayarla
  Future<void> setLanguage(String language) async {
    _language = language;
    if (_isInitialized) {
      await _flutterTts.setLanguage(_language);
    }
  }

  /// Durum getter'ları
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  double get speechRate => _speechRate;
  double get volume => _volume;
  double get pitch => _pitch;
  String get language => _language;

  /// Mevcut dilleri al
  Future<List<String>> getAvailableLanguages() async {
    if (!_isInitialized) {
      await init();
    }

    try {
      final languages = await _flutterTts.getLanguages;
      return List<String>.from(languages ?? []);
    } catch (e) {
      print('💥 Dil listesi alma hatası: $e');
      return ['tr-TR', 'en-US'];
    }
  }
}

