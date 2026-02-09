# 📰 HABER MERKEZİ - KAPSAMLI PROJE AÇIKLAMASI

## 📋 İÇİNDEKİLER
1. [Proje Genel Bakış](#proje-genel-bakış)
2. [Teknik Mimari](#teknik-mimari)
3. [Teknoloji Stack](#teknoloji-stack)
4. [Özellikler ve Fonksiyonaliteler](#özellikler-ve-fonksiyonaliteler)
5. [Proje Yapısı](#proje-yapısı)
6. [Veri Akışı ve State Management](#veri-akışı-ve-state-management)
7. [Servisler ve Altyapı](#servisler-ve-altyapı)
8. [UI/UX Tasarımı](#uiux-tasarımı)
9. [Performans Optimizasyonları](#performans-optimizasyonları)
10. [Güvenlik](#güvenlik)
11. [Test Stratejisi](#test-stratejisi)
12. [Deployment ve Build](#deployment-ve-build)

---

## 🎯 PROJE GENEL BAKIŞ

### Proje Tanımı
**Haber Merkezi**, RSS feed teknolojisini kullanarak çeşitli haber kaynaklarından otomatik olarak içerik çeken, kullanıcılara kişiselleştirilmiş haber okuma deneyimi sunan modern bir mobil uygulamadır. Flutter framework'ü kullanılarak geliştirilmiş, Clean Architecture prensipleri ile yapılandırılmış profesyonel bir üründür.

### Proje Bilgileri
- **Proje Adı:** haber_merkezi
- **Versiyon:** 1.0.0+1
- **Platform:** Android, iOS (cross-platform)
- **Geliştirme Dili:** Dart
- **Framework:** Flutter 3.8.1+
- **Mimari:** Clean Architecture
- **State Management:** Riverpod 2.6.1
- **Açıklama:** RSS tabanlı modern haber uygulaması

### Proje Hedefleri
1. **Kullanıcı Deneyimi:** Hızlı, akıcı ve sezgisel bir haber okuma deneyimi
2. **Offline Erişim:** İnternet bağlantısı olmadan da haberlere erişim
3. **Kişiselleştirme:** Kullanıcı tercihlerine göre özelleştirilebilir içerik
4. **Performans:** Düşük RAM ve CPU kullanımı ile optimize edilmiş çalışma
5. **Çok Yönlülük:** Metin, görsel, video ve podcast desteği
6. **Erişilebilirlik:** Çoklu dil, sesli okuma, okuma modu gibi özellikler

---

## 🏗️ TEKNİK MİMARİ

### Clean Architecture Yapısı

Proje, Bob Martin'in Clean Architecture prensiplerini takip eder ve katmanlı bir yapıya sahiptir:

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                     │
│  (UI, Pages, Widgets, Providers, Themes)               │
│  • Flutter Widgets                                       │
│  • Riverpod State Management                            │
│  • Material Design 3                                     │
└─────────────────────────────────────────────────────────┘
                          ↓↑
┌─────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                         │
│  (Entities, Repository Interfaces, Use Cases)           │
│  • Business Logic                                        │
│  • Core Models                                           │
│  • Abstract Repositories                                 │
└─────────────────────────────────────────────────────────┘
                          ↓↑
┌─────────────────────────────────────────────────────────┐
│                      DATA LAYER                          │
│  (Models, Data Sources, Repository Implementations)     │
│  • Remote Data Sources (RSS Feeds)                      │
│  • Local Data Sources (Hive)                            │
│  • Repository Implementations                            │
└─────────────────────────────────────────────────────────┘
                          ↓↑
┌─────────────────────────────────────────────────────────┐
│                    EXTERNAL SOURCES                      │
│  • RSS Feed Servers                                      │
│  • Firebase Services                                     │
│  • Local Storage (Hive)                                  │
└─────────────────────────────────────────────────────────┘
```

### Katman Açıklamaları

#### 1. Presentation Layer (lib/presentation/)
UI ve kullanıcı etkileşimlerinden sorumlu katman:
- **Pages:** Tam ekran sayfalar (HomePage, ArticleDetailPage, vb.)
- **Widgets:** Yeniden kullanılabilir UI bileşenleri
- **Providers:** Riverpod state management
- **Themes:** Tema ve stil tanımlamaları

#### 2. Domain Layer (lib/domain/)
İş mantığının bulunduğu katman:
- **Entities:** Temel veri modelleri (Article, Category, UserProfile)
- **Repositories:** Veri erişim sözleşmeleri (interface/abstract class)
- **Use Cases:** İş kuralları ve senaryolar (gelecekte eklenecek)

#### 3. Data Layer (lib/data/)
Veri kaynakları ve repository implementasyonları:
- **Data Sources:** Remote (RSS) ve Local (Hive) veri kaynakları
- **Models:** JSON serialization için veri modelleri
- **Repositories:** Domain katmanındaki interface'lerin implementasyonları

#### 4. Core Layer (lib/core/)
Ortak kullanılan yardımcı sınıflar:
- **Constants:** Uygulama sabitleri, API endpoint'leri
- **Services:** Ortak servisler (Notification, Audio, Hive)
- **Utils:** Yardımcı fonksiyonlar ve araçlar
- **Error:** Hata yönetimi

---

## 🔧 TEKNOLOJİ STACK

### Ana Framework ve Dil
- **Flutter:** 3.8.1+ (Cross-platform mobile framework)
- **Dart:** 3.8.1+ (Programlama dili)

### State Management
- **flutter_riverpod:** ^2.6.1
  - Modern, type-safe state management
  - Provider pattern
  - Reactive programming
  - Compile-time safety

### Networking ve Veri İşleme
- **dio:** ^5.4.0 (HTTP client, REST API çağrıları)
- **connectivity_plus:** ^7.0.0 (İnternet bağlantısı kontrolü)
- **xml:** ^6.4.2 (RSS feed XML parsing)
- **html:** ^0.15.5 (HTML içerik temizleme ve parsing)

### Local Database ve Cache
- **hive:** ^2.2.3 (NoSQL local database)
- **hive_flutter:** ^1.1.0 (Hive Flutter adaptörü)
- **hive_generator:** ^2.0.1 (Type adapter oluşturma)
- **flutter_cache_manager:** ^3.4.1 (Cache yönetimi)
- **shared_preferences:** ^2.3.2 (Key-value storage)
- **flutter_secure_storage:** ^9.2.2 (Güvenli veri saklama)

### Firebase Servisleri
- **firebase_core:** ^3.8.1 (Firebase temel)
- **firebase_auth:** ^5.3.3 (Kimlik doğrulama)
- **cloud_firestore:** ^5.5.3 (Cloud veritabanı)
- **firebase_storage:** ^12.3.6 (Dosya depolama)
- **firebase_analytics:** ^11.3.8 (Kullanıcı analitiği)
- **google_sign_in:** ^6.2.1 (Google ile giriş)

### UI/UX Kütüphaneleri
- **cached_network_image:** ^3.3.1 (Görsel cache ve yükleme)
- **shimmer:** ^3.0.0 (Yükleme animasyonları)
- **flutter_spinkit:** ^5.2.0 (Loading spinner'lar)
- **pull_to_refresh:** ^2.0.0 (Yenileme özelliği)
- **dynamic_color:** ^1.7.0 (Material Design 3 dinamik renkler)
- **google_fonts:** ^6.1.0 (Google Fonts entegrasyonu)
- **lottie:** ^3.1.2 (Lottie animasyonları)

### Multimedya Özellikleri
- **video_player:** ^2.8.2 (Video oynatma)
- **just_audio:** ^0.9.36 (Audio oynatma - podcast)
- **audio_service:** ^0.18.12 (Arka plan ses servisi)
- **youtube_player_flutter:** ^9.0.3 (YouTube entegrasyonu)
- **flutter_tts:** ^4.0.2 (Text-to-Speech, sesli okuma)

### Bildirim ve Widget
- **flutter_local_notifications:** ^19.5.0 (Yerel bildirimler)
- **timezone:** ^0.10.1 (Zaman dilimi yönetimi)
- **home_widget:** ^0.8.1 (Android home screen widget'ları)

### Yardımcı Paketler
- **url_launcher:** ^6.2.2 (URL açma)
- **share_plus:** ^12.0.1 (İçerik paylaşma)
- **fl_chart:** ^0.69.0 (Grafik ve chart'lar)
- **intl:** ^0.20.2 (Internationalization, tarih formatlama)
- **image_picker:** ^1.1.2 (Görsel seçme)
- **image_cropper:** ^8.0.2 (Görsel kırpma)
- **path_provider:** ^2.1.2 (Dosya sistemi yolları)
- **package_info_plus:** ^9.0.0 (Uygulama bilgileri)
- **in_app_update:** ^4.2.5 (Uygulama içi güncelleme)
- **flutter_dotenv:** ^5.1.0 (Environment variables)

### Development Tools
- **flutter_lints:** ^6.0.0 (Kod kalitesi ve stil)
- **build_runner:** ^2.4.7 (Kod üretimi)
- **flutter_launcher_icons:** ^0.14.4 (Uygulama ikonu oluşturma)

---

## ✨ ÖZELLİKLER VE FONKSİYONALİTELER

### 1. RSS Feed Yönetimi
#### Özellikler:
- ✅ Çoklu RSS kaynağı desteği
- ✅ RSS 2.0 ve Atom feed formatları
- ✅ Otomatik feed güncelleme (6 saatte bir)
- ✅ RSS health check (feed sağlık kontrolü)
- ✅ XML namespace desteği (iTunes, Dublin Core)
- ✅ Feed metadata parsing (başlık, açıklama, yayın tarihi)

#### Desteklenen Kaynaklar:
| Kategori | Kaynak | Format | Durum |
|----------|--------|--------|-------|
| Genel/Son Dakika | Hürriyet | RSS 2.0 | ✅ Aktif |
| Türkiye | NTV | Atom | ✅ Aktif |
| Ekonomi | Milliyet | RSS 2.0 | 🔄 Planlanmış |
| Teknoloji | WebTekno | RSS 2.0 | 🔄 Planlanmış |
| Spor | Fanatik | RSS 2.0 | 🔄 Planlanmış |

### 2. Offline Mode (Çevrimdışı Erişim)
#### Özellikler:
- ✅ Hive NoSQL database ile local storage
- ✅ 1,456+ makale cache kapasitesi
- ✅ Otomatik cache yönetimi
- ✅ Görsel cache (CachedNetworkImage)
- ✅ İnternet bağlantısı olmadan tam erişim
- ✅ Sync durumu göstergesi

#### Teknik Detaylar:
```dart
// Hive Box'ları:
- articlesBox: Makaleler
- favoritesBox: Favoriler
- readArticlesBox: Okunmuş makaleler
- settingsBox: Ayarlar
- userProfileBox: Kullanıcı profili
```

### 3. Kullanıcı Kimlik Doğrulama
#### Özellikler:
- ✅ Firebase Authentication
- ✅ Google Sign-In
- ✅ E-posta/Şifre ile giriş
- ✅ Anonim kullanıcı desteği
- ✅ Otomatik oturum yönetimi
- ✅ Güvenli token yönetimi

### 4. Tema ve Görünüm Özelleştirme
#### Tema Modları:
- **Light Mode:** Beyaz arka plan, koyu metin
- **Dark Mode:** Koyu arka plan, açık metin
- **System:** Sistem temasını otomatik takip

#### Renk Temaları:
- **Mavi Tema:** Varsayılan (Material Blue)
- **Dynamic Color:** Material You (Android 12+)
- **Özel Temalar:** Kullanıcı tanımlı (gelecekte)

#### Font Ölçekleme:
- 0.8x - 1.6x arası ayarlanabilir
- Erişilebilirlik için önemli
- Real-time değişiklik

### 5. Çoklu Dil Desteği (i18n)
#### Desteklenen Diller:
- 🇹🇷 Türkçe (tr_TR) - Varsayılan
- 🇬🇧 İngilizce (en_US)

#### Localization Yapısı:
```
lib/l10n/
├── app_tr.arb  # Türkçe çeviriler
├── app_en.arb  # İngilizce çeviriler
└── generated/  # Auto-generated localization dosyaları
```

### 6. Bildirim Sistemi
#### Bildirim Türleri:
- ✅ **Günlük Haber Özeti:** Her gün belirli saatte
- ✅ **Okuma Hedefi Hatırlatıcısı:** Hedef takibi
- ✅ **Trend Haberler:** Popüler içerik bildirimleri
- ✅ **Özel Kategori Bildirimleri:** Seçilen kategoriler için

#### Teknik Detaylar:
- flutter_local_notifications paketi
- Scheduled notifications (zamanlanmış)
- Rich notifications (görsel + metin)
- Custom notification channels
- Background notification handling

### 7. Podcast ve Audio Desteği
#### Özellikler:
- ✅ RSS podcast feed parsing
- ✅ Episode listesi ve metadata
- ✅ Audio player (just_audio)
- ✅ Arka plan oynatma
- ✅ Playback kontrolleri (play, pause, seek)
- ✅ Hız kontrolü (0.5x - 2.0x)
- ✅ Mini player (global)
- ✅ Full player modal

#### Desteklenen Formatlar:
- MP3, M4A, WAV, OGG

### 8. Video Desteği
#### Özellikler:
- ✅ Video player entegrasyonu
- ✅ YouTube video embedding
- ✅ Inline video oynatma
- ✅ Fullscreen mod
- ✅ Playback kontrolleri

### 9. Text-to-Speech (Sesli Okuma)
#### Özellikler:
- ✅ Makale içeriğini sesli okuma
- ✅ Çoklu dil desteği
- ✅ Hız kontrolü
- ✅ Ses tonu ayarlama
- ✅ Arka plan oynatma

### 10. Okuma Modu
#### Özellikler:
- ✅ Dikkat dağınıklığını azaltan minimal arayüz
- ✅ Özelleştirilebilir font boyutu
- ✅ Satır aralığı ayarı
- ✅ Arka plan rengi seçenekleri
- ✅ Otomatik scroll
- ✅ Bookmark desteği

### 11. Gamification (Oyunlaştırma)
#### Özellikler:
- ✅ Başarı sistemi (achievements)
- ✅ Rozet kazanma (badges)
- ✅ Okuma istatistikleri
- ✅ Günlük hedefler
- ✅ Seviye sistemi
- ✅ Liderlik tablosu (planlanmış)

#### Badge Türleri:
- 📖 Okuma Sayısı Rozetleri
- 🎯 Hedef Tamamlama Rozetleri
- 🔥 Günlük Streak Rozetleri
- ⭐ Özel Başarı Rozetleri

### 12. Analitik ve İstatistikler
#### Takip Edilen Metrikler:
- ✅ Toplam okunan makale sayısı
- ✅ Okuma süresi
- ✅ Favori kategoriler
- ✅ Günlük okuma hedefi
- ✅ Haftalık/aylık istatistikler
- ✅ En çok okunan kaynaklar

#### Görselleştirme:
- fl_chart ile grafikler
- Line chart (zaman serisi)
- Bar chart (kategori karşılaştırma)
- Pie chart (dağılım)

### 13. Widget Desteği (Android)
#### Widget Türleri:
- **Küçük Widget:** Günün en popüler haberi
- **Orta Widget:** 3 trending haber
- **Büyük Widget:** 5 haber + kategori seçimi

#### Özellikler:
- ✅ Otomatik güncelleme
- ✅ Tıklama ile uygulama açma
- ✅ Tema uyumlu tasarım
- ✅ Background update

### 14. Arama ve Filtreleme
#### Arama:
- ✅ Başlık içinde arama
- ✅ İçerik içinde arama
- ✅ Kaynak bazlı arama
- ✅ Tarih aralığı filtreleme

#### Filtreleme:
- ✅ Kategori filtresi
- ✅ Kaynak filtresi
- ✅ Tarih filtresi
- ✅ Okunma durumu filtresi
- ✅ Favori filtresi

### 15. Favoriler ve Okuma Listesi
#### Özellikler:
- ✅ Favori ekleme/çıkarma
- ✅ Okuma listesi yönetimi
- ✅ Offline senkronizasyon
- ✅ Cloud backup (Firebase)
- ✅ Kategori etiketleme

### 16. Paylaşım
#### Paylaşım Seçenekleri:
- ✅ Sosyal medya paylaşımı
- ✅ Link kopyalama
- ✅ E-posta gönderme
- ✅ WhatsApp, Twitter, Facebook vb.

### 17. Onboarding (İlk Giriş)
#### Özellikler:
- ✅ Hoş geldin ekranları
- ✅ Özellik tanıtımı
- ✅ İlgi alanı seçimi
- ✅ Bildirim izni
- ✅ Tema tercihi

### 18. Uygulama Güncellemeleri
#### Özellikler:
- ✅ In-app update (Android)
- ✅ Zorunlu güncelleme desteği
- ✅ Opsiyonel güncelleme
- ✅ Güncelleme dialog'ları
- ✅ Versiyon kontrolü

---

## 📁 PROJE YAPISI

### Detaylı Klasör Yapısı

```
haber_merkezi/
│
├── android/                          # Android platform dosyaları
│   ├── app/
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── AndroidManifest.xml
│   │   │       ├── kotlin/
│   │   │       └── res/
│   │   ├── build.gradle              # App-level Gradle
│   │   └── google-services.json      # Firebase config
│   ├── gradle/                       # Gradle wrapper
│   └── build.gradle                  # Project-level Gradle
│
├── ios/                              # iOS platform dosyaları
│   ├── Runner/
│   │   ├── Info.plist
│   │   ├── AppDelegate.swift
│   │   └── GoogleService-Info.plist  # Firebase config
│   └── Podfile                       # CocoaPods dependencies
│
├── lib/                              # Ana uygulama kodu
│   │
│   ├── main.dart                     # Uygulama giriş noktası
│   ├── firebase_options.dart         # Firebase yapılandırması
│   │
│   ├── core/                         # Çekirdek bileşenler
│   │   ├── constants/
│   │   │   ├── app_constants.dart    # Genel sabitler
│   │   │   ├── api_endpoints.dart    # RSS feed URL'leri
│   │   │   └── theme_constants.dart  # Renk, font sabitleri
│   │   │
│   │   ├── error/
│   │   │   ├── exceptions.dart       # Custom exception'lar
│   │   │   └── failures.dart         # Hata yönetimi
│   │   │
│   │   ├── services/
│   │   │   ├── hive_service.dart     # Hive database servisi
│   │   │   ├── notification_service.dart
│   │   │   ├── audio_player_service.dart
│   │   │   ├── podcast_service.dart
│   │   │   ├── tts_service.dart      # Text-to-Speech
│   │   │   ├── analytics_service.dart
│   │   │   ├── update_service.dart
│   │   │   └── widget_service.dart
│   │   │
│   │   └── utils/
│   │       ├── date_formatter.dart
│   │       ├── html_cleaner.dart
│   │       ├── url_helper.dart
│   │       └── retry_helper.dart
│   │
│   ├── data/                         # Veri katmanı
│   │   ├── datasources/
│   │   │   ├── remote/
│   │   │   │   └── rss_remote_datasource.dart
│   │   │   └── local/
│   │   │       └── article_local_datasource.dart
│   │   │
│   │   ├── models/
│   │   │   ├── article_model.dart
│   │   │   ├── article_model.g.dart   # Hive generated
│   │   │   ├── category_model.dart
│   │   │   ├── user_profile_model.dart
│   │   │   ├── badge_model.dart
│   │   │   └── reading_stats_model.dart
│   │   │
│   │   └── repositories/
│   │       ├── news_repository_impl.dart
│   │       ├── user_repository_impl.dart
│   │       └── analytics_repository_impl.dart
│   │
│   ├── domain/                       # İş mantığı katmanı
│   │   ├── entities/
│   │   │   ├── article.dart          # Article entity
│   │   │   ├── category.dart
│   │   │   ├── user_profile.dart
│   │   │   └── badge.dart
│   │   │
│   │   └── repositories/
│   │       ├── news_repository.dart  # Abstract interface
│   │       ├── user_repository.dart
│   │       └── analytics_repository.dart
│   │
│   ├── l10n/                         # Localization
│   │   ├── app_tr.arb                # Türkçe
│   │   ├── app_en.arb                # İngilizce
│   │   └── generated/                # Auto-generated
│   │       └── app_localizations.dart
│   │
│   └── presentation/                 # UI katmanı
│       │
│       ├── app.dart                  # Ana MaterialApp widget
│       │
│       ├── pages/                    # Sayfalar
│       │   ├── splash/
│       │   │   └── splash_page.dart
│       │   │
│       │   ├── onboarding/
│       │   │   └── onboarding_page.dart
│       │   │
│       │   ├── auth/
│       │   │   └── login_page.dart
│       │   │
│       │   ├── home/
│       │   │   ├── home_page.dart
│       │   │   └── widgets/
│       │   │       ├── article_card.dart
│       │   │       ├── category_tabs.dart
│       │   │       └── news_list.dart
│       │   │
│       │   ├── article_detail/
│       │   │   ├── article_detail_page.dart
│       │   │   └── widgets/
│       │   │       ├── article_header.dart
│       │   │       ├── article_content.dart
│       │   │       └── reading_mode_bottom_sheet.dart
│       │   │
│       │   ├── favorites/
│       │   │   └── favorites_page.dart
│       │   │
│       │   ├── search/
│       │   │   └── search_page.dart
│       │   │
│       │   ├── settings/
│       │   │   ├── settings_page.dart
│       │   │   └── widgets/
│       │   │       ├── theme_settings.dart
│       │   │       └── notification_settings.dart
│       │   │
│       │   ├── profile/
│       │   │   └── profile_page.dart
│       │   │
│       │   ├── badges/
│       │   │   └── badges_page.dart
│       │   │
│       │   ├── statistics/
│       │   │   └── statistics_page.dart
│       │   │
│       │   ├── podcast/
│       │   │   └── podcast_page.dart
│       │   │
│       │   └── notifications/
│       │       └── notification_preferences_page.dart
│       │
│       ├── providers/                # Riverpod providers
│       │   ├── providers.dart        # Provider exports
│       │   ├── news_provider.dart
│       │   ├── theme_provider.dart
│       │   ├── auth_provider.dart
│       │   ├── locale_provider.dart
│       │   ├── favorites_provider.dart
│       │   ├── search_provider.dart
│       │   ├── audio_player_provider.dart
│       │   ├── notification_provider.dart
│       │   ├── reading_mode_provider.dart
│       │   └── onboarding_provider.dart
│       │
│       ├── widgets/                  # Ortak widget'lar
│       │   ├── loading/
│       │   │   ├── shimmer_loading.dart
│       │   │   └── spinner_loading.dart
│       │   │
│       │   ├── error/
│       │   │   └── error_display.dart
│       │   │
│       │   ├── common/
│       │   │   ├── optimized_image.dart
│       │   │   ├── pull_to_refresh_wrapper.dart
│       │   │   └── custom_app_bar.dart
│       │   │
│       │   └── audio_player_widget.dart
│       │
│       └── themes/                   # Tema tanımlamaları
│           ├── app_theme.dart        # Ana tema
│           ├── color_schemes.dart    # Renk şemaları
│           └── text_styles.dart      # Text stilleri
│
├── assets/                           # Statik dosyalar
│   ├── icons/
│   │   ├── app_icon.png
│   │   └── app_icon.svg
│   └── animation/
│       └── News.json                 # Lottie animasyon
│
├── test/                             # Test dosyaları
│   ├── unit/                         # Unit testler
│   │   ├── article_test.dart
│   │   ├── news_state_test.dart
│   │   ├── gamification_service_test.dart
│   │   └── retry_helper_test.dart
│   │
│   └── widget/                       # Widget testler
│       ├── article_card_test.dart
│       ├── badges_page_test.dart
│       └── news_list_test.dart
│
├── integration_test/                 # Integration testler
│   └── app_test.dart
│
├── docs/                             # Dokümantasyon
│   ├── architecture.md
│   ├── completed_features.md
│   ├── api_documentation.md
│   └── development_roadmap_2025.md
│
├── plans/                            # Geliştirme planları
│   ├── 2026_q1_development_roadmap.md
│   ├── smart_notifications_and_reading_mode_plan.md
│   └── ui_development_plan.md
│
├── .env.example                     # Environment değişken şablonu
├── .env                              # Environment değişkenler (git ignore)
├── .gitignore                        # Git ignore kuralları
├── .metadata                         # Flutter metadata
├── analysis_options.yaml             # Dart analyzer ayarları
├── build.yaml                        # Build runner config
├── l10n.yaml                         # Localization config
├── pubspec.yaml                      # Paket bağımlılıkları
├── pubspec.lock                      # Lock file
├── README.md                         # Proje README
└── PERFORMANCE_REPORT.md             # Performans raporu
```

---

## 🔄 VERİ AKIŞI VE STATE MANAGEMENT

### Riverpod State Management Yapısı

```dart
// Provider Hierarchy
AppInitializationProvider
    ↓
├─ HiveServiceProvider
├─ FirebaseProvider
├─ ThemeProvider
│   ├─ ThemeMode (light/dark/system)
│   ├─ FontScale (0.8 - 1.6)
│   └─ ColorTheme (blue/dynamic)
├─ LocaleProvider
│   └─ Locale (tr_TR / en_US)
├─ AuthProvider
│   ├─ User (Firebase User)
│   └─ AuthState
├─ NewsProvider
│   ├─ ArticleList
│   ├─ LoadingState
│   ├─ ErrorState
│   └─ Categories
├─ FavoritesProvider
├─ SearchProvider
├─ AudioPlayerProvider
├─ NotificationProvider
└─ ReadingModeProvider
```

### State Management Örnekleri

#### 1. News Provider
```dart
final newsProvider = StateNotifierProvider<NewsNotifier, NewsState>(
  (ref) => NewsNotifier(ref.read(newsRepositoryProvider)),
);

class NewsState {
  final List<Article> articles;
  final bool isLoading;
  final String? error;
  final String selectedCategory;
  final int currentPage;
}
```

#### 2. Theme Provider
```dart
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>(
  (ref) => ThemeNotifier(),
);

class ThemeState {
  final ThemeMode themeMode;
  final double fontScale;
  final ColorTheme colorTheme;
}
```

### Veri Akış Diyagramı

```
User Action (UI)
      ↓
  Provider
      ↓
  Repository (Interface)
      ↓
  Repository Implementation
      ↓
  ┌─────────────┬─────────────┐
  ↓             ↓             ↓
Remote DS    Local DS    Firebase
(RSS Feed)   (Hive)      (Cloud)
      ↓             ↓             ↓
  Parse         Read        Query
      ↓             ↓             ↓
  Model ← → Entity ← → Model
      ↓
  Provider (Update State)
      ↓
  UI (Rebuild)
```

---

## 🛠️ SERVİSLER VE ALTYAPI

### 1. Hive Service
**Dosya:** `lib/core/services/hive_service.dart`

#### Sorumluluklar:
- Hive database başlatma
- Box açma/kapama
- Type adapter kaydetme
- CRUD işlemleri

#### Hive Box'ları:
```dart
// Box İsimleri ve Tipleri
articlesBox: Box<ArticleModel>       // 1,456+ makale
favoritesBox: Box<String>            // Favori ID'leri
readArticlesBox: Box<String>         // Okunmuş ID'leri
settingsBox: Box<dynamic>            // Ayarlar (key-value)
userProfileBox: Box<UserProfile>     // Kullanıcı profili
badgesBox: Box<Badge>                // Rozetler
statsBox: Box<ReadingStats>          // İstatistikler
```

### 2. Notification Service
**Dosya:** `lib/core/services/notification_service.dart`

#### Özellikler:
- Local notification yönetimi
- Scheduled notifications
- Channel yönetimi
- Notification tapping handling
- Background notifications

#### Notification Channels:
```dart
- daily_summary: Günlük özet
- reading_reminder: Okuma hatırlatıcısı
- trending_news: Trend haberler
- custom_category: Özel kategori
```

### 3. Audio Player Service
**Dosya:** `lib/core/services/audio_player_service.dart`

#### Özellikler:
- just_audio wrapper
- Playback kontrolleri
- Hız kontrolü (0.5x - 2.0x)
- Seek işlemleri (+/-10s)
- Progress tracking
- Background playback

### 4. Podcast Service
**Dosya:** `lib/core/services/podcast_service.dart`

#### Özellikler:
- RSS podcast feed parsing
- iTunes namespace desteği
- Episode metadata extraction
- Duration parsing
- Image URL extraction

### 5. Analytics Service
**Dosya:** `lib/core/services/analytics_service.dart`

#### Takip Edilen Eventler:
```dart
- article_read: Makale okuma
- article_favorite: Favorilere ekleme
- search_performed: Arama yapma
- category_changed: Kategori değiştirme
- badge_unlocked: Rozet kazanma
- daily_goal_achieved: Günlük hedef
```

### 6. Update Service
**Dosya:** `lib/core/services/update_service.dart`

#### Özellikler:
- In-app update (Android)
- Version checking
- Flexible update
- Immediate update
- Update progress tracking

### 7. Widget Service
**Dosya:** `lib/core/services/widget_service.dart`

#### Özellikler:
- Home widget yönetimi
- Widget data update
- Background sync
- Click handling

---

## 🎨 UI/UX TASARIMI

### Material Design 3

Proje, Google'ın Material Design 3 (Material You) prensiplerini takip eder.

#### Renk Sistemi

**Light Theme (Açık Tema):**
```dart
Primary Color:      #1976D2 (Mavi)
Primary Container:  #E3F2FD (Açık Mavi)
Secondary:          #2196F3 (Açık Mavi)
Background:         #F5F5F5 (Açık Gri)
Surface:            #FFFFFF (Beyaz)
Error:              #D32F2F (Kırmızı)
On Primary:         #FFFFFF (Beyaz)
On Background:      #000000 (Siyah)
```

**Dark Theme (Koyu Tema):**
```dart
Primary Color:      #0D47A1 (Koyu Mavi)
Primary Container:  #1565C0 (Orta Mavi)
Secondary:          #1976D2 (Mavi)
Background:         #1E1E1E (Çok Koyu Gri)
Surface:            #121212 (Koyu Gri)
Error:              #CF6679 (Açık Kırmızı)
On Primary:         #FFFFFF (Beyaz)
On Background:      #FFFFFF (Beyaz)
```

**Dynamic Color (Material You):**
- Android 12+ cihazlarda wallpaper'dan renk çıkarma
- Otomatik light/dark varyant oluşturma
- Sistem teması ile senkronizasyon

#### Typography

```dart
// Headline Styles
headlineLarge:  Roboto, 32sp, Bold
headlineMedium: Roboto, 28sp, Bold
headlineSmall:  Roboto, 24sp, Bold

// Title Styles
titleLarge:     Roboto, 22sp, Medium
titleMedium:    Roboto, 16sp, Medium
titleSmall:     Roboto, 14sp, Medium

// Body Styles
bodyLarge:      Roboto, 16sp, Regular
bodyMedium:     Roboto, 14sp, Regular
bodySmall:      Roboto, 12sp, Regular

// Label Styles
labelLarge:     Roboto, 14sp, Medium
labelMedium:    Roboto, 12sp, Medium
labelSmall:     Roboto, 11sp, Medium
```

#### Spacing System

```dart
// Padding Values
extraSmall:  4px
small:       8px
medium:      16px
large:       24px
extraLarge:  32px

// Border Radius
small:   4px
medium:  8px
large:   12px
xl:      16px
```

### UI Bileşenleri

#### 1. Article Card
**Görünüm:**
- Büyük görsel (16:9 aspect ratio)
- Başlık (max 2 satır)
- Özet (max 3 satır)
- Kaynak ve tarih bilgisi
- Favori butonu
- Okunma durumu göstergesi

#### 2. Category Tabs
- Material Tabs
- Scroll edilebilir
- Aktif kategori vurgulama
- Badge sayacı (yeni haber)

#### 3. Shimmer Loading
- Skeleton screens
- Article card şeklinde
- Smooth animation
- Native hissi

#### 4. Bottom Navigation
**Menü Öğeleri:**
- 🏠 Ana Sayfa
- ⭐ Favoriler
- 🔍 Arama
- 📊 İstatistikler
- ⚙️ Ayarlar

#### 5. App Drawer
**Menü Yapısı:**
```
├── Profil
├── Kategoriler
│   ├── Genel
│   ├── Türkiye
│   ├── Ekonomi
│   ├── Teknoloji
│   └── Spor
├── Özellikler
│   ├── Favoriler
│   ├── Okuma Listesi
│   ├── Podcast
│   └── Trending
├── Gamification
│   ├── Rozetler
│   └── İstatistikler
└── Ayarlar
```

---

## ⚡ PERFORMANS OPTİMİZASYONLARI

### RAM Kullanımı: ~312MB

#### Optimizasyon Teknikleri:

**1. Görsel Optimizasyonu:**
```dart
// CachedNetworkImage settings
maxCacheCount: 50              // (varsayılan: 1000)
maxMemoryCacheSize: 25MB       // (varsayılan: 100MB)
cacheWidth: 800px              // Görsel boyut sınırı
cacheHeight: 600px
```

**2. Lazy Loading:**
```dart
ListView.builder(
  itemBuilder: (context, index) {
    // Sadece görünür öğeleri oluştur
  }
)
```

**3. Infinite Scroll:**
- Sayfa başına 20 makale
- Scroll listener
- Auto pagination
- Loading indicator

**4. Database Indexing:**
```dart
// Hive box optimization
compactionStrategy: (entries, deletedEntries) {
  return deletedEntries > 20;
}
```

**5. Image Caching:**
- Network image cache
- Memory cache
- Disk cache
- CDN desteği

### CPU Kullanımı: ~0.5% (Idle)

#### Optimizasyonlar:
- Efficient setState kullanımı
- Widget rebuild minimizasyonu
- Const constructor'lar
- Riverpod dependency injection

### Build Performansı

**İlk Build:**
- Android: ~2-3 dakika
- iOS: ~3-5 dakika

**Hot Reload:**
- <1 saniye

**Hot Restart:**
- ~2-3 saniye

---

## 🔒 GÜVENLİK

### 1. API Key Yönetimi

**Environment Variables:**
```dart
// .env dosyası
FIREBASE_API_KEY=xxxxx
FIREBASE_APP_ID=xxxxx
FIREBASE_PROJECT_ID=xxxxx
```

**Kullanım:**
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiKey = dotenv.env['FIREBASE_API_KEY'];
```

### 2. Secure Storage

```dart
// flutter_secure_storage
final storage = FlutterSecureStorage();

// Write
await storage.write(key: 'token', value: userToken);

// Read
final token = await storage.read(key: 'token');
```

### 3. Firebase Security Rules

**Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null 
                         && request.auth.uid == userId;
    }
  }
}
```

### 4. Input Validation

```dart
// HTML sanitization
String cleanHtml(String html) {
  final document = parse(html);
  return parse(document.body?.text ?? '').documentElement?.text ?? '';
}

// URL validation
bool isValidUrl(String url) {
  final uri = Uri.tryParse(url);
  return uri != null && uri.hasScheme;
}
```

---

## 🧪 TEST STRATEJİSİ

### Test Coverage

```
test/
├── unit/                    # Unit Tests (~15 dosya)
│   ├── article_test.dart
│   ├── news_state_test.dart
│   ├── gamification_service_test.dart
│   ├── retry_helper_test.dart
│   └── ...
│
├── widget/                  # Widget Tests (~5 dosya)
│   ├── article_card_test.dart
│   ├── badges_page_test.dart
│   ├── news_list_test.dart
│   └── ...
│
└── integration_test/        # E2E Tests
    └── app_test.dart
```

### Test Örnekleri

**Unit Test:**
```dart
test('Article should be created with valid data', () {
  final article = Article(
    id: '1',
    title: 'Test',
    content: 'Content',
    publishDate: DateTime.now(),
  );
  
  expect(article.id, '1');
  expect(article.title, 'Test');
});
```

**Widget Test:**
```dart
testWidgets('ArticleCard displays title', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ArticleCard(article: testArticle),
    ),
  );
  
  expect(find.text('Test Title'), findsOneWidget);
});
```

---

## 📦 DEPLOYMENT VE BUILD

### Android Build

**Debug APK:**
```bash
flutter build apk --debug
```

**Release APK:**
```bash
flutter build apk --release
```

**App Bundle (Play Store):**
```bash
flutter build appbundle --release
```

**Split APK (ABI):**
```bash
flutter build apk --split-per-abi --release
```

### iOS Build

**Development:**
```bash
flutter build ios --debug
```

**Release:**
```bash
flutter build ios --release
```

**IPA (App Store):**
```bash
flutter build ipa --release
```

### Build Yapılandırması

**Android (build.gradle):**
```gradle
android {
    compileSdk 36
    
    defaultConfig {
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0.0"
    }
    
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile(
                'proguard-android-optimize.txt'
            ), 'proguard-rules.pro'
        }
    }
}
```

### Signing (İmzalama)

**Android Keystore:**
```bash
keytool -genkey -v -keystore haber-merkezi-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias haber-merkezi
```

**key.properties:**
```properties
storePassword=****
keyPassword=****
keyAlias=haber-merkezi
storeFile=../haber-merkezi-key.jks
```

---

## 📊 PROJE İSTATİSTİKLERİ

### Kod Metrikleri

| Metrik | Değer |
|--------|-------|
| Toplam Dosya | 150+ |
| Dart Dosyası | 120+ |
| Satır Sayısı | ~15,000+ |
| Widget Sayısı | 50+ |
| Provider Sayısı | 15+ |
| Servis Sayısı | 10+ |
| Test Dosyası | 20+ |

### Bağımlılıklar

| Kategori | Paket Sayısı |
|----------|--------------|
| Production | 50+ |
| Development | 5 |
| Toplam | 55+ |

### Platform Desteği

| Platform | Durum | Min Version |
|----------|-------|-------------|
| Android | ✅ Aktif | API 21 (Lollipop 5.0) |
| iOS | ✅ Aktif | iOS 12.0 |
| Web | 🔄 Kısmi | Modern browsers |
| Windows | 🔄 Deneysel | Windows 10+ |
| macOS | 🔄 Deneysel | macOS 10.14+ |
| Linux | 🔄 Deneysel | Ubuntu 20.04+ |

---

## 🎯 KULLANICI AKIŞLARI

### 1. İlk Kullanım (First Time User Experience)

```
Splash Screen (2s)
    ↓
Onboarding (4 ekran)
    ├─ Hoş Geldiniz
    ├─ Özellikler
    ├─ İlgi Alanları Seçimi
    └─ Bildirim İzni
    ↓
Login/Register
    ├─ Google Sign-In
    ├─ Email/Password
    └─ Anonim Devam
    ↓
Ana Sayfa
```

### 2. Haber Okuma Akışı

```
Ana Sayfa
    ↓
Kategori Seçimi
    ↓
Haber Listesi (Scroll)
    ↓
Haber Detayı
    ├─ Oku
    ├─ Favoriye Ekle
    ├─ Paylaş
    ├─ Okuma Modu
    ├─ Sesli Okuma (TTS)
    └─ Kaynak Görüntüle
```

### 3. Podcast Dinleme Akışı

```
Drawer → Podcast
    ↓
RSS Feed Girişi
    ↓
Episode Listesi
    ↓
Episode Seç
    ↓
Audio Player
    ├─ Play/Pause
    ├─ Seek (+/-10s)
    ├─ Hız (0.5x-2x)
    └─ Background Play
```

---

## 🔮 GELECEK PLANLAR (ROADMAP)

### Q1 2026
- ✅ Podcast ve video desteği
- ✅ Akıllı bildirimler
- ✅ Okuma modu
- ✅ Performans optimizasyonları
- 🔄 Push notification geliştirmeleri
- 🔄 Tablet optimizasyonu

### Q2 2026
- 📋 Backend API geliştirme
- 📋 Daha fazla RSS kaynağı
- 📋 Gelişmiş arama (NLP)
- 📋 Sosyal özellikler (yorum, beğeni)
- 📋 Çoklu dil genişletme (AR, FR, DE)

### Q3 2026
- 📋 Monetization (reklam, premium)
- 📋 AI önerileri (machine learning)
- 📋 Web versiyonu
- 📋 Desktop uygulamaları (Windows, macOS)

### Q4 2026
- 📋 API açma (üçüncü parti entegrasyon)
- 📋 White-label çözümü
- 📋 Enterprise features
- 📋 Real-time collaboration

---

## 📞 DESTEK VE İLETİŞİM

### Teknik Destek
- **Issue Tracker:** GitHub Issues
- **Email:** support@habermerkezi.com (örnek)
- **Discord:** Haber Merkezi Community

### Dokümantasyon
- **README.md:** Genel bilgiler ve hızlı başlangıç
- **docs/architecture.md:** Teknik mimari detayları
- **docs/api_documentation.md:** API referansı
- **docs/completed_features.md:** Tamamlanan özellikler

### Katkıda Bulunma
```bash
# 1. Fork the repo
# 2. Create feature branch
git checkout -b feature/amazing-feature

# 3. Commit changes
git commit -m 'Add amazing feature'

# 4. Push to branch
git push origin feature/amazing-feature

# 5. Open Pull Request
```

---

## 📄 LİSANS

Bu proje MIT lisansı altında lisanslanmıştır.

```
MIT License

Copyright (c) 2026 Haber Merkezi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

---

## 🙏 TEŞEKKÜRLER

### Kullanılan Açık Kaynak Projeler
- Flutter Framework
- Riverpod
- Hive
- Firebase
- Just Audio
- ve 50+ diğer paket...

### Topluluk
- Flutter Community
- Stack Overflow
- GitHub Contributors

---

## 📝 SÜRÜM GEÇMİŞİ

### v1.0.0 (Şubat 2026) - İlk Sürüm
- ✅ Temel RSS feed desteği
- ✅ Offline mode
- ✅ Dark/Light theme
- ✅ Firebase entegrasyonu
- ✅ Podcast ve video desteği
- ✅ Gamification sistemi
- ✅ 50+ özellik

### v0.9.0 (Aralık 2025) - Beta
- ✅ Ana özellikler tamamlandı
- ✅ Test coverage %70
- ✅ Performance optimizasyonları

### v0.5.0 (Kasım 2025) - Alpha
- ✅ MVP tamamlandı
- ✅ Temel özellikler çalışıyor

---

## 🎓 ÖĞRENİLENLER VE EN İYİ UYGULAMALAR

### Flutter Best Practices
1. **Clean Architecture** - Katmanlı mimari
2. **Riverpod** - Type-safe state management
3. **Const Constructors** - Performance
4. **Lazy Loading** - Memory efficiency
5. **Error Handling** - Robust error management

### Kod Kalitesi
- **Lint Rules:** flutter_lints ^6.0.0
- **Code Review:** Pull request sistemi
- **Testing:** Unit + Widget + Integration
- **Documentation:** Inline comments + README

### Performans
- **Image Optimization:** Cache + CDN
- **Database:** Hive indexing
- **Network:** Retry mechanism
- **Memory:** Cache limitleri

---

## 🏆 BAŞARILAR

### Teknik Başarılar
- ✅ RAM kullanımı 312MB'a düşürüldü
- ✅ Build süreleri optimize edildi
- ✅ 586 issue'dan 0 error
- ✅ Smooth 60 FPS performans

### Fonksiyonel Başarılar
- ✅ 1,456+ makale cache
- ✅ 15+ provider
- ✅ 50+ widget
- ✅ 20+ test

---

**Son Güncelleme:** 9 Şubat 2026 10:18 (UTC+3)  
**Versiyon:** 1.0.0  
**Durum:** ✅ Production Ready  
**Emülatör:** ✅ Çalışıyor (emulator-5554)

---

*Bu doküman, Haber Merkezi projesinin kapsamlı teknik ve fonksiyonel açıklamasını içermektedir. Proje, modern Flutter best practice'leri kullanılarak geliştirilmiş, Clean Architecture prensipleriyle yapılandırılmış, production-ready bir mobil uygulamadır.*
