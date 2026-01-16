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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Başlık - daha kompakt
            Row(
              children: [
                Icon(
                  Icons.headphones_rounded,
                  color: AppTheme.primaryBlue,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Sesli Okuma',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 14),
            
            // Kontrol butonları - daha küçük
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Play/Pause butonu
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _togglePlayPause,
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlaying && !_isPaused
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Stop butonu
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isPlaying ? _stop : null,
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _isPlaying 
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isPlaying 
                              ? Colors.red.withValues(alpha: 0.3)
                              : Colors.grey.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.stop_rounded,
                        color: _isPlaying ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Ayarlar - yan yana kompakt slider'lar
            Row(
              children: [
                // Hız slider
                Expanded(
                  child: _buildCompactSlider(
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
                ),
                
                const SizedBox(width: 12),
                
                // Ses slider
                Expanded(
                  child: _buildCompactSlider(
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactSlider(
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
        // Label ve değer - kompakt
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                formatValue(value),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 6),
        
        // Slider - daha ince
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.primaryBlue,
            inactiveTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
            thumbColor: AppTheme.primaryBlue,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            trackHeight: 3,
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

