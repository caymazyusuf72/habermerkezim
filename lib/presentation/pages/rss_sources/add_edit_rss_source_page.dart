import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/rss_sources_provider.dart';
import '../../themes/app_theme.dart';
import '../../../domain/entities/rss_source.dart';

/// RSS kaynağı ekleme/düzenleme sayfası
class AddEditRssSourcePage extends ConsumerStatefulWidget {
  final RssSource? source; // Null ise yeni kaynak, değilse düzenleme

  const AddEditRssSourcePage({super.key, this.source});

  @override
  ConsumerState<AddEditRssSourcePage> createState() => _AddEditRssSourcePageState();
}

class _AddEditRssSourcePageState extends ConsumerState<AddEditRssSourcePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = 'genel';
  bool _isEnabled = true;
  bool _isLoading = false;
  
  /// Düzenleme modu mu?
  bool get isEditing => widget.source != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Formu başlat
  void _initializeForm() {
    if (isEditing) {
      final source = widget.source!;
      _nameController.text = source.name;
      _urlController.text = source.url;
      _descriptionController.text = source.description;
      _selectedCategory = source.category;
      _isEnabled = source.isEnabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Kaynağı Düzenle' : 'Yeni Kaynak Ekle'),
        actions: [
          // Kaydet butonu
          TextButton(
            onPressed: _isLoading ? null : _saveSource,
            child: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Kaydet'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Kaynak adı
            _buildNameField(),
            const SizedBox(height: 16),
            
            // RSS URL
            _buildUrlField(),
            const SizedBox(height: 16),
            
            // Kategori seçimi
            _buildCategoryField(),
            const SizedBox(height: 16),
            
            // Açıklama
            _buildDescriptionField(),
            const SizedBox(height: 16),
            
            // Aktif/Pasif durumu
            _buildEnabledSwitch(theme),
            const SizedBox(height: 24),
            
            // URL test butonu
            _buildTestUrlButton(theme),
            const SizedBox(height: 24),
            
            // Kaydet butonu (alt)
            _buildSaveButton(theme),
            
            if (isEditing) ...[
              const SizedBox(height: 16),
              _buildDeleteButton(theme),
            ],
          ],
        ),
      ),
    );
  }

  /// Kaynak adı alanı
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Kaynak Adı *',
        hintText: 'Örn: CNN Türk',
        prefixIcon: Icon(Icons.label_rounded),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Kaynak adı boş olamaz';
        }
        if (value.trim().length < 2) {
          return 'Kaynak adı en az 2 karakter olmalı';
        }
        if (value.trim().length > 50) {
          return 'Kaynak adı en fazla 50 karakter olmalı';
        }
        return null;
      },
      onChanged: (value) {
        // URL boşsa, isimden otomatik tahmin et
        if (_urlController.text.isEmpty && value.isNotEmpty) {
          // Bu sadece kullanıcı deneyimi için
        }
      },
    );
  }

  /// RSS URL alanı
  Widget _buildUrlField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _urlController,
          decoration: const InputDecoration(
            labelText: 'RSS URL *',
            hintText: 'https://example.com/rss.xml',
            prefixIcon: Icon(Icons.rss_feed_rounded),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'RSS URL boş olamaz';
            }
            if (!ref.read(rssSourcesProvider.notifier).isValidRssUrl(value.trim())) {
              return 'Geçersiz URL formatı';
            }
            return null;
          },
          onChanged: (value) {
            if (value.isNotEmpty) {
              // URL'den otomatik tahmin yap
              if (_nameController.text.isEmpty) {
                final predictedName = ref.read(rssSourcesProvider.notifier).predictTitleFromUrl(value);
                _nameController.text = predictedName;
              }
              
              final predictedCategory = ref.read(rssSourcesProvider.notifier).predictCategoryFromUrl(value);
              if (predictedCategory != 'genel') {
                setState(() {
                  _selectedCategory = predictedCategory;
                });
              }
            }
          },
        ),
        const SizedBox(height: 4),
        Text(
          'RSS feed URL\'sini girin (örn: .../rss.xml, .../feed, .../rss)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  /// Kategori seçimi alanı
  Widget _buildCategoryField() {
    final categories = [
      'genel',
      'teknoloji',
      'ekonomi',
      'spor',
      'sağlık',
      'eğitim',
      'kültür',
      'sanat',
    ];

    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Kategori *',
        prefixIcon: Icon(Icons.category_rounded),
        border: OutlineInputBorder(),
      ),
      items: categories.map((category) {
        final color = AppTheme.getCategoryColor(category);
        return DropdownMenuItem(
          value: category,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(category.toUpperCase()),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedCategory = value;
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Kategori seçilmelidir';
        }
        return null;
      },
    );
  }

  /// Açıklama alanı
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Açıklama',
        hintText: 'Bu RSS kaynağı hakkında kısa açıklama...',
        prefixIcon: Icon(Icons.description_rounded),
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      maxLength: 200,
    );
  }

  /// Aktif/Pasif durumu
  Widget _buildEnabledSwitch(ThemeData theme) {
    return Card(
      child: SwitchListTile(
        title: const Text('Kaynağı Aktif Et'),
        subtitle: Text(
          _isEnabled 
              ? 'Bu kaynak haberler güncellenirken kullanılacak'
              : 'Bu kaynak haberler güncellenirken kullanılmayacak',
        ),
        value: _isEnabled,
        onChanged: (value) {
          setState(() {
            _isEnabled = value;
          });
        },
        secondary: Icon(
          _isEnabled ? Icons.check_circle_rounded : Icons.cancel_rounded,
          color: _isEnabled ? Colors.green : Colors.orange,
        ),
      ),
    );
  }

  /// URL test butonu
  Widget _buildTestUrlButton(ThemeData theme) {
    return OutlinedButton.icon(
      onPressed: _testUrl,
      icon: const Icon(Icons.link_rounded),
      label: const Text('URL\'yi Test Et'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  /// Kaydet butonu
  Widget _buildSaveButton(ThemeData theme) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _saveSource,
      icon: _isLoading 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(isEditing ? Icons.save_rounded : Icons.add_rounded),
      label: Text(isEditing ? 'Değişiklikleri Kaydet' : 'Kaynağı Ekle'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  /// Sil butonu (sadece düzenleme modunda)
  Widget _buildDeleteButton(ThemeData theme) {
    return OutlinedButton.icon(
      onPressed: _showDeleteDialog,
      icon: const Icon(Icons.delete_rounded, color: Colors.red),
      label: const Text('Kaynağı Sil', style: TextStyle(color: Colors.red)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: Colors.red),
      ),
    );
  }

  /// URL test et
  void _testUrl() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showSnackBar('URL boş olamaz', isError: true);
      return;
    }

    if (!ref.read(rssSourcesProvider.notifier).isValidRssUrl(url)) {
      _showSnackBar('Geçersiz URL formatı', isError: true);
      return;
    }

    // Basit test - URL formatının doğru olup olmadığını kontrol et
    try {
      final uri = Uri.parse(url);
      if (uri.hasScheme && uri.hasAuthority) {
        _showSnackBar('URL formatı geçerli görünüyor ✓', isError: false);
        
        // URL'den otomatik tahminler yap
        if (_nameController.text.isEmpty) {
          final predictedName = ref.read(rssSourcesProvider.notifier).predictTitleFromUrl(url);
          _nameController.text = predictedName;
        }
        
        final predictedCategory = ref.read(rssSourcesProvider.notifier).predictCategoryFromUrl(url);
        if (predictedCategory != 'genel' && _selectedCategory == 'genel') {
          setState(() {
            _selectedCategory = predictedCategory;
          });
          _showSnackBar('Kategori otomatik olarak "$predictedCategory" seçildi', isError: false);
        }
      } else {
        _showSnackBar('URL formatı eksik veya hatalı', isError: true);
      }
    } catch (e) {
      _showSnackBar('URL test edilemedi: $e', isError: true);
    }
  }

  /// Kaynağı kaydet
  Future<void> _saveSource() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final source = RssSource(
        id: isEditing ? widget.source!.id : ref.read(rssSourcesProvider.notifier).generateUniqueId(_nameController.text.trim()),
        name: _nameController.text.trim(),
        url: _urlController.text.trim(),
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        isEnabled: _isEnabled,
        createdAt: isEditing ? widget.source!.createdAt : DateTime.now(),
        lastFetchedAt: isEditing ? widget.source!.lastFetchedAt : null,
        articleCount: isEditing ? widget.source!.articleCount : null,
      );

      bool success;
      if (isEditing) {
        success = await ref.read(rssSourcesProvider.notifier).updateSource(source);
      } else {
        success = await ref.read(rssSourcesProvider.notifier).addSource(source);
      }

      if (success) {
        if (mounted) {
          _showSnackBar(
            isEditing ? 'Kaynak güncellendi' : 'Kaynak eklendi',
            isError: false,
          );
          Navigator.of(context).pop();
        }
      } else {
        _showSnackBar(
          isEditing ? 'Kaynak güncellenirken hata oluştu' : 'Kaynak eklenirken hata oluştu',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('Hata: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Silme onayı dialog'u göster
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kaynağı Sil'),
        content: Text('${widget.source!.name} kaynağını silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteSource();
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Kaynağı sil
  Future<void> _deleteSource() async {
    if (!isEditing) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ref.read(rssSourcesProvider.notifier).deleteSource(widget.source!.id);
      
      if (success && mounted) {
        _showSnackBar('Kaynak silindi', isError: false);
        Navigator.of(context).pop();
      } else {
        _showSnackBar('Kaynak silinirken hata oluştu', isError: true);
      }
    } catch (e) {
      _showSnackBar('Hata: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// SnackBar göster
  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}