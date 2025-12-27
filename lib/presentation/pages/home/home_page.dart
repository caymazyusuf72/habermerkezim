import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../providers/connectivity_provider.dart';
import '../../themes/app_theme.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../domain/entities/category.dart';
import 'widgets/news_list.dart';
import 'widgets/category_tabs.dart';
import 'widgets/app_drawer.dart';
import 'widgets/article_filter_dialog.dart';
import 'widgets/notification_banner.dart';
import 'widgets/personalized_news_section.dart';
import '../search/search_page.dart';
import '../profile/profile_page.dart';

/// CategoryTabs için PreferredSizeWidget wrapper
class CategoryTabsWrapper extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;

  const CategoryTabsWrapper({super.key, required this.child});

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Ana sayfa - Haber Merkezi'nin ana ekranı
/// Bottom navigation, kategori tabları, haber listesi içerir
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  
  TabController? _tabController;
  final Map<String, GlobalKey<NewsListState>> _newsListKeys = {};
  
  @override
  void initState() {
    super.initState();
  }

  void _initializeTabController(List<Category> categories) {
    // Her kategori için bir GlobalKey oluştur
    for (final category in categories) {
      if (!_newsListKeys.containsKey(category.id)) {
        _newsListKeys[category.id] = GlobalKey<NewsListState>();
      }
    }
    
    // Eski controller'ı dispose et
    if (_tabController != null && _tabController!.length != categories.length) {
      _tabController!.removeListener(_onTabChanged);
      _tabController!.dispose();
    }
    
    // Tab controller'ı başlat
    _tabController = TabController(
      length: categories.length,
      vsync: this,
    );
    
    // Tab değişikliklerini dinle
    _tabController!.addListener(_onTabChanged);
    
    // İlk kategoriyi yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _tabController != null) {
        final selectedCategory = categories[_tabController!.index];
        ref.read(newsProvider.notifier).loadArticlesByCategory(
          selectedCategory.id,
          refresh: true
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    super.dispose();
  }

  /// Tab değiştiğinde kategoryi değiştir
  void _onTabChanged() {
    if (_tabController != null && _tabController!.indexIsChanging) {
      final categories = ref.read(orderedCategoriesProvider);
      final selectedCategory = categories[_tabController!.index];
      ref.read(newsProvider.notifier).changeCategory(selectedCategory.id);
    }
  }


  /// Pull-to-refresh callback
  Future<void> _onRefresh() async {
    await ref.read(newsProvider.notifier).refreshArticles();
  }

  @override
  Widget build(BuildContext context) {
    // Providers'ı izle
    final newsState = ref.watch(newsProvider);
    final connectivityState = ref.watch(connectivityProvider);
    final isConnected = connectivityState.isConnected;
    final isDarkMode = ref.watch(isDarkModeProvider);
    final categories = ref.watch(orderedCategoriesProvider);
    
    // İlk kez veya kategoriler değiştiğinde TabController'ı oluştur/güncelle
    if (_tabController == null || _tabController!.length != categories.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _initializeTabController(categories);
          });
        }
      });
    }
    
    return Scaffold(
      // App Bar
      appBar: AppBar(
        title: Row(
          children: [
            // Logo
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.sageGreen, AppTheme.sageGreenLight],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.dynamic_feed_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'Haber Merkezim',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        // App bar actions
        actions: [
          // Profil butonu (sağ üst, ilk sırada)
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ProfilePage(),
                ),
              );
            },
            icon: const Icon(Icons.person_rounded),
            tooltip: 'Profil',
          ),
          
          // Bağlantı durumu göstergesi
          if (!isConnected)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.wifi_off, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Offline',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          
          // Arama butonu
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SearchPage(),
                ),
              );
            },
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Ara',
          ),
          
          // Dark mode toggle
          IconButton(
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
            icon: Icon(
              isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            tooltip: isDarkMode ? 'Açık Tema' : 'Karanlık Tema',
          ),
        ],
        
        // Kategori tabları
        bottom: _tabController != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: CategoryTabs(
                  tabController: _tabController!,
                  categories: categories,
                ),
              )
            : null,
      ),

      // Drawer
      drawer: const AppDrawer(),

      // Ana içerik
      body: Column(
        children: [
          // Bildirim banner'ı
          const NotificationBanner(),
          
          // İlgilendiğiniz Haberler bölümü
          const PersonalizedNewsSection(),
          
          // Hata mesajı (varsa)
          if (newsState.hasError && !newsState.isLoading)
            Container(
              width: double.infinity,
              color: Colors.red.shade50,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      newsState.errorMessage ?? 'Bir hata oluştu',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(newsProvider.notifier).clearError();
                      _onRefresh();
                    },
                    child: const Text('Yeniden Dene'),
                  ),
                ],
              ),
            ),

          // Haber listesi
          Expanded(
            child: _tabController != null
                ? TabBarView(
                    controller: _tabController!,
                    children: categories.map((category) {
                      return NewsList(
                        key: _newsListKeys[category.id],
                        category: category.id,
                        onRefresh: _onRefresh,
                      );
                    }).toList(),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),

      // FAB - Yukarı scroll et
      floatingActionButton: newsState.hasArticles
          ? FloatingActionButton.small(
              onPressed: () {
                // Aktif tab'ın NewsList'ine eriş ve scroll to top yap
                if (_tabController != null) {
                  final activeCategory = categories[_tabController!.index];
                  final newsListKey = _newsListKeys[activeCategory.id];
                  final newsListState = newsListKey?.currentState;
                  
                  if (newsListState != null) {
                    newsListState.scrollToTop();
                  }
                }
              },
              child: const Icon(Icons.keyboard_arrow_up),
              tooltip: 'Yukarı git',
            )
          : null,
    );
  }
}

/// Home page ile ilgili utility fonksiyonlar
class HomePageUtils {
  HomePageUtils._();
  
  /// Kategori renklerini döner
  static Color getCategoryColor(String categoryId) {
    return AppTheme.getCategoryColor(categoryId);
  }
  
  /// Kategori iconunu döner
  static IconData getCategoryIcon(String categoryId) {
    final iconName = ApiEndpoints.feedIcons[categoryId];
    
    switch (iconName) {
      case 'breaking_news':
        return Icons.flash_on;
      case 'flag':
        return Icons.flag;
      case 'trending_up':
        return Icons.trending_up;
      case 'computer':
        return Icons.computer;
      case 'sports_soccer':
        return Icons.sports_soccer;
      default:
        return Icons.article;
    }
  }
  
  /// Kategori adını formatlar
  static String formatCategoryName(String categoryId) {
    return ApiEndpoints.feedNames[categoryId] ?? categoryId;
  }
}