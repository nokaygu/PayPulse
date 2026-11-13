import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/budget_analytics_cubit.dart';

/// Akıllı bütçe öneri bilgi kartı (`StatelessWidget`).
class BudgetAdviceCard extends StatelessWidget {
  final BudgetAnalyticsState state;

  const BudgetAdviceCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final warnings = state.warningCategories;
    final adviceBody = warnings.isNotEmpty
        ? '${warnings.map((w) => w.title).join(', ')} kategorileriniz %90 limit eşiğine ulaştı. Sabit aboneliklerinizi gözden geçirerek aylık tasarrufunuzu artırabilirsiniz.'
        : 'Harcama dağılımınız planladığınız kotalarla uyumlu ilerliyor. Kalan bütçenizin bir kısmını akıllı hedef fonuna aktarabilirsiniz.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFD1FAE5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColors.primaryTeal,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PayPulse Bütçe Tavsiyesi',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  adviceBody,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF475569),
                    height: 1.4,
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

