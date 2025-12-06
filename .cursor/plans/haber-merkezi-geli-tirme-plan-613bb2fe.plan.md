---
name: Untitled Plan
overview: ""
todos:
  - id: ef566771-7c77-4cc6-a997-53e24224aeff
    content: pubspec.yaml'a google_fonts paketini ekle
    status: completed
  - id: 553f3ade-a82d-41f9-a327-dcc07a96b322
    content: AppTheme dosyasında adaçayı yeşili ve mat siyah renk paletini oluştur
    status: completed
  - id: e92673cb-fcba-4326-af3d-46d42cabeb01
    content: TextTheme stillerini Merriweather serif font ile güncelle
    status: completed
  - id: f44a2c68-14a3-4bb0-821b-d6acebefc54f
    content: Notification banner widget ve provider oluştur
    status: completed
  - id: 1811148b-c344-4f80-b7bb-8db837797f76
    content: Home page'e bildirim banner'ı entegre et
    status: completed
  - id: d94d08cd-fd8e-4fc1-80db-e0fc6c8036a3
    content: Splash screen tasarımını adaçayı yeşili/mat siyah ile güncelle ve animasyonları iyileştir
    status: completed
  - id: 36ba94f7-5f3f-432c-a6e2-345fa103f654
    content: Loading indicator ve shimmer efektini adaçayı yeşili tonlarıyla güncelle
    status: completed
  - id: 5e02c749-e129-4c10-b118-4883af3da5ea
    content: Article card tasarımını profesyonel gazete havasına uygun şekilde güncelle
    status: completed
  - id: a0486c43-08a7-4e88-8092-6952ee6adfdd
    content: AppBar, kategori tab ve bottom navigation stillerini yeni tema ile uyumlu hale getir
    status: completed
  - id: 207e541f-a050-4006-8d2c-5f9dcd475e0c
    content: Notification banner'ın boş görünme sorununu düzelt
    status: completed
  - id: b484d725-9dc0-482c-9d2c-54a02d6258c3
    content: Ana manşet (banner tarzı) widget’ının tasarımını ve veri modelini netleştirip implementasyona hazırlamak
    status: pending
  - id: ef84ea99-ce2e-4661-8f68-1de84af7603a
    content: Çoklu haber kartı widget’ının (2–3 satırlı liste) layout ve veri yapısını planlamak
    status: pending
  - id: 0dd4e935-a1e7-47b2-9168-58c77119e496
    content: Tek ve çok kategorili kısayol widget’larının kullanım senaryosu ve layout’unu planlamak
    status: pending
  - id: 6707d417-fe3f-4b7e-9718-9fbc6f757adb
    content: Okuma listesi / yer imi widget’ının veri akışını ve tasarımını planlamak
    status: pending
  - id: ab555e0d-91cd-4268-b39f-5792ac6a1ee7
    content: Günlük özet / sabah bülteni widget’ının veri kaynağı ve gösterim şeklini planlamak
    status: pending
  - id: d43b6c18-e250-47a7-b51d-37b0cc383f2e
    content: Tüm widget’lar için ortak SharedPreferences key sözleşmesi ve `WidgetService` genişletmesini tasarlamak
    status: pending
---

## Haber Uygulaması Widget Stratejisi

### Hedef

Uygulamanın haber deneyimini ana ekrana taşıyan, görsel olarak tutarlı, performanslı ve gerçekten kullanılan birden fazla widget tasarlayıp uygulamak.

### 1. Genel Teknik Çerçeve

- `home_widget` paketi üzerinden tek `appGroupId` ile tüm widget’ların veri paylaşması.
- Ortak servis: `lib/core/services/widget_service.dart` içinde çoklu widget tipine göre veri hazırlayan yapı.
- Android tarafında her widget için ayrı `AppWidgetProvider` + layout + info XML dosyaları.
- Verileri paylaşmak için tek SharedPreferences şeması (ör. `flutter.home_widget` / `group.com.habermerkezi.widget`) ve açık bir key sözleşmesi.

### 2. Ana Manşet Widget’ı (Banner Tarzı)

**Amaç:** Ekran görüntüsündeki üst bildirim banner’ına en yakın tasarımı, ana ekran widget’ı olarak sağlamak.

- Tasarım:
- Yatay, tam genişlikte, 1 satır yüksekliğinde (56dp civarı).
- Sol: menü ikonu, yanında mor çerçeveli `SON DAKİKA` rozeti.
- Orta: Marquee ile kayan haber başlığı (uygulamadaki notification banner ile aynı tipografi).
- Sağ: `>` ileri butonu, `|| / ▶` durdur/oynat butonu.
- Veri:
- `breaking` etiketli veya en güncel 10 haberin başlıkları.
- Otomatik olarak en son haberleri döndürmek için `WidgetService` içinde özel `getBreakingHeadlinesForWidget` helper’ı.
- Davranış:
- Widget’a tıklandığında: ilgili haber detayına (link varsa webview / article detail) veya uygulama ana sayfasına git.
- İleri butonu: sıradaki başlığa geç, SharedPreferences’ta index güncelle.
- Duraklat/oynat: otomatik kaydırmayı aç/kapat durumu SharedPreferences’ta tutulur.

### 3. Çoklu Haber Kartı Widget’ı (Liste Tarzı)

