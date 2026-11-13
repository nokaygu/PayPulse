import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/repositories/i_expense_repository.dart';
import '../../widgets/four_state_view.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import 'bloc/expense_approval_cubit.dart';
import 'bulk_expense_erp_receipt_screen.dart';
import 'widgets/expense_filter_dialog.dart';
import 'widgets/expense_reject_dialog.dart';
import 'widgets/expense_review_card.dart';
import 'widgets/expense_sort_dialog.dart';
import 'widgets/expense_status_tab_bar.dart';
import 'widgets/pending_summary_hero_card.dart';

/// Personel Masraf Onay Merkezi Ekranı (`StatelessWidget` + `ExpenseApprovalCubit`).
class B2bExpenseApprovalCenterScreen extends StatelessWidget {
  const B2bExpenseApprovalCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExpenseApprovalCubit>(
      create: (ctx) {
        final companyId =
            ctx.read<AuthBloc>().state.user?.companyId ??
            AppStrings.defaultCompanyId;
        return ExpenseApprovalCubit(
          expenseRepository: ctx.read<IExpenseRepository>(),
        )..watchCompany(companyId);
      },
      child: const _ExpenseApprovalBody(),
    );
  }
}

class _ExpenseApprovalBody extends StatelessWidget {
  const _ExpenseApprovalBody();

  Future<void> _onBulkApprove(
    BuildContext context, {
    required ExpenseApprovalCubit cubit,
    required AuthState authState,
    required String actorId,
    required String actorName,
  }) async {
    final approved = await cubit.approveAllPending(
      actorRole: authState.role,
      actorId: actorId,
    );
    if (approved != null && approved.isNotEmpty && context.mounted) {
      final epochMs = DateTime.now().millisecondsSinceEpoch.toString();
      context.push(
        AppRoutes.businessBatchApproval,
        extra: BulkExpenseReceiptArgs(
          approvedExpenses: approved,
          approverName: actorName,
          approvedAt: DateTime.now(),
          batchId: 'BATCH-${epochMs.substring(7)}',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExpenseApprovalCubit>();

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) =>
              prev.user?.companyId != curr.user?.companyId,
          listener: (ctx, authState) {
            ctx.read<ExpenseApprovalCubit>().watchCompany(
              authState.user?.companyId ?? AppStrings.defaultCompanyId,
            );
          },
        ),
        BlocListener<ExpenseApprovalCubit, ExpenseApprovalState>(
          listenWhen: (prev, curr) =>
              prev.actionMessage != curr.actionMessage &&
              curr.actionMessage != null,
          listener: (ctx, state) {
            final msg = state.actionMessage;
            if (msg == null) return;
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: state.isErrorAction
                    ? AppColors.expenseRed
                    : AppColors.primaryTeal,
              ),
            );
            ctx.read<ExpenseApprovalCubit>().clearActionMessage();
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const RoleSwitchAppBar(isBusinessMode: true),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final canApprove = authState.canApproveExpenses;
            final actorId = authState.user?.uid ?? '';
            final actorName =
                authState.user?.name ?? 'Şirket Finans Yöneticisi';

            return BlocBuilder<ExpenseApprovalCubit, ExpenseApprovalState>(
              builder: (context, state) {
                return RefreshIndicator(
                  onRefresh: cubit.refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExpenseStatusTabBar(
                          cubit: cubit,
                          state: state,
                          canApprove: canApprove,
                          onOpenFilter: () => ExpenseFilterDialog.show(
                            context,
                            cubit: cubit,
                            selectedCategory: state.selectedCategory,
                          ),
                        ),
                        const SizedBox(height: 14),
                        PendingSummaryHeroCard(
                          state: state,
                          canApprove: canApprove,
                          onBulkApprove: () => _onBulkApprove(
                            context,
                            cubit: cubit,
                            authState: authState,
                            actorId: actorId,
                            actorName: actorName,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SortHeaderRow(
                          count: state.filteredExpenses.length,
                          sortLabel: state.sortOrder.label,
                          onTapSort: () => ExpenseSortDialog.show(
                            context,
                            cubit: cubit,
                            selectedOrder: state.sortOrder,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _ExpensesListSection(
                          cubit: cubit,
                          state: state,
                          canApprove: canApprove,
                          actorRole: authState.role,
                          actorId: actorId,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SortHeaderRow extends StatelessWidget {
  final int count;
  final String sortLabel;
  final VoidCallback onTapSort;

  const _SortHeaderRow({
    required this.count,
    required this.sortLabel,
    required this.onTapSort,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Masraf Kayıtları ($count)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.darkNavy,
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: onTapSort,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(
              '$sortLabel ⌄',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpensesListSection extends StatelessWidget {
  final ExpenseApprovalCubit cubit;
  final ExpenseApprovalState state;
  final bool canApprove;
  final String actorRole;
  final String actorId;

  const _ExpensesListSection({
    required this.cubit,
    required this.state,
    required this.canApprove,
    required this.actorRole,
    required this.actorId,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilter =
        state.searchQuery.isNotEmpty || state.selectedCategory != 'Tümü';
    return FourStateView(
      status: state.listStatus,
      errorMessage: state.errorMessage ?? 'Masraf kayıtları yüklenemedi.',
      emptyMessage: hasFilter
          ? 'Arama veya kategori filtresine uygun masraf kaydı bulunamadı.'
          : 'Bu sekmede görüntülenecek masraf kaydı bulunmuyor.',
      onRetry: cubit.refresh,
      child: Column(
        children: state.filteredExpenses.map((exp) {
          final isBusy =
              state.isSubmitting && state.processingExpenseId == exp.expenseId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ExpenseReviewCard(
              expense: exp,
              isBusy: isBusy,
              onApprove: canApprove && exp.isPending
                  ? () => cubit.approveSingle(
                      expense: exp,
                      actorRole: actorRole,
                      actorId: actorId,
                    )
                  : null,
              onReject: canApprove && exp.isPending
                  ? () => ExpenseRejectDialog.show(
                      context,
                      cubit: cubit,
                      expense: exp,
                      actorRole: actorRole,
                      actorId: actorId,
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}
