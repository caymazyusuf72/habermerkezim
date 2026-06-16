import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/services/image_cache_service.dart';

/// Optimize edilmiş görsel widget'ı
/// CachedNetworkImage wrapper'ı, placeholder/error handling ile
/// Progressive loading ve memory optimization destekler
///
/// Performans İyileştirmeleri:
/// - Adaptive memory cache boyutları
/// - Optimized disk cache limitleri
/// - Smooth shimmer animasyonları
/// - Lazy loading desteği
class OptimizedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool enableProgressive;
  final bool enableMemoryCache;
  final bool enableLazyLoading;
  final int? maxCacheWidth;
  final int? maxCacheHeight;
  final Color? shimmerBaseColor;
  final Color? shimmerHighlightColor;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.enableProgressive = true,
    this.enableMemoryCache = true,
    this.enableLazyLoading = true,
    this.maxCacheWidth,
    this.maxCacheHeight,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return errorWidget ?? _defaultErrorWidget(context);
    }

    // Optimize edilmiş URL
    final optimizedUrl = ImageCacheService.optimizeImageUrl(
      imageUrl,
      width: width?.toInt(),
      height: height?.toInt(),
    );

    // Device pixel ratio
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    // Memory cache optimization - adaptive boyutlar
    // Düşük bellek cihazlar için daha küçük cache boyutları
    final adaptiveRatio = devicePixelRatio > 2.5 ? 2.0 : devicePixelRatio;

    final memWidth = enableMemoryCache && width != null
        ? (width! * adaptiveRatio).toInt().clamp(100, 600)
        : null;
    final memHeight = enableMemoryCache && height != null
        ? (height! * adaptiveRatio).toInt().clamp(100, 600)
        : null;

    // Disk cache boyutları - optimize edilmiş
    final diskCacheWidth = maxCacheWidth ?? 600;
    final diskCacheHeight = maxCacheHeight ?? 600;

    Widget imageWidget = CachedNetworkImage(
      imageUrl: optimizedUrl ?? imageUrl!,
      width: width,
      height: height,
      fit: fit,
      // Memory cache boyutları - adaptive ve sınırlı
      memCacheWidth: memWidth,
      memCacheHeight: memHeight,
      // Disk cache boyutları - optimize edilmiş (800→600)
      maxWidthDiskCache: diskCacheWidth,
      maxHeightDiskCache: diskCacheHeight,
      // Progressive loading için placeholder
      placeholder: (context, url) {
        if (enableProgressive) {
          return _buildProgressivePlaceholder(context);
        }
        return placeholder ?? _defaultPlaceholder(context);
      },
      errorWidget: (context, url, error) =>
          errorWidget ?? _defaultErrorWidget(context),
      // Smooth transitions - optimize edilmiş süreler
      fadeInDuration: const Duration(milliseconds: 250),
      fadeOutDuration: const Duration(milliseconds: 150),
      // Progressive loading curve
      fadeInCurve: Curves.easeOut,
      // HTTP headers - cache kontrolü
      httpHeaders: const {
        'Cache-Control': 'max-age=86400', // 1 gün cache
      },
      // Use old image on error - daha iyi UX
      useOldImageOnUrlChange: true,
      // Filter quality - performans için düşürüldü
      filterQuality: FilterQuality.medium,
    );

    // Border radius varsa uygula
    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _defaultPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      color: isDark ? Colors.grey[800] : Colors.grey[200],
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? Colors.grey[600]! : Colors.grey[400]!,
            ),
          ),
        ),
      ),
    );
  }

  /// Progressive placeholder with optimized shimmer effect
  /// Performans için TweenAnimationBuilder yerine AnimatedContainer kullanıldı
  Widget _buildProgressivePlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        shimmerBaseColor ?? (isDark ? Colors.grey[800]! : Colors.grey[300]!);
    final highlightColor =
        shimmerHighlightColor ??
        (isDark ? Colors.grey[700]! : Colors.grey[100]!);

    return _ShimmerPlaceholder(
      width: width,
      height: height,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }

  Widget _defaultErrorWidget(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      color: isDark ? Colors.grey[800] : Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported_rounded,
          color: isDark ? Colors.grey[600] : Colors.grey[400],
          size: 28,
        ),
      ),
    );
  }
}

/// Optimize edilmiş Shimmer Placeholder
/// Ayrı StatefulWidget olarak performans için ayrıldı
class _ShimmerPlaceholder extends StatefulWidget {
  final double? width;
  final double? height;
  final Color baseColor;
  final Color highlightColor;

  const _ShimmerPlaceholder({
    this.width,
    this.height,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Thumbnail için optimize edilmiş görsel widget'ı
/// Daha küçük cache boyutları ve hızlı yükleme
class OptimizedThumbnail extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final BorderRadius? borderRadius;

  const OptimizedThumbnail({
    super.key,
    required this.imageUrl,
    this.size = 60,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return OptimizedImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      maxCacheWidth: 150,
      maxCacheHeight: 150,
      enableProgressive: false, // Thumbnail için shimmer gereksiz
    );
  }
}

/// Hero image için optimize edilmiş görsel widget'ı
/// Daha büyük cache boyutları ve yüksek kalite
class OptimizedHeroImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const OptimizedHeroImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return OptimizedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      maxCacheWidth: 1200,
      maxCacheHeight: 800,
      enableProgressive: true,
    );
  }
}
