import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../widgets/budget_donut_chart.dart';
import '../bloc/budget_analytics_cubit.dart';
import 'budget_category_box.dart';

/// Harcama kategorileri donut grafik ve kota ilerleme kartı (`StatelessWidget`).
class BudgetCategoryBreakdownCard extends StatelessWidget {
  final BudgetAnalyticsState state;

  const BudgetCategoryBreakdownCard({super.key, required this.state});

  IconData _iconForCategory(String iconName) {
    switch (iconName) {
      case 'shopping_cart':
        return Icons.shopping_cart_outlined;
      case 'directions_car':
      case 'local_gas_station':
        return Icons.local_gas_station_outlined;
      case 'receipt_long':
        return Icons.receipt_long_outlined;
      case 'restaurant':
        return Icons.restaurant_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final donutItems = state.donutItems;
    final visibleList = state.visibleCategories;

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
          _BreakdownHeader(categoryCount: visibleList.length),
          const SizedBox(height: 20),
          Row(
            children: [
              BudgetDonutChart(
                items: donutItems,
                centerTitle: state.compactCenterSpent,
                centerSubtitle: state.selectedPeriodLabel,
                size: 135,
              ),
              const SizedBox(width: 18),
              Expanded(child: _DonutLegend(items: donutItems)),
            ],
          ),
          const SizedBox(height: 20),
          if (visibleList.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                'Seçili filtreye uygun bütçe kategorisi bulunamadı.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ...visibleList.map((cat) {
              final color = BudgetAnalyticsState.parseHexColor(cat.colorHex);
              final progress = cat.allocatedAmount > 0
                  ? (cat.spentAmount / cat.allocatedAmount).clamp(0.0, 1.0)
                  : 0.0;
              final pct = (progress * 100).round();
              final statusText = cat.isLimitWarning
                  ? 'Limit uyarısı (%$pct)'
                  : '%$pct kullanıldı';

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: BudgetCategoryBox(
                  icon: _iconForCategory(cat.iconName),
                  iconBg: color,
                  title: cat.title,
                  quota:
                      'Kota: ${BudgetAnalyticsState.formatTl(cat.allocatedAmount)}',
                  amount: BudgetAnalyticsState.formatTl(cat.spentAmount),
                  statusText: statusText,
                  statusColor: cat.isLimitWarning
                      ? AppColors.expenseRed
                      : AppColors.primaryTeal,
                  progress: progress,
                  barColor: color,
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _BreakdownHeader extends StatelessWidget {
  final int categoryCount;

  const _BreakdownHeader({required this.categoryCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pie_chart_outline_rounded,
                  size: 18,
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Harcama Kategorileri',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$categoryCount Kategori',
          style: AppTextStyles.labelSmall.copyWith(
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _DonutLegend extends StatelessWidget {
  final List<DonutChartItem> items;

  const _DonutLegend({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((c) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: c.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  c.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
