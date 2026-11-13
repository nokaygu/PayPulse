import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../domain/entities/expense_entity.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../widgets/transaction_list_tile_widget.dart';
import 'home_transaction_tile_item.dart';

class BusinessPendingExpensesCard extends StatelessWidget {
  final ExpenseEntity? featuredExpense;
  final List<TransactionEntity> recentTransactions;
  final bool canApproveExpenses;
  final bool isSubmitting;
  final ValueChanged<ExpenseEntity> onInspectExpense;
  final ValueChanged<ExpenseEntity> onApproveExpense;

  const BusinessPendingExpensesCard({
    super.key,
    required this.featuredExpense,
    required this.recentTransactions,
    required this.canApproveExpenses,
    required this.isSubmitting,
    required this.onInspectExpense,
    required this.onApproveExpense,
  });

  @override
  Widget build(BuildContext context) {
    final visibleTransactions = recentTransactions.take(2).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Son Tahsilat ve Onaylar',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavy,
              ),
            ),
            GestureDetector(
              onTap: () => context.go(AppRoutes.businessExpenses),
              child: Text(
                'Tümünü Gör >',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              if (featuredExpense != null) ...[
                _FeaturedExpenseRow(
                  expense: featuredExpense!,
                  canApproveExpenses: canApproveExpenses,
                  isSubmitting: isSubmitting,
                  onInspect: () => onInspectExpense(featuredExpense!),
                  onApprove: () => onApproveExpense(featuredExpense!),
                ),
              ],
              for (int i = 0; i < visibleTransactions.length; i++) ...[
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                HomeTransactionTileItem(tx: visibleTransactions[i]),
              ],
              if (featuredExpense == null && recentTransactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text('Kurumsal hareket bulunamadı.')),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeaturedExpenseRow extends StatelessWidget {
  final ExpenseEntity expense;
  final bool canApproveExpenses;
  final bool isSubmitting;
  final VoidCallback onInspect;
  final VoidCallback onApprove;

  const _FeaturedExpenseRow({
    required this.expense,
    required this.canApproveExpenses,
    required this.isSubmitting,
    required this.onInspect,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TransactionListTileWidget(
          title: expense.employeeName,
          badgeText: expense.isPending
              ? 'Onay Bekliyor'
              : (expense.isApproved ? 'Onaylandı' : 'Reddedildi'),
          badgeBgColor: expense.isApproved
              ? const Color(0xFFD1FAE5)
              : (expense.isRejected
                  ? const Color(0xFFFEE2E2)
                  : const Color(0xFFE0F2FE)),
          badgeTextColor: expense.isApproved
              ? const Color(0xFF065F46)
              : (expense.isRejected
                  ? const Color(0xFF991B1B)
                  : AppColors.darkNavy),
          subtitle: 'Masraf: ${expense.merchantTitle} • ${expense.category}',
          amountText: FinancialAmount.format(expense.amount),
          isIncome: false,
          statusOrNoteText: expense.accountingCode,
          icon: Icons.receipt_long_outlined,
          iconBgColor:
              expense.isApproved ? const Color(0xFF0F766E) : AppColors.darkNavy,
          iconColor: Colors.white,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  onPressed: onInspect,
                  child: const Text(
                    'Fişi İncele',
                    style: TextStyle(fontSize: 11.5),
                  ),
                ),
              ),
              if (canApproveExpenses) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: expense.isPending
                          ? const Color(0xFF0F766E)
                          : const Color(0xFF64748B),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 36),
                    ),
                    onPressed: (!expense.isPending || isSubmitting)
                        ? null
                        : onApprove,
                    child: Text(
                      expense.isPending ? '✓ Onayla' : 'İşlem Tamam',
                      style: const TextStyle(fontSize: 11.5),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

