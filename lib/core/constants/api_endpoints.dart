/// RSS feed API endpoints ve haber kaynakları
/// Her kategori için RSS feed URL'lerini içerir
class ApiEndpoints {
  ApiEndpoints._();

  /// RSS Feed URL'leri - Kategori bazlı (güvenilir kaynaklar)
  static const Map<String, String> rssFeedUrls = {
    // Genel/Son Dakika
    'genel': 'https://www.hurriyet.com.tr/rss/anasayfa',
    'genel_ntv': 'https://www.ntv.com.tr/son-dakika.rss',
    'genel_sabah': 'https://www.sabah.com.tr/rss/sondakika.xml',
    'genel_cumhuriyet': 'https://www.cumhuriyet.com.tr/rss/son_dakika.xml',
    'genel_haberturk': 'https://www.haberturk.com/rss',
    'genel_cnnturk': 'https://www.cnnturk.com/feed/rss/all/news',
    
    // Türkiye
    'turkiye': 'https://www.sabah.com.tr/rss/gundem.xml',
    'turkiye_ntv': 'https://www.ntv.com.tr/gundem.rss',
    'turkiye_cumhuriyet': 'https://www.cumhuriyet.com.tr/rss/1.xml',
    'turkiye_haberturk': 'https://www.haberturk.com/rss/kategori/gundem.xml',
    
    // Ekonomi
    'ekonomi': 'https://www.hurriyet.com.tr/rss/ekonomi',
    'ekonomi_sabah': 'https://www.sabah.com.tr/rss/ekonomi.xml',
    'ekonomi_ntv': 'https://www.ntv.com.tr/ekonomi.rss',
    'ekonomi_haberturk': 'https://www.haberturk.com/rss/kategori/ekonomi.xml',
    'ekonomi_bloomberght': 'https://www.bloomberght.com/rss',
    
    // Teknoloji
    'teknoloji': 'https://www.hurriyet.com.tr/rss/teknoloji',
    'teknoloji_shiftdelete': 'https://shiftdelete.net/rss',
    'teknoloji_chip': 'https://www.chip.com.tr/rss',
    'teknoloji_webtekno': 'https://www.webtekno.com/rss.xml',
    'teknoloji_donanimhaber': 'https://www.donanimhaber.com/rss',
    'teknoloji_log': 'https://www.log.com.tr/feed/',
    
    // Spor
    'spor': 'https://www.hurriyet.com.tr/rss/spor',
    'spor_sabah': 'https://www.sabah.com.tr/rss/spor.xml',
    'spor_ntv': 'https://www.ntv.com.tr/spor.rss',
    'spor_fanatik': 'https://www.fanatik.com.tr/rss',
    'spor_sporx': 'https://www.sporx.com/rss',
    
    // Dünya
    'dunya': 'https://www.hurriyet.com.tr/rss/dunya',
    'dunya_sabah': 'https://www.sabah.com.tr/rss/dunya.xml',
    'dunya_ntv': 'https://www.ntv.com.tr/dunya.rss',
    'dunya_cumhuriyet': 'https://www.cumhuriyet.com.tr/rss/2.xml',
    'dunya_haberturk': 'https://www.haberturk.com/rss/kategori/dunya.xml',
    'dunya_euronews': 'https://tr.euronews.com/rss',
    
    // Sağlık
    'saglik': 'https://www.sabah.com.tr/rss/saglik.xml',
    'saglik_hurriyet': 'https://www.hurriyet.com.tr/rss/saglik',
    'saglik_milliyet': 'https://www.milliyet.com.tr/rss/rssNew/saglikRSS.xml',
    'saglik_ntv': 'https://www.ntv.com.tr/saglik.rss',
    'saglik_haberturk': 'https://www.haberturk.com/rss/kategori/saglik.xml',
    'saglik_cumhuriyet': 'https://www.cumhuriyet.com.tr/rss/11.xml',
    
    // Kültür-Sanat
    'kultur': 'https://www.hurriyet.com.tr/rss/kultur-sanat',
    'kultur_sabah': 'https://www.sabah.com.tr/rss/kultur-sanat.xml',
    'kultur_milliyet': 'https://www.milliyet.com.tr/rss/rssNew/kulturSanatRSS.xml',
    'kultur_ntv': 'https://www.ntv.com.tr/yasam.rss',
    'kultur_cumhuriyet': 'https://www.cumhuriyet.com.tr/rss/5.xml',
    
    // Magazin
    'magazin': 'https://www.hurriyet.com.tr/rss/magazin',
    'magazin_sabah': 'https://www.sabah.com.tr/rss/magazin.xml',
    'magazin_milliyet': 'https://www.milliyet.com.tr/rss/rssNew/magazinRSS.xml',
    'magazin_posta': 'https://www.posta.com.tr/rss/magazin.xml',
    'magazin_mynet': 'https://www.mynet.com/rss/magazin',
    'magazin_ensonhaber': 'https://www.ensonhaber.com/rss/magazin.xml',
    'magazin_haberturk': 'https://www.haberturk.com/rss/kategori/magazin.xml',
    'magazin_hurses': 'https://www.hurses.com.tr/rss',
    
    // Bilim
    'bilim': 'https://shiftdelete.net/rss',
    'bilim_shiftdelete': 'https://shiftdelete.net/rss',
    'bilim_webtekno': 'https://www.webtekno.com/rss.xml',
    'bilim_ntv': 'https://www.ntv.com.tr/bilim.rss',
    
    // Eğitim
    'egitim': 'https://www.hurriyet.com.tr/rss/egitim',
    'egitim_sabah': 'https://www.sabah.com.tr/rss/egitim.xml',
    'egitim_ntv': 'https://www.ntv.com.tr/egitim.rss',
    'egitim_milliyet': 'https://www.milliyet.com.tr/rss/rssNew/egitimRSS.xml',
    'egitim_haberturk': 'https://www.haberturk.com/rss/kategori/egitim.xml',
    'egitim_cumhuriyet': 'https://www.cumhuriyet.com.tr/rss/12.xml',
    
    // Otomobil
    'otomobil': 'https://www.ntv.com.tr/otomobil.rss',
    'otomobil_ntv': 'https://www.ntv.com.tr/otomobil.rss',
    'otomobil_ensonhaber': 'https://www.ensonhaber.com/rss/otomobil.xml',
    'otomobil_haberturk': 'https://www.haberturk.com/rss/kategori/otomobil.xml',
    'otomobil_milliyet': 'https://www.milliyet.com.tr/rss/rssNew/otomotivRSS.xml',
    'otomobil_arabam': 'https://www.arabam.com/rss',
  };

