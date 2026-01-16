import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../domain/entities/article.dart';
import '../../../themes/app_theme.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/reading_list_provider.dart';

/// Kart stilleri enum
enum ArticleCardStyle {
  /// Tam boyutlu kart - görsel üstte
  full,
  /// Kompakt kart - görsel solda
  compact,
  /// Featured kart - büyük görsel, gradient overlay
  featured,
  /// Mini kart - sadece başlık ve kaynak
  mini,
  /// Grid kart - kare görsel
  grid,
}

/// Geliştirilmiş Haber kartı widget'ı - Modern tasarım
/// Yumuşak gölgeler, gradient overlay, hover efektleri, yeni kart varyantları
class ArticleCardV2 extends ConsumerStatefulWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback? onShare;
  final bool showCategoryBadge;
  final bool showRecommendationBadge;
  final String? heroTagSuffix;
  final ArticleCardStyle style;
  final bool enableHoverEffect;

  const ArticleCardV2({
    super.key,
    required this.article,
    required this.onTap,
    required this.onFavoriteToggle,
    this.onShare,
    this.showCategoryBadge = true,
    this.showRecommendationBadge = false,
    this.heroTagSuffix,
    this.style = ArticleCardStyle.full,
    this.enableHoverEffect = true,
  });

  @override
  ConsumerState<ArticleCardV2> createState() => _ArticleCardV2State();
}

