import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/services/export_service.dart';
import '../../providers/favorites_provider.dart';
// import '../../providers/reading_history_provider.dart';  // TODO: Create this provider
import '../../providers/reading_list_provider.dart';
// import '../../providers/user_statistics_provider.dart';  // TODO: Create this provider
import '../../providers/analytics_provider.dart';

/// Export/Import sayfası
class ExportImportPage extends ConsumerStatefulWidget {
  const ExportImportPage({super.key});

  @override
  ConsumerState<ExportImportPage> createState() => _ExportImportPageState();
}

class _ExportImportPageState extends ConsumerState<ExportImportPage> {
  final ExportService _exportService = ExportService();
  bool _isExporting = false;
  List<FileSystemEntity> _exportedFiles = [];

  @override
  void initState() {
    super.initState();
    _loadExportedFiles();
  }

  Future<void> _loadExportedFiles() async {
    final files = await _exportService.listExportedFiles();
    if (mounted) {
      setState(() {
        _exportedFiles = files;
      });
    }
  }

  Future<void> _exportData(ExportType type, ExportFormat format) async {
    setState(() => _isExporting = true);

    try {
      ExportResult result;

      switch (type) {
        case ExportType.favorites:
          final favState = ref.read(favoritesProvider);
          result = await _exportService.exportFavorites(
            favorites: favState.articles,
            format: format,
          );
          break;

        case ExportType.readingHistory:
          // TODO: Implement after creating reading_history_provider
          throw UnimplementedError(
            'Reading history export not yet implemented',
          );

        case ExportType.readingList:
          final readingListState = ref.read(readingListProvider);
          result = await _exportService.exportReadingList(
            readingList: readingListState.articles,
            format: format,
          );
          break;

        case ExportType.statistics:
          // TODO: Implement after creating user_statistics_provider
          final analytics = ref.read(analyticsProvider);
          final statsMap = {
            'total_articles_read': analytics.readArticles.length,
            'total_favorites': analytics.favoritedArticles.length,
          };
          result = await _exportService.exportStatistics(
            statistics: statsMap,
            format: format,
          );
          break;

        case ExportType.all:
          final favState = ref.read(favoritesProvider);
          final readingListState = ref.read(readingListProvider);
          final analytics = ref.read(analyticsProvider);
          final statsMap = {
            'total_articles_read': analytics.readArticles.length,
            'total_favorites': analytics.favoritedArticles.length,
          };
          result = await _exportService.exportAll(
            favorites: favState.articles,
            readingHistory: [], // TODO: Add after implementing provider
            readingList: readingListState.articles,
            statistics: statsMap,
          );
          break;
      }

      if (mounted) {
        if (result.success) {
          _showSuccessSnackBar(
            'Dışa aktarma başarılı! ${result.itemCount} öğe kaydedildi.',
            result.filePath!,
          );
          _loadExportedFiles();
        } else {
          _showErrorSnackBar(result.error ?? 'Bilinmeyen hata');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Dışa aktarma hatası: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _showSuccessSnackBar(String message, String filePath) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Paylaş',
          textColor: Colors.white,
          onPressed: () => _exportService.shareExportedFile(filePath),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _showExportDialog(ExportType type) async {
    final typeNames = {
      ExportType.favorites: 'Favoriler',
      ExportType.readingHistory: 'Okuma Geçmişi',
      ExportType.readingList: 'Okuma Listesi',
      ExportType.statistics: 'İstatistikler',
      ExportType.all: 'Tüm Veriler',
    };

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${typeNames[type]} Dışa Aktar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Dışa aktarma formatını seçin:'),
            const SizedBox(height: 16),
            if (type != ExportType.all) ...[
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('CSV'),
                subtitle: const Text('Excel ile uyumlu'),
                onTap: () {
                  Navigator.pop(context);
                  _exportData(type, ExportFormat.csv);
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('JSON'),
              subtitle: const Text('Yapılandırılmış veri'),
              onTap: () {
                Navigator.pop(context);
                _exportData(type, ExportFormat.json);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFile(String filePath) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dosyayı Sil'),
        content: const Text('Bu dosyayı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _exportService.deleteExportedFile(filePath);
      if (success) {
        _loadExportedFiles();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Dosya silindi')));
        }
      }
    }
  }

  Future<void> _clearAllExports() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm Dosyaları Sil'),
        content: const Text(
          'Tüm dışa aktarılmış dosyaları silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Tümünü Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _exportService.clearAllExports();
      if (success) {
        _loadExportedFiles();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Tüm dosyalar silindi')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dışa Aktar'),
        actions: [
          if (_exportedFiles.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Tümünü Sil',
              onPressed: _clearAllExports,
            ),
        ],
      ),
      body: _isExporting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Dışa aktarılıyor...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Export Options
                  Text(
                    'Dışa Aktarma Seçenekleri',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Verilerinizi CSV veya JSON formatında dışa aktarın',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Export Cards
                  _buildExportCard(
                    icon: Icons.favorite,
                    iconColor: Colors.red,
                    title: 'Favoriler',
                    subtitle: 'Favori makalelerinizi dışa aktarın',
                    onTap: () => _showExportDialog(ExportType.favorites),
                  ),
                  const SizedBox(height: 12),

                  _buildExportCard(
                    icon: Icons.history,
                    iconColor: Colors.blue,
                    title: 'Okuma Geçmişi',
                    subtitle: 'Okuduğunuz makalelerin listesi',
                    onTap: () => _showExportDialog(ExportType.readingHistory),
                  ),
                  const SizedBox(height: 12),

                  _buildExportCard(
                    icon: Icons.bookmark,
                    iconColor: Colors.orange,
                    title: 'Okuma Listesi',
                    subtitle: 'Sonra okumak için kaydettiğiniz makaleler',
                    onTap: () => _showExportDialog(ExportType.readingList),
                  ),
                  const SizedBox(height: 12),

                  _buildExportCard(
                    icon: Icons.analytics,
                    iconColor: Colors.purple,
                    title: 'İstatistikler',
                    subtitle: 'Okuma istatistikleriniz ve hedefleriniz',
                    onTap: () => _showExportDialog(ExportType.statistics),
                  ),
                  const SizedBox(height: 12),

                  _buildExportCard(
                    icon: Icons.cloud_download,
                    iconColor: Colors.green,
                    title: 'Tüm Veriler',
                    subtitle: 'Tüm verilerinizi tek dosyada dışa aktarın',
                    onTap: () => _showExportDialog(ExportType.all),
                    highlighted: true,
                  ),

                  const SizedBox(height: 32),

                  // Exported Files
                  if (_exportedFiles.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dışa Aktarılan Dosyalar',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_exportedFiles.length} dosya',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _exportedFiles.length,
                      itemBuilder: (context, index) {
                        final file = _exportedFiles[index];
                        return _buildFileCard(file);
                      },
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildExportCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: highlighted ? 4 : 1,
      color: highlighted ? colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: highlighted
                            ? colorScheme.onPrimaryContainer
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: highlighted
                            ? colorScheme.onPrimaryContainer.withValues(
                                alpha: 0.7,
                              )
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: highlighted
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileCard(FileSystemEntity file) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fileName = file.path.split(Platform.pathSeparator).last;
    final stat = file.statSync();
    final fileSize = _formatFileSize(stat.size);
    final modifiedDate = DateFormat('dd MMM yyyy, HH:mm').format(stat.modified);
    final isJson = fileName.endsWith('.json');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isJson ? Colors.orange : Colors.green).withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isJson ? Icons.code : Icons.table_chart,
            color: isJson ? Colors.orange : Colors.green,
          ),
        ),
        title: Text(
          fileName,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '$fileSize • $modifiedDate',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _exportService.shareExportedFile(file.path),
              tooltip: 'Paylaş',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _deleteFile(file.path),
              tooltip: 'Sil',
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
