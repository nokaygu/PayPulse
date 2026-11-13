import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// ERP & Muhasebe defter senkronizasyon kartı ve ortak detay satırı (`StatelessWidget`).
class ErpIntegrationCard extends StatelessWidget {
  final String batchId;

  const ErpIntegrationCard({super.key, required this.batchId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const _ErpHeaderRow(),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ErpDetailRow(label: 'Muhasebe Fiş No:', value: batchId),
                const SizedBox(height: 6),
                const ErpDetailRow(
                  label: 'Yevmiye Kaydı:',
                  value: '770.01 - Genel Yönetim Giderleri',
                ),
                const SizedBox(height: 6),
                const ErpDetailRow(
                  label: 'KDV Mahsubu:',
                  value: '191 İndirilecek KDV',
                ),
                const SizedBox(height: 6),
                const ErpDetailRow(
                  label: 'GİB E-Arşiv Durumu:',
                  value: 'İletildi & Arşivlendi',
                  valueColor: AppColors.primaryTeal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErpHeaderRow extends StatelessWidget {
  const _ErpHeaderRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.darkNavy,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.computer_rounded,
            color: Color(0xFF5EEAD4),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ERP & Muhasebe Entegrasyonu',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '● Canlı Senkronizasyon Başarılı',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primaryTeal,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '✓ Logo &\nParaşüt',
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              color: const Color(0xFF065F46),
              fontSize: 9.5,
              height: 1.15,
            ),
          ),
        ),
      ],
    );
  }
}

/// Toplu onay ve ERP dekont kartları için etiket-değer satırı.
class ErpDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const ErpDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(
              color: valueColor ?? AppColors.darkNavy,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

