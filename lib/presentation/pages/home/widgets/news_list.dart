import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';

import '../../../providers/providers.dart';
import '../../../providers/connectivity_provider.dart';
import '../../../providers/article_filter_provider.dart';
import '../../../../domain/entities/article.dart';
import '../../../widgets/loading/shimmer_loading.dart';
import '../../article_detail/article_detail_page.dart';
import 'article_card.dart';

/// Haber listesi widget'ı - Pull-to-refresh ve shimmer loading ile
/// Kategoriye göre haberleri listeler
class NewsList extends ConsumerStatefulWidget {
  final String category;
  final Future<void> Function()? onRefresh;

  const NewsList({
    super.key,
    required this.category,
    this.onRefresh,
  });

  @override
  ConsumerState<NewsList> createState() => NewsListState();
}

class NewsListState extends ConsumerState<NewsList>
    with AutomaticKeepAliveClientMixin {

  late RefreshController _refreshController;
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
    
    // Scroll listener ekle
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Scroll olaylarını dinler
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll * 0.8; // %80'e ulaşıldığında yükle
    
    if (currentScroll >= threshold) {
      final newsState = ref.read(newsProvider);
      if (newsState.hasMore && !newsState.isLoadingMore) {
        ref.read(newsProvider.notifier).loadMoreArticles();
      }
    }
  }

  /// Listeyi en üste kaydırır
  void scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  /// Pull-to-refresh callback
  void _onRefresh() async {
    try {
      if (widget.onRefresh != null) {
        await widget.onRefresh!();
      } else {
        await ref.read(newsProvider.notifier).refreshArticles(widget.category);
      }
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  /// Loading callback (sayfa sonunda daha fazla yükle)
  void _onLoading() async {
    final newsState = ref.read(newsProvider);
    if (newsState.hasMore && !newsState.isLoadingMore) {
      try {
        await ref.read(newsProvider.notifier).loadMoreArticles();
        _refreshController.loadComplete();
      } catch (e) {
        _refreshController.loadFailed();
      }
    } else {
      _refreshController.loadNoData();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    // State'leri izle
    final newsState = ref.watch(newsProvider);
    final connectivityState = ref.watch(connectivityProvider);
    final isConnected = connectivityState.isConnected;
    
    // Filtre durumunu al
    final filter = ref.watch(articleFilterProvider);
    
    // Kategoriye göre makaleleri filtrele
    var categoryArticles = newsState.articles
        .where((article) => widget.category == 'genel' || article.category == widget.category)
        .toList();
    
    // Filtreleri uygula
    if (filter.isActive) {
      categoryArticles = categoryArticles.where((article) {
        // Tarih filtresi
        if (filter.startDate != null && article.publishedDate.isBefore(filter.startDate!)) {
          return false;
        }
        if (filter.endDate != null && article.publishedDate.isAfter(filter.endDate!)) {
          return false;
        }
        
        // Kaynak filtresi
        if (filter.selectedSources.isNotEmpty &&
            !filter.selectedSources.contains(article.sourceName)) {
          return false;
        }
        
        // Kategori filtresi
        if (filter.selectedCategories.isNotEmpty &&
            !filter.selectedCategories.contains(article.category)) {
          return false;
        }
        
        // Okunmuş/okunmamış filtresi
        if (filter.isRead != null && article.isRead != filter.isRead) {
          return false;
        }
        
        // Kelime arama filtresi
        if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
          final query = filter.searchQuery!.toLowerCase();
          final titleMatch = article.title.toLowerCase().contains(query);
          final descMatch = article.description.toLowerCase().contains(query);
          final contentMatch = article.content?.toLowerCase().contains(query) ?? false;
          
          if (!titleMatch && !descMatch && !contentMatch) {
            return false;
          }
        }
        
        return true;
      }).toList();
    }

    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: newsState.hasMore,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      
      // Pull-to-refresh header
      header: CustomHeader(
        builder: (context, mode) {
          Widget body;
          
          if (mode == RefreshStatus.idle) {
            body = const Text('Yenilemek için çekin');
          } else if (mode == RefreshStatus.refreshing) {
            body = const CircularProgressIndicator();
          } else if (mode == RefreshStatus.canRefresh) {
            body = const Text('Bırakın ve yenileyin');
          } else if (mode == RefreshStatus.completed) {
            body = const Text('Yenileme tamamlandı');
          } else {
            body = const Text('Yenileme başarısız');
          }
          
          return Container(
            height: 60,
            child: Center(child: body),
          );
        },
      ),
      
      child: _buildContent(context, newsState, categoryArticles, isConnected),
    );
  }

  /// Ana içeriği oluşturur
  Widget _buildContent(
    BuildContext context,
    NewsState newsState,
    List<Article> articles,
    bool isConnected,
  ) {
    // Loading durumu
    if (newsState.isLoading && articles.isEmpty) {
      return const NewsListShimmer();
    }
    
    // Hata durumu (ve cache'de veri yok)
    if (newsState.hasError && articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(newsState.errorMessage ?? 'Bilinmeyen hata'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(newsProvider.notifier).clearError();
                _onRefresh();
              },
              child: Text('Yeniden Dene'),
            ),
            if (!isConnected)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'İnternet bağlantısı yok',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
          ],
        ),
      );
    }
    
    // Boş durum
    if (articles.isEmpty && !newsState.isLoading) {
      return _buildEmptyState(context, isConnected);
    }
    
    // Haber listesi - Gelişmiş lazy loading optimizasyonları
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      // Lazy loading optimizasyonları - PERFORMANS İYİLEŞTİRMELERİ
      addAutomaticKeepAlives: false, // Görünmeyen widget'ları dispose et
      addRepaintBoundaries: true, // Repaint boundary ekle (performans)
      addSemanticIndexes: false, // Semantic index'leri kapat (daha hızlı)
      cacheExtent: 1000, // Cache extent artırıldı (500→1000) - daha smooth scroll
      // Item extent hint - her item'ın yaklaşık boyutu (scroll performansı için)
      itemExtentBuilder: (index, dimensions) {
        // Loading item farklı boyutta
        if (index == articles.length && newsState.isLoadingMore) {
          return 80.0; // Loading indicator boyutu
        }
        // Normal article card boyutu (ortalama)
        return 180.0; // Article card ortalama yüksekliği
      },
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 80, // FAB için alan bırak
      ),
      itemCount: articles.length + (newsState.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading item (en sonda - infinite scroll için)
        if (index == articles.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        
        final article = articles[index];
        
        // Repaint boundary ve key ile widget'ı optimize et
        return RepaintBoundary(
          key: ValueKey(article.id), // Unique key - rebuild optimizasyonu
          child: ArticleCard(
            article: article,
            onTap: () => _onArticleTap(article),
            onFavoriteToggle: () => _onFavoriteToggle(article.id),
            onShare: () => _onShareArticle(article),
            showCategoryBadge: widget.category == 'genel',
          ),
        );
      },
    );
  }

  /// Boş durum widget'ı
  Widget _buildEmptyState(BuildContext context, bool isConnected) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // İkon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isConnected ? Icons.article_rounded : Icons.wifi_off_rounded,
                size: 40,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Başlık
            Text(
              isConnected ? 'Henüz haber yok' : 'İnternet bağlantısı yok',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Açıklama
            Text(
              isConnected
                  ? 'Bu kategoride henüz haber bulunmuyor.'
                  : 'Offline moddasınız. Önbelleğe alınmış haberler gösteriliyor.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Yenile butonu
            ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: Icon(isConnected ? Icons.refresh_rounded : Icons.wifi_rounded),
              label: Text(isConnected ? 'Yenile' : 'Yeniden Dene'),
            ),
          ],
        ),
      ),
    );
  }

  /// Makaleye tıklama olayı
  void _onArticleTap(Article article) {
    // Makaleyi okundu olarak işaretle
    ref.read(newsProvider.notifier).markAsRead(article.id);
    
    // Detay sayfasına git
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArticleDetailPage(article: article),
      ),
    );
  }

  /// Favori toggle olayı
  void _onFavoriteToggle(String articleId) {
    // Makaleyi bul
    final article = ref.read(newsProvider).articles
        .firstWhere((a) => a.id == articleId);
    
    // Favoriler provider'ını kullan
    ref.read(favoritesProvider.notifier).toggleFavorite(article);
    
    // Haptic feedback
    // HapticFeedback.lightImpact();
  }

  /// Makaleyi paylaş
  void _onShareArticle(Article article) {
    final text = '${article.title}\n\n${article.link}';
    Share.share(text, subject: article.title);
    
    // Feedback göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.share, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Haber paylaşıldı'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// News list için utility sınıfı
class NewsListUtils {
  NewsListUtils._();
  
  /// Sayfa başına gösterilecek makale sayısı
  static const int pageSize = 20;
  
  /// Scroll threshold - sayfa sonuna bu kadar yaklaşınca yeni sayfa yükle
  static const double loadMoreThreshold = 200.0;
  
  /// Makale listesini tarihe göre sıralar
  static List<Article> sortArticlesByDate(List<Article> articles, {bool ascending = false}) {
    final sortedList = List<Article>.from(articles);
    sortedList.sort((a, b) {
      return ascending
          ? a.publishedDate.compareTo(b.publishedDate)
          : b.publishedDate.compareTo(a.publishedDate);
    });
    return sortedList;
  }
  
  /// Makale listesini kategoriye göre gruplar
  static Map<String, List<Article>> groupArticlesByCategory(List<Article> articles) {
    final Map<String, List<Article>> grouped = {};
    
    for (final article in articles) {
      if (!grouped.containsKey(article.category)) {
        grouped[article.category] = [];
      }
      grouped[article.category]!.add(article);
    }
    
    return grouped;
  }
  
  /// Scroll position'ını hesaplar
  static double calculateScrollProgress(ScrollController controller) {
    if (!controller.hasClients) return 0.0;
    
    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.position.pixels;
    
    return maxScroll > 0 ? currentScroll / maxScroll : 0.0;
  }
}
