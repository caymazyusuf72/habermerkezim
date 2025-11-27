# Haber Merkezi - Proje Mimarisi

## Clean Architecture Yaklaşımı

### 📁 Klasör Yapısı

```
lib/
├── core/                          # Çekirdek bileşenler
│   ├── constants/
│   │   ├── app_constants.dart     # Uygulama sabitleri
│   │   ├── api_endpoints.dart     # RSS feed URL'leri
│   │   └── theme_constants.dart   # Renk ve tema sabitleri
│   ├── error/
│   │   ├── exceptions.dart        # Özel exception sınıfları
│   │   └── failures.dart          # Hata yönetimi
│   ├── network/
│   │   └── network_info.dart      # İnternet bağlantısı kontrolü
│   ├── utils/
│   │   ├── date_utils.dart        # Tarih formatlama
│   │   └── xml_parser.dart        # XML parse yardımcıları
│   └── services/
│       ├── hive_service.dart      # Hive database servisi
│       └── notification_service.dart
├── data/                          # Veri katmanı
│   ├── datasources/
│   │   ├── remote/
│   │   │   └── rss_remote_data_source.dart  # RSS API çağrıları
│   │   └── local/
│   │       └── news_local_data_source.dart  # Local storage
│   ├── models/
│   │   ├── article_model.dart     # Article data modeli
│   │   ├── category_model.dart    # Kategori modeli
│   │   └── rss_feed_model.dart    # RSS feed modeli
│   └── repositories/
│       └── news_repository_impl.dart  # Repository implementasyonu
├── domain/                        # İş mantığı katmanı
│   ├── entities/
│   │   ├── article.dart           # Article entity
│   │   ├── category.dart          # Kategori entity
│   │   └── rss_feed.dart          # RSS feed entity
│   ├── repositories/
│   │   └── news_repository.dart   # Repository interface
│   └── usecases/
│       ├── get_articles_by_category.dart
│       ├── get_cached_articles.dart
│       ├── refresh_articles.dart
│       └── search_articles.dart
├── presentation/                  # UI katmanı
│   ├── pages/
│   │   ├── splash/
│   │   │   └── splash_page.dart
│   │   ├── home/
│   │   │   ├── home_page.dart
│   │   │   └── widgets/
│   │   │       ├── category_tabs.dart
│   │   │       ├── article_card.dart
│   │   │       └── news_list.dart
│   │   ├── article_detail/
│   │   │   ├── article_detail_page.dart
│   │   │   └── widgets/
│   │   │       └── article_content.dart
│   │   └── settings/
│   │       └── settings_page.dart
│   ├── providers/                 # Riverpod providers
│   │   ├── news_provider.dart
│   │   ├── theme_provider.dart
│   │   └── connectivity_provider.dart
│   ├── widgets/                   # Ortak UI komponenleri
│   │   ├── loading/
│   │   │   ├── shimmer_loading.dart
│   │   │   └── spinner_loading.dart
│   │   ├── error/
│   │   │   └── error_widget.dart
│   │   └── common/
│   │       ├── cached_image.dart
│   │       └── pull_to_refresh.dart
│   └── themes/
│       ├── app_theme.dart         # Ana tema
│       ├── dark_theme.dart        # Dark mode
│       └── light_theme.dart       # Light mode
└── main.dart                      # Uygulama giriş noktası
```

## 🔧 Kullanılacak Paketler

### Temel Paketler
- `flutter_riverpod: ^2.4.9` - State management
- `dio: ^5.4.0` - HTTP client
- `xml: ^6.4.2` - XML parsing
- `hive: ^2.2.3` - Local database
- `hive_flutter: ^1.1.0` - Hive Flutter adapteri

### UI/UX Paketler
- `cached_network_image: ^3.3.1` - Image caching
- `shimmer: ^3.0.0` - Loading shimmer effect
- `flutter_spinkit: ^5.2.0` - Loading spinners
- `pull_to_refresh: ^2.0.0` - Pull to refresh

### Yardımcı Paketler
- `url_launcher: ^6.2.2` - URL launcher
- `connectivity_plus: ^5.0.2` - Connectivity check
- `intl: ^0.19.0` - Internationalization
- `share_plus: ^7.2.2` - Share functionality

### Dev Dependencies
- `hive_generator: ^2.0.1` - Hive type adapters
- `build_runner: ^2.4.7` - Code generation

## 📊 RSS Feed Kaynakları

| Kategori | RSS URL | Format | Test Durumu |
|----------|---------|--------|-------------|
| Genel/Son Dakika | `https://www.hurriyet.com.tr/rss/anasayfa` | RSS 2.0 | ✅ Çalışıyor |
| Türkiye Haberleri | `https://www.ntv.com.tr/gundem.rss` | Atom | ✅ Çalışıyor |
| Ekonomi | `https://www.milliyet.com.tr/rss/rss.asp?cid=8` | RSS 2.0 | ⏳ Test edilecek |
| Teknoloji | `https://feeds.feedburner.com/webtekno-teknoloji` | RSS 2.0 | ⏳ Test edilecek |
| Spor | `https://www.fanatik.com.tr/rss/manset` | RSS 2.0 | ⏳ Test edilecek |

## 🎨 Tasarım Sistemi

### Renk Paleti (Mavi-Beyaz Tema)
```dart
// Ana Renkler
primaryColor: Color(0xFF1976D2)      // Mavi
primaryVariant: Color(0xFF1565C0)    // Koyu Mavi
secondary: Color(0xFF2196F3)         // Açık Mavi
surface: Color(0xFFFFFFFF)           // Beyaz
background: Color(0xFFF5F5F5)        // Açık Gri

// Dark Mode
primaryDark: Color(0xFF0D47A1)       // Koyu Mavi
surfaceDark: Color(0xFF121212)       // Koyu Gri
backgroundDark: Color(0xFF1E1E1E)    // Çok Koyu Gri
```

### Typography
- Başlıklar: Roboto Bold, 18-24px
- İçerik: Roboto Regular, 14-16px  
- Tarih/Meta: Roboto Light, 12-14px

## 🔄 State Management (Riverpod)

### Provider Yapısı
```dart
// News Provider
final newsProvider = StateNotifierProvider<NewsNotifier, NewsState>

// Theme Provider  
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>

// Connectivity Provider
final connectivityProvider = StreamProvider<ConnectivityResult>
```

## 📱 Ekran Yapısı

### Ana Navigasyon
- **BottomNavigationBar** ile kategori geçişi
- **AppBar** ile arama ve ayarlar
- **FloatingActionButton** ile yenileme

### Ana Ekran Layout
1. **Header**: Logo + Kategori tab'ları
2. **Body**: Haber listesi (Card format)
3. **Footer**: Bottom navigation

## 🚀 Performans Optimizasyonları

- **Lazy Loading**: ListView.builder ile
- **Image Caching**: CachedNetworkImage ile
- **Data Caching**: Hive ile offline support
- **Pagination**: Sayfa sayfa yükleme
- **Shimmer Effects**: Loading sırasında

## 🧪 Testing Stratejisi

- Unit tests (domain/usecases)
- Widget tests (presentation/widgets)  
- Integration tests (E2E scenarios)