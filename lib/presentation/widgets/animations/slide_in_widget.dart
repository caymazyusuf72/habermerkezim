import 'package:flutter/material.dart';

/// Slide yönleri
enum SlideDirection { up, down, left, right }

/// Slide animasyonu ile widget gösterme
/// Yön parametresi ile yukarı, aşağı, sol, sağ slide destekler
class SlideInWidget extends StatefulWidget {
  final Widget child;
  final SlideDirection direction;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double offset;
  final bool fadeIn;

  const SlideInWidget({
    super.key,
    required this.child,
    this.direction = SlideDirection.up,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.offset = 0.3,
    this.fadeIn = true,
  });

  @override
  State<SlideInWidget> createState() => _SlideInWidgetState();
}

class _SlideInWidgetState extends State<SlideInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    final beginOffset = _getBeginOffset();
    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _fadeAnimation = Tween<double>(
      begin: widget.fadeIn ? 0.0 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _getBeginOffset() {
    switch (widget.direction) {
      case SlideDirection.up:
        return Offset(0, widget.offset);
      case SlideDirection.down:
        return Offset(0, -widget.offset);
      case SlideDirection.left:
        return Offset(widget.offset, 0);
      case SlideDirection.right:
        return Offset(-widget.offset, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );

    if (widget.fadeIn) {
      child = FadeTransition(opacity: _fadeAnimation, child: child);
    }

    return child;
  }
}
