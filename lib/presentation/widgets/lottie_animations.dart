import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Lottie animasyonları için merkezi widget
/// Not: Lottie dosyaları assets/animations/ klasöründe olmalıdır
class LottieAnimationWidget extends StatelessWidget {
  final String animationPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool repeat;
  final bool reverse;
  final AnimationController? controller;

  const LottieAnimationWidget({
    super.key,
    required this.animationPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.repeat = true,
    this.reverse = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      animationPath,
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
      reverse: reverse,
      controller: controller,
      errorBuilder: (context, error, stackTrace) {
        // Lottie dosyası bulunamazsa fallback göster
        return _buildFallback(context);
      },
    );
  }

  Widget _buildFallback(BuildContext context) {
    return SizedBox(
      width: width ?? 100,
      height: height ?? 100,
      child: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// Loading animasyonu
class LoadingAnimation extends StatelessWidget {
  final double size;
  final String? message;

  const LoadingAnimation({
    super.key,
    this.size = 120,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLoadingIndicator(context),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    // Lottie dosyası yoksa fallback kullan
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dış halka
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          // İç halka
          SizedBox(
            width: size * 0.7,
            height: size * 0.7,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          // Merkez ikon
          Icon(
            Icons.newspaper_rounded,
            size: size * 0.3,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

/// Başarı animasyonu
class SuccessAnimation extends StatefulWidget {
  final double size;
  final VoidCallback? onComplete;
  final String? message;

  const SuccessAnimation({
    super.key,
    this.size = 120,
    this.onComplete,
    this.message,
  });

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.green,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: CustomPaint(
                    size: Size(widget.size * 0.5, widget.size * 0.5),
                    painter: _CheckmarkPainter(
                      progress: _checkAnimation.value,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          FadeTransition(
            opacity: _checkAnimation,
            child: Text(
              widget.message!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CheckmarkPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Checkmark path
    final startX = size.width * 0.2;
    final startY = size.height * 0.5;
    final midX = size.width * 0.4;
    final midY = size.height * 0.7;
    final endX = size.width * 0.8;
    final endY = size.height * 0.3;

    path.moveTo(startX, startY);
    
    if (progress <= 0.5) {
      // First part of checkmark
      final t = progress * 2;
      path.lineTo(
        startX + (midX - startX) * t,
        startY + (midY - startY) * t,
      );
    } else {
      // Complete first part and draw second part
      path.lineTo(midX, midY);
      final t = (progress - 0.5) * 2;
      path.lineTo(
        midX + (endX - midX) * t,
        midY + (endY - midY) * t,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Hata animasyonu
class ErrorAnimation extends StatefulWidget {
  final double size;
  final String? message;
  final VoidCallback? onRetry;

  const ErrorAnimation({
    super.key,
    this.size = 120,
    this.message,
    this.onRetry,
  });

  @override
  State<ErrorAnimation> createState() => _ErrorAnimationState();
}

class _ErrorAnimationState extends State<ErrorAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                10 * (1 - _shakeAnimation.value) * 
                    ((_shakeAnimation.value * 10).toInt() % 2 == 0 ? 1 : -1),
                0,
              ),
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.close_rounded,
                    size: widget.size * 0.5,
                    color: Colors.red,
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (widget.onRetry != null) ...[
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: widget.onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tekrar Dene'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ],
    );
  }
}

/// Boş durum animasyonu
class EmptyStateAnimation extends StatelessWidget {
  final double size;
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? action;

  const EmptyStateAnimation({
    super.key,
    this.size = 120,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_rounded,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: size * 0.5,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (action != null) ...[
          const SizedBox(height: 24),
          action!,
        ],
      ],
    );
  }
}

/// Kutlama animasyonu (rozet açma, seviye atlama vb.)
class CelebrationAnimation extends StatefulWidget {
  final Widget child;
  final bool play;
  final Duration duration;

  const CelebrationAnimation({
    super.key,
    required this.child,
    this.play = true,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<CelebrationAnimation> createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<CelebrationAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 0.9),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.9, end: 1.0),
        weight: 40,
      ),
    ]).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );

    if (widget.play) {
      _scaleController.forward();
      _particleController.forward();
    }
  }

  @override
  void didUpdateWidget(CelebrationAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play && !oldWidget.play) {
      _scaleController.reset();
      _particleController.reset();
      _scaleController.forward();
      _particleController.forward();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Particle effects
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return CustomPaint(
              painter: _StarburstPainter(
                progress: _particleController.value,
                color: Theme.of(context).colorScheme.primary,
              ),
              size: const Size(200, 200),
            );
          },
        ),
        // Main content with scale animation
        ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ],
    );
  }
}

class _StarburstPainter extends CustomPainter {
  final double progress;
  final Color color;

  _StarburstPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || progress == 1) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Draw expanding circles
    for (int i = 0; i < 3; i++) {
      final circleProgress = (progress - i * 0.1).clamp(0.0, 1.0);
      if (circleProgress > 0) {
        final paint = Paint()
          ..color = color.withValues(alpha: (1 - circleProgress) * 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        canvas.drawCircle(
          center,
          maxRadius * circleProgress,
          paint,
        );
      }
    }

    // Draw rays
    final rayPaint = Paint()
      ..color = color.withValues(alpha: (1 - progress) * 0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * 3.14159 / 180;
      final startRadius = maxRadius * 0.3 * progress;
      final endRadius = maxRadius * progress;

      final start = Offset(
        center.dx + startRadius * cos(angle),
        center.dy + startRadius * sin(angle),
      );
      final end = Offset(
        center.dx + endRadius * cos(angle),
        center.dy + endRadius * sin(angle),
      );

      canvas.drawLine(start, end, rayPaint);
    }
  }

  double cos(double radians) => _cos(radians);
  double sin(double radians) => _sin(radians);

  double _cos(double x) {
    return 1 - (x * x) / 2 + (x * x * x * x) / 24;
  }

  double _sin(double x) {
    return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  }

  @override
  bool shouldRepaint(_StarburstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Pull to refresh animasyonu
class RefreshAnimation extends StatelessWidget {
  final double progress;
  final double size;

  const RefreshAnimation({
    super.key,
    required this.progress,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CircularProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            strokeWidth: 3,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            color: Theme.of(context).colorScheme.primary,
          ),
          // Arrow icon
          Transform.rotate(
            angle: progress * 6.28,
            child: Icon(
              Icons.arrow_downward_rounded,
              size: size * 0.5,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}