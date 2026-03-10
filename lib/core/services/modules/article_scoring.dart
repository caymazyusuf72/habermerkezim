import '../../../domain/entities/article.dart';

/// Ortak makale skorlama helper sınıfı
/// RecommendationModule ve ArticleDiscoveryModule tarafından kullanılır
/// Önceden 4 farklı serviste tekrar eden _ScoredArticle sınıfını birleştirir
class ScoredArticle {
  final Article article;
  final double score;
  final Map<String, double>? scoreBreakdown;

  const ScoredArticle({
    required this.article,
    required this.score,
    this.scoreBreakdown,
  });
}

/// Makale metni birleştirme - ortak kullanım
class ArticleTextHelper {
  ArticleTextHelper._();

  /// Haber metnini birleştirir (başlık + açıklama + içerik)
  static String getArticleText(Article article, {int maxContentLength = 500}) {
    final parts = <String>[];

    if (article.title.isNotEmpty) {
      parts.add(article.title);
    }

    if (article.description.isNotEmpty) {
      parts.add(article.description);
    }

    if (article.content != null && article.content!.isNotEmpty) {
      final content = article.content!.length > maxContentLength
          ? article.content!.substring(0, maxContentLength)
          : article.content!;
      parts.add(content);
    }

    return parts.join(' ');
  }

  /// Metinden anahtar kelimeleri çıkarır (Türkçe stop words hariç)
  static List<String> extractKeywords(String text) {
    text = text.replaceAll(RegExp(r'<[^>]*>'), ' ');

    const stopWords = {
      've', 'ile', 'için', 'bir', 'bu', 'şu', 'o', 'da', 'de', 'ki',
      'mi', 'mı', 'mu', 'mü', 'var', 'yok', 'olan', 'olarak', 'gibi',
      'kadar', 'daha', 'en', 'çok', 'az', 'ise', 'ama', 'fakat',
      'ancak', 'lakin', 'çünkü', 'zira', 'dolayı', 'göre',
    };

    final regexPattern = r'[\s\.,;:!?()\[\]{}"''-]+';
    return text
        .split(RegExp(regexPattern))
        .where((word) => word.length > 2)
        .where((word) => !stopWords.contains(word.toLowerCase()))
        .toList();
  }

  /// Güncellik skoru hesaplama (ortak kullanım)
  static double calculateRecencyScore(DateTime publishedDate) {
    final hoursSincePublished = DateTime.now().difference(publishedDate).inHours;

    if (hoursSincePublished < 6) return 100.0;
    if (hoursSincePublished < 24) return 80.0;
    if (hoursSincePublished < 48) return 60.0;
    if (hoursSincePublished < 72) return 40.0;
    if (hoursSincePublished < 168) return 20.0;
    return 0.0;
  }
}