import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/expense_approval_cubit.dart';

/// Masraf onay merkezi başlık, sekme çipleri ve arama/sıralama barı.
class ExpenseStatusTabBar extends StatelessWidget {
  final ExpenseApprovalCubit cubit;
  final ExpenseApprovalState state;
  final bool canApprove;
  final VoidCallback onOpenFilter;

  const ExpenseStatusTabBar({
    super.key,
    required this.cubit,
    required this.state,
    required this.canApprove,
    required this.onOpenFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ApprovalHeaderRow(canApprove: canApprove),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _TabPill(
                label: 'Bekleyenler (${state.pendingExpenses.length})',
                isSelected: state.selectedTab == ExpenseTabFilter.pending,
                onTap: () => cubit.setTab(ExpenseTabFilter.pending),
              ),
              const SizedBox(width: 8),
              _TabPill(
                label: 'Onaylananlar (${state.approvedExpenses.length})',
                isSelected: state.selectedTab == ExpenseTabFilter.approved,
                onTap: () => cubit.setTab(ExpenseTabFilter.approved),
              ),
              const SizedBox(width: 8),
              _TabPill(
                label: 'Reddedilenler (${state.rejectedExpenses.length})',
                isSelected: state.selectedTab == ExpenseTabFilter.rejected,
                onTap: () => cubit.setTab(ExpenseTabFilter.rejected),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SearchAndCategoryFilterRow(
          cubit: cubit,
          state: state,
          onOpenFilter: onOpenFilter,
        ),
      ],
    );
  }
}

class _ApprovalHeaderRow extends StatelessWidget {
  final bool canApprove;

  const _ApprovalHeaderRow({required this.canApprove});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KURUMSAL FİNANS',
                style: AppTextStyles.labelSmall.copyWith(
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Masraf Onay Merkezi',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.darkNavy,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: canApprove
                ? const Color(0xFFD1FAE5)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            canApprove ? 'Onay Yetkili' : 'Görüntüleme Modu',
            style: AppTextStyles.labelSmall.copyWith(
              color: canApprove
                  ? const Color(0xFF065F46)
                  : const Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchAndCategoryFilterRow extends StatelessWidget {
  final ExpenseApprovalCubit cubit;
  final ExpenseApprovalState state;
  final VoidCallback onOpenFilter;

  const _SearchAndCategoryFilterRow({
    required this.cubit,
    required this.state,
    required this.onOpenFilter,
  });

  @override
  Widget build(BuildContext context) {
    final hasCategoryFilter = state.selectedCategory != 'Tümü';
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
                hintText: 'Personel, işyeri veya muhasebe kodu ara...',
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF94A3B8),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: Color(0xFF64748B),
                ),
                suffixIcon: state.searchQuery.isNotEmpty || hasCategoryFilter
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
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
          onTap: onOpenFilter,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: hasCategoryFilter ? const Color(0xFFD1FAE5) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasCategoryFilter
                    ? AppColors.primaryTeal
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 20,
              color: hasCategoryFilter
                  ? const Color(0xFF0F766E)
                  : AppColors.darkNavy,
            ),
          ),
        ),
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkNavy : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.darkNavy : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

