import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/article.dart';
import '../../core/services/interest_matching_service.dart';
import 'user_profile_provider.dart';
import 'news_provider.dart';

/// Kişiselleştirilmiş haber state
class PersonalizedNewsState {
  final List<Article> articles;
  final bool isLoading;
  final String? errorMessage;

  const PersonalizedNewsState({
    this.articles = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  PersonalizedNewsState copyWith({
    List<Article>? articles,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PersonalizedNewsState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  bool get hasArticles => articles.isNotEmpty;
  bool get hasError => errorMessage != null;
}

/// Kişiselleştirilmiş haber provider
/// Kullanıcının ilgi alanlarına göre haberleri filtreler ve sıralar
final personalizedNewsProvider = Provider<PersonalizedNewsState>((ref) {
  final newsState = ref.watch(newsProvider);
  final userProfileState = ref.watch(userProfileProvider);

  // Kullanıcı profili yoksa veya ilgi alanı yoksa boş döndür
  if (!userProfileState.hasData) {
    return const PersonalizedNewsState();
  }

  final profile = userProfileState.profile!;
  final interestTags = profile.preferences.interestTags;

  if (interestTags.isEmpty) {
    return const PersonalizedNewsState();
  }

  // Haberler yükleniyorsa loading state döndür
  if (newsState.isLoading) {
    return const PersonalizedNewsState(isLoading: true);
  }

  // Hata varsa error state döndür
  if (newsState.hasError) {
    return PersonalizedNewsState(errorMessage: newsState.errorMessage);
  }

  // Haberler yoksa boş döndür
  if (!newsState.hasArticles) {
    return const PersonalizedNewsState();
  }

  // İlgi alanlarına göre haberleri filtrele ve sırala
  final allArticles = newsState.articles;
  final filteredArticles = InterestMatchingService.filterArticlesByInterest(
    allArticles,
    interestTags,
    threshold: 30.0,
  );

  final sortedArticles = InterestMatchingService.sortArticlesByInterest(
    filteredArticles,
    interestTags,
  );

  return PersonalizedNewsState(articles: sortedArticles);
});

/// Kişiselleştirilmiş haberleri yenile
final refreshPersonalizedNewsProvider = FutureProvider<void>((ref) async {
  // Önce tüm haberleri yenile
  await ref.read(newsProvider.notifier).refreshArticles();
  // PersonalizedNewsProvider otomatik olarak güncellenecek
});
