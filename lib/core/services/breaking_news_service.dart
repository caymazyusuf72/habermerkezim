import '../../domain/entities/article.dart';

/// Breaking news algılama servisi
/// Yeni haberlerde "breaking", "son dakika", "acil" gibi kelimeleri kontrol eder
class BreakingNewsService {
  static final BreakingNewsService _instance = BreakingNewsService._internal();
  factory BreakingNewsService() => _instance;
  BreakingNewsService._internal();

  /// Breaking news anahtar kelimeleri
  static const List<String> _breakingKeywords = [
    'son dakika',
    'breaking',
    'acil',
    'flaş',
    'flaş haber',
    'son dakika haberi',
    'breaking news',
    'urgent',
    'acil haber',
    'canlı',
    'canlı gelişme',
  ];

  /// Haber breaking news mi kontrol et
  bool isBreakingNews(Article article) {
    final title = article.title.toLowerCase();
    final description = article.description.toLowerCase();
    final category = article.category.toLowerCase();

    // Kategori kontrolü
    if (category == 'genel' || category == 'breaking_news') {
      return true;
    }

    // Başlık ve açıklamada anahtar kelime kontrolü
    final text = '$title $description';
    for (final keyword in _breakingKeywords) {
      if (text.contains(keyword.toLowerCase())) {
        return true;
      }
    }

    return false;
  }

  /// Haberler listesinden breaking news'leri filtrele
  List<Article> filterBreakingNews(List<Article> articles) {
    return articles.where((article) => isBreakingNews(article)).toList();
  }

  /// Breaking news öncelik skoru hesapla (0-100)
  int calculatePriority(Article article) {
    int score = 0;

    final title = article.title.toLowerCase();
    final description = article.description.toLowerCase();
    final category = article.category.toLowerCase();

    // Kategori kontrolü
    if (category == 'genel' || category == 'breaking_news') {
      score += 50;
    }

    // Anahtar kelime kontrolü
    final text = '$title $description';
    for (final keyword in _breakingKeywords) {
      if (text.contains(keyword.toLowerCase())) {
        score += 20;
      }
    }

    // Tarih kontrolü (son 1 saat içindeyse daha yüksek öncelik)
    final now = DateTime.now();
    final hoursSincePublished = now.difference(article.publishedDate).inHours;
    if (hoursSincePublished <= 1) {
      score += 30;
    } else if (hoursSincePublished <= 6) {
      score += 15;
    }

    return score.clamp(0, 100);
  }
}

