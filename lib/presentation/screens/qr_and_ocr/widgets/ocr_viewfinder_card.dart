import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// AI-OCR tarama ekranının kamera vizörü ve algılama önizleme kartı.
class OcrViewfinderCard extends StatelessWidget {
  final String docModeLabel;

  const OcrViewfinderCard({super.key, required this.docModeLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroCardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          _ViewfinderHeader(docModeLabel: docModeLabel),
          const SizedBox(height: 24),
          const _ViewfinderFrame(),
          const SizedBox(height: 16),
          Text(
            'VKN, Tarih, Toplam Tutar ve KDV Matrahı Otomatik Ayrıştırılır',
            style: AppTextStyles.labelSmall.copyWith(
              color: const Color(0xFF5EEAD4),
              fontSize: 10.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ViewfinderHeader extends StatelessWidget {
  final String docModeLabel;

  const _ViewfinderHeader({required this.docModeLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryTeal.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '● AI-OCR Hazır ($docModeLabel)',
            style: AppTextStyles.labelSmall.copyWith(
              color: const Color(0xFF5EEAD4),
              fontSize: 10.5,
            ),
          ),
        ),
        const Icon(Icons.qr_code_scanner, color: Colors.white70, size: 20),
      ],
    );
  }
}

class _ViewfinderFrame extends StatelessWidget {
  const _ViewfinderFrame();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_rounded,
            size: 56,
            color: Color(0xFF5EEAD4),
          ),
          const SizedBox(height: 12),
          Text(
            'Fiş veya faturayı kadraja yerleştirin',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Kamera çekimi, galeri yüklemesi veya manuel fiş girişi sonrası doğrulama adımına yönlendirilirsiniz.',
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF94A3B8),
              fontSize: 11.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

