import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../widgets/status_badge_widget.dart';
import '../bloc/budget_analytics_cubit.dart';

/// Ana cüzdan bütçe kotası ve harcama oranı hero kartı (`StatelessWidget`).
class BudgetQuotaHeroCard extends StatelessWidget {
  final BudgetAnalyticsState state;

  const BudgetQuotaHeroCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroCardGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavy.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _QuotaTopBar(remainingPercent: state.remainingPercent),
          const SizedBox(height: 14),
          Text(
            'Kalan Harcama Hakkı',
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            state.formattedRemainingTl,
            style: AppTextStyles.numericBalance.copyWith(
              color: Colors.white,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 14),
          _QuotaProgressBar(
            spentLabel: 'Harcanan: ${state.formattedTotalSpentTl}',
            allocatedLabel: 'Hedef: ${state.formattedTotalAllocatedTl}',
            spentRatio: state.spentRatio,
          ),
          const SizedBox(height: 14),
          _QuotaStatusNote(warningCount: state.warningCategories.length),
        ],
      ),
    );
  }
}

class _QuotaTopBar extends StatelessWidget {
  final int remainingPercent;

  const _QuotaTopBar({required this.remainingPercent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.primaryGreen,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'ANA CÜZDAN KOTASI',
              style: AppTextStyles.labelSmall.copyWith(
                color: const Color(0xFF94A3B8),
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        StatusBadgeWidget(
          label: '%$remainingPercent Bütçe Kaldı',
          type: BadgeType.darkGlass,
        ),
      ],
    );
  }
}

class _QuotaProgressBar extends StatelessWidget {
  final String spentLabel;
  final String allocatedLabel;
  final double spentRatio;

  const _QuotaProgressBar({
    required this.spentLabel,
    required this.allocatedLabel,
    required this.spentRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              spentLabel,
              style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
            ),
            Text(
              allocatedLabel,
              style: AppTextStyles.labelSmall.copyWith(
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: spentRatio,
            minHeight: 8,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuotaStatusNote extends StatelessWidget {
  final int warningCount;

  const _QuotaStatusNote({required this.warningCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.primaryGreen,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              warningCount == 0
                  ? 'Harika gidiyorsunuz! Tüm harcamalar planlanan bütçe limitleri içinde.'
                  : '$warningCount kategoride %90 limit eşiğine yaklaşıldı.',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

