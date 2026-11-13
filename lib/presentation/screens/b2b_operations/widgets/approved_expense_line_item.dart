import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../domain/entities/expense_entity.dart';

/// Toplu onay dekontu içindeki tekil onaylanmış masraf satır öğesi (`StatelessWidget`).
class ApprovedExpenseLineItem extends StatelessWidget {
  final ExpenseEntity expense;

  const ApprovedExpenseLineItem({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
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
                  expense.employeeName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                  ),
                ),
                Text(
                  '${expense.merchantTitle} • ${expense.category} • ${expense.accountingCode}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                FinancialAmount.format(expense.amount),
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
              ),
              Text(
                'KDV: ${FinancialAmount.format(expense.vatAmount)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryTeal,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

