import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class DarkGradientHeroCard extends StatelessWidget {
  final String title;
  final String mainAmount;
  final String? subtitle;
  final Widget? topRightBadge;
  final Widget? bottomChild;

  const DarkGradientHeroCard({
    super.key,
    required this.title,
    required this.mainAmount,
    this.subtitle,
    this.topRightBadge,
    this.bottomChild,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppDarkColors.surfaceContainerLowest, // #0E0E0E
            Color(0xFF2B160E),                    // Obsidian Terracotta geçişi
            AppLightColors.onPrimaryFixed,        // #380C00
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppDarkColors.outlineVariant,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26380C00),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppDarkColors.onSurfaceVariant,
                  ),
                ),
              ),
              if (topRightBadge != null) topRightBadge!,
            ],
          ),
          const SizedBox(height: 8),
          Text(
            mainAmount,
            style: AppTextStyles.numericBalance.copyWith(
              color: AppDarkColors.onSurface,
              fontSize: 32,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppDarkColors.primary,
              ),
            ),
          ],
          if (bottomChild != null) ...[
            const SizedBox(height: 16),
            const Divider(
              color: AppDarkColors.outlineVariant,
              height: 1,
            ),
            const SizedBox(height: 14),
            bottomChild!,
          ],
        ],
      ),
    );
  }
}