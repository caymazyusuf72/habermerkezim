// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'News Center';

  @override
  String get home => 'Home';

  @override
  String get favorites => 'Favorites';

  @override
  String get search => 'Search';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get categories => 'Categories';

  @override
  String get general => 'General';

  @override
  String get technology => 'Technology';

  @override
  String get sports => 'Sports';

  @override
  String get economy => 'Economy';

  @override
  String get health => 'Health';

  @override
  String get science => 'Science';

  @override
  String get culture => 'Culture';

  @override
  String get world => 'World';

  @override
  String get politics => 'Politics';

  @override
  String get entertainment => 'Entertainment';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get share => 'Share';

  @override
  String get refresh => 'Refresh';

  @override
  String get noArticles => 'No articles yet';

  @override
  String get noFavorites => 'No favorite articles yet';

  @override
  String get noSearchResults => 'No search results found';

  @override
  String get noReadingHistory => 'Reading history is empty';

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get removeFromFavorites => 'Remove from Favorites';

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String get readMore => 'Read More';

  @override
  String readingTime(int minutes) {
    return '$minutes min read';
  }

  @override
  String publishedAt(String date) {
    return 'Published on $date';
  }

  @override
  String get source => 'Source';

  @override
  String get category => 'Category';

  @override
  String get searchHint => 'Search news...';

  @override
  String get searchHistory => 'Search History';

  @override
  String get clearSearchHistory => 'Clear Search History';

  @override
  String get popularSearches => 'Popular Searches';

  @override
  String get recentSearches => 'Recent Searches';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemTheme => 'System Theme';

  @override
  String get themes => 'Themes';

  @override
  String get selectTheme => 'Select color theme';

  @override
  String get fontSize => 'Font Size';

  @override
  String get small => 'Small';

  @override
  String get normal => 'Normal';

  @override
  String get large => 'Large';

  @override
  String get extraLarge => 'Extra Large';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get notificationPreferences => 'Notification Preferences';

  @override
  String get dailyNewsReminder => 'Daily News Reminder';

  @override
  String get readingGoalReminder => 'Reading Goal Reminder';

  @override
  String get breakingNews => 'Breaking News';

  @override
  String get notificationsEnabled => 'Notifications enabled';

  @override
  String get notificationsDisabled => 'Notifications disabled';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get clearCacheDescription => 'Delete all cached news';

  @override
  String get clearFavorites => 'Clear Favorites';

  @override
  String get clearFavoritesDescription => 'Delete all favorite news';

  @override
  String get clearSearchHistoryDescription => 'Clear all search history';

  @override
  String get exportData => 'Export Data';

  @override
  String get exportDataDescription =>
      'Favorites, reading history and statistics';

  @override
  String get rssSources => 'News Sources';

  @override
  String get manageRssSources => 'Manage News Sources';

  @override
  String get addNewSource => 'Add New Source';

  @override
  String get resetSources => 'Reset Sources';

  @override
  String get resetSourcesDescription => 'Return to default sources';

  @override
  String get statistics => 'Statistics';

  @override
  String get readingStatistics => 'Reading Statistics';

  @override
  String get readingGoals => 'Reading Goals';

  @override
  String get readingTrends => 'Reading Trends';

  @override
  String get about => 'About';

  @override
  String get aboutApp => 'About App';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get version => 'Version';

  @override
  String get analyticsTitle => 'Statistics';

  @override
  String get overview => 'Overview';

  @override
  String get charts => 'Charts';

  @override
  String get details => 'Details';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get articlesRead => 'Articles Read';

  @override
  String get timeSpent => 'Time Spent';

  @override
  String get favoritesCount => 'Favorites';

  @override
  String get sharesCount => 'Shares';

  @override
  String get searchesCount => 'Searches';

  @override
  String get readingStreak => 'Reading Streak';

  @override
  String get consistency => 'Consistency';

  @override
  String get goals => 'Goals';

  @override
  String get dailyGoal => 'Daily Goal';

  @override
  String get weeklyGoal => 'Weekly Goal';

  @override
  String get goalAchieved => 'Congratulations! You achieved the goal.';

  @override
  String get goalNotAchieved => 'Keep reading to reach your goal.';

  @override
  String get weeklyReadingChart => 'Last 7 Days Reading Chart';

  @override
  String get categoryDistribution => 'Category Distribution';

  @override
  String get monthlyTrend => 'Monthly Reading Trend';

  @override
  String get socialActivity => 'Social Activity';

  @override
  String get totalShares => 'Total Shares';

  @override
  String get totalSearches => 'Total Searches';

  @override
  String get totalFavorites => 'Total Favorites';

  @override
  String get readingHabits => 'Your Reading Habits';

  @override
  String get readingTrend => 'Reading Trend';

  @override
  String get productiveTime => 'Most Productive Time';

  @override
  String get consistencyScore => 'Consistency Score';

  @override
  String get dailyAverage => 'Daily Average';

  @override
  String get weeklyAverage => 'Weekly Average';

  @override
  String get trendIncreasing => 'Increasing trend';

  @override
  String get trendDecreasing => 'Decreasing trend';

  @override
  String get trendStable => 'Stable';

  @override
  String get exportTitle => 'Export';

  @override
  String get exportOptions => 'Export Options';

  @override
  String get exportDescription => 'Export your data in CSV or JSON format';

  @override
  String get exportFavorites => 'Favorites';

  @override
  String get exportFavoritesDescription => 'Export your favorite articles';

  @override
  String get exportReadingHistory => 'Reading History';

  @override
  String get exportReadingHistoryDescription => 'List of articles you\'ve read';

  @override
  String get exportReadingList => 'Reading List';

  @override
  String get exportReadingListDescription => 'Articles saved for later';

  @override
  String get exportStatistics => 'Statistics';

  @override
  String get exportStatisticsDescription => 'Your reading statistics and goals';

  @override
  String get exportAll => 'All Data';

  @override
  String get exportAllDescription => 'Export all your data in a single file';

  @override
  String get exportedFiles => 'Exported Files';

  @override
  String exportSuccess(int count) {
    return 'Export successful! $count items saved.';
  }

  @override
  String get exportError => 'Export error';

  @override
  String get selectFormat => 'Select export format';

  @override
  String get csvFormat => 'CSV';

  @override
  String get csvDescription => 'Excel compatible';

  @override
  String get jsonFormat => 'JSON';

  @override
  String get jsonDescription => 'Structured data';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get turkish => 'Türkçe';

  @override
  String get english => 'English';

  @override
  String get confirmDelete => 'Are you sure you want to delete?';

  @override
  String get confirmClear => 'Are you sure you want to clear?';

  @override
  String get actionCannotBeUndone => 'This action cannot be undone.';

  @override
  String get connectionError => 'Connection error';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get serverError => 'Server error';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get minutes => 'minutes';

  @override
  String get hours => 'hours';

  @override
  String get days => 'days';

  @override
  String get articles => 'articles';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get mondayShort => 'Mon';

  @override
  String get tuesdayShort => 'Tue';

  @override
  String get wednesdayShort => 'Wed';

  @override
  String get thursdayShort => 'Thu';

  @override
  String get fridayShort => 'Fri';

  @override
  String get saturdayShort => 'Sat';

  @override
  String get sundayShort => 'Sun';

  @override
  String get notificationCategoryFilters => 'Category Notifications';

  @override
  String get notificationQuietHours => 'Quiet Hours';

  @override
  String get notificationDailyLimit => 'Daily Notification Limit';

  @override
  String get notificationQuietHoursStart => 'Start Time';

  @override
  String get notificationQuietHoursEnd => 'End Time';

  @override
  String get notificationMaxDaily => 'Maximum Notifications';

  @override
  String notificationTodayCount(int count, int max) {
    return 'Today: $count/$max';
  }

  @override
  String get notificationPrioritySettings => 'Priority Settings';

  @override
  String get notificationHighPrioritySound => 'High Priority Sound';

  @override
  String get notificationHighPriorityVibration => 'High Priority Vibration';

  @override
  String get readingMode => 'Reading Mode';

  @override
  String get readingModeFontSize => 'Font Size';

  @override
  String get readingModeBackground => 'Background Color';

  @override
  String get readingModeLineSpacing => 'Line Spacing';

  @override
  String get readingModeNightMode => 'Night Mode';

  @override
  String get readingModeReset => 'Reset to Default';

  @override
  String get readingModeSettings => 'Reading Settings';

  @override
  String get readingColorWhite => 'White';

  @override
  String get readingColorBeige => 'Beige';

  @override
  String get readingColorSepia => 'Sepia';

  @override
  String get readingColorBlack => 'Black';

  @override
  String get readingColorNight => 'Night';

  @override
  String get readingSpacingCompact => 'Compact';

  @override
  String get readingSpacingNormal => 'Normal';

  @override
  String get readingSpacingComfortable => 'Comfortable';

  @override
  String get readingSpacingWide => 'Wide';
}
