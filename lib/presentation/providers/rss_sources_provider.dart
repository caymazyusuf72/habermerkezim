import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/rss_source.dart';
import '../../core/services/rss_sources_service.dart';

/// RSS kaynakları durumu
class RssSourcesState {
  final List<RssSource> sources;
  final bool isLoading;
  final String? error;
  final String selectedCategory;
  final bool showOnlyActive;

  const RssSourcesState({
    this.sources = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory = 'tümü',
    this.showOnlyActive = false,
  });

  /// Kopya oluştur
  RssSourcesState copyWith({
    List<RssSource>? sources,
    bool? isLoading,
    String? error,
    String? selectedCategory,
    bool? showOnlyActive,
  }) {
    return RssSourcesState(
      sources: sources ?? this.sources,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      showOnlyActive: showOnlyActive ?? this.showOnlyActive,
    );
  }

  /// Hata durumu
  bool get hasError => error != null;

  /// Kaynak sayısı
  int get sourceCount => sources.length;

  /// Aktif kaynak sayısı
  int get activeSourceCount => sources.where((s) => s.isEnabled).length;

  /// Filtrelenmiş kaynaklar
  List<RssSource> get filteredSources {
    var filtered = sources;

    // Sadece aktif kaynaklarayı göster filtresi
    if (showOnlyActive) {
      filtered = filtered.where((s) => s.isEnabled).toList();
    }

    // Kategori filtresi
    if (selectedCategory != 'tümü') {
      filtered = filtered.where((s) => s.category == selectedCategory).toList();
    }

    return filtered;
  }

  /// Kategorilerin listesi
  List<String> get categories {
    final cats = <String>{'tümü'};
    for (final source in sources) {
      cats.add(source.category);
    }
    return cats.toList()..sort();
  }

  /// Kategoriye göre kaynak sayıları
  Map<String, int> get sourcesPerCategory {
    final counts = <String, int>{'tümü': sources.length};
    
    for (final source in sources) {
      counts[source.category] = (counts[source.category] ?? 0) + 1;
    }
    
    return counts;
  }
}

/// RSS kaynakları provider
class RssSourcesNotifier extends StateNotifier<RssSourcesState> {
  RssSourcesNotifier() : super(const RssSourcesState()) {
    loadSources();
  }

