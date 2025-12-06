import '../../domain/entities/article.dart';
import '../../domain/entities/interest_tag.dart';
import '../constants/interest_tags.dart';

/// İlgi alanı hashtag'leri ile haberler arasında eşleştirme yapan servis
/// Hibrit yaklaşım: Hem kategori bazlı hem anahtar kelime bazlı eşleştirme
class InterestMatchingService {
  InterestMatchingService._();

  /// Bir haberin belirli bir hashtag ile eşleşip eşleşmediğini kontrol eder
  /// Skorlama sistemi kullanır (0-100 arası)
  static double calculateMatchScore(Article article, InterestTag tag) {
    double score = 0.0;

    // 1. Kategori bazlı eşleştirme (40 puan)
    if (tag.category != null && article.category.toLowerCase() == tag.category!.toLowerCase()) {
      score += 40.0;
    }

    // 2. Anahtar kelime bazlı eşleştirme (60 puan)
    final articleText = _getArticleText(article).toLowerCase();
    final matchedKeywords = tag.keywords.where((keyword) {
      final lowerKeyword = keyword.toLowerCase();
      return articleText.contains(lowerKeyword);
    }).length;

    if (matchedKeywords > 0) {
      // Her eşleşen keyword için puan ver (maksimum 60)
      final keywordScore = (matchedKeywords / tag.keywords.length) * 60.0;
      score += keywordScore.clamp(0.0, 60.0);
    }

    return score.clamp(0.0, 100.0);
  }

  /// Bir haberin kullanıcının ilgi alanlarına uygun olup olmadığını kontrol eder
  /// Eşik değeri: 30 puan (ayarlanabilir)
  static bool isArticleRelevant(Article article, List<String> interestTagIds, {double threshold = 30.0}) {
    if (interestTagIds.isEmpty) return false;

    for (final tagId in interestTagIds) {
      final tag = InterestTags.getTagById(tagId);
      if (tag != null) {
        final score = calculateMatchScore(article, tag);
        if (score >= threshold) {
          return true;
        }
      }
    }

    return false;
  }

  /// Haberleri ilgi alanlarına göre sıralar (en yüksek skorlu önce)
  static List<Article> sortArticlesByInterest(
    List<Article> articles,
    List<String> interestTagIds,
  ) {
    if (interestTagIds.isEmpty) return articles;

    // Her haber için en yüksek skoru bul
    final scoredArticles = articles.map((article) {
      double maxScore = 0.0;

      for (final tagId in interestTagIds) {
        final tag = InterestTags.getTagById(tagId);
        if (tag != null) {
          final score = calculateMatchScore(article, tag);
          if (score > maxScore) {
            maxScore = score;
          }
        }
      }

      return _ScoredArticle(article: article, score: maxScore);
    }).toList();

    // Skora göre sırala (yüksekten düşüğe)
    scoredArticles.sort((a, b) => b.score.compareTo(a.score));

    return scoredArticles.map((sa) => sa.article).toList();
  }

  /// Haberleri ilgi alanlarına göre filtreler
  static List<Article> filterArticlesByInterest(
    List<Article> articles,
    List<String> interestTagIds, {
    double threshold = 30.0,
  }) {
    if (interestTagIds.isEmpty) return [];

    return articles.where((article) {
      return isArticleRelevant(article, interestTagIds, threshold: threshold);
    }).toList();
  }

  /// Haber metnini birleştirir (başlık + açıklama + içerik)
  static String _getArticleText(Article article) {
    final parts = <String>[];
    
    if (article.title.isNotEmpty) {
      parts.add(article.title);
    }
    
    if (article.description.isNotEmpty) {
      parts.add(article.description);
    }
    
    // Content varsa ekle (ilk 500 karakter)
    if (article.content != null && article.content!.isNotEmpty) {
      final content = article.content!.length > 500 
          ? article.content!.substring(0, 500)
          : article.content!;
      parts.add(content);
    }

    return parts.join(' ');
  }
}

/// Skorlanmış haber wrapper sınıfı
class _ScoredArticle {
  final Article article;
  final double score;

  _ScoredArticle({
    required this.article,
    required this.score,
  });
}

