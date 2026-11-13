import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../widgets/status_badge_widget.dart';
import '../bloc/budget_analytics_cubit.dart';

/// Haftalık / dönemsel harcama trend çubuk grafiği kartı (`StatelessWidget`).
class BudgetWeeklyTrendCard extends StatelessWidget {
  final BudgetAnalyticsState state;

  const BudgetWeeklyTrendCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final avgWeekly = state.totalSpentTl / 4;
    final formattedAvg = BudgetAnalyticsState.formatTl(avgWeekly);

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
          const _TrendCardHeader(),
          const SizedBox(height: 18),
          SizedBox(
            height: 135,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Expanded(
                  child: _TrendWeekBar(
                    label: '1. Hafta',
                    heightFactor: 0.72,
                    isActive: false,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _TrendWeekBar(
                    label: '2. Hafta',
                    heightFactor: 0.75,
                    isActive: false,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _TrendWeekBar(
                    label: '3. Hafta',
                    heightFactor: 0.78,
                    isActive: false,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _TrendWeekBar(
                    label: '4. Hafta',
                    heightFactor: 0.74,
                    isActive: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Haftalık Ortalama: $formattedAvg',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Toplam: ${state.formattedTotalSpentTl}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendCardHeader extends StatelessWidget {
  const _TrendCardHeader();

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
                  Icons.bar_chart_rounded,
                  size: 18,
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Dönemsel Harcama\nTrendi',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const StatusBadgeWidget(label: 'Dengeli Seyir', type: BadgeType.success),
      ],
    );
  }
}

class _TrendWeekBar extends StatelessWidget {
  final String label;
  final double heightFactor;
  final bool isActive;

  const _TrendWeekBar({
    required this.label,
    required this.heightFactor,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isActive)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF065F46),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'AKTİF',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: heightFactor,
              widthFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: isActive
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF34D399), Color(0xFF0D9488)],
                        )
                      : null,
                  color: isActive ? null : const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isActive ? AppColors.darkNavy : const Color(0xFF64748B),
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

