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
  final bool showRecommendationBadge;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    required this.onFavoriteToggle,
    this.onShare,
    this.showCategoryBadge = true,
    this.isCompact = false,
    this.showRecommendationBadge = false,
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Daha köşeli, gazete gibi
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Görsel ve kategori badge'i
            if (article.imageUrl != null) _buildImageSection(context, ref, categoryColor),
            
            // İçerik - Daha geniş padding
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori badge (görsel yoksa)
                  if (article.imageUrl == null && showCategoryBadge)
                    _buildCategoryBadge(context, categoryColor),
                  
                  const SizedBox(height: 8),
                  
                  // Başlık - Daha büyük ve okunabilir
                  Text(
                    article.truncatedTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      fontSize: 18,
                      color: article.isRead
                          ? theme.colorScheme.onSurface.withOpacity(0.6)
                          : theme.colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Özet - Daha okunabilir
                  Text(
                    article.truncatedDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.75),
                      height: 1.5,
                      fontSize: 14,
                      letterSpacing: 0.1,
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

  /// Kompakt kart (liste görünümü için) - Modern ve profesyonel tasarım
  Widget _buildCompactCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoryColor = AppTheme.getCategoryColor(article.category);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark 
              ? theme.colorScheme.outline.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark ? theme.colorScheme.surface : Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Üst kısım: Kategori badge ve action butonları
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rozetler (kategori ve öneri)
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Kategori badge
                          if (showCategoryBadge)
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: categoryColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  article.sourceName,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: categoryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          
                          // Öneri rozeti
                          if (showRecommendationBadge) ...[
                            if (showCategoryBadge) const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purple.shade400,
                                    Colors.blue.shade400,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Öneri',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Action butonları - daha küçük ve modern
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCompactActionButton(
                          context,
                          icon: Icons.share_outlined,
                          onTap: onShare ?? () => _shareArticle(context),
                        ),
                        const SizedBox(width: 6),
                        _buildCompactActionButton(
                          context,
                          icon: ref.watch(isFavoriteProvider(article.id))
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: ref.watch(isFavoriteProvider(article.id))
                              ? Colors.red
                              : null,
                          onTap: onFavoriteToggle,
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Görsel ve içerik
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Küçük görsel - daha modern
                    if (article.imageUrl != null)
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: ArticleCardUtils.optimizeImageUrl(
                              article.imageUrl,
                              width: 80,
                              height: 80,
                            ) ?? article.imageUrl!,
                            fit: BoxFit.cover,
                            memCacheWidth: 80,
                            memCacheHeight: 80,
                            placeholder: (context, url) => Container(
                              color: theme.colorScheme.surfaceVariant,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: theme.colorScheme.surfaceVariant,
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                size: 24,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    // İçerik
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Başlık - daha okunabilir
                          Text(
                            article.truncatedTitle,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              fontSize: 15,
                              color: article.isRead
                                  ? theme.colorScheme.onSurface.withOpacity(0.6)
                                  : theme.colorScheme.onSurface,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Alt bilgiler - daha kompakt
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                article.shortDateTime,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                  fontSize: 11,
                                ),
                              ),
                              if (article.isRead) ...[
                                const SizedBox(width: 8),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Kompakt action butonu - daha modern
  Widget _buildCompactActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: color ?? theme.colorScheme.onSurface.withOpacity(0.7),
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
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl: ArticleCardUtils.optimizeImageUrl(
                article.imageUrl,
                width: MediaQuery.of(context).size.width.toInt(),
              ) ?? article.imageUrl!,
              fit: BoxFit.cover,
              memCacheWidth: MediaQuery.of(context).size.width.toInt(),
              memCacheHeight: (MediaQuery.of(context).size.width / ArticleCardUtils.imageAspectRatio).toInt(),
              maxWidthDiskCache: 800,
              maxHeightDiskCache: 450,
              placeholder: (context, url) => Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
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
        
        // Rozetler (görsel üstünde)
        Positioned(
          top: 12,
          left: 12,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Kategori badge
              if (showCategoryBadge)
                _buildCategoryBadge(context, categoryColor),
              
              // Öneri rozeti
              if (showRecommendationBadge) ...[
                if (showCategoryBadge) const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.shade400,
                        Colors.blue.shade400,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Öneri',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
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
        
        // Okundu göstergesi - Adaçayı yeşili
        if (article.isRead)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppTheme.sageGreen.withOpacity(0.6),
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
          imageUrl: ArticleCardUtils.optimizeImageUrl(
            article.imageUrl,
            width: 60,
            height: 60,
          ) ?? article.imageUrl!,
          fit: BoxFit.cover,
          memCacheWidth: 60,
          memCacheHeight: 60,
          maxWidthDiskCache: 120,
          maxHeightDiskCache: 120,
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

  /// Kategori badge'i - Adaçayı yeşili accent ile
  Widget _buildCategoryBadge(BuildContext context, Color categoryColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          color: isInReadingList ? AppTheme.sageGreen : Theme.of(context).colorScheme.onSurface,
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
  /// WebP formatına çevirir ve boyutlandırır (desteklenen servisler için)
  static String? optimizeImageUrl(String? url, {int? width, int? height}) {
    if (url == null || url.isEmpty) return null;
    
    // Bazı CDN'ler için otomatik optimizasyon
    // Cloudinary, ImageKit, Imgix gibi servisler için parametre ekleme
    
    try {
      final uri = Uri.parse(url);
      
      // Cloudinary için optimizasyon
      if (uri.host.contains('cloudinary.com')) {
        final params = <String, String>{};
        if (width != null) params['w'] = width.toString();
        if (height != null) params['h'] = height.toString();
        params['f'] = 'auto'; // Format auto
        params['q'] = 'auto'; // Quality auto
        
        return uri.replace(queryParameters: {
          ...uri.queryParameters,
          ...params,
        }).toString();
      }
      
      // ImageKit için optimizasyon
      if (uri.host.contains('ik.imagekit.io')) {
        final params = <String, String>{};
        if (width != null) params['w'] = width.toString();
        if (height != null) params['h'] = height.toString();
        params['f'] = 'auto';
        params['q'] = '80';
        
        return uri.replace(queryParameters: {
          ...uri.queryParameters,
          ...params,
        }).toString();
      }
      
      // Imgix için optimizasyon
      if (uri.host.contains('imgix.net')) {
        final params = <String, String>{};
        if (width != null) params['w'] = width.toString();
        if (height != null) params['h'] = height.toString();
        params['auto'] = 'format,compress';
        params['q'] = '80';
        
        return uri.replace(queryParameters: {
          ...uri.queryParameters,
          ...params,
        }).toString();
      }
      
      // Diğer URL'ler için orijinal URL'i döndür
      return url;
    } catch (e) {
      // Parse hatası durumunda orijinal URL'i döndür
      return url;
    }
  }
  
  /// Görsel boyutunu hesaplar (ekran genişliğine göre)
  static Size calculateImageSize(BuildContext context, {bool isCompact = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isCompact) {
      return const Size(compactImageSize, compactImageSize);
    }
    
    final imageHeight = screenWidth / imageAspectRatio;
    return Size(screenWidth, imageHeight);
  }
}