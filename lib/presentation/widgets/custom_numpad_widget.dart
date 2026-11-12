import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// FAST Transfer ve Sanal POS tutar giriş ekranlarında kullanılan ortak Numpad.
class CustomNumpadWidget extends StatelessWidget {
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback? onDecimalPressed;

  const CustomNumpadWidget({
    super.key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
    this.onDecimalPressed,
  });

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      [',', '0', 'BACK'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: row.map((key) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _buildKeyButton(key),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeyButton(String key) {
    final bool isBack = key == 'BACK';
    final bool isComma = key == ',';

    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          if (isBack) {
            onBackspacePressed();
          } else if (isComma) {
            if (onDecimalPressed != null) {
              onDecimalPressed!();
            } else {
              onDigitPressed(',');
            }
          } else {
            onDigitPressed(key);
          }
        },
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: isBack
              ? const Icon(
                  Icons.backspace_outlined,
                  color: AppColors.darkNavy,
                  size: 22,
                )
              : Text(
                  key,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}
