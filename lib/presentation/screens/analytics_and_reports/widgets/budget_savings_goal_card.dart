import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/budget_entity.dart';
import '../../../widgets/status_badge_widget.dart';
import '../bloc/budget_analytics_cubit.dart';

/// Akıllı hedef ve tasarruf ilerleme kartı (`StatelessWidget`).
class BudgetSavingsGoalCard extends StatelessWidget {
  final SavingsGoalEntity goal;

  const BudgetSavingsGoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final targetText = BudgetAnalyticsState.formatTl(goal.targetAmount);
    final currentText = BudgetAnalyticsState.formatTl(goal.currentAmount);
    final remainingText = BudgetAnalyticsState.formatTl(goal.remainingAmount);

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
          _GoalHeader(progressPercentage: goal.progressPercentage),
          const SizedBox(height: 14),
          _GoalSummaryBox(goal: goal, targetText: targetText),
          const SizedBox(height: 14),
          _GoalProgressSection(
            goal: goal,
            currentText: currentText,
            targetText: targetText,
            remainingText: remainingText,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkNavy,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${goal.title} birikim hedefi güncellenmeye hazır.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Bütçe Hedefini Düzenle'),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalHeader extends StatelessWidget {
  final int progressPercentage;

  const _GoalHeader({required this.progressPercentage});

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
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.savings_outlined,
                size: 18,
                color: AppColors.primaryTeal,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Akıllı Hedef ve\nTasarruf',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavy,
                height: 1.2,
              ),
            ),
          ],
        ),
        StatusBadgeWidget(
          label: '%$progressPercentage Tamamlandı',
          type: BadgeType.success,
        ),
      ],
    );
  }
}

class _GoalSummaryBox extends StatelessWidget {
  final SavingsGoalEntity goal;
  final String targetText;

  const _GoalSummaryBox({required this.goal, required this.targetText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.darkNavy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.laptop_mac_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                  ),
                ),
                Text(
                  'Hedef: $targetText',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Bitiş Hedefi: ${goal.deadline}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w700,
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

class _GoalProgressSection extends StatelessWidget {
  final SavingsGoalEntity goal;
  final String currentText;
  final String targetText;
  final String remainingText;

  const _GoalProgressSection({
    required this.goal,
    required this.currentText,
    required this.targetText,
    required this.remainingText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Biriken Fon',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
            Text(
              '$currentText / $targetText',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.darkNavy,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: goal.progressRatio,
            minHeight: 8,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primaryGreen,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tahmini Bitiş: ${goal.deadline}',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 11,
              ),
            ),
            Text(
              'Hedefe $remainingText kaldı',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

