import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum BadgeType { primary, success, warning, error, info, darkGlass }

class StatusBadgeWidget extends StatelessWidget {
  final String label;
  final BadgeType type;
  final IconData? icon;

  const StatusBadgeWidget({
    super.key,
    required this.label,
    this.type = BadgeType.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case BadgeType.primary:
        bg = AppLightColors.primaryFixed;
        fg = AppLightColors.onPrimaryFixedVariant;
        break;
      case BadgeType.success:
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        break;
      case BadgeType.warning:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        break;
      case BadgeType.error:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        break;
      case BadgeType.info:
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0369A1);
        break;
      case BadgeType.darkGlass:
        bg = Colors.white.withValues(alpha: 0.12);
        fg = AppColors.primaryGreen;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withValues(alpha: 0.15), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
