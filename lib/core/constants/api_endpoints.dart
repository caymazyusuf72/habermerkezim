/// RSS feed API endpoints ve haber kaynakları
/// Her kategori için RSS feed URL'lerini içerir
class ApiEndpoints {
  ApiEndpoints._();

  /// RSS Feed URL'leri - Kategori bazlı (güvenilir kaynaklar)
  static const Map<String, String> rssFeedUrls = {
    'genel': 'https://www.hurriyet.com.tr/rss/anasayfa',
    'turkiye': 'https://www.sabah.com.tr/rss/gundem.xml',
    'ekonomi': 'https://www.hurriyet.com.tr/rss/ekonomi',
    'teknoloji': 'https://www.hurriyet.com.tr/rss/teknoloji',
    'spor': 'https://www.hurriyet.com.tr/rss/spor',
    'dunya': 'https://www.hurriyet.com.tr/rss/dunya',
    'saglik': 'https://www.sabah.com.tr/rss/saglik.xml',
  };

  /// RSS Feed isimler - UI'da gösterilecek
  static const Map<String, String> feedNames = {
    'genel': 'Son Dakika',
    'turkiye': 'Türkiye',
    'ekonomi': 'Ekonomi',
    'teknoloji': 'Teknoloji',
    'spor': 'Spor',
    'dunya': 'Dünya',
    'saglik': 'Sağlık',
  };

  /// RSS Feed simgeleri - Material Icons
  static const Map<String, String> feedIcons = {
    'genel': 'breaking_news',
    'turkiye': 'flag',
    'ekonomi': 'trending_up',
    'teknoloji': 'computer',
    'spor': 'sports_soccer',
    'dunya': 'public',
    'saglik': 'health_and_safety',
  };

  /// Network timeout değerleri - gerçek cihaz için artırıldı
  static const int connectTimeoutMs = 30000; // 30 saniye
  static const int receiveTimeoutMs = 45000; // 45 saniye
  static const int sendTimeoutMs = 20000; // 20 saniye

  /// Cache süreleri
  static const Duration cacheValidityDuration = Duration(minutes: 30);
  static const Duration offlineCacheDuration = Duration(days: 7);
}