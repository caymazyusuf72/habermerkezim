# Haber Merkezi - Performans Optimizasyon Planı

## 📊 Mevcut Durum Analizi

### Tespit Edilen Sorunlar

#### 1. Ana Thread Blokajı (KRİTİK)
- **Semptom**: 563 frame skip (9+ saniye donma)
- **Sebep**: XML parsing ve image processing ana thread'de
- **Etki**: Uygulama donuyor, ANR riski

#### 2. Aşırı Network Trafiği
- **Semptom**: 20+ paralel HTTP request
- **Sebep**: Tüm kategoriler aynı anda yükleniyor
- **Etki**: Yavaş başlangıç, network timeout

#### 3. Stream Bombardımanı
- **Semptom**: Her feed yüklendiğinde stream update
- **Sebep**: Debouncing yok
- **Etki**: Gereksiz rebuild'ler, UI lag

#### 4. Bellek Sorunları
- **Semptom**: Frequent GC, 5-7MB free
- **Sebep**: Binlerce makale aynı anda memory'de
- **Etki**: Yavaşlama, potansiyel crash

#### 5. Debug Logging
- **Semptom**: Yüzlerce satır log
- **Sebep**: Her işlem loglanıyor
- **Etki**: I/O overhead, performans kaybı

---

## 🎯 Optimizasyon Stratejisi

### Faz 1: Acil Müdahale (1-2 gün)

#### 1.1 XML Parsing Isolate'e Taşıma
**Dosya**: `lib/data/datasources/remote/rss_remote_data_source.dart`

```dart
// ÖNCESİ (Ana thread'de)
final articles = _parseRssFeed(xmlString);

// SONRASI (Background isolate'de)
final articles = await compute(_parseRssFeedIsolate, xmlString);

static List<ArticleModel> _parseRssFeedIsolate(String xmlString) {
  // Parse işlemi background'da
}
```

**Beklenen İyileşme**: 60-70% frame skip azalması

#### 1.2 Debug Logging Optimizasyonu
**Dosya**: `lib/core/utils/logger.dart` (yeni)

```dart
class AppLogger {
  static bool get isDebugMode {
    bool debug = false;
    assert(debug = true);
    return debug;
  }
  
  static void debug(String message) {
    if (isDebugMode) debugPrint(message);
  }
  
  static void error(String message) {
    debugPrint('❌ $message');
  }
}
```

**Değiştirilecek Dosyalar**:
- `lib/data/datasources/remote/rss_remote_data_source.dart`
- `lib/presentation/providers/news_provider.dart`
- `lib/domain/usecases/*.dart`

**Beklenen İyileşme**: 10-15% performans artışı

#### 1.3 Image Prefetch Devre Dışı
**Dosya**: `lib/core/services/image_prefetch_service.dart`

```dart
// Prefetch'i tamamen kaldır veya lazy yap
Future<void> prefetchImages(List<Article> articles) async {
  // DEVRE DIŞI - Sadece görünen görseller yüklenecek
  return;
}
```

**Beklenen İyileşme**: 20-30% startup hızlanması

---

### Faz 2: RSS Yükleme Stratejisi (2-3 gün)

#### 2.1 Progressive Loading
**Dosya**: `lib/presentation/providers/providers.dart`

```dart
final appInitializationProvider = FutureProvider<void>((ref) async {
  // 1. Sadece cache göster (anında)
  await Future.delayed(Duration(milliseconds: 100));
  
  // 2. Background'da sadece genel kategori yükle
  Future.microtask(() async {
    await ref.read(newsProvider.notifier)
        .loadArticlesByCategory('genel', refresh: true);
  });
  
  // 3. Diğer kategoriler lazy (kullanıcı tıkladığında)
});
```

#### 2.2 Feed Throttling
**Dosya**: `lib/data/datasources/remote/rss_remote_data_source.dart`

```dart
class FeedQueue {
  static const maxConcurrent = 3;
  final Queue<Future Function()> _queue = Queue();
  int _active = 0;
  
  Future<T> add<T>(Future Function() task) async {
    while (_active >= maxConcurrent) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    _active++;
    try {
      return await task();
    } finally {
      _active--;
    }
  }
}
```

**Beklenen İyileşme**: 50% network load azalması

#### 2.3 Stream Debouncing
**Dosya**: `lib/presentation/providers/news_provider.dart`

```dart
import 'package:rxdart/rxdart.dart';

void _setupArticlesStream() {
  _articlesSubscription = _watchAllArticles()
      .debounceTime(Duration(milliseconds: 500))  // 500ms debounce
      .listen((articles) {
        // Update state
      });
}
```

**Beklenen İyileşme**: 70% rebuild azalması

---

### Faz 3: Mimari İyileştirmeler (3-4 gün)

