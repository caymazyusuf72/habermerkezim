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
    
    // Türkiye
    'turkiye': 'https://www.sabah.com.tr/rss/gundem.xml',
    'turkiye_ntv': 'https://www.ntv.com.tr/gundem.rss',
    'turkiye_milliyet': 'https://www.milliyet.com.tr/rss/rssNew/gundemRSS.xml',
    
    // Ekonomi
    'ekonomi': 'https://www.hurriyet.com.tr/rss/ekonomi',
    'ekonomi_sabah': 'https://www.sabah.com.tr/rss/ekonomi.xml',
    'ekonomi_milliyet': 'https://www.milliyet.com.tr/rss/rssNew/ekonomiRSS.xml',
    
    // Teknoloji
    'teknoloji': 'https://www.hurriyet.com.tr/rss/teknoloji',
    'teknoloji_shiftdelete': 'https://shiftdelete.net/rss',
    'teknoloji_chip': 'https://www.chip.com.tr/rss',
    
    // Spor
    'spor': 'https://www.hurriyet.com.tr/rss/spor',
    'spor_sabah': 'https://www.sabah.com.tr/rss/spor.xml',
    
    // Dünya
    'dunya': 'https://www.hurriyet.com.tr/rss/dunya',
    'dunya_sabah': 'https://www.sabah.com.tr/rss/dunya.xml',
    'dunya_ntv': 'https://www.ntv.com.tr/dunya.rss',
    
    // Sağlık
    'saglik': 'https://www.sabah.com.tr/rss/saglik.xml',
    'saglik_hurriyet': 'https://www.hurriyet.com.tr/rss/saglik',
    'saglik_milliyet': 'https://www.milliyet.com.tr/rss/rssNew/saglikRSS.xml',
    
    // Kültür-Sanat
    'kultur': 'https://www.hurriyet.com.tr/rss/kultur-sanat',
    'kultur_sabah': 'https://www.sabah.com.tr/rss/kultur-sanat.xml',
    
    // Magazin
    'magazin': 'https://www.hurriyet.com.tr/rss/magazin',
    'magazin_sabah': 'https://www.sabah.com.tr/rss/magazin.xml',
    'magazin_milliyet': 'https://www.milliyet.com.tr/rss/rssNew/magazinRSS.xml',
    'magazin_posta': 'https://www.posta.com.tr/rss/magazin.xml',
    'magazin_mynet': 'https://www.mynet.com/rss/magazin',
    'magazin_ensonhaber': 'https://www.ensonhaber.com/rss/magazin.xml',
    
    // Bilim
    'bilim_ntv': 'https://www.ntv.com.tr/bilim.rss',
    'bilim_sabah': 'https://www.sabah.com.tr/rss/bilim.xml',
    
    // Eğitim
    'egitim': 'https://www.hurriyet.com.tr/rss/egitim',
    'egitim_sabah': 'https://www.sabah.com.tr/rss/egitim.xml',
    'egitim_ntv': 'https://www.ntv.com.tr/egitim.rss',
    
    // Otomobil
    'otomobil_ntv': 'https://www.ntv.com.tr/otomobil.rss',
    'otomobil_ensonhaber': 'https://www.ensonhaber.com/rss/otomobil.xml',
  };

  /// RSS Feed isimler - UI'da gösterilecek
  static const Map<String, String> feedNames = {
    // Genel/Son Dakika
    'genel': 'Hürriyet - Son Dakika',
    'genel_ntv': 'NTV - Son Dakika',
    'genel_sabah': 'Sabah - Son Dakika',
    
    // Türkiye
    'turkiye': 'Sabah - Türkiye',
    'turkiye_ntv': 'NTV - Türkiye',
    'turkiye_milliyet': 'Milliyet - Türkiye',
    
    // Ekonomi
    'ekonomi': 'Hürriyet - Ekonomi',
    'ekonomi_sabah': 'Sabah - Ekonomi',
    'ekonomi_milliyet': 'Milliyet - Ekonomi',
    
    // Teknoloji
    'teknoloji': 'Hürriyet - Teknoloji',
    'teknoloji_shiftdelete': 'ShiftDelete.Net',
    'teknoloji_chip': 'CHIP Online',
    
    // Spor
    'spor': 'Hürriyet - Spor',
    'spor_sabah': 'Sabah - Spor',
    
    // Dünya
    'dunya': 'Hürriyet - Dünya',
    'dunya_sabah': 'Sabah - Dünya',
    'dunya_ntv': 'NTV - Dünya',
    
    // Sağlık
    'saglik': 'Sabah - Sağlık',
    'saglik_hurriyet': 'Hürriyet - Sağlık',
    'saglik_milliyet': 'Milliyet - Sağlık',
    
    // Kültür-Sanat
    'kultur': 'Hürriyet - Kültür-Sanat',
    'kultur_sabah': 'Sabah - Kültür-Sanat',
    
    // Magazin
    'magazin': 'Hürriyet - Magazin',
    'magazin_sabah': 'Sabah - Magazin',
    'magazin_milliyet': 'Milliyet - Magazin',
    'magazin_posta': 'Posta - Magazin',
    'magazin_mynet': 'Mynet - Magazin',
    'magazin_ensonhaber': 'Ensonhaber - Magazin',
    
    // Bilim
    'bilim_ntv': 'NTV - Bilim',
    'bilim_sabah': 'Sabah - Bilim',
    
    // Eğitim
    'egitim': 'Hürriyet - Eğitim',
    'egitim_sabah': 'Sabah - Eğitim',
    'egitim_ntv': 'NTV - Eğitim',
    
    // Otomobil
    'otomobil_ntv': 'NTV - Otomobil',
    'otomobil_ensonhaber': 'Ensonhaber - Otomobil',
  };

  /// RSS Feed simgeleri - Material Icons
  static const Map<String, String> feedIcons = {
    // Genel/Son Dakika
    'genel': 'breaking_news',
    'genel_ntv': 'breaking_news',
    'genel_sabah': 'breaking_news',
    
    // Türkiye
    'turkiye': 'flag',
    'turkiye_ntv': 'flag',
    'turkiye_milliyet': 'flag',
    
    // Ekonomi
    'ekonomi': 'trending_up',
    'ekonomi_sabah': 'trending_up',
    'ekonomi_milliyet': 'trending_up',
    
    // Teknoloji
    'teknoloji': 'computer',
    'teknoloji_shiftdelete': 'computer',
    'teknoloji_chip': 'devices',
    
    // Spor
    'spor': 'sports_soccer',
    'spor_sabah': 'sports_soccer',
    
    // Dünya
    'dunya': 'public',
    'dunya_sabah': 'public',
    'dunya_ntv': 'public',
    
    // Sağlık
    'saglik': 'health_and_safety',
    'saglik_hurriyet': 'health_and_safety',
    'saglik_milliyet': 'health_and_safety',
    
    // Kültür-Sanat
    'kultur': 'palette',
    'kultur_sabah': 'palette',
    
    // Magazin
    'magazin': 'celebration',
    'magazin_sabah': 'celebration',
    'magazin_milliyet': 'celebration',
    'magazin_posta': 'celebration',
    'magazin_mynet': 'celebration',
    'magazin_ensonhaber': 'celebration',
    
    // Bilim
    'bilim_ntv': 'science',
    'bilim_sabah': 'science',
    
    // Eğitim
    'egitim': 'school',
    'egitim_sabah': 'school',
    'egitim_ntv': 'school',
    
    // Otomobil
    'otomobil_ntv': 'directions_car',
    'otomobil_ensonhaber': 'directions_car',
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