import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Görsel 3 ve Görsel 9'da kullanılan kurumsal işlem satırı bileşeni.
class TransactionListTileWidget extends StatelessWidget {
  final String title;
  final String badgeText;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final String subtitle;
  final String amountText;
  final bool isIncome;
  final String statusOrNoteText;
  final Color? statusTextColor;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const TransactionListTileWidget({
    super.key,
    required this.title,
    required this.badgeText,
    this.badgeBgColor = const Color(0xFFE0F2FE),
    this.badgeTextColor = const Color(0xFF0369A1),
    required this.subtitle,
    required this.amountText,
    required this.isIncome,
    required this.statusOrNoteText,
    this.statusTextColor,
    required this.icon,
    this.iconBgColor = const Color(0xFFF1F5F9),
    this.iconColor = AppColors.darkNavy,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.darkNavy,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: badgeTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amountText,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: isIncome ? AppColors.incomeGreen : AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusOrNoteText,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: statusTextColor ?? const Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

