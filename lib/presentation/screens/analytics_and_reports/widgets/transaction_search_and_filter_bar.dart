import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/transaction_history_cubit.dart';
import 'transaction_filter_sheet.dart';

/// İşlem geçmişi arama kutusu, filtre çipleri ve gelişmiş filtre butonu (`StatelessWidget`).
class TransactionSearchAndFilterBar extends StatelessWidget {
  final TransactionHistoryCubit cubit;
  final TransactionHistoryState state;

  const TransactionSearchAndFilterBar({
    super.key,
    required this.cubit,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SearchBarRow(
          cubit: cubit,
          searchQuery: state.searchQuery,
          hasAdvancedFilters: state.hasActiveAdvancedFilters,
        ),
        const SizedBox(height: 12),
        _FilterChipStrip(cubit: cubit, selectedFilter: state.selectedFilter),
      ],
    );
  }
}

class _SearchBarRow extends StatelessWidget {
  final TransactionHistoryCubit cubit;
  final String searchQuery;
  final bool hasAdvancedFilters;

  const _SearchBarRow({
    required this.cubit,
    required this.searchQuery,
    required this.hasAdvancedFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: cubit.searchController,
              onChanged: cubit.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'İsim, IBAN, kategori veya tutar ara...',
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF94A3B8),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                        onPressed: cubit.resetFilters,
                      )
                    : null,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => TransactionFilterSheet.show(context, cubit: cubit),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: hasAdvancedFilters ? const Color(0xFFD1FAE5) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasAdvancedFilters
                    ? AppColors.primaryTeal
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: hasAdvancedFilters
                  ? const Color(0xFF0F766E)
                  : AppColors.darkNavy,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChipStrip extends StatelessWidget {
  final TransactionHistoryCubit cubit;
  final TransactionFilterType selectedFilter;

  const _FilterChipStrip({
    required this.cubit,
    required this.selectedFilter,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: TransactionFilterType.values.map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => cubit.setFilter(filter),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.darkNavy : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.darkNavy
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  filter.label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

