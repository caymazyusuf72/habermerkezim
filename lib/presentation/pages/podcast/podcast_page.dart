import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haber_merkezi/presentation/providers/audio_player_provider.dart';
import 'package:haber_merkezi/core/services/podcast_service.dart';
import 'package:haber_merkezi/presentation/widgets/audio_player_widget.dart';

/// Podcast Ana Sayfası
class PodcastPage extends ConsumerStatefulWidget {
  const PodcastPage({super.key});

  @override
  ConsumerState<PodcastPage> createState() => _PodcastPageState();
}

class _PodcastPageState extends ConsumerState<PodcastPage> {
  final TextEditingController _feedUrlController = TextEditingController();
  List<PodcastEpisode> _episodes = [];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _feedUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadPodcastFeed(String feedUrl) async {
    if (feedUrl.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final podcastService = ref.read(podcastServiceProvider);
      final episodes = await podcastService.fetchPodcastFeed(feedUrl);
      
      setState(() {
        _episodes = episodes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Podcast feed yüklenemedi: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioPlayerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Podcast Haberleri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Podcast Nasıl Eklenir?'),
                  content: const Text(
                    'RSS feed URL\'sini aşağıdaki alana yapıştırarak podcast\'leri dinleyebilirsiniz.\n\n'
                    'Örnek:\n'
                    'https://feeds.feedburner.com/example-podcast',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tamam'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Feed URL Input
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _feedUrlController,
                    decoration: InputDecoration(
                      hintText: 'Podcast RSS Feed URL',
                      prefixIcon: const Icon(Icons.rss_feed),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    onSubmitted: _loadPodcastFeed,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.search),
                  onPressed: () => _loadPodcastFeed(_feedUrlController.text),
                ),
              ],
            ),
          ),

          // Sample Feeds
          if (_episodes.isEmpty && !_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Popüler Podcast Feed\'leri',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SampleFeedCard(
                    title: 'Örnek Podcast Feed',
                    description: 'Haber ve gündem podcast\'leri',
                    feedUrl: 'https://feeds.feedburner.com/example',
                    onTap: () {
                      _feedUrlController.text = 'https://feeds.feedburner.com/example';
                      _loadPodcastFeed('https://feeds.feedburner.com/example');
                    },
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Episodes List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () => _loadPodcastFeed(_feedUrlController.text),
                                child: const Text('Tekrar Dene'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _episodes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.podcasts,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Podcast feed URL\'si girin',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _episodes.length,
                            itemBuilder: (context, index) {
                              final episode = _episodes[index];
                              final isCurrentEpisode =
                                  audioState.currentEpisode?.audioUrl == episode.audioUrl;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: episode.imageUrl != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            episode.imageUrl!,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.headphones),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.headphones),
                                        ),
                                  title: Text(
                                    episode.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: isCurrentEpisode
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isCurrentEpisode
                                          ? Theme.of(context).primaryColor
                                          : null,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        episode.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            episode.formattedDuration,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Icon(
                                            Icons.calendar_today,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            episode.formattedPubDate,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: isCurrentEpisode && audioState.isPlaying
                                      ? IconButton(
                                          icon: const Icon(Icons.pause_circle_filled),
                                          iconSize: 48,
                                          onPressed: () => ref
                                              .read(audioPlayerProvider.notifier)
                                              .pause(),
                                        )
                                      : IconButton(
                                          icon: const Icon(Icons.play_circle_filled),
                                          iconSize: 48,
                                          onPressed: () {
                                            ref
                                                .read(audioPlayerProvider.notifier)
                                                .loadAndPlay(episode);
                                          },
                                        ),
                                  onTap: () {
                                    ref
                                        .read(audioPlayerProvider.notifier)
                                        .loadAndPlay(episode);
                                  },
                                ),
                              );
                            },
                          ),
          ),

          // Mini Player
          if (audioState.currentEpisode != null)
            const MiniAudioPlayer(),
        ],
      ),
    );
  }
}

/// Sample Feed Card Widget
class _SampleFeedCard extends StatelessWidget {
  final String title;
  final String description;
  final String feedUrl;
  final VoidCallback onTap;

  const _SampleFeedCard({
    required this.title,
    required this.description,
    required this.feedUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.podcasts,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}