  /// RSS Feed isimler - UI'da gösterilecek
  static const Map<String, String> feedNames = {
    // Genel/Son Dakika
    'genel': 'Hürriyet - Son Dakika',
    'genel_ntv': 'NTV - Son Dakika',
    'genel_sabah': 'Sabah - Son Dakika',
    'genel_cumhuriyet': 'Cumhuriyet - Son Dakika',
    'genel_haberturk': 'Habertürk - Son Dakika',
    'genel_cnnturk': 'CNN Türk - Tüm Haberler',
    
    // Türkiye
    'turkiye': 'Sabah - Türkiye',
    'turkiye_ntv': 'NTV - Türkiye',
    'turkiye_cumhuriyet': 'Cumhuriyet - Türkiye',
    'turkiye_haberturk': 'Habertürk - Gündem',
    
    // Ekonomi
    'ekonomi': 'Hürriyet - Ekonomi',
    'ekonomi_sabah': 'Sabah - Ekonomi',
    'ekonomi_ntv': 'NTV - Ekonomi',
    'ekonomi_haberturk': 'Habertürk - Ekonomi',
    'ekonomi_bloomberght': 'Bloomberg HT',
    
    // Teknoloji
    'teknoloji': 'Hürriyet - Teknoloji',
    'teknoloji_shiftdelete': 'ShiftDelete.Net',
    'teknoloji_chip': 'CHIP Online',
    'teknoloji_webtekno': 'Webtekno',
    'teknoloji_donanimhaber': 'Donanım Haber',
    'teknoloji_log': 'LOG Teknoloji',
    
    // Spor
    'spor': 'Hürriyet - Spor',
    'spor_sabah': 'Sabah - Spor',
    'spor_ntv': 'NTV - Spor',
    'spor_fanatik': 'Fanatik',
    'spor_sporx': 'Sporx',
    
    // Dünya
    'dunya': 'Hürriyet - Dünya',
    'dunya_sabah': 'Sabah - Dünya',
    'dunya_ntv': 'NTV - Dünya',
    'dunya_cumhuriyet': 'Cumhuriyet - Dünya',
    'dunya_haberturk': 'Habertürk - Dünya',
    'dunya_euronews': 'Euronews Türkçe',
    
    // Sağlık
    'saglik': 'Sabah - Sağlık',
    'saglik_hurriyet': 'Hürriyet - Sağlık',
    'saglik_milliyet': 'Milliyet - Sağlık',
    'saglik_ntv': 'NTV - Sağlık',
    'saglik_haberturk': 'Habertürk - Sağlık',
    'saglik_cumhuriyet': 'Cumhuriyet - Sağlık',
    
    // Kültür-Sanat
    'kultur': 'Hürriyet - Kültür-Sanat',
    'kultur_sabah': 'Sabah - Kültür-Sanat',
    'kultur_milliyet': 'Milliyet - Kültür-Sanat',
    'kultur_ntv': 'NTV - Yaşam',
    'kultur_cumhuriyet': 'Cumhuriyet - Kültür-Sanat',
    
    // Magazin
    'magazin': 'Hürriyet - Magazin',
    'magazin_sabah': 'Sabah - Magazin',
    'magazin_milliyet': 'Milliyet - Magazin',
    'magazin_posta': 'Posta - Magazin',
    'magazin_mynet': 'Mynet - Magazin',
    'magazin_ensonhaber': 'Ensonhaber - Magazin',
    'magazin_haberturk': 'Habertürk - Magazin',
    'magazin_hurses': 'Hürses',
    
    // Bilim
    'bilim': 'ShiftDelete - Bilim & Teknoloji',
    'bilim_shiftdelete': 'ShiftDelete - Bilim & Teknoloji',
    'bilim_webtekno': 'Webtekno - Bilim & Teknoloji',
    'bilim_ntv': 'NTV - Bilim',
    
    // Eğitim
    'egitim': 'Hürriyet - Eğitim',
    'egitim_sabah': 'Sabah - Eğitim',
    'egitim_ntv': 'NTV - Eğitim',
    'egitim_milliyet': 'Milliyet - Eğitim',
    'egitim_haberturk': 'Habertürk - Eğitim',
    'egitim_cumhuriyet': 'Cumhuriyet - Eğitim',
    
    // Otomobil
    'otomobil': 'NTV - Otomobil',
    'otomobil_ntv': 'NTV - Otomobil',
    'otomobil_ensonhaber': 'Ensonhaber - Otomobil',
    'otomobil_haberturk': 'Habertürk - Otomobil',
    'otomobil_milliyet': 'Milliyet - Otomotiv',
    'otomobil_arabam': 'Arabam.com',
  };

