import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.section),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: AppTextStyles.secondary),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _btn(Icons.remove_rounded, onDecrease),
        Container(
          width: 36,
          alignment: Alignment.center,
          child: Text('$quantity', style: AppTextStyles.product),
        ),
        _btn(Icons.add_rounded, onIncrease),
      ],
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) {
    return Material(
      color: AppColors.overlay,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 16, color: AppColors.brown),
        ),
      ),
    );
  }
}

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final String status;

  static String labelFor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'processing':
      case 'preparing':
        return 'Processing';
      case 'out for delivery':
      case 'out_for_delivery':
        return 'Out for delivery';
      case 'delivered':
      case 'completed':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        if (status.isEmpty) return 'Pending';
        return status[0].toUpperCase() + status.substring(1);
    }
  }

  static int stepFor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'processing':
      case 'preparing':
        return 1;
      case 'out for delivery':
      case 'out_for_delivery':
        return 2;
      case 'delivered':
      case 'completed':
        return 3;
      default:
        return 0;
    }
  }

  Color get _color {
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      case 'out for delivery':
      case 'out_for_delivery':
        return AppColors.caramel;
      default:
        return AppColors.brown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        labelFor(status),
        style: AppTextStyles.caption.copyWith(
          color: color,
          letterSpacing: 0.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class OrderProgress extends StatelessWidget {
  const OrderProgress({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final step = OrderStatusBadge.stepFor(status);
    const labels = ['Pending', 'Processing', 'On the way', 'Delivered'];

    return Row(
      children: List.generate(4, (index) {
        final active = index <= step;
        return Expanded(
          child: Column(
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
                decoration: BoxDecoration(
                  color: active ? AppColors.brown : AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                labels[index],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  color: active ? AppColors.brown : AppColors.muted,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