class _ArticleCardV2State extends ConsumerState<ArticleCardV2> 
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onHoverChanged(bool isHovered) {
    if (!widget.enableHoverEffect) return;
    setState(() => _isHovered = isHovered);
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: MouseRegion(
        onEnter: (_) => _onHoverChanged(true),
        onExit: (_) => _onHoverChanged(false),
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: widget.onTap,
          child: _buildCardByStyle(widget.style),
        ),
      ),
    );
  }

  Widget _buildCardByStyle(ArticleCardStyle style) {
    switch (style) {
      case ArticleCardStyle.full:
        return _buildFullCard(context, ref);
      case ArticleCardStyle.compact:
        return _buildCompactCard(context, ref);
      case ArticleCardStyle.featured:
        return _buildFeaturedCard(context, ref);
      case ArticleCardStyle.mini:
        return _buildMiniCard(context, ref);
      case ArticleCardStyle.grid:
        return _buildGridCard(context, ref);
    }
  }

  /// Tam boyutlu kart - Modern tasarım
  Widget _buildFullCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoryColor = AppTheme.getCategoryColor(widget.article.category);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isHovered
              ? categoryColor.withValues(alpha: 0.4)
              : isDark
                  ? theme.colorScheme.outline.withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.08),
          width: _isHovered ? 1.5 : 1,
        ),
        boxShadow: [
          // Ana gölge - yumuşak ve dağınık
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: _isHovered ? 0.12 : 0.06),
            blurRadius: _isHovered ? 24 : 16,
            offset: Offset(0, _isHovered ? 8 : 4),
            spreadRadius: _isHovered ? 2 : 0,
          ),
          // Accent gölge - renk vurgusu
          if (_isHovered)
            BoxShadow(
              color: categoryColor.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Görsel ve kategori badge'i
            if (widget.article.imageUrl != null) 
              _buildImageSection(context, ref, categoryColor),
            
            // İçerik
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Kategori badge (görsel yoksa)
                  if (widget.article.imageUrl == null && widget.showCategoryBadge)
                    _buildCategoryBadge(context, categoryColor),
                  
                  if (widget.article.imageUrl == null && widget.showCategoryBadge)
                    const SizedBox(height: 8),
                  
                  // Başlık
                  Text(
                    widget.article.truncatedTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                      fontSize: 17,
                      color: widget.article.isRead
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.55)
                          : theme.colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Özet
                  Text(
                    widget.article.truncatedDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.5,
                      fontSize: 14,
                      letterSpacing: 0.1,
                    ),
                    maxLines: 2,
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

  /// Kompakt kart - Modern tasarım
  Widget _buildCompactCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoryColor = AppTheme.getCategoryColor(widget.article.category);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isHovered 
              ? categoryColor.withValues(alpha: 0.3)
              : isDark 
                  ? theme.colorScheme.outline.withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.04),
            blurRadius: _isHovered ? 16 : 10,
            offset: Offset(0, _isHovered ? 4 : 2),
          ),
        ],
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
                // Rozetler
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.showCategoryBadge)
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: categoryColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.article.sourceName,
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
                      
                      if (widget.showRecommendationBadge) ...[
                        if (widget.showCategoryBadge) const SizedBox(width: 6),
                        _buildRecommendationBadge(context),
                      ],
                    ],
                  ),
                ),
                
                // Action butonları
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCompactActionButton(
                      context,
                      icon: Icons.share_outlined,
                      onTap: widget.onShare ?? () => _shareArticle(context),
                    ),
                    const SizedBox(width: 6),
                    _buildCompactActionButton(
                      context,
                      icon: ref.watch(isFavoriteProvider(widget.article.id))
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: ref.watch(isFavoriteProvider(widget.article.id))
                          ? Colors.red
                          : null,
                      onTap: widget.onFavoriteToggle,
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
                // Küçük görsel
                if (widget.article.imageUrl != null)
                  Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: widget.article.imageUrl!,
                        fit: BoxFit.cover,
                        memCacheWidth: 160,
                        memCacheHeight: 160,
                        placeholder: (context, url) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            size: 24,
                            color: theme.colorScheme.onsurfaceContainerHighest,
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
                      Text(
                        widget.article.truncatedTitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          fontSize: 15,
                          color: widget.article.isRead
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                              : theme.colorScheme.onSurface,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Alt bilgiler
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.article.shortDateTime,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                          if (widget.article.isRead) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppTheme.sageGreen,
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
    );
  }

  /// Featured kart - Büyük görsel, gradient overlay
  Widget _buildFeaturedCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoryColor = AppTheme.getCategoryColor(widget.article.category);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: _isHovered ? 0.18 : 0.1),
            blurRadius: _isHovered ? 28 : 20,
            offset: Offset(0, _isHovered ? 12 : 8),
            spreadRadius: _isHovered ? 2 : 0,
          ),
          if (_isHovered)
            BoxShadow(
              color: categoryColor.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Arka plan görseli
            if (widget.article.imageUrl != null)
              CachedNetworkImage(
                imageUrl: widget.article.imageUrl!,
                fit: BoxFit.cover,
                memCacheWidth: 600,
                memCacheHeight: 400,
                placeholder: (context, url) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.image_not_supported_rounded,
                    size: 48,
                    color: theme.colorScheme.onsurfaceContainerHighest,
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      categoryColor.withValues(alpha: 0.8),
                      categoryColor.withValues(alpha: 0.4),
                    ],
                  ),
                ),
              ),
            
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            
            // İçerik
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Kategori badge
                  if (widget.showCategoryBadge)
                    _buildGlassmorphismCategoryBadge(context, categoryColor),
                  
                  const SizedBox(height: 12),
                  
                  // Başlık
                  Text(
                    widget.article.truncatedTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      height: 1.3,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Alt bilgiler
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.article.shortDateTime,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.source_rounded,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          widget.article.sourceName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action butonları
            Positioned(
              top: 16,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildGlassActionButton(
                    context,
                    icon: Icons.share_rounded,
                    onTap: widget.onShare ?? () => _shareArticle(context),
                  ),
                  const SizedBox(width: 8),
                  _buildGlassActionButton(
                    context,
                    icon: ref.watch(isFavoriteProvider(widget.article.id))
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: ref.watch(isFavoriteProvider(widget.article.id))
                        ? Colors.red
                        : null,
                    onTap: widget.onFavoriteToggle,
                  ),
                ],
              ),
            ),
            
            // Okundu göstergesi
            if (widget.article.isRead)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.sageGreen.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Okundu',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Mini kart - Sadece başlık ve kaynak
  Widget _buildMiniCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoryColor = AppTheme.getCategoryColor(widget.article.category);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isHovered 
              ? categoryColor.withValues(alpha: 0.3)
              : isDark 
                  ? theme.colorScheme.outline.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.04),
            blurRadius: _isHovered ? 12 : 8,
            offset: Offset(0, _isHovered ? 4 : 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Kategori renk göstergesi
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: categoryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          
          // İçerik
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.article.truncatedTitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: widget.article.isRead
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.55)
                        : theme.colorScheme.onSurface,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      widget.article.sourceName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: categoryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.article.shortDateTime,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Favori butonu
          IconButton(
            onPressed: widget.onFavoriteToggle,
            icon: Icon(
              ref.watch(isFavoriteProvider(widget.article.id))
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              size: 20,
              color: ref.watch(isFavoriteProvider(widget.article.id))
                  ? Colors.red
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  /// Grid kart - Kare görsel
  Widget _buildGridCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoryColor = AppTheme.getCategoryColor(widget.article.category);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isHovered 
              ? categoryColor.withValues(alpha: 0.3)
              : isDark 
                  ? theme.colorScheme.outline.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: _isHovered ? 0.1 : 0.05),
            blurRadius: _isHovered ? 16 : 10,
            offset: Offset(0, _isHovered ? 6 : 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kare görsel
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.article.imageUrl != null)
                    CachedNetworkImage(
                      imageUrl: widget.article.imageUrl!,
                      fit: BoxFit.cover,
                      memCacheWidth: 300,
                      memCacheHeight: 300,
                      placeholder: (context, url) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          size: 32,
                          color: theme.colorScheme.onsurfaceContainerHighest,
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            categoryColor.withValues(alpha: 0.6),
                            categoryColor.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.article_rounded,
                          size: 40,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Kategori badge
                  if (widget.showCategoryBadge)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.article.sourceName,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  
                  // Favori butonu
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: widget.onFavoriteToggle,
                        icon: Icon(
                          ref.watch(isFavoriteProvider(widget.article.id))
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 16,
                          color: ref.watch(isFavoriteProvider(widget.article.id))
                              ? Colors.red
                              : Colors.white,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // İçerik
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article.truncatedTitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.3,
                      color: widget.article.isRead
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.55)
                          : theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.article.shortDateTime,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Görsel bölümü - Modern tasarım
  Widget _buildImageSection(BuildContext context, WidgetRef ref, Color categoryColor) {
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        // Ana görsel
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 180,
            child: CachedNetworkImage(
              imageUrl: widget.article.imageUrl!,
              fit: BoxFit.cover,
              memCacheWidth: 600,
              memCacheHeight: 300,
              placeholder: (context, url) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.image_not_supported_rounded,
                  size: 40,
                  color: theme.colorScheme.onsurfaceContainerHighest,
                ),
              ),
            ),
          ),
        ),
        
        // Gradient overlay - metin okunabilirliği için
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 80,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
        ),
        
        // Rozetler
        Positioned(
          top: 12,
          left: 12,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showCategoryBadge)
                _buildGlassmorphismCategoryBadge(context, categoryColor),
              
              if (widget.showRecommendationBadge) ...[
                if (widget.showCategoryBadge) const SizedBox(width: 8),
                _buildRecommendationBadge(context),
              ],
            ],
          ),
        ),
        
        // Action butonları
        Positioned(
          top: 12,
          right: 12,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGlassActionButton(
                context,
                icon: Icons.share_rounded,
                onTap: widget.onShare ?? () => _shareArticle(context),
              ),
              const SizedBox(width: 8),
              _buildGlassActionButton(
                context,
                icon: ref.watch(isFavoriteProvider(widget.article.id))
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: ref.watch(isFavoriteProvider(widget.article.id))
                    ? Colors.red
                    : null,
                onTap: widget.onFavoriteToggle,
              ),
            ],
          ),
        ),
        
        // Okundu göstergesi
        if (widget.article.isRead)
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
                    AppTheme.sageGreen.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Kategori badge - Normal
  Widget _buildCategoryBadge(BuildContext context, Color categoryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: categoryColor.withValues(alpha: 0.1),
        border: Border.all(color: categoryColor.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        widget.article.sourceName,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: categoryColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  /// Glassmorphism kategori badge
  Widget _buildGlassmorphismCategoryBadge(BuildContext context, Color categoryColor) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode
                  ? categoryColor.withValues(alpha: 0.5)
                  : categoryColor.withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
          child: Text(
            widget.article.sourceName,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isDarkMode ? categoryColor : categoryColor,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              shadows: isDarkMode
                  ? null
                  : [
                      Shadow(
                        offset: const Offset(0.5, 0.5),
                        blurRadius: 2.0,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }

  /// Öneri rozeti
  Widget _buildRecommendationBadge(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.shade400.withValues(alpha: 0.85),
                Colors.blue.shade400.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
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
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Glass action button
  Widget _buildGlassActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Material(
          color: Colors.black.withValues(alpha: 0.3),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 18,
                color: color ?? Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Kompakt action button
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
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: color ?? theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  /// Alt bilgiler
  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.access_time_rounded,
          size: 14,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 4),
        Text(
          widget.article.shortDateTime,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Icon(
          Icons.source_rounded,
          size: 14,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            widget.article.sourceName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        
        // Okundu göstergesi
        if (widget.article.isRead) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.sageGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.sageGreen.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 10,
                  color: AppTheme.sageGreen,
                ),
                const SizedBox(width: 4),
                Text(
                  'Okundu',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.sageGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Makaleyi paylaş
  void _shareArticle(BuildContext context) {
    final text = '${widget.article.title}\n\n${widget.article.link}';
    Share.share(
      text,
      subject: widget.article.title,
    );
    
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
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Article Card için utility sınıfı
class ArticleCardV2Utils {
  ArticleCardV2Utils._();
  
  /// Görsel aspect ratio
  static const double imageAspectRatio = 16 / 9;
  
  /// Kompakt görsel boyutu
  static const double compactImageSize = 80.0;
  
  /// Maksimum başlık satır sayısı
  static const int maxTitleLines = 2;
  
  /// Maksimum özet satır sayısı
  static const int maxDescriptionLines = 2;
  
  /// Kart yüksekliği hesaplar
  static double estimateCardHeight({
    required ArticleCardStyle style,
    required bool hasImage,
  }) {
    switch (style) {
      case ArticleCardStyle.full:
        return hasImage ? 340.0 : 160.0;
      case ArticleCardStyle.compact:
        return 140.0;
      case ArticleCardStyle.featured:
        return 280.0;
      case ArticleCardStyle.mini:
        return 72.0;
      case ArticleCardStyle.grid:
        return 220.0;
    }
  }
}
