import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// Uygulama başlığı
  ///
  /// In tr, this message translates to:
  /// **'Haber Merkezi'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get home;

  /// No description provided for @favorites.
  ///
  /// In tr, this message translates to:
  /// **'Favoriler'**
  String get favorites;

  /// No description provided for @search.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get search;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @categories.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriler'**
  String get categories;

  /// No description provided for @general.
  ///
  /// In tr, this message translates to:
  /// **'Genel'**
  String get general;

  /// No description provided for @technology.
  ///
  /// In tr, this message translates to:
  /// **'Teknoloji'**
  String get technology;

  /// No description provided for @sports.
  ///
  /// In tr, this message translates to:
  /// **'Spor'**
  String get sports;

  /// No description provided for @economy.
  ///
  /// In tr, this message translates to:
  /// **'Ekonomi'**
  String get economy;

  /// No description provided for @health.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık'**
  String get health;

  /// No description provided for @science.
  ///
  /// In tr, this message translates to:
  /// **'Bilim'**
  String get science;

  /// No description provided for @culture.
  ///
  /// In tr, this message translates to:
  /// **'Kültür'**
  String get culture;

  /// No description provided for @world.
  ///
  /// In tr, this message translates to:
  /// **'Dünya'**
  String get world;

  /// No description provided for @politics.
  ///
  /// In tr, this message translates to:
  /// **'Politika'**
  String get politics;

  /// No description provided for @entertainment.
  ///
  /// In tr, this message translates to:
  /// **'Magazin'**
  String get entertainment;

  /// No description provided for @loading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get ok;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @share.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get share;

  /// No description provided for @refresh.
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get refresh;

  /// No description provided for @noArticles.
  ///
  /// In tr, this message translates to:
  /// **'Henüz haber yok'**
  String get noArticles;

  /// No description provided for @noFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Henüz favori haber yok'**
  String get noFavorites;

  /// No description provided for @noSearchResults.
  ///
  /// In tr, this message translates to:
  /// **'Arama sonucu bulunamadı'**
  String get noSearchResults;

  /// No description provided for @noReadingHistory.
  ///
  /// In tr, this message translates to:
  /// **'Okuma geçmişi boş'**
  String get noReadingHistory;

  /// No description provided for @addToFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favorilere Ekle'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favorilerden Çıkar'**
  String get removeFromFavorites;

  /// No description provided for @addedToFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favorilere eklendi'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favorilerden çıkarıldı'**
  String get removedFromFavorites;

  /// No description provided for @readMore.
  ///
  /// In tr, this message translates to:
  /// **'Devamını Oku'**
  String get readMore;

  /// No description provided for @readingTime.
  ///
  /// In tr, this message translates to:
  /// **'{minutes} dk okuma'**
  String readingTime(int minutes);

  /// No description provided for @publishedAt.
  ///
  /// In tr, this message translates to:
  /// **'{date} tarihinde yayınlandı'**
  String publishedAt(String date);

  /// No description provided for @source.
  ///
  /// In tr, this message translates to:
  /// **'Kaynak'**
  String get source;

  /// No description provided for @category.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get category;

  /// No description provided for @searchHint.
  ///
  /// In tr, this message translates to:
  /// **'Haber ara...'**
  String get searchHint;

  /// No description provided for @searchHistory.
  ///
  /// In tr, this message translates to:
  /// **'Arama Geçmişi'**
  String get searchHistory;

  /// No description provided for @clearSearchHistory.
  ///
  /// In tr, this message translates to:
  /// **'Arama Geçmişini Temizle'**
  String get clearSearchHistory;

  /// No description provided for @popularSearches.
  ///
  /// In tr, this message translates to:
  /// **'Popüler Aramalar'**
  String get popularSearches;

  /// No description provided for @recentSearches.
  ///
  /// In tr, this message translates to:
  /// **'Son Aramalar'**
  String get recentSearches;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @appearance.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In tr, this message translates to:
  /// **'Karanlık Tema'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In tr, this message translates to:
  /// **'Açık Tema'**
  String get lightMode;

  /// No description provided for @systemTheme.
  ///
  /// In tr, this message translates to:
  /// **'Sistem Teması'**
  String get systemTheme;

  /// No description provided for @themes.
  ///
  /// In tr, this message translates to:
  /// **'Temalar'**
  String get themes;

  /// No description provided for @selectTheme.
  ///
  /// In tr, this message translates to:
  /// **'Renk teması seçin'**
  String get selectTheme;

  /// No description provided for @fontSize.
  ///
  /// In tr, this message translates to:
  /// **'Font Boyutu'**
  String get fontSize;

  /// No description provided for @small.
  ///
  /// In tr, this message translates to:
  /// **'Küçük'**
  String get small;

  /// No description provided for @normal.
  ///
  /// In tr, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @large.
  ///
  /// In tr, this message translates to:
  /// **'Büyük'**
  String get large;

  /// No description provided for @extraLarge.
  ///
  /// In tr, this message translates to:
  /// **'Çok Büyük'**
  String get extraLarge;

  /// No description provided for @notifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// No description provided for @notificationSettings.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Ayarları'**
  String get notificationSettings;

  /// No description provided for @notificationPreferences.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Tercihleri'**
  String get notificationPreferences;

  /// No description provided for @dailyNewsReminder.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Haber Hatırlatması'**
  String get dailyNewsReminder;

  /// No description provided for @readingGoalReminder.
  ///
  /// In tr, this message translates to:
  /// **'Okuma Hedefi Hatırlatması'**
  String get readingGoalReminder;

  /// No description provided for @breakingNews.
  ///
  /// In tr, this message translates to:
  /// **'Son Dakika Haberleri'**
  String get breakingNews;

  /// No description provided for @notificationsEnabled.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler aktif'**
  String get notificationsEnabled;

  /// No description provided for @notificationsDisabled.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler kapalı'**
  String get notificationsDisabled;

  /// No description provided for @dataManagement.
  ///
  /// In tr, this message translates to:
  /// **'Veri Yönetimi'**
  String get dataManagement;

  /// No description provided for @clearCache.
  ///
  /// In tr, this message translates to:
  /// **'Önbelleği Temizle'**
  String get clearCache;

  /// No description provided for @clearCacheDescription.
  ///
  /// In tr, this message translates to:
  /// **'Tüm kaydedilmiş haberleri sil'**
  String get clearCacheDescription;

  /// No description provided for @clearFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favorileri Temizle'**
  String get clearFavorites;

  /// No description provided for @clearFavoritesDescription.
  ///
  /// In tr, this message translates to:
  /// **'Tüm favori haberleri sil'**
  String get clearFavoritesDescription;

  /// No description provided for @clearSearchHistoryDescription.
  ///
  /// In tr, this message translates to:
  /// **'Tüm arama geçmişini temizle'**
  String get clearSearchHistoryDescription;

  /// No description provided for @exportData.
  ///
  /// In tr, this message translates to:
  /// **'Verileri Dışa Aktar'**
  String get exportData;

  /// No description provided for @exportDataDescription.
  ///
  /// In tr, this message translates to:
  /// **'Favoriler, okuma geçmişi ve istatistikler'**
  String get exportDataDescription;

  /// No description provided for @rssSources.
  ///
  /// In tr, this message translates to:
  /// **'Haber Kaynakları'**
  String get rssSources;

  /// No description provided for @manageRssSources.
  ///
  /// In tr, this message translates to:
  /// **'Haber Kaynaklarını Yönet'**
  String get manageRssSources;

  /// No description provided for @addNewSource.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Kaynak Ekle'**
  String get addNewSource;

  /// No description provided for @resetSources.
  ///
  /// In tr, this message translates to:
  /// **'Kaynakları Sıfırla'**
  String get resetSources;

  /// No description provided for @resetSourcesDescription.
  ///
  /// In tr, this message translates to:
  /// **'Varsayılan kaynaklara dön'**
  String get resetSourcesDescription;

  /// No description provided for @statistics.
  ///
  /// In tr, this message translates to:
  /// **'İstatistikler'**
  String get statistics;

  /// No description provided for @readingStatistics.
  ///
  /// In tr, this message translates to:
  /// **'Okuma İstatistikleri'**
  String get readingStatistics;

  /// No description provided for @readingGoals.
  ///
  /// In tr, this message translates to:
  /// **'Okuma Hedefleri'**
  String get readingGoals;

  /// No description provided for @readingTrends.
  ///
  /// In tr, this message translates to:
  /// **'Okuma Trendleri'**
  String get readingTrends;

  /// No description provided for @about.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get about;

  /// No description provided for @aboutApp.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Hakkında'**
  String get aboutApp;

  /// No description provided for @privacyPolicy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Şartları'**
  String get termsOfService;

  /// No description provided for @version.
  ///
  /// In tr, this message translates to:
  /// **'Versiyon'**
  String get version;

  /// No description provided for @analyticsTitle.
  ///
  /// In tr, this message translates to:
  /// **'İstatistikler'**
  String get analyticsTitle;

  /// No description provided for @overview.
  ///
  /// In tr, this message translates to:
  /// **'Genel Bakış'**
  String get overview;

  /// No description provided for @charts.
  ///
  /// In tr, this message translates to:
  /// **'Grafikler'**
  String get charts;

  /// No description provided for @details.
  ///
  /// In tr, this message translates to:
  /// **'Detaylar'**
  String get details;

  /// No description provided for @today.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Bu Hafta'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In tr, this message translates to:
  /// **'Bu Ay'**
  String get thisMonth;

  /// No description provided for @articlesRead.
  ///
  /// In tr, this message translates to:
  /// **'Okunan Makale'**
  String get articlesRead;

  /// No description provided for @timeSpent.
  ///
  /// In tr, this message translates to:
  /// **'Geçirilen Süre'**
  String get timeSpent;

  /// No description provided for @favoritesCount.
  ///
  /// In tr, this message translates to:
  /// **'Favoriler'**
  String get favoritesCount;

  /// No description provided for @sharesCount.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşımlar'**
  String get sharesCount;

  /// No description provided for @searchesCount.
  ///
  /// In tr, this message translates to:
  /// **'Aramalar'**
  String get searchesCount;

  /// No description provided for @readingStreak.
  ///
  /// In tr, this message translates to:
  /// **'Okuma Serisi'**
  String get readingStreak;

  /// No description provided for @consistency.
  ///
  /// In tr, this message translates to:
  /// **'Tutarlılık'**
  String get consistency;

  /// No description provided for @goals.
  ///
  /// In tr, this message translates to:
  /// **'Hedefler'**
  String get goals;

  /// No description provided for @dailyGoal.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Hedef'**
  String get dailyGoal;

  /// No description provided for @weeklyGoal.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık Hedef'**
  String get weeklyGoal;

  /// No description provided for @goalAchieved.
  ///
  /// In tr, this message translates to:
  /// **'Tebrikler! Hedefi başardınız.'**
  String get goalAchieved;

  /// No description provided for @goalNotAchieved.
  ///
  /// In tr, this message translates to:
  /// **'Hedefe ulaşmak için okumaya devam edin.'**
  String get goalNotAchieved;

  /// No description provided for @weeklyReadingChart.
  ///
  /// In tr, this message translates to:
  /// **'Son 7 Günün Okuma Grafiği'**
  String get weeklyReadingChart;

  /// No description provided for @categoryDistribution.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Dağılımı'**
  String get categoryDistribution;

  /// No description provided for @monthlyTrend.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Okuma Trendi'**
  String get monthlyTrend;

  /// No description provided for @socialActivity.
  ///
  /// In tr, this message translates to:
  /// **'Sosyal Aktivite'**
  String get socialActivity;

  /// No description provided for @totalShares.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Paylaşım'**
  String get totalShares;

  /// No description provided for @totalSearches.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Arama'**
  String get totalSearches;

  /// No description provided for @totalFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Favori'**
  String get totalFavorites;

  /// No description provided for @readingHabits.
  ///
  /// In tr, this message translates to:
  /// **'Okuma Alışkanlıklarınız'**
  String get readingHabits;

  /// No description provided for @readingTrend.
  ///
  /// In tr, this message translates to:
  /// **'Okuma Trendi'**
  String get readingTrend;

  /// No description provided for @productiveTime.
  ///
  /// In tr, this message translates to:
  /// **'En Verimli Saat'**
  String get productiveTime;

  /// No description provided for @consistencyScore.
  ///
  /// In tr, this message translates to:
  /// **'Tutarlılık Puanı'**
  String get consistencyScore;

  /// No description provided for @dailyAverage.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Ortalama'**
  String get dailyAverage;

  /// No description provided for @weeklyAverage.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık Ortalama'**
  String get weeklyAverage;

  /// No description provided for @trendIncreasing.
  ///
  /// In tr, this message translates to:
  /// **'Artış trendi'**
  String get trendIncreasing;

  /// No description provided for @trendDecreasing.
  ///
  /// In tr, this message translates to:
  /// **'Azalış trendi'**
  String get trendDecreasing;

  /// No description provided for @trendStable.
  ///
  /// In tr, this message translates to:
  /// **'Stabil'**
  String get trendStable;

  /// No description provided for @exportTitle.
  ///
  /// In tr, this message translates to:
  /// **'Dışa Aktar'**
  String get exportTitle;

  /// No description provided for @exportOptions.
  ///
  /// In tr, this message translates to:
  /// **'Dışa Aktarma Seçenekleri'**
  String get exportOptions;

  /// No description provided for @exportDescription.
  ///
  /// In tr, this message translates to:
  /// **'Verilerinizi CSV veya JSON formatında dışa aktarın'**
  String get exportDescription;

  /// No description provided for @exportFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favoriler'**
  String get exportFavorites;

  /// No description provided for @exportFavoritesDescription.
  ///
  /// In tr, this message translates to:
  /// **'Favori makalelerinizi dışa aktarın'**
  String get exportFavoritesDescription;

  /// No description provided for @exportReadingHistory.
  ///
  /// In tr, this message translates to:
  /// **'Okuma Geçmişi'**
  String get exportReadingHistory;

  /// No description provided for @exportReadingHistoryDescription.
  ///
  /// In tr, this message translates to:
  /// **'Okuduğunuz makalelerin listesi'**
  String get exportReadingHistoryDescription;

  /// No description provided for @exportReadingList.
  ///
  /// In tr, this message translates to:
  /// **'Okuma Listesi'**
  String get exportReadingList;

  /// No description provided for @exportReadingListDescription.
  ///
  /// In tr, this message translates to:
  /// **'Sonra okumak için kaydettiğiniz makaleler'**
  String get exportReadingListDescription;

  /// No description provided for @exportStatistics.
  ///
  /// In tr, this message translates to:
  /// **'İstatistikler'**
  String get exportStatistics;

  /// No description provided for @exportStatisticsDescription.
  ///
  /// In tr, this message translates to:
  /// **'Okuma istatistikleriniz ve hedefleriniz'**
  String get exportStatisticsDescription;

  /// No description provided for @exportAll.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Veriler'**
  String get exportAll;

  /// No description provided for @exportAllDescription.
  ///
  /// In tr, this message translates to:
  /// **'Tüm verilerinizi tek dosyada dışa aktarın'**
  String get exportAllDescription;

  /// No description provided for @exportedFiles.
  ///
  /// In tr, this message translates to:
  /// **'Dışa Aktarılan Dosyalar'**
  String get exportedFiles;

  /// No description provided for @exportSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Dışa aktarma başarılı! {count} öğe kaydedildi.'**
  String exportSuccess(int count);

  /// No description provided for @exportError.
  ///
  /// In tr, this message translates to:
  /// **'Dışa aktarma hatası'**
  String get exportError;

  /// No description provided for @selectFormat.
  ///
  /// In tr, this message translates to:
  /// **'Dışa aktarma formatını seçin'**
  String get selectFormat;

  /// No description provided for @csvFormat.
  ///
  /// In tr, this message translates to:
  /// **'CSV'**
  String get csvFormat;

  /// No description provided for @csvDescription.
  ///
  /// In tr, this message translates to:
  /// **'Excel ile uyumlu'**
  String get csvDescription;

  /// No description provided for @jsonFormat.
  ///
  /// In tr, this message translates to:
  /// **'JSON'**
  String get jsonFormat;

  /// No description provided for @jsonDescription.
  ///
  /// In tr, this message translates to:
  /// **'Yapılandırılmış veri'**
  String get jsonDescription;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil Seçin'**
  String get selectLanguage;

  /// No description provided for @turkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @english.
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @confirmDelete.
  ///
  /// In tr, this message translates to:
  /// **'Silmek istediğinizden emin misiniz?'**
  String get confirmDelete;

  /// No description provided for @confirmClear.
  ///
  /// In tr, this message translates to:
  /// **'Temizlemek istediğinizden emin misiniz?'**
  String get confirmClear;

  /// No description provided for @actionCannotBeUndone.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem geri alınamaz.'**
  String get actionCannotBeUndone;

  /// No description provided for @connectionError.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı hatası'**
  String get connectionError;

  /// No description provided for @noInternet.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı yok'**
  String get noInternet;

  /// No description provided for @serverError.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu hatası'**
  String get serverError;

  /// No description provided for @unknownError.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen hata'**
  String get unknownError;

  /// No description provided for @minutes.
  ///
  /// In tr, this message translates to:
  /// **'dakika'**
  String get minutes;

  /// No description provided for @hours.
  ///
  /// In tr, this message translates to:
  /// **'saat'**
  String get hours;

  /// No description provided for @days.
  ///
  /// In tr, this message translates to:
  /// **'gün'**
  String get days;

  /// No description provided for @articles.
  ///
  /// In tr, this message translates to:
  /// **'makale'**
  String get articles;

  /// No description provided for @monday.
  ///
  /// In tr, this message translates to:
  /// **'Pazartesi'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In tr, this message translates to:
  /// **'Salı'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In tr, this message translates to:
  /// **'Çarşamba'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In tr, this message translates to:
  /// **'Perşembe'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In tr, this message translates to:
  /// **'Cuma'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In tr, this message translates to:
  /// **'Cumartesi'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In tr, this message translates to:
  /// **'Pazar'**
  String get sunday;

  /// No description provided for @mondayShort.
  ///
  /// In tr, this message translates to:
  /// **'Pzt'**
  String get mondayShort;

  /// No description provided for @tuesdayShort.
  ///
  /// In tr, this message translates to:
  /// **'Sal'**
  String get tuesdayShort;

  /// No description provided for @wednesdayShort.
  ///
  /// In tr, this message translates to:
  /// **'Çar'**
  String get wednesdayShort;

  /// No description provided for @thursdayShort.
  ///
  /// In tr, this message translates to:
  /// **'Per'**
  String get thursdayShort;

  /// No description provided for @fridayShort.
  ///
  /// In tr, this message translates to:
  /// **'Cum'**
  String get fridayShort;

  /// No description provided for @saturdayShort.
  ///
  /// In tr, this message translates to:
  /// **'Cmt'**
  String get saturdayShort;

  /// No description provided for @sundayShort.
  ///
  /// In tr, this message translates to:
  /// **'Paz'**
  String get sundayShort;

  /// No description provided for @notificationCategoryFilters.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Bildirimleri'**
  String get notificationCategoryFilters;

  /// No description provided for @notificationQuietHours.
  ///
  /// In tr, this message translates to:
  /// **'Sessiz Saatler'**
  String get notificationQuietHours;

  /// No description provided for @notificationDailyLimit.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Bildirim Limiti'**
  String get notificationDailyLimit;

  /// No description provided for @notificationQuietHoursStart.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç Saati'**
  String get notificationQuietHoursStart;

  /// No description provided for @notificationQuietHoursEnd.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş Saati'**
  String get notificationQuietHoursEnd;

  /// No description provided for @notificationMaxDaily.
  ///
  /// In tr, this message translates to:
  /// **'Maksimum Bildirim'**
  String get notificationMaxDaily;

  /// No description provided for @notificationTodayCount.
  ///
  /// In tr, this message translates to:
  /// **'Bugün: {count}/{max}'**
  String notificationTodayCount(int count, int max);

  /// No description provided for @notificationPrioritySettings.
  ///
  /// In tr, this message translates to:
  /// **'Öncelik Ayarları'**
  String get notificationPrioritySettings;

  /// No description provided for @notificationHighPrioritySound.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek Öncelik Sesi'**
  String get notificationHighPrioritySound;

  /// No description provided for @notificationHighPriorityVibration.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek Öncelik Titreşimi'**
  String get notificationHighPriorityVibration;

  /// No description provided for @readingMode.
  ///
  /// In tr, this message translates to:
  /// **'Okuma Modu'**
  String get readingMode;

  /// No description provided for @readingModeFontSize.
  ///
  /// In tr, this message translates to:
  /// **'Font Boyutu'**
  String get readingModeFontSize;

  /// No description provided for @readingModeBackground.
  ///
  /// In tr, this message translates to:
  /// **'Arka Plan Rengi'**
  String get readingModeBackground;

  /// No description provided for @readingModeLineSpacing.
  ///
  /// In tr, this message translates to:
  /// **'Satır Aralığı'**
  String get readingModeLineSpacing;

  /// No description provided for @readingModeNightMode.
  ///
  /// In tr, this message translates to:
  /// **'Gece Modu'**
  String get readingModeNightMode;

  /// No description provided for @readingModeReset.
  ///
  /// In tr, this message translates to:
  /// **'Varsayılana Dön'**
  String get readingModeReset;

  /// No description provided for @readingModeSettings.
  ///
  /// In tr, this message translates to:
  /// **'Okuma Ayarları'**
  String get readingModeSettings;

  /// No description provided for @readingColorWhite.
  ///
  /// In tr, this message translates to:
  /// **'Beyaz'**
  String get readingColorWhite;

  /// No description provided for @readingColorBeige.
  ///
  /// In tr, this message translates to:
  /// **'Bej'**
  String get readingColorBeige;

  /// No description provided for @readingColorSepia.
  ///
  /// In tr, this message translates to:
  /// **'Sepia'**
  String get readingColorSepia;

  /// No description provided for @readingColorBlack.
  ///
  /// In tr, this message translates to:
  /// **'Siyah'**
  String get readingColorBlack;

  /// No description provided for @readingColorNight.
  ///
  /// In tr, this message translates to:
  /// **'Gece'**
  String get readingColorNight;

  /// No description provided for @readingSpacingCompact.
  ///
  /// In tr, this message translates to:
  /// **'Dar'**
  String get readingSpacingCompact;

  /// No description provided for @readingSpacingNormal.
  ///
  /// In tr, this message translates to:
  /// **'Normal'**
  String get readingSpacingNormal;

  /// No description provided for @readingSpacingComfortable.
  ///
  /// In tr, this message translates to:
  /// **'Rahat'**
  String get readingSpacingComfortable;

  /// No description provided for @readingSpacingWide.
  ///
  /// In tr, this message translates to:
  /// **'Geniş'**
  String get readingSpacingWide;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
