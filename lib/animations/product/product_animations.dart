import 'package:flutter/material.dart';

/// ------------------------------------------------------------
/// PRODUCT IMAGE ENTRANCE
/// ------------------------------------------------------------
///
/// The product image fades in, scales softly and moves upward
/// slightly for a more polished entrance.
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
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.0,
        0.75,
        curve: Curves.easeOut,
      ),
    );

    _scale = TweenSequence<double>(
      [
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 0.90,
            end: 1.02,
          ).chain(
            CurveTween(
              curve: Curves.easeOutCubic,
            ),
          ),
          weight: 75,
        ),
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 1.02,
            end: 1.0,
          ).chain(
            CurveTween(
              curve: Curves.easeOut,
            ),
          ),
          weight: 25,
        ),
      ],
    ).animate(_controller);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.045),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
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
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(
          scale: _scale,
          child: widget.child,
        ),
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
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _scale = Tween<double>(
      begin: 0.985,
      end: 1.0,
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
        child: ScaleTransition(
          scale: _scale,
          child: widget.child,
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// PRODUCT BOTTOM BAR ENTRANCE
/// ------------------------------------------------------------
///
/// Used for the price + Add to Cart button at the bottom.
/// ------------------------------------------------------------

class ProductBottomBarAnimation extends StatefulWidget {
  const ProductBottomBarAnimation({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ProductBottomBarAnimation> createState() =>
      _ProductBottomBarAnimationState();
}

class _ProductBottomBarAnimationState
    extends State<ProductBottomBarAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    Future.delayed(
      const Duration(milliseconds: 250),
          () {
        if (!mounted) return;

        _controller.forward();
      },
    );
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