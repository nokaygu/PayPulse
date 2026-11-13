import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Transfer özet ekranının üst başlık ve 4 adımlı ilerleme çubuğu (`StatelessWidget`).
class TransferStepIndicator extends StatelessWidget {
  final bool isPaymentRequestFlow;
  final VoidCallback onBack;

  const TransferStepIndicator({
    super.key,
    required this.isPaymentRequestFlow,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 18,
                  color: AppColors.darkNavy,
                ),
              ),
            ),
            Column(
              children: [
                Text(
                  isPaymentRequestFlow ? 'Ödeme Talebi Onayı' : 'Transfer Özeti',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 12,
                      color: AppColors.primaryTeal,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '256-Bit SSL Uçtan Uca Şifreli',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primaryTeal,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(
                Icons.verified_user_outlined,
                size: 18,
                color: AppColors.primaryTeal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StepCircle('1. Alıcı', stepNum: 1, isCompleted: true),
              _StepCircle('2. Tutar', stepNum: 2, isCompleted: true),
              _StepCircle('3. Onay', stepNum: 3, isCurrent: true),
              _StepCircle('4. Sonuç', stepNum: 4),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  final String label;
  final int stepNum;
  final bool isCompleted;
  final bool isCurrent;

  const _StepCircle(
    this.label, {
    required this.stepNum,
    this.isCompleted = false,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.primaryTeal
                : (isCurrent ? AppColors.darkNavy : const Color(0xFFF1F5F9)),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : Text(
                  '$stepNum',
                  style: TextStyle(
                    color: isCurrent ? Colors.white : const Color(0xFF64748B),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isCurrent ? AppColors.darkNavy : const Color(0xFF64748B),
            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }
}

