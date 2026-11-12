import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

enum BadgeType { primary, success, warning, error, darkGlass }

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
        bg = AppDarkColors.tertiaryFixed;
        fg = AppDarkColors.onTertiaryFixedVariant;
        break;
      case BadgeType.warning:
        bg = AppLightColors.tertiaryFixed;
        fg = AppLightColors.onTertiaryFixedVariant;
        break;
      case BadgeType.error:
        bg = AppLightColors.errorContainer;
        fg = AppLightColors.onErrorContainer;
        break;
      case BadgeType.darkGlass:
        bg = const Color(0x24FFFFFF);
        fg = AppDarkColors.primary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}