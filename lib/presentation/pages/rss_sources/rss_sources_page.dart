import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/rss_sources_provider.dart';
import '../../themes/app_theme.dart';
import '../../../domain/entities/rss_source.dart';
import 'add_edit_rss_source_page.dart';

/// RSS kaynakları yönetimi sayfası
class RssSourcesPage extends ConsumerStatefulWidget {
  const RssSourcesPage({super.key});

  @override
  ConsumerState<RssSourcesPage> createState() => _RssSourcesPageState();
}

class _RssSourcesPageState extends ConsumerState<RssSourcesPage> {
  String _selectedCategory = 'tümü';
  bool _showOnlyActive = false;

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında kaynakları yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rssSourcesProvider.notifier).loadSources();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sourcesState = ref.watch(rssSourcesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Haber Kaynakları'),
        actions: [
          // Filtre butonu
          IconButton(
            onPressed: () => _showFilterBottomSheet(),
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filtrele',
          ),
          
          // Menü butonu
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset_defaults',
                child: Row(
                  children: [
                    Icon(Icons.restore_rounded),
                    SizedBox(width: 8),
                    Text('Varsayılanlara Sıfırla'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_rounded),
                    SizedBox(width: 8),
                    Text('Tümünü Sil'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(context, sourcesState, theme),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddSource(),
        tooltip: 'Yeni Kaynak Ekle',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  /// Ana içerik
  Widget _buildBody(BuildContext context, RssSourcesState sourcesState, ThemeData theme) {
    // Yükleniyor durumu
    if (sourcesState.isLoading && sourcesState.sources.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('RSS kaynakları yükleniyor...'),
          ],
        ),
      );
    }

    // Hata durumu
    if (sourcesState.hasError && sourcesState.sources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Hata',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              sourcesState.error ?? 'Bilinmeyen hata',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.read(rssSourcesProvider.notifier).loadSources(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    // RSS kaynakları listesi
    return RefreshIndicator(
      onRefresh: () => ref.read(rssSourcesProvider.notifier).loadSources(),
      child: Column(
        children: [
          // İstatistikler
          _buildStatsCard(context, sourcesState, theme),
          
          // Kaynak listesi
          Expanded(
            child: _buildSourcesList(context, sourcesState, theme),
          ),
        ],
      ),
    );
  }

  /// İstatistikler kartı
  Widget _buildStatsCard(BuildContext context, RssSourcesState sourcesState, ThemeData theme) {
    final filteredCount = sourcesState.filteredSources.length;
    final totalCount = sourcesState.sourceCount;
    final activeCount = sourcesState.activeSourceCount;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Toplam kaynak
          Expanded(
            child: _buildStatItem(
              context,
              'Toplam',
              totalCount.toString(),
              Icons.rss_feed_rounded,
              AppTheme.primaryBlue,
            ),
          ),
          
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          
          // Aktif kaynak
          Expanded(
            child: _buildStatItem(
              context,
              'Aktif',
              activeCount.toString(),
              Icons.check_circle_rounded,
              Colors.green,
            ),
          ),
          
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          
          // Filtrelenmiş
          Expanded(
            child: _buildStatItem(
              context,
              'Gösterilen',
              filteredCount.toString(),
              Icons.filter_list_rounded,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  /// İstatistik item'ı
  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  /// Kaynak listesi
  Widget _buildSourcesList(BuildContext context, RssSourcesState sourcesState, ThemeData theme) {
    final filteredSources = sourcesState.filteredSources;

    if (filteredSources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rss_feed_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'RSS Kaynağı Bulunamadı',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _showOnlyActive
                  ? 'Aktif RSS kaynağı bulunamadı'
                  : _selectedCategory != 'tümü'
                      ? '$_selectedCategory kategorisinde RSS kaynağı bulunamadı'
                      : 'Henüz RSS kaynağı eklenmemiş',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddSource(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('İlk Kaynağı Ekle'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredSources.length,
      itemBuilder: (context, index) {
        final source = filteredSources[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildSourceCard(context, source, theme),
        );
      },
    );
  }

  /// Kaynak kartı
  Widget _buildSourceCard(BuildContext context, RssSource source, ThemeData theme) {
    final categoryColor = AppTheme.getCategoryColor(source.category);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToEditSource(source),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık satırı
              Row(
                children: [
                  // Kaynak adı
                  Expanded(
                    child: Text(
                      source.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Aktif/Pasif toggle
                  Switch.adaptive(
                    value: source.isEnabled,
                    onChanged: (value) => _toggleSourceStatus(source.id),
                    activeColor: Colors.green,
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Kategori badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: categoryColor, width: 1),
                ),
                child: Text(
                  source.category.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: categoryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // URL
              Text(
                source.domain,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Alt bilgiler
              Row(
                children: [
                  // Son güncelleme
                  Expanded(
                    child: Text(
                      source.lastFetchStatus,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                  
                  // Makale sayısı
                  if (source.articleCount != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${source.articleCount} haber',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  
                  // Menü butonu
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleSourceAction(value, source),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded),
                            SizedBox(width: 8),
                            Text('Düzenle'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy_rounded),
                            SizedBox(width: 8),
                            Text('Kopyala'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_rounded, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Sil', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Filtre bottom sheet'ini göster
  void _showFilterBottomSheet() {
    final sourcesState = ref.read(rssSourcesProvider);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtreler',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Sadece aktif kaynakları göster
            SwitchListTile(
              title: const Text('Sadece Aktif Kaynaklar'),
              subtitle: const Text('Pasif kaynakları gizle'),
              value: _showOnlyActive,
              onChanged: (value) {
                setState(() {
                  _showOnlyActive = value;
                });
                ref.read(rssSourcesProvider.notifier).setShowOnlyActive(value);
                Navigator.of(context).pop();
              },
            ),
            
            const Divider(),
            
            // Kategori filtresi
            Text(
              'Kategori',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              children: sourcesState.categories.map((category) {
                final isSelected = _selectedCategory == category;
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                    ref.read(rssSourcesProvider.notifier).setSelectedCategory(category);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Kaynak durumunu değiştir
  Future<void> _toggleSourceStatus(String sourceId) async {
    final success = await ref.read(rssSourcesProvider.notifier).toggleSourceStatus(sourceId);
    
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kaynak durumu güncellendi'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Menü aksiyonlarını handle et
  void _handleMenuAction(String action) {
    switch (action) {
      case 'reset_defaults':
        _showResetDefaultsDialog();
        break;
      case 'clear_all':
        _showClearAllDialog();
        break;
    }
  }

  /// Kaynak aksiyonlarını handle et
  void _handleSourceAction(String action, RssSource source) {
    switch (action) {
      case 'edit':
        _navigateToEditSource(source);
        break;
      case 'duplicate':
        _duplicateSource(source);
        break;
      case 'delete':
        _showDeleteSourceDialog(source);
        break;
    }
  }

  /// Yeni kaynak ekleme sayfasına git
  void _navigateToAddSource() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditRssSourcePage(),
      ),
    );
  }

  /// Kaynak düzenleme sayfasına git
  void _navigateToEditSource(RssSource source) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditRssSourcePage(source: source),
      ),
    );
  }

  /// Kaynağı kopyala
  Future<void> _duplicateSource(RssSource source) async {
    final duplicatedSource = await ref.read(rssSourcesProvider.notifier).duplicateSource(source.id);
    
    if (mounted && duplicatedSource != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${source.name} kopyalandı'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Kaynağı sil onayı
  void _showDeleteSourceDialog(RssSource source) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kaynağı Sil'),
        content: Text('${source.name} kaynağını silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteSource(source.id);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Kaynağı sil
  Future<void> _deleteSource(String sourceId) async {
    final success = await ref.read(rssSourcesProvider.notifier).deleteSource(sourceId);
    
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kaynak silindi'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Varsayılanlara sıfırla onayı
  void _showResetDefaultsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Varsayılanlara Sıfırla'),
        content: const Text(
          'Tüm mevcut kaynaklar silinecek ve varsayılan kaynaklar geri yüklenecek. Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetToDefaults();
            },
            child: const Text('Sıfırla', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  /// Varsayılanlara sıfırla
  Future<void> _resetToDefaults() async {
    final success = await ref.read(rssSourcesProvider.notifier).resetToDefaults();
    
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Varsayılan kaynaklar geri yüklendi'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Tümünü sil onayı
  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tümünü Sil'),
        content: const Text('Tüm RSS kaynaklarını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearAllSources();
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Tüm kaynakları temizle
  Future<void> _clearAllSources() async {
    final success = await ref.read(rssSourcesProvider.notifier).clearAllSources();
    
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tüm kaynaklar silindi'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}