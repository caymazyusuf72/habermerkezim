import 'app_localizations.dart';

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  // ==================== App General ====================
  
  @override
  String get appName => 'Haber Merkezi';

  @override
  String get appSlogan => 'Güncel haberler, tek bir yerde';

  // ==================== Navigation ====================
  
  @override
  String get navHome => 'Ana Sayfa';

  @override
  String get navCategories => 'Kategoriler';

  @override
  String get navFavorites => 'Favoriler';

  @override
  String get navProfile => 'Profil';

  // ==================== Home Page ====================
  
  @override
  String get breakingNews => 'Son Dakika';

  @override
  String get latestNews => 'En Son Haberler';

  @override
  String get popularNews => 'Popüler Haberler';

  @override
  String get allNews => 'Tüm Haberler';

  @override
  String get refresh => 'Yenile';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get noNewsFound => 'Haber bulunamadı';

  @override
  String get pullToRefresh => 'Yenilemek için aşağı çekin';

  // ==================== Categories ====================
  
  @override
  String get allCategories => 'Tüm Kategoriler';

  @override
  String get categoryTechnology => 'Teknoloji';

  @override
  String get categorySports => 'Spor';

  @override
  String get categoryEconomy => 'Ekonomi';

  @override
  String get categoryMagazine => 'Magazin';

  @override
  String get categoryHealth => 'Sağlık';

  @override
  String get categoryScience => 'Bilim';

  @override
  String get categoryCulture => 'Kültür-Sanat';

  @override
  String get categoryWorld => 'Dünya';

  @override
  String get categoryPolitics => 'Politika';

  @override
  String get categoryEducation => 'Eğitim';

  @override
  String get categoryAutomotive => 'Otomobil';

  @override
  String get categoryTravel => 'Seyahat';

  @override
  String get categoryFood => 'Yemek';

  @override
  String get categoryFashion => 'Moda';

  // ==================== Article ====================
  
  @override
  String get readMore => 'Devamını Oku';

  @override
  String get share => 'Paylaş';

  @override
  String get addToFavorites => 'Favorilere Ekle';

  @override
  String get removeFromFavorites => 'Favorilerden Çıkar';

  @override
  String get addedToFavorites => 'Favorilere eklendi';

  @override
  String get removedFromFavorites => 'Favorilerden çıkarıldı';

  @override
  String readTime(int minutes) => '$minutes dk okuma';

  @override
  String get source => 'Kaynak';

  @override
  String get publishedDate => 'Yayın Tarihi';

  @override
  String get openInBrowser => 'Tarayıcıda Aç';

  @override
  String get copyLink => 'Bağlantıyı Kopyala';

  @override
  String get linkCopied => 'Bağlantı kopyalandı';

  // ==================== Favorites ====================
  
  @override
  String get favorites => 'Favoriler';

  @override
  String get noFavorites => 'Henüz favori yok';

  @override
  String get noFavoritesDescription => 'Beğendiğiniz haberleri favorilere ekleyerek daha sonra okuyabilirsiniz';

  @override
  String get clearAllFavorites => 'Tüm Favorileri Temizle';

  @override
  String get clearFavoritesConfirmation => 'Tüm favorileri silmek istediğinizden emin misiniz?';

  // ==================== Profile ====================
  
  @override
  String get profile => 'Profil';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get readingStatistics => 'Okuma İstatistikleri';

  @override
  String get articlesRead => 'Okunan Haber';

  @override
  String get timeSpentReading => 'Okuma Süresi';

  @override
  String get favoriteArticles => 'Favori Haberler';

  @override
  String get categoriesFollowed => 'Takip Edilen Kategoriler';

  @override
  String get achievements => 'Başarılar';

  @override
  String get level => 'Seviye';

  @override
  String get points => 'Puan';

  // ==================== Settings ====================
  
  @override
  String get settings => 'Ayarlar';

  @override
  String get generalSettings => 'Genel Ayarlar';

  @override
  String get appearance => 'Görünüm';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get language => 'Dil';

  @override
  String get theme => 'Tema';

  @override
  String get darkMode => 'Karanlık Mod';

  @override
  String get lightTheme => 'Açık Tema';

  @override
  String get darkTheme => 'Koyu Tema';

  @override
  String get systemTheme => 'Sistem Teması';

  @override
  String get fontSize => 'Yazı Boyutu';

  @override
  String get fontSizeSmall => 'Küçük';

  @override
  String get fontSizeNormal => 'Normal';

  @override
  String get fontSizeLarge => 'Büyük';

  @override
  String get fontSizeExtraLarge => 'Çok Büyük';

  @override
  String get pushNotifications => 'Anlık Bildirimler';

  @override
  String get breakingNewsNotifications => 'Son Dakika Bildirimleri';

  @override
  String get dailyDigestNotifications => 'Günlük Özet';

  @override
  String get sound => 'Ses';

  @override
  String get vibration => 'Titreşim';

  @override
  String get dataManagement => 'Veri Yönetimi';

  @override
  String get clearCache => 'Önbelleği Temizle';

  @override
  String get cacheCleared => 'Önbellek temizlendi';

  @override
  String get exportData => 'Verileri Dışa Aktar';

  @override
  String get importData => 'Verileri İçe Aktar';

  @override
  String get about => 'Hakkında';

  @override
  String get version => 'Versiyon';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get termsOfService => 'Kullanım Koşulları';

  @override
  String get rateApp => 'Uygulamayı Değerlendir';

  @override
  String get contactUs => 'Bize Ulaşın';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get logoutConfirmation => 'Çıkış yapmak istediğinizden emin misiniz?';

  // ==================== Search ====================
  
  @override
  String get searchHint => 'Haber ara...';

  @override
  String get searchResults => 'Arama Sonuçları';

  @override
  String get noResultsFound => 'Sonuç bulunamadı';

  @override
  String get recentSearches => 'Son Aramalar';

  @override
  String get clearSearchHistory => 'Arama Geçmişini Temizle';

  @override
  String get popularSearches => 'Popüler Aramalar';

  // ==================== Errors ====================
  
  @override
  String get errorGeneric => 'Bir hata oluştu';

  @override
  String get errorNetwork => 'Bağlantı hatası';

  @override
  String get errorServer => 'Sunucu hatası';

  @override
  String get errorTimeout => 'Zaman aşımı';

  @override
  String get errorNoInternet => 'İnternet bağlantısı yok';

  @override
  String get tryAgain => 'Tekrar Dene';

  @override
  String get retry => 'Yeniden Dene';

  // ==================== Common Actions ====================
  
  @override
  String get ok => 'Tamam';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get delete => 'Sil';

  @override
  String get edit => 'Düzenle';

  @override
  String get close => 'Kapat';

  @override
  String get done => 'Bitti';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get confirm => 'Onayla';

  @override
  String get back => 'Geri';

  @override
  String get next => 'İleri';

  @override
  String get skip => 'Atla';

  @override
  String get continueButton => 'Devam Et';

  // ==================== Time ====================
  
  @override
  String get justNow => 'Az önce';

  @override
  String minutesAgo(int minutes) => '$minutes dakika önce';

  @override
  String hoursAgo(int hours) => '$hours saat önce';

  @override
  String daysAgo(int days) => '$days gün önce';

  @override
  String get yesterday => 'Dün';

  @override
  String get today => 'Bugün';

  @override
  String get thisWeek => 'Bu Hafta';

  @override
  String get thisMonth => 'Bu Ay';

  // ==================== Onboarding ====================
  
  @override
  String get onboardingTitle1 => 'Haberlere Hoş Geldiniz';

  @override
  String get onboardingDescription1 => 'Türkiye ve dünyadan en güncel haberleri takip edin';

  @override
  String get onboardingTitle2 => 'Kişiselleştirilmiş İçerik';

  @override
  String get onboardingDescription2 => 'İlgi alanlarınıza göre haberler alın';

  @override
  String get onboardingTitle3 => 'Çevrimdışı Okuma';

  @override
  String get onboardingDescription3 => 'Haberleri kaydedin ve internet olmadan okuyun';

  @override
  String get getStarted => 'Başla';

  // ==================== Auth ====================
  
  @override
  String get login => 'Giriş Yap';

  @override
  String get register => 'Kayıt Ol';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get confirmPassword => 'Şifre Tekrar';

  @override
  String get forgotPassword => 'Şifremi Unuttum';

  @override
  String get dontHaveAccount => 'Hesabınız yok mu?';

  @override
  String get alreadyHaveAccount => 'Zaten hesabınız var mı?';

  @override
  String get signInWithGoogle => 'Google ile Giriş Yap';

  @override
  String get signInWithApple => 'Apple ile Giriş Yap';

  @override
  String get continueAsGuest => 'Misafir Olarak Devam Et';

  // ==================== Analytics ====================
  
  @override
  String get analytics => 'Analitik';

  @override
  String get readingHistory => 'Okuma Geçmişi';

  @override
  String get weeklyReport => 'Haftalık Rapor';

  @override
  String get monthlyReport => 'Aylık Rapor';

  @override
  String get mostReadCategories => 'En Çok Okunan Kategoriler';

  @override
  String get readingStreak => 'Okuma Serisi';

  @override
  String get days => 'gün';

  // ==================== Export/Import ====================
  
  @override
  String get exportFavorites => 'Favorileri Dışa Aktar';

  @override
  String get exportReadingHistory => 'Okuma Geçmişini Dışa Aktar';

  @override
  String get exportAllData => 'Tüm Verileri Dışa Aktar';

  @override
  String get exportSuccessful => 'Dışa aktarma başarılı';

  @override
  String get importSuccessful => 'İçe aktarma başarılı';

  @override
  String get exportFormat => 'Dışa Aktarma Formatı';

  @override
  String get csvFormat => 'CSV Formatı';

  @override
  String get jsonFormat => 'JSON Formatı';
}