import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Sanal POS sekme seçicisi (`Kredi / Banka Kartı` ↔ `PayPulse QR Tahsilat`).
class PosTabSwitcher extends StatelessWidget {
  final bool isCardTab;
  final ValueChanged<bool> onTabSelected;

  const PosTabSwitcher({
    super.key,
    required this.isCardTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PosTabPill(
              label: 'Kredi / Banka Kartı',
              icon: Icons.credit_card_rounded,
              selected: isCardTab,
              onTap: () => onTabSelected(true),
            ),
          ),
          Expanded(
            child: _PosTabPill(
              label: 'PayPulse QR Tahsilat',
              icon: Icons.qr_code_rounded,
              selected: !isCardTab,
              onTap: () => onTabSelected(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _PosTabPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PosTabPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? AppColors.darkNavy : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: selected
                      ? AppColors.darkNavy
                      : const Color(0xFF64748B),
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

