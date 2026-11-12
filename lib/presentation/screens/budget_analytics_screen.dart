import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'auth/widgets/budget_donut_chart.dart';
import 'auth/widgets/dark_gradient_hero_card.dart';
import 'auth/widgets/status_badge_widget.dart';
import 'auth/widgets/weekly_bar_chart.dart';

class BudgetAnalyticsScreen extends StatelessWidget {
  const BudgetAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    const categories = [
      DonutChartItem(label: 'Market', percentage: 42, color: AppLightColors.primary),
      DonutChartItem(label: 'Ulaşım', percentage: 24, color: AppLightColors.secondaryContainer),
      DonutChartItem(label: 'Faturalar', percentage: 18, color: AppLightColors.tertiaryContainer),
      DonutChartItem(label: 'Yeme & İçme', percentage: 10, color: AppDarkColors.tertiaryContainer),
      DonutChartItem(label: 'Diğer', percentage: 6, color: AppLightColors.outline),
    ];

    const weeklyPoints = [
      BarChartPoint(label: 'Pzt', value: 1200),
      BarChartPoint(label: 'Sal', value: 850),
      BarChartPoint(label: 'Çar', value: 1900),
      BarChartPoint(label: 'Per', value: 1450),
      BarChartPoint(label: 'Cum', value: 2800, isHighlighted: true),
      BarChartPoint(label: 'Cmt', value: 2100),
      BarChartPoint(label: 'Paz', value: 950),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Bütçe ve Analitik', style: AppTextStyles.headlineSmall),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 6.580 TL Kalan Harcama Hakkı Kartı
            DarkGradientHeroCard(
              title: 'Kalan Harcama Hakkı (Kasım)',
              mainAmount: '₺6.580,00',
              subtitle: 'Aylık Bütçe: ₺25.000,00 • Harcanan: ₺18.420,00',
              topRightBadge: const StatusBadgeWidget(
                label: 'Limit uyarısı (%94)',
                type: BadgeType.warning,
                icon: Icons.warning_amber_rounded,
              ),
              bottomChild: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: const LinearProgressIndicator(
                  value: 0.74,
                  minHeight: 8,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(AppDarkColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Haftalık Harcama Trendi Bar Grafiği
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Haftalık Harcama Trendi', style: AppTextStyles.headlineSmall),
                        const StatusBadgeWidget(label: 'Bu Hafta', type: BadgeType.primary),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const WeeklyBarChart(points: weeklyPoints),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. 5 Kategorili Halka Grafik + Progress Bar Listesi
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kategori Bazlı Dağılım', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 20),
                    const Center(
                      child: BudgetDonutChart(
                        items: categories,
                        centerTitle: '%100',
                        centerSubtitle: '5 Kategori',
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...categories.map((cat) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(radius: 5, backgroundColor: cat.color),
                                      const SizedBox(width: 8),
                                      Text(cat.label, style: AppTextStyles.bodyLarge),
                                    ],
                                  ),
                                  Text('%${cat.percentage.toInt()}', style: AppTextStyles.labelLarge),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: cat.percentage / 100,
                                  minHeight: 6,
                                  backgroundColor: AppLightColors.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 4. "Yeni Laptop (M4 Pro)" Tasarruf Hedefi Kartı
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppLightColors.primaryFixed,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.laptop_mac_rounded, color: colorScheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Yeni Laptop (M4 Pro)', style: AppTextStyles.headlineSmall),
                              Text('Tasarruf Hedefi • ₺64.000 / ₺80.000', style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        const StatusBadgeWidget(label: '%80', type: BadgeType.success),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 0.80,
                        minHeight: 8,
                        backgroundColor: AppLightColors.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}