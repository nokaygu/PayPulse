import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// QR Ödeme Merkezi üst mod seçici çubuğu (`QR Kodumu Göster` ↔ `QR Okut ve Öde`).
class QrModeSwitcher extends StatelessWidget {
  final bool isShowQrMode;
  final ValueChanged<bool> onModeSelected;

  const QrModeSwitcher({
    super.key,
    required this.isShowQrMode,
    required this.onModeSelected,
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
            child: _QrModeTab(
              label: 'QR Kodumu Göster',
              selected: isShowQrMode,
              onTap: () => onModeSelected(true),
            ),
          ),
          Expanded(
            child: _QrModeTab(
              label: 'QR Okut ve Öde',
              selected: !isShowQrMode,
              onTap: () => onModeSelected(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _QrModeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: selected ? AppColors.darkNavy : const Color(0xFF64748B),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

