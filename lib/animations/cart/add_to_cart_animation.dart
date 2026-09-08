import 'dart:math' as math;

import 'package:flutter/material.dart';

class AddToCartAnimation {
  static Future<void> play({
    required BuildContext context,
    required GlobalKey sourceKey,
    required GlobalKey targetKey,
    required String imageUrl,
  }) async {
    if (imageUrl.isEmpty) return;

    final sourceContext = sourceKey.currentContext;
    final targetContext = targetKey.currentContext;

    if (sourceContext == null || targetContext == null) {
      return;
    }

    final sourceObject = sourceContext.findRenderObject();
    final targetObject = targetContext.findRenderObject();

    if (sourceObject is! RenderBox ||
        targetObject is! RenderBox) {
      return;
    }

    final overlay = Overlay.of(
      context,
      rootOverlay: true,
    );

    final overlayObject =
    overlay.context.findRenderObject();

    if (overlayObject is! RenderBox) {
      return;
    }

    // ==========================================================
    // START POSITION
    // ==========================================================

    final sourceGlobal =
    sourceObject.localToGlobal(Offset.zero);

    final sourceLocal =
    overlayObject.globalToLocal(sourceGlobal);

    final sourceSize = sourceObject.size;

    final startCenter = Offset(
      sourceLocal.dx + sourceSize.width / 2,
      sourceLocal.dy + sourceSize.height / 2,
    );

    // ==========================================================
    // CART POSITION
    // ==========================================================

    final targetGlobal =
    targetObject.localToGlobal(Offset.zero);

    final targetLocal =
    overlayObject.globalToLocal(targetGlobal);

    final targetSize = targetObject.size;

    final endCenter = Offset(
      targetLocal.dx + targetSize.width / 2,
      targetLocal.dy + targetSize.height / 2,
    );

    // ==========================================================
    // CURVE CONTROL POINTS
    //
    // Image starts from the product,
    // moves upward,
    // then curves toward the cart.
    // ==========================================================

    final controlPoint1 = Offset(
      startCenter.dx,
      startCenter.dy - 170,
    );

    final controlPoint2 = Offset(
      endCenter.dx - 35,
      endCenter.dy - 120,
    );

    // ==========================================================
    // CONTROLLER
    // ==========================================================

    final controller = AnimationController(
      vsync: overlay,
      duration: const Duration(
        milliseconds: 1100,
      ),
    );

    // ==========================================================
    // POSITION
    // ==========================================================

    final positionAnimation =
    CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );

    // ==========================================================
    // SCALE
    //
    // Starts relatively large,
    // then continuously shrinks
    // until it reaches the cart.
    // ==========================================================

    final scaleAnimation = Tween<double>(
      begin: 0.52,
      end: 0.055,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInCubic,
      ),
    );

    // ==========================================================
    // ROTATION
    // ==========================================================

    final rotationAnimation = Tween<double>(
      begin: -0.04,
      end: 0.12,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    // ==========================================================
    // OPACITY
    //
    // Keep visible almost until it reaches the cart.
    // ==========================================================

    final opacityAnimation = TweenSequence<double>(
      [
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 1.0,
            end: 1.0,
          ),
          weight: 85,
        ),
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 1.0,
            end: 0.0,
          ).chain(
            CurveTween(
              curve: Curves.easeIn,
            ),
          ),
          weight: 15,
        ),
      ],
    ).animate(controller);

    // ==========================================================
    // FLYING IMAGE SIZE
    // ==========================================================

    final flyingSize = math.min(
      sourceSize.width,
      sourceSize.height,
    ) * 0.52;

    // ==========================================================
    // OVERLAY
    // ==========================================================

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return IgnorePointer(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final t = positionAnimation.value;

              // Cubic Bezier curve.
              final position = _cubicBezier(
                startCenter,
                controlPoint1,
                controlPoint2,
                endCenter,
                t,
              );

              final scale =
                  scaleAnimation.value;

              final size =
                  flyingSize * scale;

              return Positioned(
                left: position.dx - size / 2,
                top: position.dy - size / 2,
                width: size,
                height: size,
                child: Opacity(
                  opacity: opacityAnimation.value,
                  child: Transform.rotate(
                    angle: rotationAnimation.value,
                    child: ClipRRect(
                      borderRadius:
                      BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        width: size,
                        height: size,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) {
                          return const SizedBox();
                        },
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

    overlay.insert(entry);

    try {
      await controller.forward();
    } finally {
      if (entry.mounted) {
        entry.remove();
      }

      controller.dispose();
    }
  }

  // ==========================================================
  // CUBIC BEZIER
  // ==========================================================

  static Offset _cubicBezier(
      Offset p0,
      Offset p1,
      Offset p2,
      Offset p3,
      double t,
      ) {
    final inverse = 1 - t;

    final x =
        inverse * inverse * inverse * p0.dx +
            3 *
                inverse *
                inverse *
                t *
                p1.dx +
            3 *
                inverse *
                t *
                t *
                p2.dx +
            t * t * t * p3.dx;

    final y =
        inverse * inverse * inverse * p0.dy +
            3 *
                inverse *
                inverse *
                t *
                p1.dy +
            3 *
                inverse *
                t *
                t *
                p2.dy +
            t * t * t * p3.dy;

    return Offset(x, y);
  }
}