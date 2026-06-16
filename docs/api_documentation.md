# 📚 Haber Merkezi - API Dokümantasyonu

**Versiyon:** 1.0.0  
**Son Güncelleme:** 17 Ocak 2026  
**Durum:** Tamamlandı

---

## 📑 İçindekiler

1. [Genel Bakış](#genel-bakış)
2. [Servisler](#servisler)
3. [Veri Modelleri](#veri-modelleri)
4. [State Management](#state-management)
5. [Güvenlik](#güvenlik)
6. [Hata Yönetimi](#hata-yönetimi)

---

## 🎯 Genel Bakış

Haber Merkezi, RSS tabanlı modern bir haber uygulamasıdır. Clean Architecture prensiplerine uygun olarak geliştirilmiştir.

### Mimari Katmanlar

```
lib/
├── core/               # Çekirdek işlevsellik
│   ├── services/      # Servisler
│   ├── utils/         # Yardımcı sınıflar
│   └── constants/     # Sabitler
├── data/              # Veri katmanı
│   ├── models/        # Veri modelleri
│   ├── datasources/   # API, Veritabanı
│   └── repositories/  # Repository implementasyonları
├── domain/            # İş mantığı
│   ├── entities/      # Domain varlıkları
│   ├── repositories/  # Repository arayüzleri
│   └── usecases/      # Kullanım senaryoları
└── presentation/      # UI katmanı
    ├── pages/         # Sayfalar
    ├── widgets/       # Widget'lar
    ├── providers/     # State management
    └── themes/        # Tema ayarları
```

---

## 🔧 Servisler

### 1. RSS Service

RSS feed'lerini yönetir.

```dart
class RssService {
  /// RSS feed'i çeker ve parse eder
  Future<List<Article>> fetchFeed(String url);
  
  /// Birden fazla feed'i paralel olarak çeker
  Future<List<Article>> fetchMultipleFeeds(List<String> urls);
  
  /// Feed'i cache'den alır
  Future<List<Article>?> getCachedFeed(String url);
  
  /// Feed'i cache'e kaydeder
  Future<void> cacheFeed(String url, List<Article> articles);
}
```

**Kullanım:**
```dart
final rssService = RssService();
final articles = await rssService.fetchFeed('https://example.com/rss');
```

---

### 2. Gamification Service

Oyunlaştırma sistemini yönetir.

```dart
class GamificationService {
  static GamificationService get instance;
  
  /// Servisi başlatır
  Future<void> init();
  
  /// Makale okuma kaydeder
  Future<List<Badge>> recordArticleRead();
  
  /// Favori ekleme kaydeder
  Future<List<Badge>> recordFavoriteAdded();
  
  /// Paylaşım kaydeder
  Future<List<Badge>> recordShare();
  
  /// Arama kaydeder
  Future<List<Badge>> recordSearch();
  
  /// XP ekler
  Future<XPGainResult> addXP(int amount);
  
  /// Tüm rozetleri getirir
  List<Badge> getAllBadges();
  
  /// Kullanıcı seviyesini getirir
  UserLevel getUserLevel();
  
  /// Günlük seri sayısını getirir
  int getDailyStreak();
}
```

**Kullanım:**
```dart
final service = GamificationService.instance;
await service.init();

// Makale okunduğunda
final unlockedBadges = await service.recordArticleRead();
if (unlockedBadges.isNotEmpty) {
  // Rozet kazanıldı bildirimi göster
}

// XP eklerken
final result = await service.addXP(50);
if (result.leveledUp) {
  // Seviye atlama bildirimi göster
}
```

---

### 3. Export Service

Veri dışa aktarma işlemlerini yönetir.

```dart
class ExportService {
  /// Okuma geçmişini CSV formatında export eder
  String generateReadingHistoryCSV(List<Article> articles);
  
  /// Favorileri CSV formatında export eder
  String generateFavoritesCSV(List<Article> articles);
  
  /// Okuma geçmişini JSON formatında export eder
  String generateReadingHistoryJSON(List<Article> articles);
  
  /// Favorileri JSON formatında export eder
  String generateFavoritesJSON(List<Article> articles);
  
  /// İstatistikleri JSON formatında export eder
  String generateStatisticsJSON(Map<String, dynamic> stats);
}
```

**Kullanım:**
```dart
final exportService = ExportService();
final articles = [...]; // Makaleler

// CSV export
final csv = exportService.generateReadingHistoryCSV(articles);

// JSON export
final json = exportService.generateReadingHistoryJSON(articles);
```

---

### 4. Secure Storage Service

Hassas verileri güvenli şekilde saklar.

```dart
class SecureStorageService {
  static SecureStorageService get instance;
  
  // Temel operasyonlar
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
  
  // Auth token
  Future<void> saveAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> deleteAuthToken();
  
  // User data
  Future<void> saveUserId(String userId);
  Future<String?> getUserId();
  
  // API keys
  Future<void> saveApiKey(String apiKey);
  Future<String?> getApiKey();
  
  // Session management
  Future<void> clearSession();
  Future<bool> hasValidSession();
}
```

**Kullanım:**
```dart
final storage = SecureStorageService();

// Token kaydetme
await storage.saveAuthToken('token_value');

// Token okuma
final token = await storage.getAuthToken();

// Session temizleme
await storage.clearSession();
```

---

### 5. Environment Config Service

Ortam değişkenlerini yönetir.

```dart
class EnvConfigService {
  static EnvConfigService get instance;
  
  /// Servisi başlatır (.env dosyasını yükler)
  Future<void> init();
  
  // Getter methods
  String getString(String key, {String defaultValue = ''});
  int getInt(String key, {int defaultValue = 0});
  bool getBool(String key, {bool defaultValue = false});
  double getDouble(String key, {double defaultValue = 0.0});
  
  // App configuration
  String get appName;
  String get appVersion;
  bool get debugMode;
  
  // API keys
  String get newsApiKey;
  String get weatherApiKey;
  
  // Feature flags
  bool get featureGamification;
  bool get featureDarkMode;
  bool get featureNotifications;
  bool get featureOfflineMode;
  
  /// Özel feature kontrolü
  bool isFeatureEnabled(String featureName);
}
```

**Kullanım:**
```dart
final config = EnvConfigService();
await config.init();

// Değer okuma
final appName = config.appName;
final apiKey = config.newsApiKey;

// Feature flag kontrolü
if (config.featureGamification) {
  // Gamification özelliklerini etkinleştir
}
```

---

## 📊 Veri Modelleri

### Article Entity

```dart
class Article {
  final String id;
  final String title;
  final String description;
  final String content;
  final String url;
  final String? imageUrl;
  final DateTime publishedAt;
  final String source;
  final String category;
  final bool isFavorite;
  final bool isRead;
  
  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.url,
    this.imageUrl,
    required this.publishedAt,
    required this.source,
    required this.category,
    this.isFavorite = false,
    this.isRead = false,
  });
  
  Article copyWith({...});
  Map<String, dynamic> toJson();
  factory Article.fromJson(Map<String, dynamic> json);
}
```

---

### Badge Entity

```dart
enum BadgeCategory {
  reading,      // Okuma
  streak,       // Seri
  favorites,    // Favoriler
  sharing,      // Paylaşım
  exploration,  // Keşif
  achievement,  // Başarı
  special,      // Özel
}

enum BadgeTier {
  bronze,    // Bronz
  silver,    // Gümüş
  gold,      // Altın
  platinum,  // Platin
  diamond,   // Elmas
}

class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final BadgeCategory category;
  final BadgeTier tier;
  final int requiredCount;
  final int currentCount;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  
  /// İlerleme yüzdesi (0.0 - 1.0)
  double get progress => (currentCount / requiredCount).clamp(0.0, 1.0);
  
  Badge copyWith({...});
}
```

---

### UserLevel

```dart
class UserLevel {
  final int level;
  final String title;
  final int currentXP;
  final int xpForNextLevel;
  
  /// Sonraki seviyeye ilerleme yüzdesi
  double get progressToNextLevel => 
    (currentXP / xpForNextLevel).clamp(0.0, 1.0);
}
```

---

## 🔄 State Management

### Riverpod Providers

#### News Provider

```dart
final newsProvider = StateNotifierProvider<NewsNotifier, NewsState>((ref) {
  return NewsNotifier();
});

class NewsState {
  final List<Article> articles;
  final bool isLoading;
  final String? error;
  final String selectedCategory;
  
  NewsState({
    this.articles = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory = 'Genel',
  });
}
```

**Kullanım:**
```dart
// Widget içinde
final newsState = ref.watch(newsProvider);

// Makale yükleme
ref.read(newsProvider.notifier).loadArticles();

// Kategori değiştirme
ref.read(newsProvider.notifier).changeCategory('Teknoloji');
```

---

#### Gamification Provider

```dart
final gamificationProvider = 
  StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
    return GamificationNotifier();
  });

// Derived providers
final userLevelProvider = Provider<UserLevel>((ref) {
  return ref.watch(gamificationProvider).userLevel;
});

final totalPointsProvider = Provider<int>((ref) {
  return ref.watch(gamificationProvider).totalPoints;
});

final dailyStreakProvider = Provider<int>((ref) {
  return ref.watch(gamificationProvider).dailyStreak;
});
```

**Kullanım:**
```dart
// Seviye bilgisi
final level = ref.watch(userLevelProvider);

// Puan bilgisi
final points = ref.watch(totalPointsProvider);

// Makale okundu kaydı
await ref.read(gamificationProvider.notifier).recordArticleRead();
```

---

#### Locale Provider

```dart
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('tr'));
  
  void setLocale(Locale locale);
  void toggleLocale();
}
```

**Kullanım:**
```dart
// Dil değiştirme
ref.read(localeProvider.notifier).toggleLocale();

// Özel dil seçme
ref.read(localeProvider.notifier).setLocale(const Locale('en'));
```

---

## 🔐 Güvenlik

### Environment Variables

`.env` dosyasında hassas bilgiler saklanır:

```env
# API Keys
NEWS_API_KEY=your_api_key_here
WEATHER_API_KEY=your_weather_key_here

# Firebase
FIREBASE_API_KEY=your_firebase_key
FIREBASE_PROJECT_ID=your_project_id

# Feature Flags
FEATURE_GAMIFICATION=true
FEATURE_DARK_MODE=true
```

**Önemli:** `.env` dosyası `.gitignore`'a eklenmelidir!

---

### Secure Storage

Platform-specific güvenli depolama:
- **iOS:** Keychain
- **Android:** EncryptedSharedPreferences

```dart
// Hassas veri kaydetme
await SecureStorageService().saveAuthToken(token);

// Hassas veri okuma
final token = await SecureStorageService().getAuthToken();
```

---

## ⚠️ Hata Yönetimi

### Hata Türleri

```dart
class AppException implements Exception {
  final String message;
  final String? code;
  
  AppException(this.message, {this.code});
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message, code: 'NETWORK_ERROR');
}

class CacheException extends AppException {
  CacheException(String message) : super(message, code: 'CACHE_ERROR');
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message, code: 'VALIDATION_ERROR');
}
```

### Hata Yakalama

```dart
try {
  final articles = await rssService.fetchFeed(url);
} on NetworkException catch (e) {
  // Network hatası
  showError('İnternet bağlantısı yok: ${e.message}');
} on CacheException catch (e) {
  // Cache hatası
  showError('Önbellek hatası: ${e.message}');
} catch (e) {
  // Genel hata
  showError('Beklenmeyen hata: $e');
}
```

---

## 🧪 Test

### Unit Test

```dart
// test/unit/gamification_service_test.dart
void main() {
  group('Badge Entity Tests', () {
    test('Badge should calculate progress correctly', () {
      final badge = Badge(
        id: 'test',
        name: 'Test Badge',
        // ...
        requiredCount: 10,
        currentCount: 5,
      );
      
      expect(badge.progress, 0.5);
    });
  });
}
```

### Widget Test

```dart
// test/widget/badges_page_test.dart
void main() {
  testWidgets('Should display badge list', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: BadgesPage()),
      ),
    );
    
    expect(find.byType(BadgeCard), findsWidgets);
  });
}
```

### Integration Test

```dart
// integration_test/app_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Complete user flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    
    // Navigation testi
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    
    expect(find.byType(SearchPage), findsOneWidget);
  });
}
```

---

## 📱 Kullanım Örnekleri

### Makale Listeleme

```dart
class NewsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsState = ref.watch(newsProvider);
    
    if (newsState.isLoading) {
      return const LoadingWidget();
    }
    
    if (newsState.error != null) {
      return ErrorWidget(message: newsState.error!);
    }
    
    return ListView.builder(
      itemCount: newsState.articles.length,
      itemBuilder: (context, index) {
        final article = newsState.articles[index];
        return ArticleCard(article: article);
      },
    );
  }
}
```

---

### Favori Ekleme

```dart
Future<void> toggleFavorite(Article article, WidgetRef ref) async {
  await ref.read(newsProvider.notifier).toggleFavorite(article);
  
  // Gamification kaydı
  if (!article.isFavorite) {
    final badges = await ref
      .read(gamificationProvider.notifier)
      .recordFavoriteAdded();
    
    if (badges.isNotEmpty) {
      showBadgeUnlockDialog(context, badges);
    }
  }
}
```

---

### Tema Değiştirme

```dart
class ThemeToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    
    return Switch(
      value: isDark,
      onChanged: (value) {
        ref.read(themeProvider.notifier).toggle();
      },
    );
  }
}
```

---

## 📞 Destek

Sorularınız için:
- GitHub Issues: [github.com/yourusername/haber-merkezi/issues]
- Email: support@habermerkezi.com
- Dokümantasyon: [docs.habermerkezi.com]

---

**Son Güncelleme:** 17 Ocak 2026  
**Versiyon:** 1.0.0  
**Hazırlayan:** Roo (AI Assistant)