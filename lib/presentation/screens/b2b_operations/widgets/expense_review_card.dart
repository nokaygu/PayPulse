import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../domain/entities/expense_entity.dart';

/// Tekil personel masraf inceleme, onaylama ve reddetme kartı (`StatelessWidget`).
class ExpenseReviewCard extends StatelessWidget {
  final ExpenseEntity expense;
  final bool isBusy;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const ExpenseReviewCard({
    super.key,
    required this.expense,
    required this.isBusy,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ExpenseTopRow(expense: expense),
          const SizedBox(height: 12),
          _ExpenseStatusBanner(expense: expense),
          if (onApprove != null || onReject != null) ...[
            const SizedBox(height: 12),
            _ExpenseActionButtons(
              isBusy: isBusy,
              onApprove: onApprove,
              onReject: onReject,
            ),
          ],
        ],
      ),
    );
  }
}

class _ExpenseTopRow extends StatelessWidget {
  final ExpenseEntity expense;

  const _ExpenseTopRow({required this.expense});

  @override
  Widget build(BuildContext context) {
    final initials = expense.employeeName.trim().isNotEmpty
        ? expense.employeeName
              .trim()
              .split(' ')
              .where((p) => p.isNotEmpty)
              .map((n) => n[0])
              .take(2)
              .join()
              .toUpperCase()
        : 'PR';

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.darkNavy,
          child: Text(
            initials,
            style: AppTextStyles.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                expense.employeeName.isEmpty
                    ? 'Şirket Çalışanı'
                    : expense.employeeName,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
              ),
              Text(
                '${expense.category} • ${expense.accountingCode}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              FinancialAmount.format(expense.amount),
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavy,
              ),
            ),
            Text(
              'KDV (${FinancialAmount.format(expense.vatAmount)})',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryTeal,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExpenseStatusBanner extends StatelessWidget {
  final ExpenseEntity expense;

  const _ExpenseStatusBanner({required this.expense});

  @override
  Widget build(BuildContext context) {
    final statusLabel = expense.isApproved
        ? '✓ Onaylandı & Muhasebeleştirildi'
        : expense.isRejected
        ? '✕ Reddedildi (${expense.rejectReason ?? 'Gerekçeli'})'
        : '● İnceleme Bekliyor';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${expense.merchantTitle} • ${expense.date.day}.${expense.date.month}.${expense.date.year}',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.darkNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            statusLabel,
            style: AppTextStyles.bodySmall.copyWith(
              color: expense.isRejected
                  ? AppColors.expenseRed
                  : expense.isApproved
                  ? AppColors.primaryTeal
                  : const Color(0xFFD97706),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseActionButtons extends StatelessWidget {
  final bool isBusy;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _ExpenseActionButtons({
    required this.isBusy,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onReject != null)
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.expenseRed,
                side: const BorderSide(color: Color(0xFFFECACA)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: isBusy ? null : onReject,
              child: const Text('Reddet'),
            ),
          ),
        if (onApprove != null && onReject != null) const SizedBox(width: 10),
        if (onApprove != null)
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: isBusy ? null : onApprove,
              child: Text(isBusy ? 'İşleniyor...' : 'Onayla'),
            ),
          ),
      ],
    );
  }
}

