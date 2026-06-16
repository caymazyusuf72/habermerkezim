import 'package:flutter/material.dart';

/// Sayfa geçiş türleri
enum PageTransitionType {
  /// Sağdan sola kayma
  slideRight,

  /// Soldan sağa kayma
  slideLeft,

  /// Alttan yukarı kayma
  slideUp,

  /// Üstten aşağı kayma
  slideDown,

  /// Fade efekti
  fade,

  /// Scale efekti
  scale,

  /// Fade + Scale kombinasyonu
  fadeScale,

  /// Slide + Fade kombinasyonu
  slideFade,

  /// Material tasarım geçişi
  material,

  /// iOS tarzı geçiş
  cupertino,

  /// Shared axis geçişi
  sharedAxis,
}

/// Custom sayfa geçiş route'u
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final PageTransitionType transitionType;
  final Duration duration;
  final Duration reverseDuration;
  final Curve curve;
  final Curve reverseCurve;

  CustomPageRoute({
    required this.page,
    this.transitionType = PageTransitionType.slideFade,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOutCubic,
    this.reverseCurve = Curves.easeInCubic,
    super.settings,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionDuration: duration,
         reverseTransitionDuration: reverseDuration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return _buildTransition(
             context,
             animation,
             secondaryAnimation,
             child,
             transitionType,
             curve,
             reverseCurve,
           );
         },
       );

  static Widget _buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    PageTransitionType type,
    Curve curve,
    Curve reverseCurve,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
      reverseCurve: reverseCurve,
    );

    switch (type) {
      case PageTransitionType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.fade:
        return FadeTransition(opacity: curvedAnimation, child: child);

      case PageTransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.fadeScale:
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.92,
              end: 1.0,
            ).animate(curvedAnimation),
            child: child,
          ),
        );

      case PageTransitionType.slideFade:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.1, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(opacity: curvedAnimation, child: child),
        );

      case PageTransitionType.material:
        return _MaterialPageTransition(
          animation: curvedAnimation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );

      case PageTransitionType.cupertino:
        return _CupertinoPageTransition(
          animation: curvedAnimation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );

      case PageTransitionType.sharedAxis:
        return _SharedAxisTransition(
          animation: curvedAnimation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
    }
  }
}

/// Material tasarım sayfa geçişi
class _MaterialPageTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const _MaterialPageTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 0.05),
        end: Offset.zero,
      ).animate(animation),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}

/// iOS tarzı sayfa geçişi
class _CupertinoPageTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const _CupertinoPageTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.linearToEaseOut,
              reverseCurve: Curves.easeInToLinear,
            ),
          ),
      child: SlideTransition(
        position:
            Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.3, 0.0),
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: Curves.linearToEaseOut,
                reverseCurve: Curves.easeInToLinear,
              ),
            ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1 * animation.value),
                blurRadius: 20,
                offset: const Offset(-5, 0),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Shared axis geçişi (Material Motion)
class _SharedAxisTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const _SharedAxisTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

/// Modal bottom sheet geçişi
class ModalBottomSheetRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final bool isDismissible;
  final bool enableDrag;
  final Color? _barrierColorValue;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;

  @override
  Color? get barrierColor => _barrierColorValue ?? Colors.black54;

  ModalBottomSheetRoute({
    required this.page,
    this.isDismissible = true,
    this.enableDrag = true,
    Color? barrierColor,
    this.initialChildSize = 0.9,
    this.minChildSize = 0.5,
    this.maxChildSize = 1.0,
    super.settings,
  }) : _barrierColorValue = barrierColor,
       super(
         opaque: false,
         barrierDismissible: isDismissible,
         barrierColor: barrierColor ?? Colors.black54,
         transitionDuration: const Duration(milliseconds: 350),
         reverseTransitionDuration: const Duration(milliseconds: 300),
         pageBuilder: (context, animation, secondaryAnimation) {
           return _ModalBottomSheetPage(
             animation: animation,
             page: page,
             enableDrag: enableDrag,
             initialChildSize: initialChildSize,
             minChildSize: minChildSize,
             maxChildSize: maxChildSize,
           );
         },
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return child;
         },
       );
}

