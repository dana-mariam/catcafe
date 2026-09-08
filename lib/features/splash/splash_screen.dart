import 'package:flutter/material.dart';

import '../../animations/splash/splash_animations.dart';
import '../auth/login/login_screen.dart';
import '../onboarding/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.hasSeenOnboarding,
  });

  final bool hasSeenOnboarding;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _floatingController;

  late final Animation<double> _logoAnimation;

  late final Animation<Offset> _titleAnimation;
  late final Animation<double> _titleFadeAnimation;

  late final Animation<Offset> _taglineAnimation;
  late final Animation<double> _taglineFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Main entrance animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    // Continuous subtle floating animation
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // --------------------------------------------------
    // LOGO
    // Small → Big → Slight Overshoot → Normal
    // --------------------------------------------------

    _logoAnimation = TweenSequence<double>(
      [
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 0.15,
            end: 1.12,
          ).chain(
            CurveTween(
              curve: Curves.easeOutBack,
            ),
          ),
          weight: 75,
        ),
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 1.12,
            end: 1.0,
          ).chain(
            CurveTween(
              curve: Curves.easeOut,
            ),
          ),
          weight: 25,
        ),
      ],
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.48,
        ),
      ),
    );

    // --------------------------------------------------
    // TITLE
    // Slide + Fade
    // --------------------------------------------------

    _titleAnimation = Tween<Offset>(
      begin: const Offset(0, 0.9),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.30,
          0.68,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    _titleFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.30,
        0.62,
        curve: Curves.easeOut,
      ),
    );

    // --------------------------------------------------
    // TAGLINE
    // Small Slide + Fade
    // --------------------------------------------------

    _taglineAnimation = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.60,
          0.88,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _taglineFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.58,
        0.86,
        curve: Curves.easeIn,
      ),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    _floatingController.repeat(
      reverse: true,
    );

    await _controller.forward();

    if (!mounted) return;

    await Future.delayed(
      const Duration(milliseconds: 550),
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) {
          return widget.hasSeenOnboarding
              ? const LoginScreen()
              : const OnboardingScreen();
        },
        transitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7EBD8),
      body: Stack(
        children: [
          // --------------------------------------------------
          // BACKGROUND DECORATIONS
          // --------------------------------------------------

          AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              final value = _floatingController.value;

              return Stack(
                children: [
                  Positioned(
                    top: 90 + (value * 18),
                    left: -35,
                    child: _buildBackgroundCircle(
                      size: 150,
                    ),
                  ),

                  Positioned(
                    top: 210 - (value * 15),
                    right: -55,
                    child: _buildBackgroundCircle(
                      size: 190,
                    ),
                  ),

                  Positioned(
                    bottom: 100 + (value * 12),
                    left: 35,
                    child: _buildBackgroundCircle(
                      size: 90,
                    ),
                  ),

                  Positioned(
                    bottom: 65 - (value * 10),
                    right: 45,
                    child: _buildBackgroundCircle(
                      size: 75,
                    ),
                  ),
                ],
              );
            },
          ),

          // --------------------------------------------------
          // MAIN CONTENT
          // --------------------------------------------------

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO
                SplashLogoAnimation(
                  animation: _logoAnimation,
                  floatingAnimation: Tween<double>(
                    begin: -5,
                    end: 5,
                  ).animate(
                    CurvedAnimation(
                      parent: _floatingController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: Image.asset(
                    'lib/assets/images/1eeff59a-8095-439f-b65a-841b45972423.png',
                    width: 230,
                  ),
                ),

                const SizedBox(height: 28),

                // APP NAME
                SplashTitleAnimation(
                  slideAnimation: _titleAnimation,
                  fadeAnimation: _titleFadeAnimation,
                  child: Text(
                    'Purr & Pour',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // TAGLINE
                SplashTaglineAnimation(
                  slideAnimation: _taglineAnimation,
                  fadeAnimation: _taglineFadeAnimation,
                  child: Text(
                    'Coffee • Cats • Cozy',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundCircle({
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(
          alpha: 0.18,
        ),
      ),
    );
  }
}