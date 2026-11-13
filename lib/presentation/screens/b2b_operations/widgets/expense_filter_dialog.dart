import 'package:flutter/material.dart';

import '../bloc/expense_approval_cubit.dart';

/// Masraf kategori filtresi seçim alt sayfası (`StatelessWidget`).
class ExpenseFilterDialog extends StatelessWidget {
  final ExpenseApprovalCubit cubit;
  final String selectedCategory;

  const ExpenseFilterDialog({
    super.key,
    required this.cubit,
    required this.selectedCategory,
  });

  static Future<void> show(
    BuildContext context, {
    required ExpenseApprovalCubit cubit,
    required String selectedCategory,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ExpenseFilterDialog(
        cubit: cubit,
        selectedCategory: selectedCategory,
      ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kategori Filtresi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              TextButton(
                onPressed: () {
                  cubit.setCategory('Tümü');
                  Navigator.pop(context);
                },
                child: const Text('Temizle'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ExpenseApprovalState.availableCategories.map((cat) {
              return ChoiceChip(
                label: Text(cat),
                selected: selectedCategory == cat,
                selectedColor: const Color(0xFF5EEAD4),
                onSelected: (_) {
                  cubit.setCategory(cat);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

