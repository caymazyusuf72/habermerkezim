import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/services/hive_service.dart';
import '../../../domain/entities/article.dart';
import '../../themes/app_theme.dart';
import '../../widgets/loading/shimmer_loading.dart';
import '../home/widgets/article_card.dart';
import '../article_detail/article_detail_page.dart';

/// Archive sayfası - geçmiş haberler, tarih bazlı filtreleme, arama
class ArchivePage extends ConsumerStatefulWidget {
  const ArchivePage({super.key});

  @override
  ConsumerState<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends ConsumerState<ArchivePage> {
  List<Article> _allArticles = [];
  List<Article> _filteredArticles = [];
  bool _isLoading = true;
  DateTime? _selectedDate;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadArchiveData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadArchiveData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cache'den tüm makaleleri al
      final allArticles = HiveService.articlesBox.values.toList();
      
      final entities = allArticles
          .map((model) => model.toEntity())
          .toList();
      
      // Tarihe göre sırala (en yeni önce)
      entities.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));

      setState(() {
        _allArticles = entities;
        _filteredArticles = entities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Arşiv yüklenirken hata: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredArticles = _allArticles.where((article) {
        // Tarih filtresi
        if (_selectedDate != null) {
          final articleDate = DateTime(
            article.publishedDate.year,
            article.publishedDate.month,
            article.publishedDate.day,
          );
          final selectedDate = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
          );
          if (articleDate != selectedDate) {
            return false;
          }
        }
        
        // Arama filtresi
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          final titleMatch = article.title.toLowerCase().contains(query);
          final descMatch = article.description.toLowerCase().contains(query);
          if (!titleMatch && !descMatch) {
            return false;
          }
        }
        
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arşiv'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filtrele',
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Arşivde ara...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          _applyFilters();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _applyFilters();
              },
            ),
          ),
          
          // Filtre bilgisi
          if (_selectedDate != null || _searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.primaryBlue.withOpacity(0.1),
              child: Row(
                children: [
                  if (_selectedDate != null)
                    Chip(
                      label: Text(
                        DateFormat('dd.MM.yyyy').format(_selectedDate!),
                      ),
                      onDeleted: () {
                        setState(() {
                          _selectedDate = null;
                        });
                        _applyFilters();
                      },
                    ),
                  if (_searchQuery.isNotEmpty) ...[
                    if (_selectedDate != null) const SizedBox(width: 8),
                    Chip(
                      label: Text('Arama: $_searchQuery'),
                      onDeleted: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                        _applyFilters();
                      },
                    ),
                  ],
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      _selectedDate = null;
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                      _applyFilters();
                    },
                    child: const Text('Temizle'),
                  ),
                ],
              ),
            ),
          
          // Haber listesi
          Expanded(
            child: _isLoading
                ? const NewsListShimmer()
                : _filteredArticles.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredArticles.length,
                        itemBuilder: (context, index) {
                          final article = _filteredArticles[index];
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
                                // Favorite toggle logic
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.archive_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Arşiv boş',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Henüz haber yok veya filtreler sonuç vermedi',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tarih Filtresi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tarih Seç'),
              subtitle: Text(
                _selectedDate != null
                    ? DateFormat('dd.MM.yyyy').format(_selectedDate!)
                    : 'Tarih seçilmedi',
              ),
              trailing: const Icon(Icons.calendar_today_rounded),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                  _applyFilters();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedDate = null;
              });
              _applyFilters();
              Navigator.of(context).pop();
            },
            child: const Text('Temizle'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}

