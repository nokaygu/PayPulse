import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class BusinessQuickActionBox extends StatelessWidget {
  final IconData icon;
  final String badgeText;
  final Color badgeBg;
  final Color badgeFg;
  final String title;
  final String subtitle;
  final bool isHighlighted;
  final VoidCallback onTap;

  const BusinessQuickActionBox({
    super.key,
    required this.icon,
    required this.badgeText,
    required this.badgeBg,
    required this.badgeFg,
    required this.title,
    required this.subtitle,
    required this.isHighlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isHighlighted
              ? const Color(0xFFCCFBF1).withValues(alpha: 0.55)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isHighlighted
                ? const Color(0xFF5EEAD4)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? const Color(0xFF0F766E)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isHighlighted ? Colors.white : AppColors.darkNavy,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: badgeFg,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SmallPeriodToggle extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const SmallPeriodToggle({
    super.key,
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: AppTextStyles.labelSmall.copyWith(
            color: active ? AppColors.darkNavy : const Color(0xFF64748B),
            fontSize: 9.5,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

