import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/expense_approval_cubit.dart';

/// Masraf kayıtları sıralama ölçütü alt sayfası (`StatelessWidget`).
class ExpenseSortDialog extends StatelessWidget {
  final ExpenseApprovalCubit cubit;
  final ExpenseSortOrder selectedOrder;

  const ExpenseSortDialog({
    super.key,
    required this.cubit,
    required this.selectedOrder,
  });

  static Future<void> show(
    BuildContext context, {
    required ExpenseApprovalCubit cubit,
    required ExpenseSortOrder selectedOrder,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          ExpenseSortDialog(cubit: cubit, selectedOrder: selectedOrder),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sıralama Ölçütü',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...ExpenseSortOrder.values.map((s) {
            final selected = selectedOrder == s;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected
                    ? AppColors.primaryTeal
                    : const Color(0xFF94A3B8),
              ),
              title: Text(s.label),
              onTap: () {
                cubit.setSortOrder(s);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }
}

