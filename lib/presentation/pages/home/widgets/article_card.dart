import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../domain/entities/article.dart';
import '../../../themes/app_theme.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/reading_list_provider.dart';

/// Haber kartı widget'ı - her bir haberi gösteren kart
/// Görsel, başlık, özet, tarih ve kategori bilgilerini içerir
class ArticleCard extends ConsumerWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback? onShare;
  final bool showCategoryBadge;
  final bool isCompact;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    required this.onFavoriteToggle,
    this.onShare,
    this.showCategoryBadge = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return isCompact ? _buildCompactCard(context, ref) : _buildFullCard(context, ref);
  }

  /// Tam boyutlu kart
  Widget _buildFullCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoryColor = AppTheme.getCategoryColor(article.category);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Görsel ve kategori badge'i
            if (article.imageUrl != null) _buildImageSection(context, ref, categoryColor),
            
            // İçerik
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori badge (görsel yoksa)
                  if (article.imageUrl == null && showCategoryBadge)
                    _buildCategoryBadge(context, categoryColor),
                  
                  const SizedBox(height: 8),
                  
                  // Başlık
                  Text(
                    article.truncatedTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: article.isRead
                          ? theme.colorScheme.onSurface.withOpacity(0.7)
                          : theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Özet
                  Text(
                    article.truncatedDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Alt bilgiler
                  _buildFooter(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kompakt kart (liste görünümü için)
  Widget _buildCompactCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoryColor = AppTheme.getCategoryColor(article.category);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Küçük görsel
              if (article.imageUrl != null)
                _buildCompactImage(context),
              
              // İçerik
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategori badge
                    if (showCategoryBadge)
                      _buildCategoryBadge(context, categoryColor),
                    
                    const SizedBox(height: 4),
                    
                    // Başlık
                    Text(
                      article.truncatedTitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: article.isRead
                            ? theme.colorScheme.onSurface.withOpacity(0.7)
                            : theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Alt bilgiler
                    _buildCompactFooter(context),
                  ],
                ),
              ),
              
              // Action butonları
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildShareButton(context),
                  const SizedBox(height: 4),
                  _buildReadingListButton(context, ref),
                  const SizedBox(height: 4),
                  _buildFavoriteButton(context, ref),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Görsel bölümü
  Widget _buildImageSection(BuildContext context, WidgetRef ref, Color categoryColor) {
    return Stack(
      children: [
        // Ana görsel
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl: article.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Icon(
                  Icons.image_not_supported_rounded,
                  size: 40,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
        
        // Kategori badge (görsel üstünde)
        if (showCategoryBadge)
          Positioned(
            top: 12,
            left: 12,
            child: _buildCategoryBadge(context, categoryColor),
          ),
        
        // Action butonları (görsel üstünde)
        Positioned(
          top: 12,
          right: 12,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildShareButton(context),
              const SizedBox(width: 8),
              _buildFavoriteButton(context, ref),
            ],
          ),
        ),
        
        // Okundu göstergesi
        if (article.isRead)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Kompakt görsel
  Widget _buildCompactImage(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: article.imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: const Icon(Icons.image_rounded, size: 20),
          ),
          errorWidget: (context, url, error) => Container(
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: const Icon(Icons.image_not_supported_rounded, size: 20),
          ),
        ),
      ),
    );
  }

  /// Kategori badge'i
  Widget _buildCategoryBadge(BuildContext context, Color categoryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.1),
        border: Border.all(color: categoryColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        article.sourceName,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: categoryColor,
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
      ),
    );
  }

  /// Okuma listesi butonu
  Widget _buildReadingListButton(BuildContext context, WidgetRef ref) {
    // Okuma listesi durumunu provider'dan al
    final isInReadingList = ref.watch(isInReadingListProvider(article.id));
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () {
          ref.read(readingListProvider.notifier).toggleReadingList(article);
        },
        icon: Icon(
          isInReadingList ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          color: isInReadingList ? AppTheme.primaryBlue : Theme.of(context).colorScheme.onSurface,
          size: 20,
        ),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        padding: EdgeInsets.zero,
        tooltip: isInReadingList ? 'Okuma listesinden çıkar' : 'Okuma listesine ekle',
      ),
    );
  }

  /// Favori butonu
  Widget _buildFavoriteButton(BuildContext context, WidgetRef ref) {
    // Favori durumunu provider'dan al
    final isFavorite = ref.watch(isFavoriteProvider(article.id));
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onFavoriteToggle,
        icon: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFavorite ? Colors.red : Theme.of(context).colorScheme.onSurface,
          size: 20,
        ),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// Paylaş butonu
  Widget _buildShareButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onShare ?? () => _shareArticle(context),
        icon: Icon(
          Icons.share_rounded,
          color: Theme.of(context).colorScheme.onSurface,
          size: 20,
        ),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        padding: EdgeInsets.zero,
        tooltip: 'Paylaş',
      ),
    );
  }


  /// Makaleyi paylaş
  void _shareArticle(BuildContext context) {
    final text = '${article.title}\n\n${article.link}';
    Share.share(
      text,
      subject: article.title,
    );
    
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

  /// Alt bilgiler (tam kart için)
  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        // Kaynak ve tarih
        Expanded(
          flex: 3,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  article.shortDateTime,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.source_rounded,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  article.sourceName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        
        // Okundu göstergesi
        if (article.isRead) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Okundu',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Alt bilgiler (kompakt kart için)
  Widget _buildCompactFooter(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            article.shortDateTime,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (article.isRead) ...[
          const SizedBox(width: 8),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }
}

/// Article Card için utility sınıfı
class ArticleCardUtils {
  ArticleCardUtils._();
  
  /// Görsel aspect ratio
  static const double imageAspectRatio = 16 / 9;
  
  /// Kompakt görsel boyutu
  static const double compactImageSize = 60.0;
  
  /// Maksimum başlık satır sayısı
  static const int maxTitleLines = 2;
  
  /// Maksimum özet satır sayısı
  static const int maxDescriptionLines = 3;
  
  /// Kart yüksekliği hesaplar (tahmin)
  static double estimateCardHeight({
    required bool hasImage,
    required bool isCompact,
    required String title,
    required String description,
  }) {
    if (isCompact) {
      return 80.0; // Kompakt kart sabit yükseklik
    }
    
    double height = 32.0; // Padding
    
    if (hasImage) {
      height += 200.0; // Image height (16:9 ratio)
    }
    
    height += 24.0; // Title height (2 lines)
    height += 60.0; // Description height (3 lines)
    height += 32.0; // Footer height
    
    return height;
  }
  
  /// Görsel URL'ini optimize eder
  static String? optimizeImageUrl(String? url, {int? width}) {
    if (url == null || url.isEmpty) return null;
    
    // TODO: Image resizing/optimization logic
    // Örnek: Cloudinary, ImageKit vs. entegrasyonu
    
    return url;
  }
}