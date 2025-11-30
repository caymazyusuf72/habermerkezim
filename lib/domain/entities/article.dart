/// Haber makalesini temsil eden domain entity sınıfı
/// Clean Architecture'da business logic katmanında yer alır
/// External dependencies içermez, saf Dart sınıfıdır
class Article {
  final String id;
  final String title;
  final String description;
  final String? content;
  final String link;
  final String? imageUrl;
  final String? videoUrl;
  final String? videoThumbnail;
  final DateTime publishedDate;
  final String category;
  final String sourceName;
  final bool isRead;
  final bool isFavorite;

  const Article({
    required this.id,
    required this.title,
    required this.description,
    this.content,
    required this.link,
    this.imageUrl,
    this.videoUrl,
    this.videoThumbnail,
    required this.publishedDate,
    required this.category,
    required this.sourceName,
    this.isRead = false,
    this.isFavorite = false,
  });

  /// Article kopyalama methodu - immutable pattern
  Article copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? link,
    String? imageUrl,
    String? videoUrl,
    String? videoThumbnail,
    DateTime? publishedDate,
    String? category,
    String? sourceName,
    bool? isRead,
    bool? isFavorite,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      link: link ?? this.link,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      videoThumbnail: videoThumbnail ?? this.videoThumbnail,
      publishedDate: publishedDate ?? this.publishedDate,
      category: category ?? this.category,
      sourceName: sourceName ?? this.sourceName,
      isRead: isRead ?? this.isRead,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Equality karşılaştırması - id bazlı
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Article && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Debug için string representation
  @override
  String toString() {
    return 'Article{id: $id, title: $title, category: $category, sourceName: $sourceName}';
  }

  /// Makale tarihinin ne kadar önce olduğunu hesaplar
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishedDate);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  /// Makale tarihinin gerçek zaman formatını döner (örn: "25 Kasım 2025, 14:30")
  String get formattedDateTime {
    final months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    
    final day = publishedDate.day;
    final month = months[publishedDate.month - 1];
    final year = publishedDate.year;
    final hour = publishedDate.hour.toString().padLeft(2, '0');
    final minute = publishedDate.minute.toString().padLeft(2, '0');
    
    return '$day $month $year, $hour:$minute';
  }

  /// Makale tarihinin kısa formatını döner (kartlar için)
  /// Örnek: "Dün 10:00", "Bugün 14:30", "25 Kasım, 10:00"
  String get shortDateTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final articleDate = DateTime(publishedDate.year, publishedDate.month, publishedDate.day);
    final difference = today.difference(articleDate).inDays;
    
    final months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    
    final hour = publishedDate.hour.toString().padLeft(2, '0');
    final minute = publishedDate.minute.toString().padLeft(2, '0');
    final time = '$hour:$minute';
    
    if (difference == 0) {
      // Bugün
      return 'Bugün $time';
    } else if (difference == 1) {
      // Dün
      return 'Dün $time';
    } else if (difference < 7) {
      // Bu hafta içinde
      final day = publishedDate.day;
      final month = months[publishedDate.month - 1];
      return '$day $month, $time';
    } else if (publishedDate.year == now.year) {
      // Bu yıl içinde
      final day = publishedDate.day;
      final month = months[publishedDate.month - 1];
      return '$day $month, $time';
    } else {
      // Farklı yıl
      final day = publishedDate.day;
      final month = months[publishedDate.month - 1];
      final year = publishedDate.year;
      return '$day $month $year, $time';
    }
  }

  /// Makale başlığını kısaltır (UI için)
  String get truncatedTitle {
    const maxLength = 80;
    if (title.length <= maxLength) return title;
    return '${title.substring(0, maxLength)}...';
  }

  /// Makale açıklamasını kısaltır (UI için)  
  String get truncatedDescription {
    const maxLength = 120;
    if (description.length <= maxLength) return description;
    return '${description.substring(0, maxLength)}...';
  }
}