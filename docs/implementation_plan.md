# Haber Merkezi - Uygulama Geliştirme Planı

## 🎯 Proje Hedefleri

### ✅ Temel Özellikler
- [x] RSS tabanlı haber çekme sistemi
- [ ] Kategori bazlı haber filtreleme
- [ ] Offline mode desteği
- [ ] Modern, responsive UI tasarımı
- [ ] Dark/Light mode desteği
- [ ] Pull-to-refresh özelliği
- [ ] Haber detay sayfası
- [ ] Kaynak linkine yönlendirme

### 📊 Teknik Detaylar

#### RSS Feed Yapısı
```xml
<!-- Hürriyet RSS (RSS 2.0) -->
<rss version="2.0">
  <channel>
    <title>Hürriyet</title>
    <item>
      <title>Haber Başlığı</title>
      <link>https://...</link>
      <description>Haber içeriği...</description>
      <pubDate>Thu, 14 Sep 2025 09:00:00 GMT</pubDate>
      <media:content url="image_url.jpg" />
    </item>
  </channel>
</rss>

<!-- NTV RSS (Atom) -->
<feed xmlns="http://www.w3.org/2005/Atom">
  <entry>
    <title>Haber Başlığı</title>
    <link href="https://..." />
    <updated>2025-09-14T09:00:00Z</updated>
    <content type="html">İçerik...</content>
  </entry>
</feed>
```

## 🔧 Geliştirme Adımları

### Phase 1: Temel Yapı (Gün 1)
1. **pubspec.yaml güncellemesi** - Tüm gerekli paketler
2. **Klasör yapısı oluşturma** - Clean Architecture
3. **Temel model sınıfları** - Article, Category, RssFeed
4. **Constants ve configuration** - API endpoints, theme colors

### Phase 2: Data Layer (Gün 1-2)
1. **RSS API service** - Dio ile HTTP client
2. **XML parser service** - RSS ve Atom format desteği  
3. **Hive setup** - Local database configuration
4. **Repository implementation** - Data source coordination

### Phase 3: Domain Layer (Gün 2)
1. **Entity sınıfları** - Business logic models
2. **Use case sınıfları** - Business rules
3. **Repository interface** - Abstract contracts

### Phase 4: State Management (Gün 2)
1. **Riverpod providers** - State management setup
2. **Theme provider** - Dark/Light mode
3. **Connectivity provider** - Network status
4. **News provider** - Article state management

### Phase 5: UI Foundation (Gün 3)
1. **Theme configuration** - Colors, typography, components
2. **Main app structure** - MaterialApp, routing
3. **Common widgets** - Loading, error, image components
4. **Navigation structure** - Bottom navigation, app bar

### Phase 6: Core Screens (Gün 3-4)
1. **Splash screen** - App initialization
2. **Home page** - Article list, categories
3. **Article detail page** - Full article view
4. **Settings page** - Theme toggle, preferences

### Phase 7: Advanced Features (Gün 4)
1. **Pull-to-refresh** - Manual data refresh
2. **Search functionality** - Article search
3. **Share feature** - Article sharing
4. **Error handling** - Comprehensive error management

### Phase 8: Polish & Testing (Gün 5)
1. **Performance optimization** - Lazy loading, caching
2. **UI refinements** - Animations, transitions
3. **Testing** - Unit, widget, integration tests
4. **Bug fixes** - Issue resolution

## 📱 UI/UX Tasarım Kılavuzu

### Renk Şeması
```dart
// Light Theme
final lightColorScheme = ColorScheme.fromSeed(
  seedColor: Color(0xFF1976D2), // Ana Mavi
  brightness: Brightness.light,
);

// Dark Theme  
final darkColorScheme = ColorScheme.fromSeed(
  seedColor: Color(0xFF1976D2),
  brightness: Brightness.dark,
);
```

### Ekran Boyutları ve Layout
- **Phone (< 600dp)**: Single column layout
- **Tablet (600dp+)**: Two column layout
- **Responsive images**: AspectRatio widgets
- **Safe areas**: SafeArea wrapping

### Component Library
```dart
// Article Card
- Height: 120dp
- Image: 80x80dp (left side)
- Title: 2 lines max, bold
- Summary: 3 lines max, regular
- Date: Small, gray text

// Category Tabs
- Height: 48dp
- Selected: Blue background
- Unselected: Transparent
- Indicator: Blue underline

// Bottom Navigation
- 4-5 categories max
- Icons: Material Design
- Labels: Category names
```

## 🔍 Quality Assurance

### Testing Checklist
- [ ] RSS feed parsing accuracy
- [ ] Offline mode functionality  
- [ ] Dark/Light theme switching
- [ ] Pull-to-refresh behavior
- [ ] Image loading and caching
- [ ] Network error handling
- [ ] Deep link navigation
- [ ] Memory leak prevention

### Performance Benchmarks
- App startup: < 3 seconds
- RSS feed fetch: < 5 seconds
- Image loading: Progressive/Shimmer
- Smooth scrolling: 60fps
- Memory usage: < 100MB

## 🚀 Deployment Hazırlığı

### Android
- minSdkVersion: 21 (Android 5.0)
- targetSdkVersion: 34 (Android 14)
- Internet permission required

### iOS  
- iOS deployment target: 12.0+
- App Transport Security: RSS HTTP/HTTPS

### Icon ve Assets
- App icon: 1024x1024 (iOS), 192x192 (Android)
- Splash screen: Haber Merkezi logosu
- Category icons: Material Design icons

## 📝 Code Standards

### Dart/Flutter Best Practices
- Null safety enabled
- Linting rules: flutter_lints
- Method documentation
- Error handling with try-catch
- Resource disposal (dispose methods)

### File Organization
```
lib/
├── main.dart                 # Entry point
├── app.dart                  # MyApp widget
├── core/                     # Shared utilities
├── data/                     # Data layer
├── domain/                   # Business logic
└── presentation/             # UI layer
```

## 🔧 Development Tools

### Required Tools
- Flutter SDK (3.8.1+)
- Android Studio / VSCode
- iOS Simulator / Android Emulator
- Git version control

### Recommended Extensions
- Dart/Flutter (VSCode)
- Flutter Riverpod Snippets
- Error Lens
- Git Lens