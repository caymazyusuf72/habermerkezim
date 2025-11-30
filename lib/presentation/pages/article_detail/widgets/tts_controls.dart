import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/text_to_speech_service.dart';
import '../../../../domain/entities/article.dart';
import '../../../themes/app_theme.dart';

/// TTS kontrolleri widget'ı
class TtsControls extends ConsumerStatefulWidget {
  final Article article;

  const TtsControls({
    super.key,
    required this.article,
  });

  @override
  ConsumerState<TtsControls> createState() => _TtsControlsState();
}

class _TtsControlsState extends ConsumerState<TtsControls> {
  final TextToSpeechService _ttsService = TextToSpeechService();
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await _ttsService.init();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (!_isInitialized) {
      await _initializeTts();
    }

    if (_isPlaying && !_isPaused) {
      await _ttsService.pause();
      setState(() {
        _isPaused = true;
      });
    } else if (_isPaused) {
      await _ttsService.resume();
      setState(() {
        _isPaused = false;
      });
    } else {
      // Metni hazırla ve oynat
      final text = _prepareText();
      await _ttsService.speak(text);
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
    }
  }

  Future<void> _stop() async {
    await _ttsService.stop();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
    });
  }

  String _prepareText() {
    // HTML tag'lerini temizle
    String text = widget.article.content ?? widget.article.description;
    text = text.replaceAll(RegExp(r'<[^>]*>'), ' ');
    text = text.replaceAll(RegExp(r'\s+'), ' ');
    return text.trim();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Play/Pause butonu
                IconButton(
                  onPressed: _togglePlayPause,
                  icon: Icon(
                    _isPlaying && !_isPaused
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_filled_rounded,
                    size: 48,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Stop butonu
                IconButton(
                  onPressed: _isPlaying ? _stop : null,
                  icon: const Icon(Icons.stop_circle_rounded),
                  iconSize: 32,
                  color: Colors.red,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Ayarlar - Column ile dikey yerleşim (overflow önlemek için)
            Column(
              children: [
                // Hız
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Hız',
                        style: theme.textTheme.bodySmall,
                      ),
                      Slider(
                        value: _ttsService.speechRate,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        label: (_ttsService.speechRate * 100).toInt().toString(),
                        onChanged: (value) {
                          _ttsService.setSpeechRate(value);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Ses
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ses',
                        style: theme.textTheme.bodySmall,
                      ),
                      Slider(
                        value: _ttsService.volume,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        label: (_ttsService.volume * 100).toInt().toString(),
                        onChanged: (value) {
                          _ttsService.setVolume(value);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

