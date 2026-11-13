import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Yaklaşan KDV-1 beyanname taslağı ve GİB bildir kartı (`StatelessWidget`).
class VatDeclarationDraftCard extends StatelessWidget {
  final String periodLabel;
  final VoidCallback onSubmitDraft;

  const VatDeclarationDraftCard({
    super.key,
    required this.periodLabel,
    required this.onSubmitDraft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _DeclarationHeaderRow(periodLabel: periodLabel),
          const SizedBox(height: 12),
          _DeclarationSubmitBanner(onSubmitDraft: onSubmitDraft),
        ],
      ),
    );
  }
}

class _DeclarationHeaderRow extends StatelessWidget {
  final String periodLabel;

  const _DeclarationHeaderRow({required this.periodLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.event_note_rounded,
            color: Color(0xFFDC2626),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Yaklaşan Beyanname: KDV-1',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
              ),
              Text(
                '$periodLabel Dönemi Yasal Bildirimi',
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '15 Gün\nKaldı',
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              color: const Color(0xFFB91C1C),
              fontSize: 10,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _DeclarationSubmitBanner extends StatelessWidget {
  final VoidCallback onSubmitDraft;

  const _DeclarationSubmitBanner({required this.onSubmitDraft});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.laptop_chromebook_rounded,
            color: AppColors.primaryTeal,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ön Taslak Hazır',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'ERP & GİB Fatura Defteri Senkronize',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkNavy,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onSubmitDraft,
            child: const Text(
              'GİB Bildir →',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

