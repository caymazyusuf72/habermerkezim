/// RSS feed kaynağını temsil eden domain entity sınıfı
/// Clean Architecture'da business logic katmanında yer alır
class RssFeed {
  final String id;
  final String url;
  final String title;
  final String description;
  final String category;
  final String language;
  final DateTime? lastFetchTime;
  final DateTime? lastBuildDate;
  final bool isActive;
  final String feedFormat; // 'rss' veya 'atom'

  const RssFeed({
    required this.id,
    required this.url,
    required this.title,
    required this.description,
    required this.category,
    this.language = 'tr',
    this.lastFetchTime,
    this.lastBuildDate,
    this.isActive = true,
    this.feedFormat = 'rss',
  });

  /// RssFeed kopyalama methodu - immutable pattern
  RssFeed copyWith({
    String? id,
    String? url,
    String? title,
    String? description,
    String? category,
    String? language,
    DateTime? lastFetchTime,
    DateTime? lastBuildDate,
    bool? isActive,
    String? feedFormat,
  }) {
    return RssFeed(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      language: language ?? this.language,
      lastFetchTime: lastFetchTime ?? this.lastFetchTime,
      lastBuildDate: lastBuildDate ?? this.lastBuildDate,
      isActive: isActive ?? this.isActive,
      feedFormat: feedFormat ?? this.feedFormat,
    );
  }

  /// Equality karşılaştırması - id bazlı
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RssFeed && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Debug için string representation
  @override
  String toString() {
    return 'RssFeed{id: $id, url: $url, title: $title, category: $category, feedFormat: $feedFormat}';
  }

  /// Feed'in güncel olup olmadığını kontrol eder
  bool get isStale {
    if (lastFetchTime == null) return true;
    final now = DateTime.now();
    const staleDuration = Duration(minutes: 30);
    return now.difference(lastFetchTime!) > staleDuration;
  }

  /// Feed'in en son ne zaman güncellendiğini gösterir
  String get lastUpdateText {
    if (lastFetchTime == null) return 'Hiç güncellenmedi';

    final now = DateTime.now();
    final difference = now.difference(lastFetchTime!);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce güncellendi';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce güncellendi';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce güncellendi';
    } else {
      return 'Az önce güncellendi';
    }
  }
}
