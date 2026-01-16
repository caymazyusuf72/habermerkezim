import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
///   # Coverage for all locales
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # If you also want to use the generated localization delegate
///   # add the following dependency
///   flutter:
///     generate: true
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you'll need to edit this
/// file.
///
/// First, open your project's ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project's Runner folder.
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('tr'),
    Locale('en')
  ];

  // ==================== App General ====================
  
  /// App name
  String get appName;

  /// App slogan
  String get appSlogan;

  // ==================== Navigation ====================
  
  /// Home navigation label
  String get navHome;

  /// Categories navigation label
  String get navCategories;

  /// Favorites navigation label
  String get navFavorites;

  /// Profile navigation label
  String get navProfile;

  // ==================== Home Page ====================
  
  /// Breaking news title
  String get breakingNews;

  /// Latest news title
  String get latestNews;

  /// Popular news title
  String get popularNews;

  /// All news title
  String get allNews;

  /// Refresh button text
  String get refresh;

  /// Loading text
  String get loading;

  /// No news found message
  String get noNewsFound;

  /// Pull to refresh text
  String get pullToRefresh;

  // ==================== Categories ====================
  
  /// All categories title
  String get allCategories;

  /// Technology category
  String get categoryTechnology;

  /// Sports category
  String get categorySports;

  /// Economy category
  String get categoryEconomy;

  /// Magazine category
  String get categoryMagazine;

  /// Health category
  String get categoryHealth;

  /// Science category
  String get categoryScience;

  /// Culture category
  String get categoryCulture;

  /// World category
  String get categoryWorld;

  /// Politics category
  String get categoryPolitics;

  /// Education category
  String get categoryEducation;

  /// Automotive category
  String get categoryAutomotive;

  /// Travel category
  String get categoryTravel;

  /// Food category
  String get categoryFood;

  /// Fashion category
  String get categoryFashion;

  // ==================== Article ====================
  
  /// Read more button
  String get readMore;

  /// Share button
  String get share;

  /// Add to favorites
  String get addToFavorites;

  /// Remove from favorites
  String get removeFromFavorites;

  /// Added to favorites message
  String get addedToFavorites;

  /// Removed from favorites message
  String get removedFromFavorites;

  /// Read time format
  String readTime(int minutes);

  /// Source label
  String get source;

  /// Published date label
  String get publishedDate;

  /// Open in browser
  String get openInBrowser;

  /// Copy link
  String get copyLink;

  /// Link copied message
  String get linkCopied;

  // ==================== Favorites ====================
  
  /// Favorites page title
  String get favorites;

  /// No favorites message
  String get noFavorites;

  /// No favorites description
  String get noFavoritesDescription;

  /// Clear all favorites
  String get clearAllFavorites;

  /// Clear favorites confirmation
  String get clearFavoritesConfirmation;

  // ==================== Profile ====================
  
  /// Profile page title
  String get profile;

  /// Edit profile
  String get editProfile;

  /// Reading statistics
  String get readingStatistics;

  /// Articles read
  String get articlesRead;

  /// Time spent reading
  String get timeSpentReading;

  /// Favorite articles
  String get favoriteArticles;

  /// Categories followed
  String get categoriesFollowed;

  /// Achievements
  String get achievements;

  /// Level label
  String get level;

  /// Points label
  String get points;

  // ==================== Settings ====================
  
  /// Settings page title
  String get settings;

  /// General settings section
  String get generalSettings;

  /// Appearance settings section
  String get appearance;

  /// Notifications settings section
  String get notifications;

  /// Language setting
  String get language;

  /// Theme setting
  String get theme;

  /// Dark mode setting
  String get darkMode;

  /// Light theme
  String get lightTheme;

  /// Dark theme
  String get darkTheme;

  /// System theme
  String get systemTheme;

  /// Font size setting
  String get fontSize;

  /// Small font size
  String get fontSizeSmall;

  /// Normal font size
  String get fontSizeNormal;

  /// Large font size
  String get fontSizeLarge;

  /// Extra large font size
  String get fontSizeExtraLarge;

  /// Push notifications setting
  String get pushNotifications;

  /// Breaking news notifications
  String get breakingNewsNotifications;

  /// Daily digest notifications
  String get dailyDigestNotifications;

  /// Sound setting
  String get sound;

  /// Vibration setting
  String get vibration;

  /// Data management section
  String get dataManagement;

  /// Clear cache
  String get clearCache;

  /// Cache cleared message
  String get cacheCleared;

  /// Export data
  String get exportData;

  /// Import data
  String get importData;

  /// About section
  String get about;

  /// Version label
  String get version;

  /// Privacy policy
  String get privacyPolicy;

  /// Terms of service
  String get termsOfService;

  /// Rate app
  String get rateApp;

  /// Contact us
  String get contactUs;

  /// Logout
  String get logout;

  /// Logout confirmation
  String get logoutConfirmation;

  // ==================== Search ====================
  
  /// Search hint
  String get searchHint;

  /// Search results title
  String get searchResults;

  /// No results found
  String get noResultsFound;

  /// Recent searches
  String get recentSearches;

  /// Clear search history
  String get clearSearchHistory;

  /// Popular searches
  String get popularSearches;

  // ==================== Errors ====================
  
  /// Generic error message
  String get errorGeneric;

  /// Network error message
  String get errorNetwork;

  /// Server error message
  String get errorServer;

  /// Timeout error message
  String get errorTimeout;

  /// No internet connection
  String get errorNoInternet;

  /// Try again button
  String get tryAgain;

  /// Retry button
  String get retry;

  // ==================== Common Actions ====================
  
  /// OK button
  String get ok;

  /// Cancel button
  String get cancel;

  /// Save button
  String get save;

  /// Delete button
  String get delete;

  /// Edit button
  String get edit;

  /// Close button
  String get close;

  /// Done button
  String get done;

  /// Yes button
  String get yes;

  /// No button
  String get no;

  /// Confirm button
  String get confirm;

  /// Back button
  String get back;

  /// Next button
  String get next;

  /// Skip button
  String get skip;

  /// Continue button
  String get continueButton;

  // ==================== Time ====================
  
  /// Just now
  String get justNow;

  /// Minutes ago format
  String minutesAgo(int minutes);

  /// Hours ago format
  String hoursAgo(int hours);

  /// Days ago format
  String daysAgo(int days);

  /// Yesterday
  String get yesterday;

  /// Today
  String get today;

  /// This week
  String get thisWeek;

  /// This month
  String get thisMonth;

  // ==================== Onboarding ====================
  
  /// Onboarding title 1
  String get onboardingTitle1;

  /// Onboarding description 1
  String get onboardingDescription1;

  /// Onboarding title 2
  String get onboardingTitle2;

  /// Onboarding description 2
  String get onboardingDescription2;

  /// Onboarding title 3
  String get onboardingTitle3;

  /// Onboarding description 3
  String get onboardingDescription3;

  /// Get started button
  String get getStarted;

  // ==================== Auth ====================
  
  /// Login title
  String get login;

  /// Register title
  String get register;

  /// Email label
  String get email;

  /// Password label
  String get password;

  /// Confirm password label
  String get confirmPassword;

  /// Forgot password
  String get forgotPassword;

  /// Don't have an account
  String get dontHaveAccount;

  /// Already have an account
  String get alreadyHaveAccount;

  /// Sign in with Google
  String get signInWithGoogle;

  /// Sign in with Apple
  String get signInWithApple;

  /// Continue as guest
  String get continueAsGuest;

  // ==================== Analytics ====================
  
  /// Analytics page title
  String get analytics;

  /// Reading history
  String get readingHistory;

  /// Weekly report
  String get weeklyReport;

  /// Monthly report
  String get monthlyReport;

  /// Most read categories
  String get mostReadCategories;

  /// Reading streak
  String get readingStreak;

  /// Days label
  String get days;

  // ==================== Export/Import ====================
  
  /// Export favorites
  String get exportFavorites;

  /// Export reading history
  String get exportReadingHistory;

  /// Export all data
  String get exportAllData;

  /// Export successful
  String get exportSuccessful;

  /// Import successful
  String get importSuccessful;

  /// Export format
  String get exportFormat;

  /// CSV format
  String get csvFormat;

  /// JSON format
  String get jsonFormat;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'tr'].contains(locale.languageCode);

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
      'that was used.');
}