**Amaç:** Kullanıcıya bir bakışta birden fazla haberi göstermek.

- Tasarım:
- 2 veya 3 satırlı dikey layout.
- Her satır: küçük görsel placeholder (veya kategori rengi), kategori etiketi, başlık, kısa özet.
- Alt satırda "Tümünü gör" linki.
- Veri:
- Son X haber (ör. 3 veya 5), görseli olanlara öncelik.
- Davranış:
- Her satıra tıklayınca ilgili haber detay sayfası açılır.
- "Tümünü gör" tıklanınca uygulama ana sayfası ilgili kategori sekmesiyle açılır.

### 4. Kategori Kısayol Widget’ları

**Amaç:** Kullanıcının en çok takip ettiği kategorilere hızlı erişim.

- 4.1 Tek Kategori Widget’ı
- Küçük kare/uzun dikdörtgen; başlık: kategori adı ("TEKNOLOJİ"), altında son haber başlığı.
- Kullanıcı widget eklerken konfigürasyonda kategori seçer (ConfigActivity / `AppWidgetConfigure` + `home_widget` argümanları).
- Tıklayınca uygulama o kategori sekmesine açılır.
- 4.2 Çok Kategorili Grid Widget
- 2x2 veya 3x2 grid; her kare bir kategori butonu.
- Sabit popüler kategoriler: Genel, Teknoloji, Ekonomi, Spor, Dünya.

### 5. Okuma Listesi / Yer İmleri Widget’ı

**Amaç:** Daha sonra okunacak haberleri ana ekrandan yönetmek.

- Tasarım:
- 1–3 maddelik liste: "Son kaydedilen haberler".
- Küçük yıldız/yer imi ikonu + başlık.
- Veri:
- Uygulamadaki "Okuma listesi" / favoriler ile aynı veri kaynağı (Hive / local DB). `WidgetService` bu listeye özel bir serializer ekler.
- Davranış:
- Her öğe tıklandığında ilgili haber detayına gider.
- Alt satır: "Tüm okuma listesi" -> uygulamada ilgili sayfaya açılır.

### 6. Günlük Özet / Sabah Bülteni Widget’ı

**Amaç:** Günün en önemli manşetlerini ve sayıları bir bakışta göstermek.

- Tasarım:
- Üstte tarih ve "Günün Özeti" başlığı.
- Ortada küçük istatistikler: bugün okunan haber sayısı, kategori bazlı küçük etiketler.
- Altta 1 öne çıkan manşet.
- Veri:
- Analytics servisinden (zaten uygulamada mevcut) günlük okuma istatistikleri.
- Haber kaynağından seçilmiş 1–3 kritik manşet (ör. Dünya veya Türkiye gündemi).
- Davranış:
- Tıklayınca uygulama içinde özel "Günün Özeti" sayfası açılabilir (yoksa ana sayfa + tarih filtresi).

### 7. Widget Veri Mimarisi

- `WidgetService` genişletme:
- Mevcut generic kaydetme fonksiyonuna ek olarak, widget tipine göre isimlendirilmiş key’ler (örn. `headline_title_0`, `list_title_0`, `reading_title_0`).
- Seri hale getirme: basit `title|subtitle|link|imageUrl` formatı; farklı listeler için farklı prefix.
- Java tarafı:
- Şu anki `NewsWidgetProvider` banner widget’ı için kullanılır.
- Yeni provider sınıfları: `ListWidgetProvider`, `CategoryWidgetProvider`, `ReadingListWidgetProvider`, `DailySummaryWidgetProvider`.
- Ortak yardımcı metot: SharedPreferences’ten okuma, index güncelleme, tıklama `PendingIntent` oluşturma.

### 8. Performans ve Stabilite

- Her widget'ın update frekansı düşük tutulacak (ör. 30dk) + manuel tetikleme sadece haberler yenilendiğinde (`WidgetService.updateAllWidgets` gibi bir giriş noktası).
- Layout’lar basit, nested `LinearLayout` ile; constraint ve custom view yok.
- Ağ çağrısı yapılmaz; sadece uygulama zaten haber çektiğinde cache’ten okunur.
- Hata durumunda (veri yok, parse edilemedi) graceful fallback: "Haberler yükleniyor" + uygulamayı aç butonu.

### 9. Uygulama ile Görsel Tutarlılık

- Renkler: `AppTheme` içindeki seçilen `ColorTheme`’e göre basitleştirilmiş ama uyumlu palet (mor/sage/diğer temalar için ayrı XML color setleri planlama).
- Tipografi: Android widget’larda custom font kısıtı olduğundan, `Merriweather`’a benzeyen standart serif kombinasyonu (`serif` family, bold/normal) kullanılır.
- İkonlar: Uygulamadaki mor accent ile uyumlu `tint` renkleri.

### 10. Test ve Yayınlama Stratejisi

- Önce sadece Ana Manşet Widget’ı + Çoklu Haber Kartı Widget’ını tam çalışır hale getir.
- Ardından Kategori Kısayol ve Okuma Listesi widget’larını ekle.
- Son aşamada Günlük Özet widget’ını ekleyip performans/regresyon testleri yap.
- Gerçek cihaz ve en az 2 farklı Android sürümünde (ör. 8.1 ve 14) widget davranışlarını test et.