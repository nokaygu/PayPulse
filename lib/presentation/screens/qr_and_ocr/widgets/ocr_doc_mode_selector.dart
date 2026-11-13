import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// AI-OCR belge tipi sekme seçicisi (`Expanded` doğrudan `Row` içindedir).
class OcrDocModeSelector extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const OcrDocModeSelector({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(
          labels.length,
          (index) => Expanded(
            child: _DocModeTab(
              label: labels[index],
              selected: selectedIndex == index,
              onTap: () => onSelect(index),
            ),
          ),
        ),
      ),
    );
  }
}

class _DocModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DocModeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: selected ? AppColors.darkNavy : const Color(0xFF64748B),
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 11,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

