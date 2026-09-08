import 'package:flutter/material.dart';

/// ------------------------------------------------------------
/// PRODUCT IMAGE ENTRANCE
/// ------------------------------------------------------------
///
/// The product image softly fades in and scales from 0.94 to 1.
/// ------------------------------------------------------------

class ProductImageEntrance extends StatefulWidget {
  const ProductImageEntrance({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ProductImageEntrance> createState() =>
      _ProductImageEntranceState();
}

class _ProductImageEntranceState
    extends State<ProductImageEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scale = Tween<double>(
      begin: 0.94,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
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
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}

/// ------------------------------------------------------------
/// PRODUCT CONTENT ENTRANCE
/// ------------------------------------------------------------
///
/// Used for the product name, category, description and info.
/// ------------------------------------------------------------

class ProductContentAnimation extends StatefulWidget {
  const ProductContentAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  State<ProductContentAnimation> createState() =>
      _ProductContentAnimationState();
}

class _ProductContentAnimationState
    extends State<ProductContentAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
    }

    if (!mounted) return;

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}