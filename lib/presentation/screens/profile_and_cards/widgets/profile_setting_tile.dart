import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProfileSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? subtitleColor;
  final String? trailingBadge;
  final bool badgeIsSuccess;
  final String? trailingText;
  final bool showDivider;
  final VoidCallback? onTap;
  final bool isDark;

  const ProfileSettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.subtitleColor,
    this.trailingBadge,
    this.badgeIsSuccess = false,
    this.trailingText,
    this.showDivider = true,
    this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryTextColor = isDark ? Colors.white : AppColors.darkNavy;
    final secondaryTextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: primaryTextColor, size: 19),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: primaryTextColor,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: subtitleColor ?? secondaryTextColor,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailingBadge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: badgeIsSuccess
                          ? const Color(0xFFD1FAE5)
                          : (isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      trailingBadge!,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: badgeIsSuccess
                            ? const Color(0xFF065F46)
                            : primaryTextColor,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (trailingText != null) ...[
                  Text(
                    trailingText!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: primaryTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),
      ],
    );
  }
}

class ProfileBiometricSwitchTile extends StatelessWidget {
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const ProfileBiometricSwitchTile({
    super.key,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.fingerprint_rounded,
                  color: AppColors.primaryTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Biyometrik Giriş',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.darkNavy,
                      ),
                    ),
                    Text(
                      'Face ID / Parmak İzi ile aç',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primaryTeal,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
      ],
    );
  }
}

