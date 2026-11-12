import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../../widgets/status_badge_widget.dart';

/// AI-OCR Fiş Veri Doğrulama ve Muhasebeleştirme Ekranı
class OcrDataVerificationScreen extends StatelessWidget {
  const OcrDataVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const RoleSwitchAppBar(
        isBusinessMode: true,
        showBackButton: true,
        customTitle: 'OCR Veri Doğrulama',
        customSubtitle: 'Petrol Ofisi A.Ş. • ₺1.420,50',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tedarikçi Ünvanı'),
                      StatusBadgeWidget(
                        label: '%99 Güven Skoru',
                        type: BadgeType.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'PETROL OFİSİ A.Ş.',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.darkNavy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Divider(height: 24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Toplam Tutar (KDV Dahil)'),
                      Text(
                        '₺1.420,50',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('KDV Oranı (%20)'), Text('₺236,75')],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