#### 3.1 Background Isolate Worker
**Dosya**: `lib/core/workers/background_worker.dart` (yeni)

```dart
class BackgroundWorker {
  static Future<List<ArticleModel>> parseRssFeed(String xml) async {
    return await compute(_parseInIsolate, xml);
  }
  
  static Future<Uint8List> processImage(Uint8List bytes) async {
    return await compute(_processInIsolate, bytes);
  }
}
```

#### 3.2 Lazy Category Loading
**Dosya**: `lib/presentation/pages/home/home_page.dart`

```dart
// Kategori değiştiğinde yükle
void _onCategoryChanged(String category) {
  if (!_loadedCategories.contains(category)) {
    ref.read(newsProvider.notifier)
        .loadArticlesByCategory(category);
    _loadedCategories.add(category);
  }
}
```

#### 3.3 Cache Strategy
**Dosya**: `lib/data/repositories/news_repository_impl.dart`

```dart
Future<List<Article>> getAllArticles() async {
  // 1. Cache'den hemen dön
  final cached = await _localDataSource.getCachedArticles();
  if (cached.isNotEmpty) {
    _emitToStream(cached);
  }
  
  // 2. Background'da refresh (stale-while-revalidate)
  if (_shouldRefresh(cached)) {
    _refreshInBackground();
  }
  
  return cached;
}
```

---

## 📈 Beklenen İyileştirmeler

### Performans Metrikleri

| Metrik | Önce | Sonra | İyileşme |
|--------|------|-------|----------|
| Startup Süresi | 10-15s | 2-3s | 70-80% |
| Frame Skip | 500+ | <50 | 90% |
| Memory Usage | 150MB | 80MB | 45% |
| Network Requests | 20+ | 3-5 | 75% |
| UI Responsiveness | Kötü | İyi | 80% |

### Kullanıcı Deneyimi

- ✅ Anında açılış (cache)
- ✅ Smooth scrolling
- ✅ Responsive UI
- ✅ Düşük bellek kullanımı
- ✅ Az network trafiği

---

## 🔧 İmplementasyon Sırası

### Gün 1-2: Acil Müdahale
1. ✅ XML parsing isolate'e taşı
2. ✅ Debug logging kaldır
3. ✅ Image prefetch devre dışı
4. ✅ Test ve doğrula

### Gün 3-4: RSS Optimizasyonu
1. ✅ Progressive loading
2. ✅ Feed throttling
3. ✅ Stream debouncing
4. ✅ Test ve doğrula

### Gün 5-6: Mimari İyileştirmeler
1. ✅ Background worker
2. ✅ Lazy loading
3. ✅ Cache strategy
4. ✅ Final test

### Gün 7: Test ve Deployment
1. ✅ Performance profiling
2. ✅ Memory leak check
3. ✅ User acceptance test
4. ✅ Production deployment

---

## 🎯 Başarı Kriterleri

### Teknik
- [ ] Startup < 3 saniye
- [ ] Frame skip < 50
- [ ] Memory < 100MB
- [ ] Network requests < 5 (startup)
- [ ] No ANR errors

### Kullanıcı
- [ ] Anında açılış hissi
- [ ] Smooth scrolling
- [ ] Responsive UI
- [ ] Düşük data kullanımı
- [ ] Stabil çalışma

---

## 📝 Notlar

### Dikkat Edilmesi Gerekenler
1. **Backward Compatibility**: Mevcut cache'ler çalışmalı
2. **Error Handling**: Network hataları graceful handle edilmeli
3. **Testing**: Her faz sonrası test edilmeli
4. **Monitoring**: Production'da performans izlenmeli

### Riskler ve Mitigasyon
1. **Risk**: Isolate overhead
   - **Mitigasyon**: Sadece heavy operations için kullan
   
2. **Risk**: Cache staleness
   - **Mitigasyon**: TTL ve background refresh
   
3. **Risk**: Lazy loading UX
   - **Mitigasyon**: Loading indicators ve skeleton screens

---

## 🔗 İlgili Dosyalar

### Değiştirilecek Dosyalar
1. `lib/data/datasources/remote/rss_remote_data_source.dart`
2. `lib/presentation/providers/news_provider.dart`
3. `lib/presentation/providers/providers.dart`
4. `lib/data/repositories/news_repository_impl.dart`
5. `lib/core/services/image_prefetch_service.dart`

### Yeni Dosyalar
1. `lib/core/utils/logger.dart`
2. `lib/core/workers/background_worker.dart`
3. `lib/core/utils/feed_queue.dart`

---

## 📊 Monitoring

### Production Metrikleri
- Startup time
- Frame rate
- Memory usage
- Network traffic
- Crash rate
- ANR rate

### Alerting
- Startup > 5s
- Frame skip > 100
- Memory > 150MB
- Crash rate > 1%