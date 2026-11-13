import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/expense_entity.dart';
import '../bloc/expense_approval_cubit.dart';

/// Masraf talebi reddetme gerekçesi giriş diyalogu (`StatelessWidget`).
class ExpenseRejectDialog extends StatelessWidget {
  final ExpenseApprovalCubit cubit;
  final ExpenseEntity expense;
  final String actorRole;
  final String actorId;

  const ExpenseRejectDialog({
    super.key,
    required this.cubit,
    required this.expense,
    required this.actorRole,
    required this.actorId,
  });

  static Future<void> show(
    BuildContext context, {
    required ExpenseApprovalCubit cubit,
    required ExpenseEntity expense,
    required String actorRole,
    required String actorId,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => ExpenseRejectDialog(
        cubit: cubit,
        expense: expense,
        actorRole: actorRole,
        actorId: actorId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var reasonText = 'Şirket harcama politikasına uygun olmayan harcama kalemi.';

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.expenseRed,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Masraf Talebini Reddet',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                  ),
                ),
                Text(
                  expense.employeeName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      content: TextFormField(
        initialValue: reasonText,
        maxLines: 3,
        onChanged: (value) => reasonText = value,
        decoration: const InputDecoration(
          labelText: 'Resmi Red Gerekçesi',
          hintText: 'Red gerekçesi yazınız...',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Vazgeç'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.expenseRed,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 44),
          ),
          onPressed: () {
            final cleaned = reasonText.trim();
            Navigator.of(context).pop();
            cubit.rejectSingle(
              expense: expense,
              actorRole: actorRole,
              actorId: actorId,
              reason: cleaned.isEmpty
                  ? 'Şirket finans politikası gereği reddedildi.'
                  : cleaned,
            );
          },
          child: const Text('Reddet'),
        ),
      ],
    );
  }
}

