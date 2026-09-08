import 'package:flutter/material.dart';

/// ============================================================
/// ADOPTION HEADER ANIMATION
/// ============================================================
///
/// Header drops down smoothly when the screen opens.
/// ============================================================

class AdoptionHeaderAnimation extends StatefulWidget {
  const AdoptionHeaderAnimation({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AdoptionHeaderAnimation> createState() =>
      _AdoptionHeaderAnimationState();
}

class _AdoptionHeaderAnimationState
    extends State<AdoptionHeaderAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fade;
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
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -0.20),
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
        child: widget.child,
      ),
    );
  }
}

/// ============================================================
/// ADOPTION HEADER ICON ANIMATION
/// ============================================================
///
/// Small scale + rotation for the paw icon.
/// ============================================================

class AdoptionHeaderIconAnimation extends StatefulWidget {
  const AdoptionHeaderIconAnimation({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AdoptionHeaderIconAnimation> createState() =>
      _AdoptionHeaderIconAnimationState();
}

class _AdoptionHeaderIconAnimationState
    extends State<AdoptionHeaderIconAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _scale;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _scale = TweenSequence<double>(
      [
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 0.65,
            end: 1.08,
          ),
          weight: 70,
        ),
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 1.08,
            end: 1.0,
          ),
          weight: 30,
        ),
      ],
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _rotation = Tween<double>(
      begin: -0.10,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    Future.delayed(
      const Duration(milliseconds: 180),
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
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotation.value,
          child: Transform.scale(
            scale: _scale.value,
            child: child,
          ),
        );
      },
    );
  }
}

/// ============================================================
/// ADOPTION INTRO ANIMATION
/// ============================================================
///
/// Intro card slides in from the right.
/// ============================================================

class AdoptionIntroAnimation extends StatefulWidget {
  const AdoptionIntroAnimation({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AdoptionIntroAnimation> createState() =>
      _AdoptionIntroAnimationState();
}

class _AdoptionIntroAnimationState
    extends State<AdoptionIntroAnimation>
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
      duration: const Duration(milliseconds: 650),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0.18, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _scale = Tween<double>(
      begin: 0.96,
      end: 1.0,
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
        child: ScaleTransition(
          scale: _scale,
          child: widget.child,
        ),
      ),
    );
  }
}

/// ============================================================
/// ADOPTION CARD ANIMATION
/// ============================================================
///
/// Cards enter one after another.
///
/// Odd cards  -> from right
/// Even cards -> from left
///
/// The card slightly overshoots its position and settles.
/// ============================================================

class AdoptionCardAnimation extends StatefulWidget {
  const AdoptionCardAnimation({
    super.key,
    required this.child,
    required this.delay,
    required this.fromRight,
  });

  final Widget child;
  final Duration delay;
  final bool fromRight;

  @override
  State<AdoptionCardAnimation> createState() =>
      _AdoptionCardAnimationState();
}

class _AdoptionCardAnimationState
    extends State<AdoptionCardAnimation>
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
      duration: const Duration(milliseconds: 720),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.0,
        0.65,
        curve: Curves.easeOut,
      ),
    );

    _scale = TweenSequence<double>(
      [
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 0.92,
            end: 1.025,
          ).chain(
            CurveTween(
              curve: Curves.easeOutCubic,
            ),
          ),
          weight: 78,
        ),
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 1.025,
            end: 1.0,
          ).chain(
            CurveTween(
              curve: Curves.easeOut,
            ),
          ),
          weight: 22,
        ),
      ],
    ).animate(_controller);

    final horizontalOffset =
    widget.fromRight ? 0.22 : -0.22;

    _slide = Tween<Offset>(
      begin: Offset(horizontalOffset, 0.035),
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
        child: ScaleTransition(
          scale: _scale,
          child: widget.child,
        ),
      ),
    );
  }
}

/// ============================================================
/// ADOPTION IMAGE ANIMATION
/// ============================================================
///
/// The cat image briefly zooms in and settles back.
/// This makes the image feel alive without being distracting.
/// ============================================================

class AdoptionImageAnimation extends StatefulWidget {
  const AdoptionImageAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  State<AdoptionImageAnimation> createState() =>
      _AdoptionImageAnimationState();
}

class _AdoptionImageAnimationState
    extends State<AdoptionImageAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _scale = TweenSequence<double>(
      [
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 1.08,
            end: 0.985,
          ).chain(
            CurveTween(
              curve: Curves.easeOutCubic,
            ),
          ),
          weight: 70,
        ),
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 0.985,
            end: 1.0,
          ).chain(
            CurveTween(
              curve: Curves.easeOut,
            ),
          ),
          weight: 30,
        ),
      ],
    ).animate(_controller);

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
    return ClipRect(
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}