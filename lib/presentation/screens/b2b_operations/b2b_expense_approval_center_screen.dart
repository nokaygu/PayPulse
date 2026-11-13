import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/financial_amount.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../../domain/repositories/i_expense_repository.dart';
import '../../widgets/four_state_view.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import 'bloc/expense_approval_cubit.dart';
import 'bulk_expense_erp_receipt_screen.dart';

/// Personel Masraf Onay Merkezi Ekranı (Stateless + ExpenseApprovalCubit + ApproveOrRejectExpenseUseCase)
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
                        // Başlık Satırı
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
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
                                  style: AppTextStyles.headlineMedium.copyWith(
                                    color: AppColors.darkNavy,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: canApprove
                                    ? const Color(0xFFD1FAE5)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                canApprove
                                    ? 'Onay Yetkili'
                                    : 'Görüntüleme Modu',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: canApprove
                                      ? const Color(0xFF065F46)
                                      : const Color(0xFF64748B),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Sekme Çipleri (Bekleyenler | Onaylananlar | Reddedilenler)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _TabPill(
                                label:
                                    'Bekleyenler (${state.pendingExpenses.length})',
                                isSelected:
                                    state.selectedTab ==
                                    ExpenseTabFilter.pending,
                                onTap: () =>
                                    cubit.setTab(ExpenseTabFilter.pending),
                              ),
                              const SizedBox(width: 8),
                              _TabPill(
                                label:
                                    'Onaylananlar (${state.approvedExpenses.length})',
                                isSelected:
                                    state.selectedTab ==
                                    ExpenseTabFilter.approved,
                                onTap: () =>
                                    cubit.setTab(ExpenseTabFilter.approved),
                              ),
                              const SizedBox(width: 8),
                              _TabPill(
                                label:
                                    'Reddedilenler (${state.rejectedExpenses.length})',
                                isSelected:
                                    state.selectedTab ==
                                    ExpenseTabFilter.rejected,
                                onTap: () =>
                                    cubit.setTab(ExpenseTabFilter.rejected),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Arama + Kategori Filtresi
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: TextField(
                                  controller: cubit.searchController,
                                  onChanged: cubit.setSearchQuery,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Personel, işyeri veya muhasebe kodu ara...',
                                    hintStyle: AppTextStyles.bodySmall.copyWith(
                                      color: const Color(0xFF94A3B8),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search_rounded,
                                      size: 20,
                                      color: Color(0xFF64748B),
                                    ),
                                    suffixIcon:
                                        state.searchQuery.isNotEmpty ||
                                            state.selectedCategory != 'Tümü'
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.close_rounded,
                                              size: 18,
                                            ),
                                            onPressed: cubit.resetFilters,
                                          )
                                        : null,
                                    fillColor: Colors.transparent,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => _showFilterDialog(context, state),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: state.selectedCategory != 'Tümü'
                                      ? const Color(0xFFD1FAE5)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: state.selectedCategory != 'Tümü'
                                        ? AppColors.primaryTeal
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Icon(
                                  Icons.tune_rounded,
                                  size: 20,
                                  color: state.selectedCategory != 'Tümü'
                                      ? const Color(0xFF0F766E)
                                      : AppColors.darkNavy,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // 1. Bekleyen Toplam Tutar Koyu Kartı (Gerçek Toplam + Toplu Onay)
                        _PendingSummaryHeroCard(
                          state: state,
                          canApprove: canApprove,
                          onBulkApprove: () async {
                            final approved = await cubit.approveAllPending(
                              actorRole: authState.role,
                              actorId: actorId,
                            );
                            if (approved != null &&
                                approved.isNotEmpty &&
                                context.mounted) {
                              context.push(
                                AppRoutes.businessBatchApproval,
                                extra: BulkExpenseReceiptArgs(
                                  approvedExpenses: approved,
                                  approverName: actorName,
                                  approvedAt: DateTime.now(),
                                  batchId:
                                      'BATCH-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // İnceleme Harcamalar Başlığı & Sıralama
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Masraf Kayıtları (${state.filteredExpenses.length})',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkNavy,
                              ),
                            ),
                            InkWell(
                              onTap: () => _showSortDialog(context, state),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                child: Text(
                                  '${state.sortOrder.label} ⌄',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.primaryTeal,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // 2. 4-State Yönetimli Canlı Masraf Kartları
                        FourStateView(
                          status: state.listStatus,
                          errorMessage:
                              state.errorMessage ??
                              'Masraf kayıtları yüklenemedi.',
                          emptyMessage: state.searchQuery.isNotEmpty ||
                                  state.selectedCategory != 'Tümü'
                              ? 'Arama veya kategori filtresine uygun masraf kaydı bulunamadı.'
                              : 'Bu sekmede görüntülenecek masraf kaydı bulunmuyor.',
                          onRetry: cubit.refresh,
                          child: Column(
                            children: state.filteredExpenses.map((exp) {
                              final isBusy =
                                  state.isSubmitting &&
                                  state.processingExpenseId == exp.expenseId;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ExpenseReviewCard(
                                  expense: exp,
                                  isBusy: isBusy,
                                  onApprove: canApprove && exp.isPending
                                      ? () => cubit.approveSingle(
                                          expense: exp,
                                          actorRole: authState.role,
                                          actorId: actorId,
                                        )
                                      : null,
                                  onReject: canApprove && exp.isPending
                                      ? () => _showRejectDialog(
                                          context: context,
                                          cubit: cubit,
                                          expense: exp,
                                          actorRole: authState.role,
                                          actorId: actorId,
                                        )
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),
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

  void _showFilterDialog(BuildContext context, ExpenseApprovalState state) {
    final cubit = context.read<ExpenseApprovalCubit>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
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
                    Navigator.pop(ctx);
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
                final isSelected = state.selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: const Color(0xFF5EEAD4),
                  onSelected: (_) {
                    cubit.setCategory(cat);
                    Navigator.pop(ctx);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortDialog(BuildContext context, ExpenseApprovalState state) {
    final cubit = context.read<ExpenseApprovalCubit>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
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
              final selected = state.sortOrder == s;
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
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog({
    required BuildContext context,
    required ExpenseApprovalCubit cubit,
    required ExpenseEntity expense,
    required String actorRole,
    required String actorId,
  }) {
    final controller = TextEditingController(
      text: 'Şirket harcama politikasına uygun olmayan harcama kalemi.',
    );

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
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
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Resmi Red Gerekçesi',
            hintText: 'Red gerekçesi yazınız...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expenseRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final reason = controller.text.trim();
              Navigator.of(ctx).pop();
              cubit.rejectSingle(
                expense: expense,
                actorRole: actorRole,
                actorId: actorId,
                reason: reason.isEmpty
                    ? 'Şirket finans politikası gereği reddedildi.'
                    : reason,
              );
            },
            child: const Text('Reddet'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
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

class _PendingSummaryHeroCard extends StatelessWidget {
  final ExpenseApprovalState state;
  final bool canApprove;
  final VoidCallback onBulkApprove;

  const _PendingSummaryHeroCard({
    required this.state,
    required this.canApprove,
    required this.onBulkApprove,
  });

  @override
  Widget build(BuildContext context) {
    final pendingCount = state.pendingExpenses.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroCardGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavy.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BEKLEYEN TOPLAM TUTAR',
                style: AppTextStyles.labelSmall.copyWith(
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.7,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$pendingCount Fatura / Fiş',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFF5EEAD4),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            state.formattedPendingTotal,
            style: AppTextStyles.numericBalance.copyWith(
              color: Colors.white,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.savings_outlined,
                        size: 16,
                        color: Color(0xFF5EEAD4),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'KDV İndirimi Kazanımı',
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  state.formattedPendingVat,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: const Color(0xFF5EEAD4),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (canApprove && pendingCount > 0) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.darkNavy,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: state.isSubmitting ? null : onBulkApprove,
                icon: const Icon(
                  Icons.done_all_rounded,
                  size: 18,
                  color: AppColors.primaryTeal,
                ),
                label: Text(
                  state.isSubmitting
                      ? 'Toplu Onay İşleniyor...'
                      : 'Tümünü İncele & Toplu Onayla (${state.formattedPendingTotal})',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExpenseReviewCard extends StatelessWidget {
  final ExpenseEntity expense;
  final bool isBusy;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _ExpenseReviewCard({
    required this.expense,
    required this.isBusy,
    this.onApprove,
    this.onReject,
  });

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

    final statusLabel = expense.isApproved
        ? '✓ Onaylandı & Muhasebeleştirildi'
        : expense.isRejected
        ? '✕ Reddedildi (${expense.rejectReason ?? 'Gerekçeli'})'
        : '● İnceleme Bekliyor';

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
          Row(
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
          ),
          const SizedBox(height: 12),
          Container(
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
          ),
          if (onApprove != null || onReject != null) ...[
            const SizedBox(height: 12),
            Row(
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
                if (onApprove != null && onReject != null)
                  const SizedBox(width: 10),
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
            ),
          ],
        ],
      ),
    );
  }
}
