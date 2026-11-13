import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../widgets/weekly_bar_chart.dart';
import '../bloc/business_overview_cubit.dart';
import 'business_metric_card.dart';
import 'business_quick_action_box.dart';

class BusinessMetricsGrid extends StatelessWidget {
  final BusinessOverviewState state;

  const BusinessMetricsGrid({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: BusinessMetricCard(
                icon: Icons.trending_up_rounded,
                badge: '+%18',
                badgeIsGreen: true,
                title: 'Bugünkü Tahsilat',
                amount: FinancialAmount.format(state.todayTransactionsKurus),
                subtitle: 'POS & FAST toplamı',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: BusinessMetricCard(
                icon: Icons.calendar_month_outlined,
                badge: '${state.posTransactions.length} POS',
                badgeIsGreen: true,
                title: 'POS Hacmi',
                amount: FinancialAmount.format(state.posTotalKurus),
                subtitle: 'Onaylı kart işlemleri',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: BusinessMetricCard(
                icon: Icons.fact_check_outlined,
                badge: '${state.pendingExpenseCount} Bekleyen',
                badgeIsGreen: state.pendingExpenseCount == 0,
                title: 'Masraf Talepleri',
                amount: '${state.expenses.length} Fiş',
                subtitle: 'Personel harcamaları',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: BusinessMetricCard(
                icon: Icons.percent_rounded,
                badge: '%1,39 Ort.',
                badgeIsGreen: false,
                title: 'Komisyon Kesintisi',
                amount: FinancialAmount.format(state.totalCommissionKurus),
                subtitle: '${state.posTransactions.length} işlem',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class BusinessWeeklyCashflowCard extends StatelessWidget {
  final BusinessOverviewState state;
  final bool canApproveExpenses;
  final ValueChanged<int> onSetPeriod;
  final ValueChanged<int> onSelectBar;

  const BusinessWeeklyCashflowCard({
    super.key,
    required this.state,
    required this.canApproveExpenses,
    required this.onSetPeriod,
    required this.onSelectBar,
  });

  @override
  Widget build(BuildContext context) {
    final periodLabel = state.periodIndex == 0
        ? 'Canlı Günlük Akış'
        : (state.periodIndex == 1
            ? 'Kasım 2026 Haftalık'
            : '2026 Yıllık Trend');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ciro ve Tahsilat Trendi',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    periodLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    SmallPeriodToggle(
                      text: 'Günlük',
                      active: state.periodIndex == 0,
                      onTap: () => onSetPeriod(0),
                    ),
                    SmallPeriodToggle(
                      text: 'Haftalık',
                      active: state.periodIndex == 1,
                      onTap: () => onSetPeriod(1),
                    ),
                    SmallPeriodToggle(
                      text: 'Aylık',
                      active: state.periodIndex == 2,
                      onTap: () => onSetPeriod(2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          WeeklyBarChart(
            points: state.chartPoints,
            maxHeight: 110,
            onBarTap: onSelectBar,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    state.chartSummaryText,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.darkNavy,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (canApproveExpenses)
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.businessReports),
                    child: Text(
                      'Raporu Aç',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.w800,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

