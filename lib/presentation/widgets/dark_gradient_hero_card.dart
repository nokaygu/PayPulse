import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class DarkGradientHeroCard extends StatelessWidget {
  final String title;
  final String mainAmount;
  final String? subtitle;
  final Widget? topRightBadge;
  final Widget? bottomChild;
  final VoidCallback? onTap;

  const DarkGradientHeroCard({
    super.key,
    required this.title,
    required this.mainAmount,
    this.subtitle,
    this.topRightBadge,
    this.bottomChild,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.heroCardGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkNavy.withOpacity(0.4),
              blurRadius: 18,
              offset: const Offset(0, 8),
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
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                if (topRightBadge != null) topRightBadge!,
              ],
            ),
            const SizedBox(height: 10),
            Text(
              mainAmount,
              style: AppTextStyles.numericBalance.copyWith(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
            if (bottomChild != null) ...[
              const SizedBox(height: 16),
              Divider(
                color: Colors.white.withOpacity(0.12),
                height: 1,
              ),
              const SizedBox(height: 14),
              bottomChild!,
            ],
          ],
        ),
      ),
    );
  }
}

