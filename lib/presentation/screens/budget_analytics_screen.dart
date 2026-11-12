import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'auth/widgets/budget_donut_chart.dart';
import 'auth/widgets/dark_gradient_hero_card.dart';
import 'auth/widgets/status_badge_widget.dart';
import 'auth/widgets/weekly_bar_chart.dart';
import 'budget_analytics/bloc/budget_bloc.dart';
import 'budget_analytics/bloc/budget_event.dart';
import 'budget_analytics/bloc/budget_state.dart';

class BudgetAnalyticsScreen extends StatelessWidget {
  const BudgetAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BudgetBloc()..add(const BudgetLoadRequested('user_1')),
      child: const _BudgetAnalyticsView(),
    );
  }
}

class _BudgetAnalyticsView extends StatelessWidget {
  const _BudgetAnalyticsView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    const weeklyPoints = [
      BarChartPoint(label: 'Pzt', value: 1200),
      BarChartPoint(label: 'Sal', value: 850),
      BarChartPoint(label: 'Çar', value: 1900),
      BarChartPoint(label: 'Per', value: 1450),
      BarChartPoint(label: 'Cum', value: 2800, isHighlighted: true),
      BarChartPoint(label: 'Cmt', value: 2100),
      BarChartPoint(label: 'Paz', value: 950),
    ];

    final chartColors = [
      AppLightColors.primary,
      AppLightColors.secondaryContainer,
      AppLightColors.tertiaryContainer,
      AppDarkColors.tertiaryContainer,
      AppLightColors.outline,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Bütçe ve Analitik', style: AppTextStyles.headlineSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<BudgetBloc>().add(const BudgetRefreshRequested());
            },
          ),
        ],
      ),
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final budget = state.budget;
          if (budget == null) {
            return Center(
              child: Text(
                state.errorMessage ?? 'Bütçe verisi bulunamadı.',
                style: AppTextStyles.bodyLarge,
              ),
            );
          }

          final remainingTl = (budget.remainingQuotaInKurus / 100.0).toStringAsFixed(2);
          final totalQuotaTl = (budget.monthlyQuotaInKurus / 100.0).toStringAsFixed(2);
          final spentTl = (budget.spentInKurus / 100.0).toStringAsFixed(2);

          final donutItems = budget.categories.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final color = chartColors[index % chartColors.length];
            final percent = budget.spentInKurus > 0
                ? (item.spentInKurus / budget.spentInKurus) * 100
                : 0.0;
            return DonutChartItem(
              label: item.title,
              percentage: percent,
              color: color,
            );
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Kalan Harcama Hakkı Hero Kartı
                DarkGradientHeroCard(
                  title: 'Kalan Harcama Hakkı (Kasım)',
                  mainAmount: '₺$remainingTl',
                  subtitle: 'Aylık Bütçe: ₺$totalQuotaTl • Harcanan: ₺$spentTl',
                  topRightBadge: StatusBadgeWidget(
                    label: 'Kalan: %${budget.remainingPercentage}',
                    type: budget.spentRatio >= 0.90
                        ? BadgeType.error
                        : budget.spentRatio >= 0.70
                            ? BadgeType.warning
                            : BadgeType.success,
                    icon: budget.spentRatio >= 0.90
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline_rounded,
                  ),
                  bottomChild: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: budget.spentRatio,
                      minHeight: 8,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        budget.spentRatio >= 0.90
                            ? Colors.redAccent
                            : AppDarkColors.primary,
                      ),
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
                            Text('Haftalık Harcama Trendi',
                                style: AppTextStyles.headlineSmall),
                            const StatusBadgeWidget(
                              label: 'Bu Hafta',
                              type: BadgeType.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const WeeklyBarChart(points: weeklyPoints),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Kategori Bazlı Dağılım Halka Grafiği
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kategori Bazlı Dağılım',
                            style: AppTextStyles.headlineSmall),
                        const SizedBox(height: 20),
                        Center(
                          child: BudgetDonutChart(
                            items: donutItems,
                            centerTitle: '%100',
                            centerSubtitle: '${budget.categories.length} Kategori',
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...donutItems.map((cat) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                              radius: 5,
                                              backgroundColor: cat.color),
                                          const SizedBox(width: 8),
                                          Text(cat.label,
                                              style: AppTextStyles.bodyLarge),
                                        ],
                                      ),
                                      Text('%${cat.percentage.toInt()}',
                                          style: AppTextStyles.labelLarge),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: (cat.percentage / 100).clamp(0.0, 1.0),
                                      minHeight: 6,
                                      backgroundColor:
                                          AppLightColors.surfaceContainerHighest,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(cat.color),
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

                // 4. Akıllı Tasarruf Hedefi Kartı
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
                              child: Icon(Icons.laptop_mac_rounded,
                                  color: colorScheme.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(budget.savingsGoalTitle,
                                      style: AppTextStyles.headlineSmall),
                                  Text(
                                    'Tasarruf Hedefi • ₺${(budget.savingsCurrentInKurus / 100).toStringAsFixed(0)} / ₺${(budget.savingsTargetInKurus / 100).toStringAsFixed(0)}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            StatusBadgeWidget(
                              label: '%${budget.savingsProgressPercentage}',
                              type: BadgeType.success,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (budget.savingsCurrentInKurus /
                                    budget.savingsTargetInKurus)
                                .clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor:
                                AppLightColors.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
