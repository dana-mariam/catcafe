import 'dart:math' as math;

import 'package:flutter/material.dart';

/// ============================================================
/// LOGIN LOGO ANIMATION
/// ============================================================

class LoginLogoAnimation extends StatefulWidget {
  const LoginLogoAnimation({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<LoginLogoAnimation> createState() =>
      _LoginLogoAnimationState();
}

class _LoginLogoAnimationState
    extends State<LoginLogoAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
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
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final value = Curves.easeOutBack.transform(
          _controller.value,
        );

        final scale = 0.72 + (value * 0.28);

        final opacity =
        _controller.value.clamp(0.0, 1.0);

        final rotation =
            -0.035 * (1 - _controller.value);

        return Opacity(
          opacity: opacity,
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// ============================================================
/// LOGIN TEXT ANIMATION
/// ============================================================

class LoginTextAnimation extends StatefulWidget {
  const LoginTextAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  State<LoginTextAnimation> createState() =>
      _LoginTextAnimationState();
}

class _LoginTextAnimationState
    extends State<LoginTextAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _start();
  }

  Future<void> _start() async {
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
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(
          _controller.value,
        );

        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(
              0,
              -28 * (1 - t),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// ============================================================
/// LOGIN CARD ANIMATION
/// ============================================================

class LoginCardAnimation extends StatefulWidget {
  const LoginCardAnimation({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<LoginCardAnimation> createState() =>
      _LoginCardAnimationState();
}

class _LoginCardAnimationState
    extends State<LoginCardAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    Future.delayed(
      const Duration(milliseconds: 300),
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
        final t = Curves.easeOutCubic.transform(
          _controller.value,
        );

        final scale = 0.94 + (0.06 * t);

        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(
              0,
              65 * (1 - t),
            ),
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// ============================================================
/// LOGIN FIELD ANIMATION
/// ============================================================

class LoginFieldAnimation extends StatefulWidget {
  const LoginFieldAnimation({
    super.key,
    required this.child,
    required this.fromRight,
    this.delay = Duration.zero,
  });

  final Widget child;
  final bool fromRight;
  final Duration delay;

  @override
  State<LoginFieldAnimation> createState() =>
      _LoginFieldAnimationState();
}

class _LoginFieldAnimationState
    extends State<LoginFieldAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    _start();
  }

  Future<void> _start() async {
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
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(
          _controller.value,
        );

        final direction =
        widget.fromRight ? 1.0 : -1.0;

        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(
              direction * 45 * (1 - t),
              0,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// ============================================================
/// LOGIN BUTTON ANIMATION
/// ============================================================

class LoginButtonAnimation extends StatefulWidget {
  const LoginButtonAnimation({
    super.key,
    required this.child,
    this.delay = const Duration(milliseconds: 650),
  });

  final Widget child;
  final Duration delay;

  @override
  State<LoginButtonAnimation> createState() =>
      _LoginButtonAnimationState();
}

class _LoginButtonAnimationState
    extends State<LoginButtonAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _start();
  }

  Future<void> _start() async {
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
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeOutBack.transform(
          _controller.value,
        );

        final scale = 0.88 + (0.12 * t);

        return Opacity(
          opacity: _controller.value.clamp(
            0.0,
            1.0,
          ),
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
    );
  }
}

/// ============================================================
/// PAW TRAIL ANIMATION
/// ============================================================

class LoginPawTrailAnimation extends StatefulWidget {
  const LoginPawTrailAnimation({
    super.key,
  });

  @override
  State<LoginPawTrailAnimation> createState() =>
      _LoginPawTrailAnimationState();
}

class _LoginPawTrailAnimationState
    extends State<LoginPawTrailAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const int pawCount = 6;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    Future.delayed(
      const Duration(milliseconds: 450),
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

  double _pawProgress(int index) {
    const pawDuration = 0.38;
    const pawDelay = 0.105;

    final start = index * pawDelay;
    final end = start + pawDuration;

    final progress =
        (_controller.value - start) /
            (end - start);

    return progress.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Positioned.fill(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

                return Stack(
                  clipBehavior: Clip.none,
                  children: List.generate(
                    pawCount,
                        (index) {
                      final progress =
                      _pawProgress(index);

                      if (progress <= 0) {
                        return const SizedBox.shrink();
                      }

                      final curved =
                      Curves.easeOutCubic.transform(
                        progress,
                      );

                      // ======================================
                      // START
                      // Clearly at the bottom of the screen.
                      // ======================================

                      final startX =
                          width *
                              (0.18 +
                                  index * 0.065);

                      final startY =
                          height * 1.02;

                      // ======================================
                      // END
                      // Moves upward toward the login card.
                      // ======================================

                      final endX =
                          width *
                              (0.40 +
                                  index * 0.045);

                      final endY =
                          height *
                              (0.70 -
                                  index * 0.035);

                      final x =
                          startX +
                              (endX - startX) *
                                  curved;

                      final y =
                          startY +
                              (endY - startY) *
                                  curved;

                      // ======================================
                      // PAW APPEAR / DISAPPEAR
                      // ======================================

                      double opacity;

                      if (progress < 0.15) {
                        opacity =
                            progress / 0.15;
                      } else if (progress > 0.82) {
                        opacity =
                            (1 - progress) / 0.18;
                      } else {
                        opacity = 1.0;
                      }

                      // ======================================
                      // SCALE
                      // ======================================

                      double scale;

                      if (progress < 0.12) {
                        scale =
                            0.55 +
                                (progress / 0.12) *
                                    0.45;
                      } else if (progress > 0.82) {
                        scale =
                            1.0 +
                                ((progress - 0.82) /
                                    0.18) *
                                    0.15;
                      } else {
                        scale = 1.0;
                      }

                      // ======================================
                      // SLIGHT ROTATION
                      // ======================================

                      final rotation =
                          (index.isEven ? -1 : 1) *
                              (0.10 +
                                  math.sin(
                                    progress *
                                        math.pi,
                                  ) *
                                      0.06);

                      return Positioned(
                        left: x - 12,
                        top: y - 12,
                        child: Opacity(
                          opacity:
                          opacity.clamp(
                            0.0,
                            1.0,
                          ),
                          child: Transform.rotate(
                            angle: rotation,
                            child: Transform.scale(
                              scale: scale,
                              child: const Icon(
                                Icons.pets_rounded,
                                size: 24,
                                color: Color(
                                  0xFF713D27,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}