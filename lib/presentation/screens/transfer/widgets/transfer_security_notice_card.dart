import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Güvenlik eşiği uyarısı, kural onay kutusu ve transfer onay butonları (`StatelessWidget`).
class TransferSecurityNoticeCard extends StatelessWidget {
  final bool isAboveFraudThreshold;
  final bool rulesAccepted;
  final bool isSubmitting;
  final ValueChanged<bool> onRulesChanged;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const TransferSecurityNoticeCard({
    super.key,
    required this.isAboveFraudThreshold,
    required this.rulesAccepted,
    required this.isSubmitting,
    required this.onRulesChanged,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isAboveFraudThreshold) ...[
          const _FraudThresholdBanner(),
          const SizedBox(height: 12),
        ],
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Checkbox(
                value: rulesAccepted,
                activeColor: AppColors.primaryTeal,
                onChanged: (v) => onRulesChanged(v ?? true),
              ),
              Expanded(
                child: Text(
                  'TCMB FAST transfer kurallarını, alıcı IBAN doğruluğunu ve işlem detaylarını kontrol ederek onaylıyorum.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.darkNavy,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkNavy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: isSubmitting ? null : onConfirm,
            icon: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.face_unlock_outlined, size: 20),
            label: Text(
              isSubmitting
                  ? 'FAST İşlemi Yapılıyor...'
                  : 'Transferi Onayla (Biyometrik / PIN Simülasyonu)',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: onCancel,
            child: Text(
              'Vazgeç ve İptal Et',
              style: AppTextStyles.labelMedium.copyWith(
                color: const Color(0xFF475569),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FraudThresholdBanner extends StatelessWidget {
  const _FraudThresholdBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFB45309)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.fraudWarningMessage,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF92400E),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

