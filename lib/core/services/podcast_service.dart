import 'package:dio/dio.dart';
import 'package:xml/xml.dart';
import 'package:haber_merkezi/domain/entities/article.dart';
import 'package:haber_merkezi/core/services/audio_player_service.dart';

/// Podcast RSS feed'lerini yönetmek için servis
class PodcastService {
  static final PodcastService _instance = PodcastService._internal();
  factory PodcastService() => _instance;
  PodcastService._internal();

  final Dio _dio = Dio();
  final AudioPlayerService _audioPlayer = AudioPlayerService();

  /// Podcast RSS feed'ini parse et
  Future<List<PodcastEpisode>> fetchPodcastFeed(String feedUrl) async {
    try {
      final response = await _dio.get(feedUrl);
      final document = XmlDocument.parse(response.data);
      
      final episodes = <PodcastEpisode>[];
      final items = document.findAllElements('item');
      
      for (var item in items) {
        try {
          final episode = _parseEpisode(item);
          if (episode != null) {
            episodes.add(episode);
          }
        } catch (e) {
          debugPrint('Episode parse error: $e');
        }
      }
      
      return episodes;
    } catch (e) {
      debugPrint('Podcast feed fetch error: $e');
      return [];
    }
  }

  /// XML item'dan podcast episode oluştur
  PodcastEpisode? _parseEpisode(XmlElement item) {
    try {
      final title = item.findElements('title').firstOrNull?.innerText ?? '';
      final description = item.findElements('description').firstOrNull?.innerText ?? '';
      final pubDate = item.findElements('pubDate').firstOrNull?.innerText ?? '';
      
      // Audio URL'sini bul (enclosure tag)
      final enclosure = item.findElements('enclosure').firstOrNull;
      final audioUrl = enclosure?.getAttribute('url') ?? '';
      final duration = enclosure?.getAttribute('length') ?? '';
      
      // iTunes namespace için
      final itunesImage = item.findElements('itunes:image').firstOrNull?.getAttribute('href');
      final itunesDuration = item.findElements('itunes:duration').firstOrNull?.innerText;
      
      if (audioUrl.isEmpty) return null;
      
      return PodcastEpisode(
        title: title,
        description: description,
        audioUrl: audioUrl,
        pubDate: pubDate,
        duration: itunesDuration ?? duration,
        imageUrl: itunesImage,
      );
    } catch (e) {
      debugPrint('Parse episode error: $e');
      return null;
    }
  }

  /// Podcast'i oynat
  Future<void> playPodcast(PodcastEpisode episode) async {
    try {
      await _audioPlayer.loadAudio(
        episode.audioUrl,
        title: episode.title,
        artist: 'Haber Merkezi Podcast',
      );
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Play podcast error: $e');
    }
  }

  /// Podcast playlist'i oluştur
  Future<void> playPlaylist(List<PodcastEpisode> episodes) async {
    try {
      final items = episodes.map((ep) => {
        'url': ep.audioUrl,
        'title': ep.title,
        'artist': 'Haber Merkezi',
      }).toList();
      
      await _audioPlayer.loadPlaylist(items);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Play playlist error: $e');
    }
  }

  /// Article'dan podcast episode'a dönüştür (eğer audio link varsa)
  PodcastEpisode? articleToPodcast(Article article) {
    // Article içinde audio URL varsa podcast'e dönüştür
    // Bu özellik gelecekte genişletilebilir
    if (article.description.contains('audio') ||
        article.description.contains('podcast')) {
      return PodcastEpisode(
        title: article.title,
        description: article.description,
        audioUrl: '', // Article'dan audio URL çıkar
        pubDate: article.publishedDate.toString(),
        imageUrl: article.imageUrl,
      );
    }
    return null;
  }

  /// Popüler podcast feed URL'leri
  static const List<String> popularPodcastFeeds = [
    // Türkçe podcast feed'leri buraya eklenebilir
    'https://feeds.feedburner.com/example-podcast',
  ];
}

/// Podcast Episode entity
class PodcastEpisode {
  final String title;
  final String description;
  final String audioUrl;
  final String pubDate;
  final String? duration;
  final String? imageUrl;

  PodcastEpisode({
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.pubDate,
    this.duration,
    this.imageUrl,
  });

  /// Duration'u insan okunabilir formata çevir
  String get formattedDuration {
    if (duration == null) return '';
    
    try {
      // Eğer saniye cinsinden ise
      final seconds = int.tryParse(duration!);
      if (seconds != null) {
        final minutes = seconds ~/ 60;
        final remainingSeconds = seconds % 60;
        return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
      }
      
      // Zaten formatlanmış ise (HH:MM:SS)
      return duration!;
    } catch (e) {
      return duration ?? '';
    }
  }

  /// Yayın tarihini formatla
  String get formattedPubDate {
    try {
      final date = DateTime.parse(pubDate);
      return '${date.day}.${date.month}.${date.year}';
    } catch (e) {
      return pubDate;
    }
  }
}