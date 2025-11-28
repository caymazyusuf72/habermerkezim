import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';
import 'providers.dart' show newsRepositoryProvider;

/// Bildirim banner'ı için state
class NotificationBannerState {
  final List<Article> latestArticles;
  final List<AppNotification> appNotifications;
  final bool isLoading;
  final String? error;

  const NotificationBannerState({
    this.latestArticles = const [],
    this.appNotifications = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationBannerState copyWith({
    List<Article>? latestArticles,
    List<AppNotification>? appNotifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationBannerState(
      latestArticles: latestArticles ?? this.latestArticles,
      appNotifications: appNotifications ?? this.appNotifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<BannerItem> get allItems {
    final items = <BannerItem>[];
    
    // RSS haberleri
    for (final article in latestArticles.take(5)) {
      items.add(BannerItem.article(article));
    }
    
    // Uygulama bildirimleri
    for (final notification in appNotifications) {
      items.add(BannerItem.notification(notification));
    }
    
    return items;
  }
}

/// Banner item - RSS haberi veya uygulama bildirimi
class BannerItem {
  final Article? article;
  final AppNotification? notification;
  final bool isArticle;

  BannerItem.article(this.article)
      : notification = null,
        isArticle = true;

  BannerItem.notification(this.notification)
      : article = null,
        isArticle = false;

  String get title {
    if (isArticle) {
      return article?.title ?? '';
    } else {
      return notification?.title ?? '';
    }
  }

  String get subtitle {
    if (isArticle) {
      return article?.sourceName ?? '';
    } else {
      return notification?.message ?? '';
    }
  }
}

/// Uygulama içi bildirim
class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
  });
}

enum NotificationType {
  readingGoal,
  newCategory,
  breakingNews,
  achievement,
}

/// Notification Banner Provider
final notificationBannerProvider =
    StateNotifierProvider<NotificationBannerNotifier, NotificationBannerState>(
  (ref) => NotificationBannerNotifier(ref),
);

class NotificationBannerNotifier extends StateNotifier<NotificationBannerState> {
  final Ref _ref;

  NotificationBannerNotifier(this._ref) : super(const NotificationBannerState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadLatestArticles();
    _loadAppNotifications();
  }

  /// RSS feed'lerden son haberleri yükle
  Future<void> loadLatestArticles() async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = _ref.read(newsRepositoryProvider);
      final articles = await repository.getAllArticles();

      // En son 5-10 haberi al
      final latest = articles
          .where((article) => article.imageUrl != null && article.imageUrl!.isNotEmpty)
          .take(10)
          .toList();

      state = state.copyWith(
        latestArticles: latest,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Uygulama içi bildirimleri yükle
  void _loadAppNotifications() {
    final notifications = <AppNotification>[];

    // Okuma hedefi bildirimi (gelecekte analytics provider ile entegre edilebilir)
    // Şimdilik basit bir örnek bildirim ekleyelim
    // notifications.add(AppNotification(
    //   id: 'reading_goal_${DateTime.now().millisecondsSinceEpoch}',
    //   title: 'Okuma Hedefi',
    //   message: '5 / 10 haber okudunuz',
    //   type: NotificationType.readingGoal,
    //   createdAt: DateTime.now(),
    // ));

    // Yeni kategori bildirimi (örnek)
    // notifications.add(AppNotification(
    //   id: 'new_category_${DateTime.now().millisecondsSinceEpoch}',
    //   title: 'Yeni Kategori',
    //   message: 'Bilim kategorisi eklendi',
    //   type: NotificationType.newCategory,
    //   createdAt: DateTime.now(),
    // ));

    state = state.copyWith(appNotifications: notifications);
  }

  /// Bildirimleri yenile
  Future<void> refresh() async {
    await loadLatestArticles();
    _loadAppNotifications();
  }
}

