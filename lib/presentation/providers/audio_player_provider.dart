import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:haber_merkezi/core/services/audio_player_service.dart';
import 'package:haber_merkezi/core/services/podcast_service.dart';

import 'package:flutter/foundation.dart';
/// Audio Player State
class AudioPlayerState {
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration? duration;
  final double speed;
  final double volume;
  final PodcastEpisode? currentEpisode;
  final String? error;

  AudioPlayerState({
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration,
    this.speed = 1.0,
    this.volume = 1.0,
    this.currentEpisode,
    this.error,
  });

  AudioPlayerState copyWith({
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    double? speed,
    double? volume,
    PodcastEpisode? currentEpisode,
    String? error,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      volume: volume ?? this.volume,
      currentEpisode: currentEpisode ?? this.currentEpisode,
      error: error ?? this.error,
    );
  }

  /// Pozisyon yüzdesi (0.0 - 1.0)
  double get progress {
    if (duration == null || duration!.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration!.inMilliseconds;
  }

  /// Kalan süre
  Duration get remaining {
    if (duration == null) return Duration.zero;
    return duration! - position;
  }
}

/// Audio Player Provider
class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  final AudioPlayerService _audioService;

  AudioPlayerNotifier(this._audioService) : super(AudioPlayerState()) {
    _initialize();
  }

  /// Servisi başlat ve stream'leri dinle
  Future<void> _initialize() async {
    try {
      await _audioService.initialize();
      
      // Player state değişikliklerini dinle
      _audioService.playerStateStream.listen((playerState) {
        state = state.copyWith(
          isPlaying: playerState.playing,
          isLoading: playerState.processingState == ProcessingState.loading ||
              playerState.processingState == ProcessingState.buffering,
        );
      });

      // Pozisyon değişikliklerini dinle
      _audioService.positionStream.listen((position) {
        if (position != null) {
          state = state.copyWith(position: position);
        }
      });

      // Duration değişikliklerini dinle
      _audioService.durationStream.listen((duration) {
        if (duration != null) {
          state = state.copyWith(duration: duration);
        }
      });

      // Speed değişikliklerini dinle
      _audioService.speedStream.listen((speed) {
        debugPrint('🔊 DEBUG: Speed stream değişti: $speed');
        state = state.copyWith(speed: speed);
      });

      // Volume değişikliklerini dinle
      _audioService.volumeStream.listen((volume) {
        debugPrint('🔊 DEBUG: Volume stream değişti: $volume');
        state = state.copyWith(volume: volume);
      });
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Podcast'i yükle ve oynat
  Future<void> loadAndPlay(PodcastEpisode episode) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentEpisode: episode,
      );

      final duration = await _audioService.loadAudio(
        episode.audioUrl,
        title: episode.title,
        artist: 'Haber Merkezi',
      );

      if (duration != null) {
        state = state.copyWith(duration: duration);
        await play();
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Podcast yüklenemedi: $e',
        isLoading: false,
      );
    }
  }

  /// Oynat
  Future<void> play() async {
    try {
      await _audioService.play();
      state = state.copyWith(isPlaying: true, error: null);
    } catch (e) {
      state = state.copyWith(error: 'Oynatma hatası: $e');
    }
  }

  /// Duraklat
  Future<void> pause() async {
    try {
      await _audioService.pause();
      state = state.copyWith(isPlaying: false);
    } catch (e) {
      state = state.copyWith(error: 'Duraklatma hatası: $e');
    }
  }

  /// Durdur
  Future<void> stop() async {
    try {
      await _audioService.stop();
      state = state.copyWith(
        isPlaying: false,
        position: Duration.zero,
      );
    } catch (e) {
      state = state.copyWith(error: 'Durdurma hatası: $e');
    }
  }

  /// Pozisyona git
  Future<void> seek(Duration position) async {
    try {
      await _audioService.seek(position);
      state = state.copyWith(position: position);
    } catch (e) {
      state = state.copyWith(error: 'Atlama hatası: $e');
    }
  }

  /// 10 saniye ileri git
  Future<void> seekForward() async {
    final newPosition = state.position + const Duration(seconds: 10);
    if (state.duration != null && newPosition <= state.duration!) {
      await seek(newPosition);
    }
  }

  /// 10 saniye geri git
  Future<void> seekBackward() async {
    final newPosition = state.position - const Duration(seconds: 10);
    if (newPosition >= Duration.zero) {
      await seek(newPosition);
    }
  }

  /// Oynatma hızını değiştir
  Future<void> setSpeed(double speed) async {
    try {
      debugPrint('🔊 DEBUG: Speed değiştiriliyor: $speed');
      await _audioService.setSpeed(speed);
      debugPrint('🔊 DEBUG: Service setSpeed tamamlandı');
      state = state.copyWith(speed: speed);
      debugPrint('🔊 DEBUG: State güncellendi, yeni speed: ${state.speed}');
    } catch (e) {
      debugPrint('🔊 DEBUG: Speed ayarlama hatası: $e');
      state = state.copyWith(error: 'Hız ayarlama hatası: $e');
    }
  }

  /// Ses seviyesini ayarla
  Future<void> setVolume(double volume) async {
    try {
      debugPrint('🔊 DEBUG: Volume değiştiriliyor: $volume');
      await _audioService.setVolume(volume);
      debugPrint('🔊 DEBUG: Service setVolume tamamlandı');
      state = state.copyWith(volume: volume);
      debugPrint('🔊 DEBUG: State güncellendi, yeni volume: ${state.volume}');
    } catch (e) {
      debugPrint('🔊 DEBUG: Volume ayarlama hatası: $e');
      state = state.copyWith(error: 'Ses seviyesi ayarlama hatası: $e');
    }
  }

  /// Play/Pause toggle
  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}

/// Audio Player Provider
final audioPlayerProvider = StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
  return AudioPlayerNotifier(AudioPlayerService());
});

/// Podcast Service Provider
final podcastServiceProvider = Provider<PodcastService>((ref) {
  return PodcastService();
});

/// Podcast Episodes Provider (belirli bir feed için)
final podcastEpisodesProvider = FutureProvider.family<List<PodcastEpisode>, String>((ref, feedUrl) async {
  final podcastService = ref.watch(podcastServiceProvider);
  return await podcastService.fetchPodcastFeed(feedUrl);
});