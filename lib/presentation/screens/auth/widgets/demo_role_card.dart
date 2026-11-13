import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Demo modunda hızlı rol seçimi kartı (`StatelessWidget`).
class DemoRoleCard extends StatelessWidget {
  final String title;
  final String roleBadge;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color badgeBg;
  final Color badgeColor;
  final VoidCallback onTap;

  const DemoRoleCard({
    super.key,
    required this.title,
    required this.roleBadge,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.badgeBg,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _LeadingIcon(icon: icon, iconBg: iconBg, iconColor: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: _RoleInfoColumn(
                  title: title,
                  roleBadge: roleBadge,
                  subtitle: subtitle,
                  badgeBg: badgeBg,
                  badgeColor: badgeColor,
                ),
              ),
              const SizedBox(width: 8),
              const _TrailingArrow(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _LeadingIcon({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: iconBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }
}

class _RoleInfoColumn extends StatelessWidget {
  final String title;
  final String roleBadge;
  final String subtitle;
  final Color badgeBg;
  final Color badgeColor;

  const _RoleInfoColumn({
    required this.title,
    required this.roleBadge,
    required this.subtitle,
    required this.badgeBg,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.darkNavy,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                roleBadge,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmall.copyWith(
            color: const Color(0xFF64748B),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _TrailingArrow extends StatelessWidget {
  const _TrailingArrow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.arrow_forward_rounded,
        size: 16,
        color: Color(0xFF64748B),
      ),
    );
  }
}

