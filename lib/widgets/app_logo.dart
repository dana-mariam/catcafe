import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 56,
    this.showWordmark = true,
    this.compact = false,
  });

  final double size;
  final bool showWordmark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'lib/assets/images/cat_logo.png',
          width: size,
          height: size,
          errorBuilder: (_, __, ___) {
            return Icon(
              Icons.local_cafe_rounded,
              size: size * 0.8,
              color: AppColors.brown,
            );
          },
        ),
        if (showWordmark) ...[
          SizedBox(height: compact ? 4 : 8),
          Text('Purr & Pour', style: AppTextStyles.display.copyWith(fontSize: compact ? 22 : 28)),
          const SizedBox(height: 2),
          Text(
            'CAT CAFÉ',
            style: AppTextStyles.overline.copyWith(letterSpacing: 3.2),
          ),
        ],
      ],
    );
  }
}
