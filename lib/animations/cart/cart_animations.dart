import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// ------------------------------------------------------------
/// CHECKOUT SUCCESS ANIMATION
/// ------------------------------------------------------------

class CartCheckoutSuccessAnimation extends StatefulWidget {
  const CartCheckoutSuccessAnimation({
    super.key,
    this.onFinished,
  });

  final VoidCallback? onFinished;

  @override
  State<CartCheckoutSuccessAnimation> createState() =>
      _CartCheckoutSuccessAnimationState();
}

class _CartCheckoutSuccessAnimationState
    extends State<CartCheckoutSuccessAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _circleAnimation;
  late final Animation<double> _checkAnimation;
  late final Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _circleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.0,
        0.55,
        curve: Curves.easeOutBack,
      ),
    );

    _checkAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.25,
        0.70,
        curve: Curves.easeOutBack,
      ),
    );

    _textAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.55,
        1.0,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward().then((_) {
      widget.onFinished?.call();
    });
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
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(
              scale: _circleAnimation.value,
              child: Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brown.withValues(
                    alpha: 0.10,
                  ),
                ),
                child: Center(
                  child: Transform.scale(
                    scale: _checkAnimation.value,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.brown,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            FadeTransition(
              opacity: _textAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(_textAnimation),
                child: Column(
                  children: [
                    Text(
                      'Order placed!',
                      style: AppTextStyles.section,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your coffee is on its way ☕',
                      style: AppTextStyles.secondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// ------------------------------------------------------------
/// EMPTY CART ANIMATION
/// ------------------------------------------------------------

class CartEmptyAnimation extends StatefulWidget {
  const CartEmptyAnimation({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<CartEmptyAnimation> createState() =>
      _CartEmptyAnimationState();
}

class _CartEmptyAnimationState
    extends State<CartEmptyAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.94,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
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
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// CART ITEM ENTRANCE ANIMATION
/// ------------------------------------------------------------
///
/// Each cart item enters with a small fade + slide.
/// The delay creates a subtle staggered effect.
/// ------------------------------------------------------------

class CartItemAnimation extends StatefulWidget {
  const CartItemAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  State<CartItemAnimation> createState() =>
      _CartItemAnimationState();
}

class _CartItemAnimationState
    extends State<CartItemAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.08, 0),
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