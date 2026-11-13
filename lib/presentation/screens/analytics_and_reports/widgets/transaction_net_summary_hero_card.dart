import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/transaction_history_cubit.dart';

/// Aylık net bakiye değişimi, gelen/giden akışı özetleyen hero kart (`StatelessWidget`).
class TransactionNetSummaryHeroCard extends StatelessWidget {
  final TransactionHistoryState state;

  const TransactionNetSummaryHeroCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.heroCardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavy.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AYLIK NET BAKİYE DEĞİŞİMİ',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 9.5,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    state.formattedNetChange,
                    style: AppTextStyles.numericBalance.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${state.transactions.length} Kayıtlı İşlem',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Expanded(
                  child: _MiniFlowBox(
                    icon: Icons.south_west_rounded,
                    iconColor: AppColors.primaryGreen,
                    label: 'Gelen',
                    amount: state.formattedTotalIncome,
                    amountColor: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _MiniFlowBox(
                    icon: Icons.north_east_rounded,
                    iconColor: const Color(0xFFF87171),
                    label: 'Giden',
                    amount: state.formattedTotalExpense,
                    amountColor: Colors.white,
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

class _MiniFlowBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String amount;
  final Color amountColor;

  const _MiniFlowBox({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.amount,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: iconColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: AppTextStyles.labelLarge.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

