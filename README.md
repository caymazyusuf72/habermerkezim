# 📰 Haber Merkezi - RSS Tabanlı Haber Uygulaması

Modern Flutter ile geliştirilmiş, RSS feed tabanlı kapsamlı haber uygulaması.

## 🎯 Özellikler

- ✅ **RSS Tabanlı İçerik**: Güvenilir haber kaynaklarından otomatik içerik çekimi
- 📱 **Modern UI/UX**: Material Design 3 ile modern, kullanıcı dostu arayüz
- 🌙 **Dark Mode**: Göz yorgunluğunu azaltan karanlık tema desteği (Sistem teması otomatik algılama)
- 📴 **Offline Mode**: İnternet bağlantısı olmadan da haberleri görüntüleme
- 🔄 **Pull-to-Refresh**: Hızlı içerik yenileme
- 📄 **Infinite Scroll**: Sayfa sayfa haber yükleme ile performans optimizasyonu
- 🏷️ **Kategori Filtreleme**: Genel, Türkiye, Ekonomi, Teknoloji kategorileri
- 🎨 **Gelişmiş Filtreleme**: Tarih aralığı, kaynak, kategori ve okunma durumu filtreleri
- 🔗 **Kaynak Görüntüleme**: Orijinal haberlere doğrudan erişim
- 📤 **Paylaşım**: Haberleri sosyal medyada paylaşma
- 🔍 **Arama**: İçerik içinde arama özelliği
- ⚡ **Görsel Optimizasyonu**: Otomatik görsel boyutlandırma ve cache yönetimi
- 📊 **Analitik**: Okuma istatistikleri ve hedef takibi
- 🔔 **Bildirimler**: Günlük haber özetleri ve okuma hedefi hatırlatıcıları

## 🏗️ Teknik Mimari

### Clean Architecture
```
📁 lib/
├── 🎯 core/           # Temel bileşenler ve yardımcılar
├── 💾 data/           # Veri kaynakları ve repository implementasyonu
├── 🧠 domain/         # İş mantığı ve use case'ler  
├── 🎨 presentation/   # UI bileşenleri ve state management
└── 📱 main.dart       # Uygulama başlangıç noktası
```

### State Management
- **Riverpod**: Modern, güvenilir state management
- **Provider Pattern**: Dependency injection
- **Reactive Programming**: Stream-based data flow

### Teknoloji Stack
| Kategori | Teknoloji | Versiyon |
|----------|-----------|----------|
| **Framework** | Flutter | 3.8.1+ |
| **Language** | Dart | 3.0+ |
| **State Management** | Riverpod | ^2.4.9 |
| **HTTP Client** | Dio | ^5.4.0 |
| **Local Database** | Hive | ^2.2.3 |
| **XML Parsing** | xml | ^6.4.2 |
| **UI Components** | Material 3 | Built-in |

## 📊 RSS Haber Kaynakları

| Kategori | Kaynak | Format | Durum |
|----------|--------|--------|-------|
| 🚨 **Genel/Son Dakika** | Hürriyet | RSS 2.0 | ✅ Aktif |
| 🇹🇷 **Türkiye Haberleri** | NTV | Atom | ✅ Aktif |
| 💰 **Ekonomi** | Milliyet | RSS 2.0 | 🔄 Entegre edilecek |
| 💻 **Teknoloji** | WebTekno | RSS 2.0 | 🔄 Entegre edilecek |
| ⚽ **Spor** | Fanatik | RSS 2.0 | 🔄 Entegre edilecek |

## 🎨 Tasarım Sistemi

### Renk Paleti
```dart
// Light Theme (Mavi-Beyaz)
Primary: #1976D2    (Ana Mavi)
Secondary: #2196F3  (Açık Mavi)
Surface: #FFFFFF    (Beyaz)
Background: #F5F5F5 (Açık Gri)

// Dark Theme
Primary: #0D47A1    (Koyu Mavi) 
Surface: #121212    (Koyu Gri)
Background: #1E1E1E (Çok Koyu Gri)
```

### Typography
- **Başlıklar**: Roboto Bold, 18-24px
- **İçerik**: Roboto Regular, 14-16px  
- **Meta Bilgi**: Roboto Light, 12-14px

## 🚀 Kurulum ve Çalıştırma

### Ön Gereksinimler
- Flutter SDK (3.8.1 veya üstü)
- Android Studio / VSCode
- Git

### Adım Adım Kurulum

1. **Repository'yi klonlayın:**
```bash
git clone <repository-url>
cd haber-merkezi
```

2. **Dependencies yükleyin:**
```bash
flutter pub get
```

3. **Hive adaptörlerini oluşturun:**
```bash
flutter packages pub run build_runner build
```

4. **Uygulamayı çalıştırın:**
```bash
flutter run
```

### Build Komutları

**Android APK:**
```bash
flutter build apk --release
```

**iOS IPA:**
```bash
flutter build ios --release
```

## 📱 Ekran Görüntüleri

### Ana Sayfa
- Kategori tabları
- Haber kartları (görsel + başlık + özet)
- Pull-to-refresh özelliği

### Haber Detayı
- Büyük görsel
- Tam başlık ve içerik
- Kaynak görüntüleme butonu
- Paylaşım seçenekleri

### Dark Mode
- Göz dostu karanlık tema
- Tutarlı renk paleti
- Otomatik sistem teması desteği

## 🔧 Konfigürasyon

### RSS Feed Ekleme
```dart
// lib/core/constants/api_endpoints.dart
static const Map<String, String> rssFeedUrls = {
  'genel': 'https://www.hurriyet.com.tr/rss/anasayfa',
  'turkiye': 'https://www.ntv.com.tr/gundem.rss',
  // Yeni feed ekleyin...
};
```

### Tema Özelleştirme
```dart
// lib/presentation/themes/app_theme.dart
static final lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF1976D2),
  ),
);
```

## 🧪 Testing

### Test Çalıştırma
```bash
# Tüm testler
flutter test

# Sadece unit testler
flutter test test/unit/

# Sadece widget testler
flutter test test/widget/

# Integration testler  
flutter test integration_test/
```

### Test Coverage
- ✅ **Unit Tests**: Domain entities (Article, NewsState)
- ✅ **Widget Tests**: UI components (ArticleCard)
- 🔄 **Integration Tests**: E2E scenarios (planlanıyor)

### Mevcut Testler
- `test/unit/article_test.dart` - Article entity testleri
- `test/unit/news_state_test.dart` - NewsState testleri
- `test/widget/article_card_test.dart` - ArticleCard widget testleri

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'i push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 📞 İletişim

- **Proje Sahibi**: [İsim]
- **E-posta**: [email@example.com]
- **GitHub**: [github.com/username]

## ✨ Son Güncellemeler

### v1.1.0 (Güncel)
- ✅ Debug kodlarının temizlenmesi
- ✅ Infinite scroll implementasyonu
- ✅ Görsel optimizasyonu (CDN desteği, memory cache)
- ✅ Sistem teması otomatik algılama
- ✅ Analytics progress entegrasyonu
- ✅ Performans iyileştirmeleri
- ✅ Unit ve widget testleri eklendi

## 🔮 Gelecek Planları

- [x] Infinite scroll
- [x] Görsel optimizasyonu
- [x] Sistem teması algılama
- [ ] Push notification geliştirmeleri
- [ ] Çoklu dil desteği
- [ ] Widget desteği (Android/iOS)
- [ ] Tablet optimizasyonu
- [ ] Daha fazla test coverage

---

⭐ **Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!**