class _ModalBottomSheetPage extends StatelessWidget {
  final Animation<double> animation;
  final Widget page;
  final bool enableDrag;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;

  const _ModalBottomSheetPage({
    required this.animation,
    required this.page,
    required this.enableDrag,
    required this.initialChildSize,
    required this.minChildSize,
    required this.maxChildSize,
  });

  @override
  Widget build(BuildContext context) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        snap: true,
        snapSizes: [minChildSize, initialChildSize, maxChildSize],
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: page,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Fade through geçişi (Material Motion)
class FadeThroughPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeThroughPageRoute({required this.page, super.settings})
    : super(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return _FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
      );
}

class _FadeThroughTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const _FadeThroughTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        ),
      ),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    );
  }
}

/// Navigator extension for easy navigation
extension NavigatorExtension on NavigatorState {
  /// Custom push with transition
  Future<T?> pushWithTransition<T>(
    Widget page, {
    PageTransitionType type = PageTransitionType.slideFade,
    Duration? duration,
    Curve? curve,
    RouteSettings? settings,
  }) {
    return push<T>(
      CustomPageRoute<T>(
        page: page,
        transitionType: type,
        duration: duration ?? const Duration(milliseconds: 300),
        curve: curve ?? Curves.easeOutCubic,
        settings: settings,
      ),
    );
  }

  /// Push replacement with transition
  Future<T?> pushReplacementWithTransition<T, TO>(
    Widget page, {
    PageTransitionType type = PageTransitionType.fade,
    Duration? duration,
    Curve? curve,
    RouteSettings? settings,
    TO? result,
  }) {
    return pushReplacement<T, TO>(
      CustomPageRoute<T>(
        page: page,
        transitionType: type,
        duration: duration ?? const Duration(milliseconds: 300),
        curve: curve ?? Curves.easeOutCubic,
        settings: settings,
      ),
      result: result,
    );
  }

  /// Push and remove until with transition
  Future<T?> pushAndRemoveUntilWithTransition<T>(
    Widget page,
    RoutePredicate predicate, {
    PageTransitionType type = PageTransitionType.fadeScale,
    Duration? duration,
    Curve? curve,
    RouteSettings? settings,
  }) {
    return pushAndRemoveUntil<T>(
      CustomPageRoute<T>(
        page: page,
        transitionType: type,
        duration: duration ?? const Duration(milliseconds: 300),
        curve: curve ?? Curves.easeOutCubic,
        settings: settings,
      ),
      predicate,
    );
  }
}

/// BuildContext extension for easy navigation
extension NavigationContextExtension on BuildContext {
  /// Navigate to page with custom transition
  Future<T?> navigateTo<T>(
    Widget page, {
    PageTransitionType type = PageTransitionType.slideFade,
    Duration? duration,
    Curve? curve,
    RouteSettings? settings,
  }) {
    return Navigator.of(this).pushWithTransition<T>(
      page,
      type: type,
      duration: duration,
      curve: curve,
      settings: settings,
    );
  }

  /// Navigate and replace current page
  Future<T?> navigateReplace<T, TO>(
    Widget page, {
    PageTransitionType type = PageTransitionType.fade,
    Duration? duration,
    Curve? curve,
    RouteSettings? settings,
    TO? result,
  }) {
    return Navigator.of(this).pushReplacementWithTransition<T, TO>(
      page,
      type: type,
      duration: duration,
      curve: curve,
      settings: settings,
      result: result,
    );
  }

  /// Navigate and clear stack
  Future<T?> navigateAndClear<T>(
    Widget page, {
    PageTransitionType type = PageTransitionType.fadeScale,
    Duration? duration,
    Curve? curve,
    RouteSettings? settings,
  }) {
    return Navigator.of(this).pushAndRemoveUntilWithTransition<T>(
      page,
      (route) => false,
      type: type,
      duration: duration,
      curve: curve,
      settings: settings,
    );
  }

  /// Go back
  void goBack<T>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }

  /// Can go back
  bool get canGoBack => Navigator.of(this).canPop();
}