  /// RSS Feed simgeleri - Material Icons
  static const Map<String, String> feedIcons = {
    // Genel/Son Dakika
    'genel': 'breaking_news',
    'genel_ntv': 'breaking_news',
    'genel_sabah': 'breaking_news',
    'genel_cumhuriyet': 'breaking_news',
    'genel_haberturk': 'breaking_news',
    'genel_cnnturk': 'breaking_news',
    
    // Türkiye
    'turkiye': 'flag',
    'turkiye_ntv': 'flag',
    'turkiye_cumhuriyet': 'flag',
    'turkiye_haberturk': 'flag',
    
    // Ekonomi
    'ekonomi': 'trending_up',
    'ekonomi_sabah': 'trending_up',
    'ekonomi_ntv': 'trending_up',
    'ekonomi_haberturk': 'trending_up',
    'ekonomi_bloomberght': 'trending_up',
    
    // Teknoloji
    'teknoloji': 'computer',
    'teknoloji_shiftdelete': 'computer',
    'teknoloji_chip': 'devices',
    'teknoloji_webtekno': 'computer',
    'teknoloji_donanimhaber': 'memory',
    'teknoloji_log': 'computer',
    
    // Spor
    'spor': 'sports_soccer',
    'spor_sabah': 'sports_soccer',
    'spor_ntv': 'sports_soccer',
    'spor_fanatik': 'sports_soccer',
    'spor_sporx': 'sports_soccer',
    
    // Dünya
    'dunya': 'public',
    'dunya_sabah': 'public',
    'dunya_ntv': 'public',
    'dunya_cumhuriyet': 'public',
    'dunya_haberturk': 'public',
    'dunya_euronews': 'public',
    
    // Sağlık
    'saglik': 'health_and_safety',
    'saglik_hurriyet': 'health_and_safety',
    'saglik_milliyet': 'health_and_safety',
    'saglik_ntv': 'health_and_safety',
    'saglik_haberturk': 'health_and_safety',
    'saglik_cumhuriyet': 'health_and_safety',
    
    // Kültür-Sanat
    'kultur': 'palette',
    'kultur_sabah': 'palette',
    'kultur_milliyet': 'palette',
    'kultur_ntv': 'palette',
    'kultur_cumhuriyet': 'palette',
    
    // Magazin
    'magazin': 'celebration',
    'magazin_sabah': 'celebration',
    'magazin_milliyet': 'celebration',
    'magazin_posta': 'celebration',
    'magazin_mynet': 'celebration',
    'magazin_ensonhaber': 'celebration',
    'magazin_haberturk': 'celebration',
    'magazin_hurses': 'celebration',
    
    // Bilim
    'bilim': 'science',
    'bilim_shiftdelete': 'science',
    'bilim_webtekno': 'science',
    'bilim_ntv': 'science',
    
    // Eğitim
    'egitim': 'school',
    'egitim_sabah': 'school',
    'egitim_ntv': 'school',
    'egitim_milliyet': 'school',
    'egitim_haberturk': 'school',
    'egitim_cumhuriyet': 'school',
    
    // Otomobil
    'otomobil': 'directions_car',
    'otomobil_ntv': 'directions_car',
    'otomobil_ensonhaber': 'directions_car',
    'otomobil_haberturk': 'directions_car',
    'otomobil_milliyet': 'directions_car',
    'otomobil_arabam': 'directions_car',
  };

  /// Network timeout değerleri - yavaş sunucular için artırıldı
  static const int connectTimeoutMs = 15000; // 15 saniye (yavaş sunucular için)
  static const int receiveTimeoutMs = 20000; // 20 saniye (büyük feed'ler için)
  static const int sendTimeoutMs = 10000; // 10 saniye

  /// Cache süreleri
  static const Duration cacheValidityDuration = Duration(minutes: 30);
  static const Duration offlineCacheDuration = Duration(days: 7);

  /// Versiyon kontrol endpoint'i (opsiyonel - manuel kontrol için)
  /// Bu endpoint'ten JSON formatında versiyon bilgisi alınır
  /// Örnek JSON yapısı:
  /// {
  ///   "version": "1.0.1",
  ///   "versionCode": 2,
  ///   "forceUpdate": false,
  ///   "message": "Yeni özellikler ve iyileştirmeler",
  ///   "downloadUrl": "https://play.google.com/store/apps/details?id=..."
  /// }
  static const String versionCheckUrl = 'https://raw.githubusercontent.com/your-repo/version-check.json';
  
  /// Play Store uygulama URL'i
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.example.untitled';
}