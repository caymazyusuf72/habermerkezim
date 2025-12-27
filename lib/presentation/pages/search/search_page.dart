import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/search_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/article_filter_provider.dart';
import '../../themes/app_theme.dart';
import '../../../domain/entities/article.dart';
import '../home/widgets/article_card.dart';
import '../home/widgets/article_filter_dialog.dart';
import '../article_detail/article_detail_page.dart';

/// Arama sayfası - makalelerde arama yapma
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında klavyeyi göster
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// Arama işlemi
  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      ref.read(searchProvider.notifier).searchArticles(query.trim());
      
      // Analytics kaydı - arama yapıldı
      ref.read(analyticsProvider.notifier).recordSearchPerformed();
    }
  }

  /// Arama geçmişinden seç
  void _selectFromHistory(String query) {
    _searchController.text = query;
    _performSearch(query);
  }

  /// Arama geçmişinden sil
  void _removeFromHistory(String query) {
    ref.read(searchProvider.notifier).removeFromSearchHistory(query);
  }

  /// Arama temizle
  void _clearSearch() {
    _searchController.clear();
    ref.read(searchProvider.notifier).clearSearch();
    _searchFocusNode.requestFocus();
  }

  /// Haberi paylaş
  Future<void> _shareArticle(Article article) async {
    try {
      final shareText = '${article.title}\n\n${article.link}';
      await Share.share(
        shareText,
        subject: article.title,
      );
      
      // Analytics kaydı - paylaşım yapıldı
      ref.read(analyticsProvider.notifier).recordSharePerformed();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Haber paylaşıldı'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paylaşım sırasında hata oluştu'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ara'),
        actions: [
          // Filtre butonu
          Consumer(
            builder: (context, ref, child) {
              final filter = ref.watch(articleFilterProvider);
              return IconButton(
                icon: Stack(
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      color: filter.isActive ? AppTheme.sageGreen : null,
                    ),
                    if (filter.isActive)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ArticleFilterDialog(),
                  );
                },
                tooltip: 'Filtrele',
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSearchBar(theme),
          ),
        ),
      ),
      body: _buildBody(context, searchState, theme),
    );
  }

  /// Arama çubuğu
  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Haber ara...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: _performSearch,
        onChanged: (value) {
          setState(() {}); // Suffux icon için rebuild
        },
      ),
    );
  }

  /// Ana içerik
  Widget _buildBody(BuildContext context, SearchState searchState, ThemeData theme) {
    // Yükleniyor durumu
    if (searchState.isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Aranıyor...'),
          ],
        ),
      );
    }

    // Hata durumu
    if (searchState.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Arama Hatası',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              searchState.error ?? 'Bilinmeyen hata',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _performSearch(_searchController.text),
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    // Arama sonuçları var
    if (searchState.hasResults) {
      return _buildSearchResults(searchState.searchResults);
    }

    // Arama yapılmamış - arama geçmişi göster
    if (searchState.searchQuery.isEmpty) {
      return _buildSearchHistory(searchState.searchHistory, theme);
    }

    // Sonuç bulunamadı
    return _buildNoResults(theme);
  }

  /// Arama sonuçları
  Widget _buildSearchResults(List<Article> articles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sonuç sayısı
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '${articles.length} sonuç bulundu',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        
        // Sonuç listesi
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ArticleCard(
                  article: article,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ArticleDetailPage(article: article),
                      ),
                    );
                  },
                  onFavoriteToggle: () {
                    final wasAlreadyFavorite = article.isFavorite;
                    ref.read(favoritesProvider.notifier).toggleFavorite(article);
                    
                    // Analytics kaydı - sadece favori eklendiğinde
                    if (!wasAlreadyFavorite) {
                      ref.read(analyticsProvider.notifier).recordFavoriteAdded();
                    }
                  },
                  onShare: () => _shareArticle(article),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Arama geçmişi
  Widget _buildSearchHistory(List<String> history, ThemeData theme) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Arama Yapmaya Başlayın',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Haber başlıkları, açıklamalar veya kaynaklarda arama yapabilirsiniz',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık ve temizle butonu
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Son Aramalar',
                style: theme.textTheme.titleMedium,
              ),
              TextButton.icon(
                onPressed: () {
                  ref.read(searchProvider.notifier).clearSearchHistory();
                },
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Temizle'),
              ),
            ],
          ),
        ),
        
        // Geçmiş listesi
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final query = history[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(query),
                trailing: IconButton(
                  onPressed: () => _removeFromHistory(query),
                  icon: const Icon(Icons.close),
                  tooltip: 'Geçmişten sil',
                ),
                onTap: () => _selectFromHistory(query),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Sonuç bulunamadı
  Widget _buildNoResults(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Sonuç Bulunamadı',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '"${_searchController.text}" için sonuç bulunamadı',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _clearSearch,
            icon: const Icon(Icons.refresh),
            label: const Text('Yeni Arama'),
          ),
        ],
      ),
    );
  }
}