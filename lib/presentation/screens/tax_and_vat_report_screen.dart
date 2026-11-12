import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'auth/widgets/dark_gradient_hero_card.dart';
import 'auth/widgets/status_badge_widget.dart';
import 'auth/widgets/weekly_bar_chart.dart';

class TaxAndVatReportScreen extends StatelessWidget {
  const TaxAndVatReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    const last4MonthsVat = [
      BarChartPoint(label: 'Ağu', value: 19400),
      BarChartPoint(label: 'Eyl', value: 24100),
      BarChartPoint(label: 'Eki', value: 21800),
      BarChartPoint(label: 'Kas', value: 28450, isHighlighted: true),
    ];

    final expenseAnalysis = [
      ('Kurumsal Yazılım & Bulut', 'Matrah: ₺65.000', 'KDV: ₺13.000 (%20)'),
      ('Personel Yemek & Konaklama', 'Matrah: ₺42.000', 'KDV: ₺4.200 (%10)'),
      ('Operasyon & Lojistik Gideri', 'Matrah: ₺38.500', 'KDV: ₺7.700 (%20)'),
      ('Temel Gıda & Ofis Sarf', 'Matrah: ₺15.000', 'KDV: ₺150 (%1)'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('B2B Raporlar / KDV Analizi', style: AppTextStyles.headlineSmall),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Net Ödenecek KDV (28.450,00 TL) + KDV-1 Beyanname Uyarısı
            DarkGradientHeroCard(
              title: 'Net Ödenecek KDV (Kasım 2026)',
              mainAmount: '₺28.450,00',
              subtitle: 'Hesaplanan: ₺43.500,00 • İndirilecek: ₺15.050,00',
              topRightBadge: const StatusBadgeWidget(
                label: '%100 GİB Uyumlu',
                type: BadgeType.darkGlass,
                icon: Icons.verified_rounded,
              ),
              bottomChild: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppDarkColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'KDV-1 Beyanname son onay tarihi: 28 Kasım 2026',
                      style: AppTextStyles.bodySmall.copyWith(color: AppDarkColors.onSurface),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. KDV Oran Dağılımı (%20 Genel, %10 Hizmet, %1 Temel)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KDV Oran Dağılımı', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildVatRateBox(
                          '%20 Genel',
                          '₺21.400',
                          AppLightColors.primary,
                          AppLightColors.primaryFixed,
                        ),
                        const SizedBox(width: 8),
                        _buildVatRateBox(
                          '%10 Hizmet',
                          '₺6.200',
                          AppLightColors.tertiary,
                          AppLightColors.tertiaryFixed,
                        ),
                        const SizedBox(width: 8),
                        _buildVatRateBox(
                          '%1 Temel',
                          '₺850',
                          AppDarkColors.onTertiaryFixedVariant,
                          AppDarkColors.tertiaryFixed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Son 4 Ay KDV Seyri Grafiği
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Son 4 Ay KDV Seyri', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 16),
                    const WeeklyBarChart(points: last4MonthsVat, maxHeight: 100),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 4. 4'lü Gider & Matrah Analizi Listesi
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gider & Matrah Analizi', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 12),
                    ...expenseAnalysis.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppLightColors.outlineVariant,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.$1, style: AppTextStyles.labelLarge),
                                      const SizedBox(height: 2),
                                      Text(item.$2, style: AppTextStyles.bodySmall),
                                    ],
                                  ),
                                ),
                                StatusBadgeWidget(label: item.$3, type: BadgeType.primary),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVatRateBox(String label, String amount, Color textColor, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelMedium.copyWith(color: textColor)),
            const SizedBox(height: 6),
            Text(amount, style: AppTextStyles.headlineSmall.copyWith(color: AppLightColors.onSurface)),
          ],
        ),
      ),
    );
  }
}