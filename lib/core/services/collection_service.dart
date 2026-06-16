import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/article.dart';
import '../../data/models/article_model.dart';

/// Koleksiyon modeli
class ArticleCollection {
  final String id;
  final String name;
  final String? description;
  final String? coverImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> articleIds;
  final bool isDefault;

  const ArticleCollection({
    required this.id,
    required this.name,
    this.description,
    this.coverImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.articleIds = const [],
    this.isDefault = false,
  });

  int get articleCount => articleIds.length;

  ArticleCollection copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? articleIds,
    bool? isDefault,
  }) {
    return ArticleCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      articleIds: articleIds ?? this.articleIds,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'coverImageUrl': coverImageUrl,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'articleIds': articleIds,
    'isDefault': isDefault,
  };

  factory ArticleCollection.fromJson(Map<String, dynamic> json) {
    return ArticleCollection(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      coverImageUrl: json['coverImageUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      articleIds: List<String>.from(json['articleIds'] ?? []),
      isDefault: json['isDefault'] ?? false,
    );
  }
}

/// Haber Koleksiyonlari Servisi
/// Ozel koleksiyonlar olusturma, haberleri ekleme/cikarma
class CollectionService {
  static final CollectionService _instance = CollectionService._internal();
  factory CollectionService() => _instance;
  CollectionService._internal();

  static const String _collectionsBoxName = 'article_collections';
  static const String _collectionArticlesBoxName = 'collection_articles';

  // Default koleksiyon ID'leri
  static const String favoritesCollectionId = 'default_favorites';
  static const String readLaterCollectionId = 'default_read_later';

  Box<dynamic>? _collectionsBox;
  Box<ArticleModel>? _articlesBox;

  /// Servisi baslat
  Future<void> initialize() async {
    try {
      if (!Hive.isBoxOpen(_collectionsBoxName)) {
        _collectionsBox = await Hive.openBox<dynamic>(_collectionsBoxName);
      } else {
        _collectionsBox = Hive.box<dynamic>(_collectionsBoxName);
      }

      if (!Hive.isBoxOpen(_collectionArticlesBoxName)) {
        _articlesBox = await Hive.openBox<ArticleModel>(_collectionArticlesBoxName);
      } else {
        _articlesBox = Hive.box<ArticleModel>(_collectionArticlesBoxName);
      }

      // Default koleksiyonlari olustur
      await _ensureDefaultCollections();

      debugPrint('CollectionService initialized');
    } catch (e) {
      debugPrint('CollectionService initialization error: $e');
    }
  }

  Box<dynamic> get _collections {
    if (_collectionsBox == null || !_collectionsBox!.isOpen) {
      throw StateError('CollectionService initialize edilmemis!');
    }
    return _collectionsBox!;
  }

  Box<ArticleModel> get _articles {
    if (_articlesBox == null || !_articlesBox!.isOpen) {
      throw StateError('CollectionService initialize edilmemis!');
    }
    return _articlesBox!;
  }

  /// Default koleksiyonlari olustur
  Future<void> _ensureDefaultCollections() async {
    if (!_collections.containsKey(favoritesCollectionId)) {
      final favorites = ArticleCollection(
        id: favoritesCollectionId,
        name: 'Favoriler',
        description: 'Favori haberleriniz',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDefault: true,
      );
      await _collections.put(favoritesCollectionId, jsonEncode(favorites.toJson()));
    }

    if (!_collections.containsKey(readLaterCollectionId)) {
      final readLater = ArticleCollection(
        id: readLaterCollectionId,
        name: 'Sonra Oku',
        description: 'Daha sonra okumak istediginiz haberler',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDefault: true,
      );
      await _collections.put(readLaterCollectionId, jsonEncode(readLater.toJson()));
    }
  }

  // ─── Koleksiyon CRUD ──────────────────────────────────────────────────────

  /// Yeni koleksiyon olustur
  Future<ArticleCollection> createCollection({
    required String name,
    String? description,
  }) async {
    final id = 'col_${DateTime.now().millisecondsSinceEpoch}';
    final collection = ArticleCollection(
      id: id,
      name: name,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDefault: false,
    );

    await _collections.put(id, jsonEncode(collection.toJson()));
    debugPrint('Koleksiyon olusturuldu: $name');
    return collection;
  }

  /// Koleksiyonu guncelle
  Future<void> updateCollection(ArticleCollection collection) async {
    final updated = collection.copyWith(updatedAt: DateTime.now());
    await _collections.put(collection.id, jsonEncode(updated.toJson()));
  }

  /// Koleksiyonu sil (default koleksiyonlar silinemez)
  Future<bool> deleteCollection(String collectionId) async {
    final collection = getCollection(collectionId);
    if (collection == null || collection.isDefault) {
      return false;
    }

    // Koleksiyondaki makale referanslarini temizle
    await _collections.delete(collectionId);
    debugPrint('Koleksiyon silindi: $collectionId');
    return true;
  }

  /// Koleksiyonu getir
  ArticleCollection? getCollection(String collectionId) {
    try {
      final data = _collections.get(collectionId);
      if (data is String && data.isNotEmpty) {
        return ArticleCollection.fromJson(
          Map<String, dynamic>.from(jsonDecode(data)),
        );
      }
      return null;
    } catch (e) {
      debugPrint('Koleksiyon getirme hatasi: $e');
      return null;
    }
  }

