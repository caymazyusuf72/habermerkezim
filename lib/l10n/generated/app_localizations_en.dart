import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  // ==================== App General ====================
  
  @override
  String get appName => 'News Center';

  @override
  String get appSlogan => 'Latest news, all in one place';

  // ==================== Navigation ====================
  
  @override
  String get navHome => 'Home';

  @override
  String get navCategories => 'Categories';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navProfile => 'Profile';

  // ==================== Home Page ====================
  
  @override
  String get breakingNews => 'Breaking News';

  @override
  String get latestNews => 'Latest News';

  @override
  String get popularNews => 'Popular News';

  @override
  String get allNews => 'All News';

  @override
  String get refresh => 'Refresh';

  @override
  String get loading => 'Loading...';

  @override
  String get noNewsFound => 'No news found';

  @override
  String get pullToRefresh => 'Pull to refresh';

  // ==================== Categories ====================
  
  @override
  String get allCategories => 'All Categories';

  @override
  String get categoryTechnology => 'Technology';

  @override
  String get categorySports => 'Sports';

  @override
  String get categoryEconomy => 'Economy';

  @override
  String get categoryMagazine => 'Entertainment';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryScience => 'Science';

  @override
  String get categoryCulture => 'Culture & Arts';

  @override
  String get categoryWorld => 'World';

  @override
  String get categoryPolitics => 'Politics';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryAutomotive => 'Automotive';

  @override
  String get categoryTravel => 'Travel';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryFashion => 'Fashion';

  // ==================== Article ====================
  
  @override
  String get readMore => 'Read More';

  @override
  String get share => 'Share';

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get removeFromFavorites => 'Remove from Favorites';

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String readTime(int minutes) => '$minutes min read';

  @override
  String get source => 'Source';

  @override
  String get publishedDate => 'Published Date';

  @override
  String get openInBrowser => 'Open in Browser';

  @override
  String get copyLink => 'Copy Link';

  @override
  String get linkCopied => 'Link copied';

  // ==================== Favorites ====================
  
  @override
  String get favorites => 'Favorites';

  @override
  String get noFavorites => 'No favorites yet';

  @override
  String get noFavoritesDescription => 'Add articles you like to favorites to read them later';

  @override
  String get clearAllFavorites => 'Clear All Favorites';

  @override
  String get clearFavoritesConfirmation => 'Are you sure you want to delete all favorites?';

  // ==================== Profile ====================
  
  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get readingStatistics => 'Reading Statistics';

  @override
  String get articlesRead => 'Articles Read';

  @override
  String get timeSpentReading => 'Time Spent Reading';

  @override
  String get favoriteArticles => 'Favorite Articles';

  @override
  String get categoriesFollowed => 'Categories Followed';

  @override
  String get achievements => 'Achievements';

  @override
  String get level => 'Level';

  @override
  String get points => 'Points';

  // ==================== Settings ====================
  
  @override
  String get settings => 'Settings';

  @override
  String get generalSettings => 'General Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get systemTheme => 'System Theme';

  @override
  String get fontSize => 'Font Size';

  @override
  String get fontSizeSmall => 'Small';

  @override
  String get fontSizeNormal => 'Normal';

  @override
  String get fontSizeLarge => 'Large';

  @override
  String get fontSizeExtraLarge => 'Extra Large';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get breakingNewsNotifications => 'Breaking News Notifications';

  @override
  String get dailyDigestNotifications => 'Daily Digest';

  @override
  String get sound => 'Sound';

  @override
  String get vibration => 'Vibration';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get cacheCleared => 'Cache cleared';

  @override
  String get exportData => 'Export Data';

  @override
  String get importData => 'Import Data';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get rateApp => 'Rate App';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  // ==================== Search ====================
  
  @override
  String get searchHint => 'Search news...';

  @override
  String get searchResults => 'Search Results';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get recentSearches => 'Recent Searches';

  @override
  String get clearSearchHistory => 'Clear Search History';

  @override
  String get popularSearches => 'Popular Searches';

  // ==================== Errors ====================
  
  @override
  String get errorGeneric => 'An error occurred';

  @override
  String get errorNetwork => 'Connection error';

  @override
  String get errorServer => 'Server error';

  @override
  String get errorTimeout => 'Timeout';

  @override
  String get errorNoInternet => 'No internet connection';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get retry => 'Retry';

  // ==================== Common Actions ====================
  
  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get done => 'Done';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get confirm => 'Confirm';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get continueButton => 'Continue';

  // ==================== Time ====================
  
  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) => '$minutes minutes ago';

  @override
  String hoursAgo(int hours) => '$hours hours ago';

  @override
  String daysAgo(int days) => '$days days ago';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  // ==================== Onboarding ====================
  
  @override
  String get onboardingTitle1 => 'Welcome to News';

  @override
  String get onboardingDescription1 => 'Follow the latest news from Turkey and the world';

  @override
  String get onboardingTitle2 => 'Personalized Content';

  @override
  String get onboardingDescription2 => 'Get news based on your interests';

  @override
  String get onboardingTitle3 => 'Offline Reading';

  @override
  String get onboardingDescription3 => 'Save articles and read them without internet';

  @override
  String get getStarted => 'Get Started';

  // ==================== Auth ====================
  
  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get continueAsGuest => 'Continue as Guest';

  // ==================== Analytics ====================
  
  @override
  String get analytics => 'Analytics';

  @override
  String get readingHistory => 'Reading History';

  @override
  String get weeklyReport => 'Weekly Report';

  @override
  String get monthlyReport => 'Monthly Report';

  @override
  String get mostReadCategories => 'Most Read Categories';

  @override
  String get readingStreak => 'Reading Streak';

  @override
  String get days => 'days';

  // ==================== Export/Import ====================
  
  @override
  String get exportFavorites => 'Export Favorites';

  @override
  String get exportReadingHistory => 'Export Reading History';

  @override
  String get exportAllData => 'Export All Data';

  @override
  String get exportSuccessful => 'Export successful';

  @override
  String get importSuccessful => 'Import successful';

  @override
  String get exportFormat => 'Export Format';

  @override
  String get csvFormat => 'CSV Format';

  @override
  String get jsonFormat => 'JSON Format';
}