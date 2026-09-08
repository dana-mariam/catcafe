import 'package:flutter/material.dart';

/// Entrance animation for Home screen elements.
class HomeEntranceAnimation extends StatefulWidget {
  const HomeEntranceAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.offset = const Offset(0, 0.08),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;

  @override
  State<HomeEntranceAnimation> createState() =>
      _HomeEntranceAnimationState();
}

class _HomeEntranceAnimationState
    extends State<HomeEntranceAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.offset,
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
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Subtle press animation for Home product cards.
class HomePressScale extends StatefulWidget {
  const HomePressScale({
    super.key,
    required this.child,
    this.scale = 0.97,
  });

  final Widget child;
  final double scale;

  @override
  State<HomePressScale> createState() =>
      _HomePressScaleState();
}

class _HomePressScaleState
    extends State<HomePressScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        setState(() {
          _pressed = true;
        });
      },
      onPointerUp: (_) {
        setState(() {
          _pressed = false;
        });
      },
      onPointerCancel: (_) {
        setState(() {
          _pressed = false;
        });
      },
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        duration:
        const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Subtle continuous animation for the Home Hero.
///
/// The image slowly breathes in and out while the
/// card shadow changes slightly, creating a polished
/// and calm visual effect.
class HomeHeroAnimation extends StatefulWidget {
  const HomeHeroAnimation({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<HomeHeroAnimation> createState() =>
      _HomeHeroAnimationState();
}

class _HomeHeroAnimationState
    extends State<HomeHeroAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _verticalAnimation;
  late final Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.025,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _verticalAnimation = Tween<double>(
      begin: 0,
      end: -2.5,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _shadowAnimation = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(
      reverse: true,
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
        return Transform.translate(
          offset: Offset(
            0,
            _verticalAnimation.value,
          ),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha:
                      0.10 *
                          _shadowAnimation.value,
                    ),
                    blurRadius:
                    18 *
                        _shadowAnimation.value,
                    offset: Offset(
                      0,
                      6 *
                          _shadowAnimation.value,
                    ),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}