  /// Tum koleksiyonlari listele
  List<ArticleCollection> getAllCollections() {
    try {
      final collections = <ArticleCollection>[];
      for (final key in _collections.keys) {
        final data = _collections.get(key);
        if (data is String && data.isNotEmpty) {
          try {
            collections.add(ArticleCollection.fromJson(
              Map<String, dynamic>.from(jsonDecode(data)),
            ));
          } catch (_) {}
        }
      }

      // Default koleksiyonlar basta, sonra tarihe gore sirala
      collections.sort((a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });

      return collections;
    } catch (e) {
      debugPrint('Koleksiyonlari listeleme hatasi: $e');
      return [];
    }
  }

  // ─── Haber Ekleme/Cikarma ────────────────────────────────────────────────

  /// Haberi koleksiyona ekle
  Future<bool> addArticleToCollection(String collectionId, Article article) async {
    try {
      final collection = getCollection(collectionId);
      if (collection == null) return false;

      // Zaten ekliyse atla
      if (collection.articleIds.contains(article.id)) return true;

      // Makaleyi kaydet
      final model = ArticleModel.fromEntity(article);
      await _articles.put(article.id, model);

      // Koleksiyonu guncelle
      final newArticleIds = List<String>.from(collection.articleIds)..add(article.id);
      final coverUrl = collection.coverImageUrl ?? article.imageUrl;
      final updated = collection.copyWith(
        articleIds: newArticleIds,
        coverImageUrl: coverUrl,
        updatedAt: DateTime.now(),
      );
      await _collections.put(collectionId, jsonEncode(updated.toJson()));

      debugPrint('Haber koleksiyona eklendi: ${article.id} -> $collectionId');
      return true;
    } catch (e) {
      debugPrint('Haber ekleme hatasi: $e');
      return false;
    }
  }

  /// Haberi koleksiyondan cikar
  Future<bool> removeArticleFromCollection(String collectionId, String articleId) async {
    try {
      final collection = getCollection(collectionId);
      if (collection == null) return false;

      final newArticleIds = List<String>.from(collection.articleIds)..remove(articleId);
      final updated = collection.copyWith(
        articleIds: newArticleIds,
        updatedAt: DateTime.now(),
      );
      await _collections.put(collectionId, jsonEncode(updated.toJson()));

      debugPrint('Haber koleksiyondan cikarildi: $articleId <- $collectionId');
      return true;
    } catch (e) {
      debugPrint('Haber cikarma hatasi: $e');
      return false;
    }
  }

  /// Haber koleksiyonda mi kontrol et
  bool isArticleInCollection(String collectionId, String articleId) {
    final collection = getCollection(collectionId);
    return collection?.articleIds.contains(articleId) ?? false;
  }

  /// Koleksiyondaki haberleri getir
  List<Article> getCollectionArticles(String collectionId) {
    try {
      final collection = getCollection(collectionId);
      if (collection == null) return [];

      final articles = <Article>[];
      for (final articleId in collection.articleIds) {
        final model = _articles.get(articleId);
        if (model != null) {
          articles.add(model.toEntity());
        }
      }
      return articles;
    } catch (e) {
      debugPrint('Koleksiyon haberleri getirme hatasi: $e');
      return [];
    }
  }

  /// Koleksiyon sayisi
  int get collectionCount => _collections.length;
}

// ─── Riverpod Provider'lari ─────────────────────────────────────────────────

/// CollectionService provider
final collectionServiceProvider = Provider<CollectionService>((ref) {
  return CollectionService();
});

/// Tum koleksiyonlar provider
final collectionsProvider = StateNotifierProvider<CollectionsNotifier, List<ArticleCollection>>((ref) {
  final service = ref.watch(collectionServiceProvider);
  return CollectionsNotifier(service);
});

/// Koleksiyon detay provider
final collectionArticlesProvider = Provider.family<List<Article>, String>((ref, collectionId) {
  final service = ref.watch(collectionServiceProvider);
  return service.getCollectionArticles(collectionId);
});

/// Collections StateNotifier
class CollectionsNotifier extends StateNotifier<List<ArticleCollection>> {
  final CollectionService _service;

  CollectionsNotifier(this._service) : super([]) {
    _loadCollections();
  }

  void _loadCollections() {
    state = _service.getAllCollections();
  }

  Future<ArticleCollection> createCollection({
    required String name,
    String? description,
  }) async {
    final collection = await _service.createCollection(
      name: name,
      description: description,
    );
    _loadCollections();
    return collection;
  }

  Future<void> updateCollection(ArticleCollection collection) async {
    await _service.updateCollection(collection);
    _loadCollections();
  }

  Future<bool> deleteCollection(String collectionId) async {
    final result = await _service.deleteCollection(collectionId);
    if (result) _loadCollections();
    return result;
  }

  Future<bool> addArticle(String collectionId, Article article) async {
    final result = await _service.addArticleToCollection(collectionId, article);
    if (result) _loadCollections();
    return result;
  }

  Future<bool> removeArticle(String collectionId, String articleId) async {
    final result = await _service.removeArticleFromCollection(collectionId, articleId);
    if (result) _loadCollections();
    return result;
  }

  void refresh() {
    _loadCollections();
  }
}