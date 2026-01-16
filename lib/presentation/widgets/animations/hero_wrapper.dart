import 'package:flutter/material.dart';

/// Hero animasyonu için wrapper widget
/// Unique tag oluşturarak çakışma sorununu çözer
class HeroWrapper extends StatelessWidget {
  final String tag;
  final Widget child;
  final bool enabled;
  final CreateRectTween? createRectTween;
  final HeroFlightShuttleBuilder? flightShuttleBuilder;
  final HeroPlaceholderBuilder? placeholderBuilder;

  const HeroWrapper({
    super.key,
    required this.tag,
    required this.child,
    this.enabled = true,
    this.createRectTween,
    this.flightShuttleBuilder,
    this.placeholderBuilder,
  });

  /// Unique hero tag oluşturur
  static String createUniqueTag(String baseTag, String id, [String? suffix]) {
    final parts = [baseTag, id];
    if (suffix != null && suffix.isNotEmpty) {
      parts.add(suffix);
    }
    return parts.join('-');
  }

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return Hero(
      tag: tag,
      createRectTween: createRectTween ?? _defaultCreateRectTween,
      flightShuttleBuilder: flightShuttleBuilder ?? _defaultFlightShuttleBuilder,
      placeholderBuilder: placeholderBuilder,
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }

  /// Varsayılan rect tween - yumuşak geçiş
  static RectTween _defaultCreateRectTween(Rect? begin, Rect? end) {
    return MaterialRectCenterArcTween(begin: begin, end: end);
  }

  /// Varsayılan flight shuttle builder
  static Widget _defaultFlightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final Hero toHero = toHeroContext.widget as Hero;
    
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: animation.drive(
            Tween<double>(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: Curves.easeInOut),
            ),
          ),
          child: child,
        );
      },
      child: toHero.child,
    );
  }
}

/// Görsel için Hero wrapper
class ImageHeroWrapper extends StatelessWidget {
  final String articleId;
  final String? suffix;
  final Widget child;
  final bool enabled;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ImageHeroWrapper({
    super.key,
    required this.articleId,
    required this.child,
    this.suffix,
    this.enabled = true,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return _buildClippedChild();
    }

    final tag = HeroWrapper.createUniqueTag('article-image', articleId, suffix);

    return Hero(
      tag: tag,
      createRectTween: (begin, end) {
        return MaterialRectCenterArcTween(begin: begin, end: end);
      },
      flightShuttleBuilder: (
        flightContext,
        animation,
        flightDirection,
        fromHeroContext,
        toHeroContext,
      ) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            );
            
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.lerp(
                  borderRadius ?? BorderRadius.circular(16),
                  BorderRadius.zero,
                  flightDirection == HeroFlightDirection.push
                      ? curvedAnimation.value
                      : 1 - curvedAnimation.value,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2 * (1 - curvedAnimation.value)),
                    blurRadius: 20 * (1 - curvedAnimation.value),
                    offset: Offset(0, 10 * (1 - curvedAnimation.value)),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.lerp(
                  borderRadius ?? BorderRadius.circular(16),
                  BorderRadius.zero,
                  flightDirection == HeroFlightDirection.push
                      ? curvedAnimation.value
                      : 1 - curvedAnimation.value,
                )!,
                child: child,
              ),
            );
          },
        );
      },
      child: _buildClippedChild(),
    );
  }

  Widget _buildClippedChild() {
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }
    return child;
  }
}

/// Başlık için Hero wrapper
class TitleHeroWrapper extends StatelessWidget {
  final String articleId;
  final String? suffix;
  final Widget child;
  final bool enabled;

  const TitleHeroWrapper({
    super.key,
    required this.articleId,
    required this.child,
    this.suffix,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    final tag = HeroWrapper.createUniqueTag('article-title', articleId, suffix);

    return Hero(
      tag: tag,
      flightShuttleBuilder: (
        flightContext,
        animation,
        flightDirection,
        fromHeroContext,
        toHeroContext,
      ) {
        final Hero toHero = toHeroContext.widget as Hero;
        
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return FadeTransition(
              opacity: animation.drive(
                Tween<double>(begin: 0.5, end: 1.0).chain(
                  CurveTween(curve: Curves.easeOut),
                ),
              ),
              child: DefaultTextStyle(
                style: DefaultTextStyle.of(toHeroContext).style,
                child: toHero.child,
              ),
            );
          },
        );
      },
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }
}

/// FAB için Hero wrapper
class FabHeroWrapper extends StatelessWidget {
  final String tag;
  final Widget child;
  final bool enabled;

  const FabHeroWrapper({
    super.key,
    required this.tag,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return Hero(
      tag: tag,
      createRectTween: (begin, end) {
        return MaterialRectCenterArcTween(begin: begin, end: end);
      },
      child: child,
    );
  }
}