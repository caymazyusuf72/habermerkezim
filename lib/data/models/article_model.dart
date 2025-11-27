import 'package:hive/hive.dart';
import '../../domain/entities/article.dart';

part 'article_model.g.dart';

/// Article entity'sinin data layer implementasyonu
/// JSON serialization ve Hive database desteği ile
/// Domain entity'den farklı olarak external dependencies içerir
@HiveType(typeId: 0)
class ArticleModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final String? content;
  
  @HiveField(4)
  final String link;
  
  @HiveField(5)
  final String? imageUrl;
  
  @HiveField(6)
  final DateTime publishedDate;
  
  @HiveField(7)
  final String category;
  
  @HiveField(8)
  final String sourceName;
  
  @HiveField(9)
  final bool isRead;
  
  @HiveField(10)
  final bool isFavorite;

  ArticleModel({
    required this.id,
    required this.title,
    required this.description,
    this.content,
    required this.link,
    this.imageUrl,
    required this.publishedDate,
    required this.category,
    required this.sourceName,
    this.isRead = false,
    this.isFavorite = false,
  });

  /// JSON'dan ArticleModel oluşturur (RSS XML parse sonrası)
  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'],
      link: json['link'] ?? '',
      imageUrl: json['imageUrl'],
      publishedDate: json['publishedDate'] != null
          ? DateTime.parse(json['publishedDate'])
          : DateTime.now(),
      category: json['category'] ?? '',
      sourceName: json['sourceName'] ?? '',
      isRead: json['isRead'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  /// RSS XML item'ından ArticleModel oluşturur
  factory ArticleModel.fromRssItem({
    required Map<String, dynamic> rssItem,
    required String category,
    required String sourceName,
  }) {
    // Unique ID oluştur (link + publishDate bazlı)
    final id = _generateId(rssItem['link'] ?? '', rssItem['pubDate'] ?? '');
    
    return ArticleModel(
      id: id,
      title: _cleanHtml(rssItem['title'] ?? ''),
      description: _cleanHtml(rssItem['description'] ?? ''),
      content: _cleanHtml(rssItem['content'] ?? rssItem['description'] ?? ''),
      link: rssItem['link'] ?? '',
      imageUrl: _extractImageUrl(rssItem),
      publishedDate: _parseDate(rssItem['pubDate']),
      category: category,
      sourceName: sourceName,
    );
  }

  /// ArticleModel'i JSON'a çevirir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'link': link,
      'imageUrl': imageUrl,
      'publishedDate': publishedDate.toIso8601String(),
      'category': category,
      'sourceName': sourceName,
      'isRead': isRead,
      'isFavorite': isFavorite,
    };
  }

  /// Domain entity'ye çevirir
  Article toEntity() {
    return Article(
      id: id,
      title: title,
      description: description,
      content: content,
      link: link,
      imageUrl: imageUrl,
      publishedDate: publishedDate,
      category: category,
      sourceName: sourceName,
      isRead: isRead,
      isFavorite: isFavorite,
    );
  }

  /// Domain entity'den oluşturur
  factory ArticleModel.fromEntity(Article article) {
    return ArticleModel(
      id: article.id,
      title: article.title,
      description: article.description,
      content: article.content,
      link: article.link,
      imageUrl: article.imageUrl,
      publishedDate: article.publishedDate,
      category: article.category,
      sourceName: article.sourceName,
      isRead: article.isRead,
      isFavorite: article.isFavorite,
    );
  }

  /// HTML taglerini temizler
  static String _cleanHtml(String htmlString) {
    if (htmlString.isEmpty) return htmlString;
    
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlString
        .replaceAll(exp, '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }

  /// RSS item'ından görsel URL'i çıkarır
  static String? _extractImageUrl(Map<String, dynamic> rssItem) {
    // media:content URL'i
    if (rssItem['mediaContent'] != null) {
      return rssItem['mediaContent'];
    }
    
    // enclosure URL'i
    if (rssItem['enclosure'] != null) {
      return rssItem['enclosure'];
    }
    
    // description içindeki img tag'i
    final description = rssItem['description'] ?? '';
    final RegExp imgRegex = RegExp(r'<img[^>]+src="([^"]+)"', caseSensitive: false);
    final match = imgRegex.firstMatch(description);
    
    return match?.group(1);
  }

  /// Tarih parse eder - RSS feed'lerindeki farklı tarih formatlarını destekler
  static DateTime _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      print('⚠️ Tarih string boş, şu anki zaman kullanılıyor');
      return DateTime.now();
    }
    
    // String'i temizle
    final cleaned = dateString.trim();
    
    // RFC 2822 formatı (Thu, 14 Sep 2025 09:00:00 GMT veya +0300)
    try {
      // RFC 2822 formatını parse et
      // Örnek: "Thu, 14 Sep 2025 09:00:00 GMT" veya "Thu, 14 Sep 2025 09:00:00 +0300"
      if (cleaned.contains(',') && cleaned.length > 20) {
        // RFC 2822 formatı
        final parts = cleaned.split(' ');
        if (parts.length >= 5) {
          // Ay ismini sayıya çevir
          final monthMap = {
            'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
            'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
            'Oca': 1, 'Şub': 2, 'Mar': 3, 'Nis': 4, 'May': 5, 'Haz': 6,
            'Tem': 7, 'Ağu': 8, 'Eyl': 9, 'Eki': 10, 'Kas': 11, 'Ara': 12,
          };
          
          final day = int.tryParse(parts[1]) ?? 1;
          final monthStr = parts[2];
          final month = monthMap[monthStr] ?? DateTime.now().month;
          final year = int.tryParse(parts[3]) ?? DateTime.now().year;
          
          // Saat bilgisi
          final timeParts = parts[4].split(':');
          final hour = int.tryParse(timeParts[0]) ?? 0;
          final minute = int.tryParse(timeParts[1]) ?? 0;
          final second = timeParts.length > 2 ? (int.tryParse(timeParts[2]) ?? 0) : 0;
          
          final date = DateTime(year, month, day, hour, minute, second);
          
          // Timezone offset varsa uygula
          if (parts.length > 5) {
            final tzStr = parts[5];
            if (tzStr.startsWith('+') || tzStr.startsWith('-')) {
              // +0300 formatı
              final offsetHours = int.tryParse(tzStr.substring(1, 3)) ?? 0;
              final offsetMinutes = int.tryParse(tzStr.substring(3, 5)) ?? 0;
              final offset = Duration(hours: offsetHours, minutes: offsetMinutes);
              
              if (tzStr.startsWith('-')) {
                return date.add(offset);
              } else {
                return date.subtract(offset);
              }
            } else if (tzStr == 'GMT' || tzStr == 'UTC') {
              // GMT/UTC için local timezone'a çevir
              final localOffset = DateTime.now().timeZoneOffset;
              return date.add(localOffset);
            }
          }
          
          return date;
        }
      }
    } catch (e) {
      print('⚠️ RFC 2822 parse hatası: $e');
    }
    
    // ISO 8601 formatı (2025-09-14T09:00:00Z veya 2025-09-14T09:00:00+03:00)
    try {
      return DateTime.parse(cleaned);
    } catch (e) {
      print('⚠️ ISO 8601 parse hatası: $e');
    }
    
    // Unix timestamp (milliseconds)
    try {
      final timestamp = int.tryParse(cleaned);
      if (timestamp != null && timestamp > 0) {
        // Timestamp 10 haneli ise saniye, 13 haneli ise milisaniye
        if (timestamp.toString().length == 10) {
          return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        } else if (timestamp.toString().length == 13) {
          return DateTime.fromMillisecondsSinceEpoch(timestamp);
        }
      }
    } catch (e) {
      print('⚠️ Timestamp parse hatası: $e');
    }
    
    // Parse edilemezse şu anki zamanı kullan ama logla
    print('⚠️ Tarih parse edilemedi: "$dateString", şu anki zaman kullanılıyor');
    return DateTime.now();
  }

  /// Unique ID oluşturur
  static String _generateId(String link, String pubDate) {
    final combined = '$link$pubDate';
    return combined.hashCode.abs().toString();
  }

  @override
  String toString() {
    return 'ArticleModel{id: $id, title: $title, category: $category}';
  }
}