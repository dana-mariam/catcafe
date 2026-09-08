import 'package:flutter/material.dart';

class SplashLogoAnimation extends StatelessWidget {
  const SplashLogoAnimation({
    super.key,
    required this.animation,
    required this.floatingAnimation,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> floatingAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        animation,
        floatingAnimation,
      ]),
      builder: (context, child) {
        final floatingOffset = floatingAnimation.value;

        return Transform.translate(
          offset: Offset(0, floatingOffset),
          child: FadeTransition(
            opacity: animation,
            child: Transform.scale(
              scale: animation.value,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class SplashTitleAnimation extends StatelessWidget {
  const SplashTitleAnimation({
    super.key,
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.child,
  });

  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }
}

class SplashTaglineAnimation extends StatelessWidget {
  const SplashTaglineAnimation({
    super.key,
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.child,
  });

  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }
}