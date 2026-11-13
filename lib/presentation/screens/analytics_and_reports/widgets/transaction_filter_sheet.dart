import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/transaction_history_cubit.dart';

/// İşlem geçmişi gelişmiş kategori ve sıralama filtre alt penceresi (`StatelessWidget`).
class TransactionFilterSheet extends StatelessWidget {
  const TransactionFilterSheet({super.key});

  static Future<void> show(
    BuildContext context, {
    required TransactionHistoryCubit cubit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider<TransactionHistoryCubit>.value(
        value: cubit,
        child: const TransactionFilterSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TransactionHistoryCubit>();

    return BlocBuilder<TransactionHistoryCubit, TransactionHistoryState>(
      builder: (context, state) {
        final categories = state.availableCategories;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'İşlemleri Filtrele ve Sırala',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.darkNavy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        cubit.resetFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Sıfırla'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Sıralama Ölçütü',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TransactionSortOrder.values.map((order) {
                    final isSelected = state.sortOrder == order;
                    return ChoiceChip(
                      label: Text(order.label),
                      selected: isSelected,
                      selectedColor: AppColors.darkNavy,
                      backgroundColor: const Color(0xFFF1F5F9),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.darkNavy,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      onSelected: (_) => cubit.setSortOrder(order),
                    );
                  }).toList(),
                ),
                if (categories.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Kategori Filtresi',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.darkNavy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Tüm Kategoriler'),
                        selected: state.selectedCategory == null,
                        selectedColor: AppColors.primaryTeal,
                        backgroundColor: const Color(0xFFF1F5F9),
                        labelStyle: TextStyle(
                          color: state.selectedCategory == null
                              ? Colors.white
                              : AppColors.darkNavy,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        onSelected: (_) => cubit.setCategoryFilter(null),
                      ),
                      ...categories.map((cat) {
                        final selected = state.selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: selected,
                          selectedColor: AppColors.primaryTeal,
                          backgroundColor: const Color(0xFFF1F5F9),
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : AppColors.darkNavy,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          onSelected: (_) => cubit.setCategoryFilter(
                            selected ? null : cat,
                          ),
                        );
                      }),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkNavy,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Sonuçları Göster (${state.filteredTransactions.length})',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