  /// Kaynakları yükle
  Future<void> loadSources() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final sources = RssSourcesService.getAllSources();
      state = state.copyWith(
        sources: sources,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Kaynaklar yüklenirken hata oluştu: $e',
      );
    }
  }

  /// Yeni kaynak ekle
  Future<bool> addSource(RssSource source) async {
    try {
      final success = await RssSourcesService.addSource(source);
      if (success) {
        await loadSources(); // Listeyi güncelle
      }
      return success;
    } catch (e) {
      state = state.copyWith(error: 'Kaynak eklenirken hata oluştu: $e');
      return false;
    }
  }

  /// Kaynağı güncelle
  Future<bool> updateSource(RssSource source) async {
    try {
      final success = await RssSourcesService.updateSource(source);
      if (success) {
        await loadSources(); // Listeyi güncelle
      }
      return success;
    } catch (e) {
      state = state.copyWith(error: 'Kaynak güncellenirken hata oluştu: $e');
      return false;
    }
  }

  /// Kaynağı sil
  Future<bool> deleteSource(String sourceId) async {
    try {
      final success = await RssSourcesService.deleteSource(sourceId);
      if (success) {
        await loadSources(); // Listeyi güncelle
      }
      return success;
    } catch (e) {
      state = state.copyWith(error: 'Kaynak silinirken hata oluştu: $e');
      return false;
    }
  }

  /// Kaynak durumunu değiştir (aktif/pasif)
  Future<bool> toggleSourceStatus(String sourceId) async {
    try {
      final success = await RssSourcesService.toggleSourceStatus(sourceId);
      if (success) {
        await loadSources(); // Listeyi güncelle
      }
      return success;
    } catch (e) {
      state = state.copyWith(error: 'Kaynak durumu değiştirilirken hata oluştu: $e');
      return false;
    }
  }

  /// Kaynağı kopyala
  Future<RssSource?> duplicateSource(String sourceId) async {
    try {
      final duplicatedSource = await RssSourcesService.duplicateSource(sourceId);
      if (duplicatedSource != null) {
        await loadSources(); // Listeyi güncelle
      }
      return duplicatedSource;
    } catch (e) {
      state = state.copyWith(error: 'Kaynak kopyalanırken hata oluştu: $e');
      return null;
    }
  }

  /// Varsayılan kaynaklara sıfırla
  Future<bool> resetToDefaults() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await RssSourcesService.resetToDefaults();
      if (success) {
        await loadSources();
      }
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Varsayılan kaynaklara sıfırlanırken hata oluştu: $e',
      );
      return false;
    }
  }

  /// Tüm kaynakları temizle
  Future<bool> clearAllSources() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await RssSourcesService.clearAllSources();
      if (success) {
        await loadSources();
      }
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Kaynaklar temizlenirken hata oluştu: $e',
      );
      return false;
    }
  }

  /// Kategori filtresini değiştir
  void setSelectedCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// Sadece aktif kaynakları göster filtresini değiştir
  void setShowOnlyActive(bool showOnlyActive) {
    state = state.copyWith(showOnlyActive: showOnlyActive);
  }

  /// Hatayı temizle
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Kaynağın son güncelleme tarihini güncelle
  Future<bool> updateLastFetchedTime(String sourceId, {int? articleCount}) async {
    try {
      final success = await RssSourcesService.updateLastFetchedTime(
        sourceId, 
        articleCount: articleCount,
      );
      if (success) {
        // Sadece ilgili kaynağı güncelle (tam yeniden yükleme yapmadan)
        final sources = List<RssSource>.from(state.sources);
        final index = sources.indexWhere((s) => s.id == sourceId);
        if (index != -1) {
          final updatedSource = sources[index].copyWith(
            lastFetchedAt: DateTime.now(),
            articleCount: articleCount ?? sources[index].articleCount,
          );
          sources[index] = updatedSource;
          state = state.copyWith(sources: sources);
        }
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// ID'ye göre kaynak al
  RssSource? getSourceById(String id) {
    try {
      return state.sources.firstWhere((source) => source.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Aktif kaynakları al
  List<RssSource> getActiveSources() {
    return state.sources.where((s) => s.isEnabled).toList();
  }

  /// Kategoriye göre aktif kaynakları al
  List<RssSource> getActiveSourcesByCategory(String category) {
    return getActiveSources().where((s) => s.category == category).toList();
  }

  /// Yeni kaynak için benzersiz ID oluştur
  String generateUniqueId(String name) {
    return RssSourcesService.generateUniqueId(name);
  }

  /// RSS URL doğrulaması
  bool isValidRssUrl(String url) {
    return RssSourcesService.isValidRssUrl(url);
  }

  /// URL'den başlık tahmin et
  String predictTitleFromUrl(String url) {
    return RssSourcesHelper.predictTitleFromUrl(url);
  }

  /// URL'den kategori tahmin et
  String predictCategoryFromUrl(String url) {
    return RssSourcesHelper.predictCategoryFromUrl(url);
  }

  /// RSS kaynağını doğrula
  Map<String, String?> validateRssSource({
    required String name,
    required String url,
    required String category,
  }) {
    return RssSourcesHelper.validateRssSource(
      name: name,
      url: url,
      category: category,
    );
  }

  /// Yeni kaynak oluştur
  RssSource createNewSource({
    required String name,
    required String url,
    required String category,
    String description = '',
    String? iconUrl,
  }) {
    return RssSource(
      id: generateUniqueId(name),
      name: name.trim(),
      url: url.trim(),
      category: category.trim(),
      description: description.trim(),
      createdAt: DateTime.now(),
      iconUrl: iconUrl?.trim(),
    );
  }
}

/// RSS kaynakları provider
final rssSourcesProvider = StateNotifierProvider<RssSourcesNotifier, RssSourcesState>((ref) {
  return RssSourcesNotifier();
});

/// Aktif RSS kaynaklarını al
final activeRssSourcesProvider = Provider<List<RssSource>>((ref) {
  final state = ref.watch(rssSourcesProvider);
  return state.sources.where((source) => source.isEnabled).toList();
});

/// Kategoriye göre aktif RSS kaynaklarını al
final activeRssSourcesByCategoryProvider = Provider.family<List<RssSource>, String>((ref, category) {
  final sources = ref.watch(activeRssSourcesProvider);
  if (category == 'genel' || category == 'tümü') {
    return sources;
  }
  return sources.where((source) => source.category == category).toList();
});

/// RSS kaynak kategorileri provider
final rssSourceCategoriesProvider = Provider<List<String>>((ref) {
  final state = ref.watch(rssSourcesProvider);
  return state.categories;
});

/// RSS kaynak istatistikleri provider
final rssSourceStatsProvider = Provider<Map<String, int>>((ref) {
  final state = ref.watch(rssSourcesProvider);
  return {
    'toplam': state.sourceCount,
    'aktif': state.activeSourceCount,
    'pasif': state.sourceCount - state.activeSourceCount,
  };
});