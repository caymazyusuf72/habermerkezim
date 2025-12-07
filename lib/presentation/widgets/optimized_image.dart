import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/services/image_cache_service.dart';

/// Optimize edilmiş görsel widget'ı
/// CachedNetworkImage wrapper'ı, placeholder/error handling ile
/// Progressive loading ve memory optimization destekler
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
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return errorWidget ?? _defaultErrorWidget();
    }

    // Optimize edilmiş URL
    final optimizedUrl = ImageCacheService.optimizeImageUrl(
      imageUrl,
      width: width?.toInt(),
      height: height?.toInt(),
    );

    // Memory cache optimization
    final memWidth = enableMemoryCache && width != null
        ? (width! * MediaQuery.of(context).devicePixelRatio).toInt()
        : null;
    final memHeight = enableMemoryCache && height != null
        ? (height! * MediaQuery.of(context).devicePixelRatio).toInt()
        : null;

    Widget imageWidget = CachedNetworkImage(
      imageUrl: optimizedUrl ?? imageUrl!,
      width: width,
      height: height,
      fit: fit,
      // Memory cache boyutları device pixel ratio ile optimize edildi
      memCacheWidth: memWidth,
      memCacheHeight: memHeight,
      // Disk cache boyutları makul sınırlarda tutuldu
      maxWidthDiskCache: 800,
      maxHeightDiskCache: 800,
      // Progressive loading için placeholder
      placeholder: (context, url) {
        if (enableProgressive) {
          return _buildProgressivePlaceholder();
        }
        return placeholder ?? _defaultPlaceholder();
      },
      errorWidget: (context, url, error) => errorWidget ?? _defaultErrorWidget(),
      // Smooth transitions
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 200),
      // Progressive loading curve
      fadeInCurve: Curves.easeInOut,
    );

    // Border radius varsa uygula
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _defaultPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      ),
    );
  }

  /// Progressive placeholder with shimmer effect
  Widget _buildProgressivePlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[200]!,
            Colors.grey[100]!,
            Colors.grey[200]!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: -1.0, end: 2.0),
        duration: const Duration(milliseconds: 1500),
        builder: (context, value, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: const [
                  Colors.transparent,
                  Colors.white,
                  Colors.transparent,
                ],
                stops: [
                  value - 0.3,
                  value,
                  value + 0.3,
                ],
              ).createShader(bounds);
            },
            child: Container(
              color: Colors.grey[300],
            ),
          );
        },
        onEnd: () {},
      ),
    );
  }

  Widget _defaultErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.image_not_supported_rounded,
          color: Colors.grey,
          size: 32,
        ),
      ),
    );
  }
}

