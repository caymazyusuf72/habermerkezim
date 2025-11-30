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
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Başlık
            Row(
              children: [
                Icon(
                  Icons.headphones_rounded,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sesli Okuma',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Kontrol butonları
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Play/Pause butonu - daha büyük ve modern
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _togglePlayPause,
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlaying && !_isPaused
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Stop butonu
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isPlaying ? _stop : null,
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _isPlaying 
                            ? Colors.red.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isPlaying 
                              ? Colors.red.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.stop_rounded,
                        color: _isPlaying ? Colors.red : Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Ayarlar - Modern slider tasarımı
            _buildModernSlider(
              context,
              label: 'Hız',
              icon: Icons.speed_rounded,
              value: _ttsService.speechRate,
              min: 0.25,
              max: 1.0,
              divisions: 15,
              onChanged: (value) {
                _ttsService.setSpeechRate(value);
                setState(() {});
              },
              formatValue: (value) => '${(value * 100).toInt()}%',
            ),
            
            const SizedBox(height: 20),
            
            _buildModernSlider(
              context,
              label: 'Ses',
              icon: Icons.volume_up_rounded,
              value: _ttsService.volume,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              onChanged: (value) {
                _ttsService.setVolume(value);
                setState(() {});
              },
              formatValue: (value) => '${(value * 100).toInt()}%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernSlider(
    BuildContext context, {
    required String label,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String Function(double) formatValue,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label ve değer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                formatValue(value),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.primaryBlue,
            inactiveTrackColor: AppTheme.primaryBlue.withOpacity(0.2),
            thumbColor: AppTheme.primaryBlue,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

