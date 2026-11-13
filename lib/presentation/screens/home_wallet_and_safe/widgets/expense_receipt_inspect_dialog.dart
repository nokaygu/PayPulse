import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../domain/entities/expense_entity.dart';

Future<void> showExpenseReceiptInspectDialog({
  required BuildContext context,
  required ExpenseEntity expense,
  required bool canApproveExpenses,
  required VoidCallback onApprove,
  required VoidCallback onReject,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => ExpenseReceiptInspectDialog(
      expense: expense,
      canApproveExpenses: canApproveExpenses,
      onApprove: () {
        onApprove();
        Navigator.pop(ctx);
      },
      onReject: () {
        onReject();
        Navigator.pop(ctx);
      },
      onClose: () => Navigator.pop(ctx),
    ),
  );
}

class ExpenseReceiptInspectDialog extends StatelessWidget {
  final ExpenseEntity expense;
  final bool canApproveExpenses;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onClose;

  const ExpenseReceiptInspectDialog({
    super.key,
    required this.expense,
    required this.canApproveExpenses,
    required this.onApprove,
    required this.onReject,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(expense.merchantTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personel: ${expense.employeeName}'),
          Text('Kategori: ${expense.category}'),
          Text('Tutar: ${FinancialAmount.format(expense.amount)}'),
          Text('KDV: ${FinancialAmount.format(expense.vatAmount)}'),
          Text('Muhasebe Kodu: ${expense.accountingCode}'),
        ],
      ),
      actions: [
        if (canApproveExpenses && expense.isPending) ...[
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.expenseRed),
            onPressed: onReject,
            child: const Text('Reddet'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 44),
            ),
            onPressed: onApprove,
            child: const Text('✓ Onayla'),
          ),
        ] else
          TextButton(onPressed: onClose, child: const Text('Kapat')),
      ],
    );
  }
}

