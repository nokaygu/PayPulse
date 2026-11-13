import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Gelen (Alış) / Giden (Satış) E-Fatura sekme seçicisi (`Expanded` doğrudan `Row` içindedir).
class InvoiceDirectionTabBar extends StatelessWidget {
  final int incomingCount;
  final int outgoingCount;
  final bool isIncomingTab;
  final ValueChanged<bool> onSelectTab;

  const InvoiceDirectionTabBar({
    super.key,
    required this.incomingCount,
    required this.outgoingCount,
    required this.isIncomingTab,
    required this.onSelectTab,
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
            child: _TabButton(
              icon: Icons.arrow_downward_rounded,
              label: 'Gelen (Alış)  $incomingCount',
              isSelected: isIncomingTab,
              onTap: () => onSelectTab(true),
            ),
          ),
          Expanded(
            child: _TabButton(
              icon: Icons.arrow_upward_rounded,
              label: 'Giden (Satış)  $outgoingCount',
              isSelected: !isIncomingTab,
              onTap: () => onSelectTab(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? AppColors.primaryTeal : const Color(0xFF64748B),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? AppColors.darkNavy : const Color(0xFF64748B),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
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

