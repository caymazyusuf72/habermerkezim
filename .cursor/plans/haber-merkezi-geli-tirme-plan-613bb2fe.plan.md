<!-- 613bb2fe-c8ef-4841-919f-8fd4270ca64d cddba115-0ff6-4164-a101-34dfeea7a421 -->
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

### To-dos

- [x] pubspec.yaml'a google_fonts paketini ekle
- [x] AppTheme dosyasında adaçayı yeşili ve mat siyah renk paletini oluştur
- [x] TextTheme stillerini Merriweather serif font ile güncelle
- [x] Notification banner widget ve provider oluştur
- [x] Home page'e bildirim banner'ı entegre et
- [x] Splash screen tasarımını adaçayı yeşili/mat siyah ile güncelle ve animasyonları iyileştir
- [x] Loading indicator ve shimmer efektini adaçayı yeşili tonlarıyla güncelle
- [x] Article card tasarımını profesyonel gazete havasına uygun şekilde güncelle
- [x] AppBar, kategori tab ve bottom navigation stillerini yeni tema ile uyumlu hale getir
- [x] Notification banner'ın boş görünme sorununu düzelt
- [ ] Ana manşet (banner tarzı) widget’ının tasarımını ve veri modelini netleştirip implementasyona hazırlamak
- [ ] Çoklu haber kartı widget’ının (2–3 satırlı liste) layout ve veri yapısını planlamak
- [ ] Tek ve çok kategorili kısayol widget’larının kullanım senaryosu ve layout’unu planlamak
- [ ] Okuma listesi / yer imi widget’ının veri akışını ve tasarımını planlamak
- [ ] Günlük özet / sabah bülteni widget’ının veri kaynağı ve gösterim şeklini planlamak
- [ ] Tüm widget’lar için ortak SharedPreferences key sözleşmesi ve `WidgetService` genişletmesini tasarlamak