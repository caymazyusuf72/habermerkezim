import 'package:flutter/material.dart';

/// Temel shimmer animasyon widget'ı
/// Pure Flutter ile AnimationController + LinearGradient kullanır
/// shimmer paketi kullanmadan çalışır
class ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color? baseColor;
  final Color? highlightColor;
  final ShimmerDirection direction;

  const ShimmerWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor,
    this.highlightColor,
    this.direction = ShimmerDirection.leftToRight,
  });

  /// Dikdörtgen shimmer placeholder
  factory ShimmerWidget.rectangular({
    Key? key,
    required double width,
    required double height,
    BorderRadius? borderRadius,
    Duration duration = const Duration(milliseconds: 1500),
    Color? baseColor,
    Color? highlightColor,
  }) {
    return ShimmerWidget(
      key: key,
      duration: duration,
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }

  /// Yuvarlak shimmer placeholder
  factory ShimmerWidget.circular({
    Key? key,
    required double size,
    Duration duration = const Duration(milliseconds: 1500),
    Color? baseColor,
    Color? highlightColor,
  }) {
    return ShimmerWidget(
      key: key,
      duration: duration,
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor =
        widget.baseColor ??
        (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0));
    final highlightColor =
        widget.highlightColor ??
        (isDark ? const Color(0xFF3D3D3D) : const Color(0xFFF5F5F5));

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        final begin = _getBeginAlignment();
        final end = _getEndAlignment();

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: begin,
              end: end,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                (value - 0.3).clamp(0.0, 1.0),
                value.clamp(0.0, 1.0),
                (value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }

  Alignment _getBeginAlignment() {
    switch (widget.direction) {
      case ShimmerDirection.leftToRight:
        return const Alignment(-1.0, -0.3);
      case ShimmerDirection.rightToLeft:
        return const Alignment(1.0, -0.3);
      case ShimmerDirection.topToBottom:
        return const Alignment(-0.3, -1.0);
      case ShimmerDirection.bottomToTop:
        return const Alignment(-0.3, 1.0);
    }
  }

  Alignment _getEndAlignment() {
    switch (widget.direction) {
      case ShimmerDirection.leftToRight:
        return const Alignment(1.0, 0.3);
      case ShimmerDirection.rightToLeft:
        return const Alignment(-1.0, 0.3);
      case ShimmerDirection.topToBottom:
        return const Alignment(0.3, 1.0);
      case ShimmerDirection.bottomToTop:
        return const Alignment(0.3, -1.0);
    }
  }
}

/// Shimmer animasyon yönü
enum ShimmerDirection { leftToRight, rightToLeft, topToBottom, bottomToTop }
