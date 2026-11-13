import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/repositories/i_company_repository.dart';
import '../../../domain/repositories/i_expense_repository.dart';
import '../../../domain/repositories/i_transaction_repository.dart';
import '../../../domain/repositories/i_user_repository.dart';
import '../../../domain/repositories/i_wallet_repository.dart';
import '../../widgets/four_state_view.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import '../auth/bloc/auth_state.dart';
import 'bloc/business_overview_cubit.dart';
import 'bloc/home_wallet_cubit.dart';
import 'widgets/business_pending_expenses_card.dart';
import 'widgets/business_quick_actions_grid.dart';
import 'widgets/business_safe_hero_card.dart';
import 'widgets/business_top_up_balance_sheet.dart';
import 'widgets/business_transfer_to_account_sheet.dart';
import 'widgets/business_weekly_cashflow_card.dart';
import 'widgets/demo_seed_banner_card.dart';
import 'widgets/expense_receipt_inspect_dialog.dart';
import 'widgets/personal_wallet_hero_card.dart';
import 'widgets/recent_transactions_card.dart';

/// 1. BİREYSEL CÜZDAN ANA EKRANI (B2C & Çalışanlar için Kişisel Bakiye Görünümü)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState.user?.uid ?? AppStrings.demoB2CUid;
    final userName = (authState.user?.name.isNotEmpty ?? false)
        ? authState.user!.name
        : 'Deniz Aksoy';

    return BlocProvider<HomeWalletCubit>(
      create: (ctx) => HomeWalletCubit(
        walletRepository: ctx.read<IWalletRepository>(),
        transactionRepository: ctx.read<ITransactionRepository>(),
        userRepository: ctx.read<IUserRepository>(),
      )..watchUser(currentUserId),
      child: _HomeWalletView(
        currentUserId: currentUserId,
        currentUserName: userName,
        fallbackIban:
            authState.user?.iban ?? 'TR42 0006 2000 8492 0100 0000 01',
        canAccessBusinessPanel: authState.canAccessBusinessPanel,
      ),
    );
  }
}

class _HomeWalletView extends StatelessWidget {
  final String currentUserId;
  final String currentUserName;
  final String fallbackIban;
  final bool canAccessBusinessPanel;

  const _HomeWalletView({
    required this.currentUserId,
    required this.currentUserName,
    required this.fallbackIban,
    required this.canAccessBusinessPanel,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeWalletCubit>();
    if (cubit.state.activeUserId != currentUserId) {
      cubit.watchUser(currentUserId);
    }

    return Scaffold(
      backgroundColor: AppLightColors.surface,
      appBar: const RoleSwitchAppBar(isBusinessMode: false),
      body: BlocConsumer<HomeWalletCubit, HomeWalletState>(
        listenWhen: (prev, curr) => prev.actionMessage != curr.actionMessage,
        listener: (context, state) {
          final msg = state.actionMessage;
          if (msg == null) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: state.isErrorAction
                  ? AppColors.warningOrange
                  : AppColors.primaryGreen,
            ),
          );
          cubit.clearActionMessage();
        },
        builder: (context, state) {
          final ibanStr = state.wallet?.iban ?? fallbackIban;
          return FourStateView(
            status: state.status == ViewStatus.loading && state.wallet == null
                ? ViewStatus.loading
                : (state.status == ViewStatus.error
                    ? ViewStatus.error
                    : ViewStatus.success),
            errorMessage: state.errorMessage ?? 'Cüzdan verileri yüklenemedi.',
            onRetry: cubit.refresh,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PersonalContextBanner(
                    leftLabel:
                        '$currentUserName • ${state.wallet?.walletId ?? 'PP-849201'}',
                    trailing: canAccessBusinessPanel
                        ? _ModeSwitchPill(
                            icon: Icons.business_center_outlined,
                            label: 'İşletme Paneline Geç',
                            onTap: () {
                              context.read<AuthBloc>().add(
                                const AuthPanelModeToggled(
                                  isBusinessMode: true,
                                ),
                              );
                              context.go(AppRoutes.businessOverview);
                            },
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Bireysel Cüzdan',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: const Color(0xFF065F46),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 14),
                  PersonalWalletHeroCard(
                    state: state,
                    ibanStr: ibanStr,
                    onSelectCurrency: cubit.selectCurrency,
                    onToggleHideBalance: cubit.toggleHideBalance,
                  ),
                  const SizedBox(height: 18),
                  RecentTransactionsCard(
                    status: state.transactionsViewStatus,
                    transactions: state.transactions,
                    onRetry: cubit.refresh,
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 16),
                    DemoSeedBannerCard(
                      title: 'Kasım 2026 Verilerini Yenile',
                      subtitle:
                          'Sunum verilerini yenileyin veya geliştirici konsolunu açın.',
                      isBusy: state.isSeeding,
                      onSeedPressed: cubit.seedDemoData,
                      onConsolePressed: () =>
                          context.push(AppRoutes.developerConsole),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 2. İŞLETME KASASI & YÖNETİM PANELİ (B2B Admin & Employee için Safe Overview)
class BusinessSafeOverviewScreen extends StatelessWidget {
  const BusinessSafeOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final companyId =
        authState.user?.companyId ?? AppStrings.defaultCompanyId;

    return BlocProvider<BusinessOverviewCubit>(
      create: (ctx) => BusinessOverviewCubit(
        walletRepository: ctx.read<IWalletRepository>(),
        companyRepository: ctx.read<ICompanyRepository>(),
        expenseRepository: ctx.read<IExpenseRepository>(),
        transactionRepository: ctx.read<ITransactionRepository>(),
        userRepository: ctx.read<IUserRepository>(),
      )..loadCompany(companyId),
      child: _BusinessOverviewView(authState: authState, companyId: companyId),
    );
  }
}

class _BusinessOverviewView extends StatelessWidget {
  final AuthState authState;
  final String companyId;

  const _BusinessOverviewView({
    required this.authState,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BusinessOverviewCubit>();
    if (cubit.state.activeCompanyId != companyId) {
      cubit.loadCompany(companyId);
    }

    return Scaffold(
      backgroundColor: AppLightColors.surface,
      appBar: const RoleSwitchAppBar(isBusinessMode: true),
      body: BlocConsumer<BusinessOverviewCubit, BusinessOverviewState>(
        listenWhen: (prev, curr) => prev.actionMessage != curr.actionMessage,
        listener: (context, state) {
          final msg = state.actionMessage;
          if (msg == null) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: state.isErrorAction
                  ? AppColors.expenseRed
                  : AppColors.primaryGreen,
            ),
          );
          cubit.clearActionMessage();
        },
        builder: (context, state) {
          final companyName =
              state.company?.name ?? AppStrings.defaultCompanyName;
          final taxNo = state.company?.taxNumber ?? '6320984112';
          final corporateIban =
              state.company?.corporateIban ??
              state.companyWallet?.iban ??
              'TR89 0006 2000 0001 9845 2819 01';

          return FourStateView(
            status:
                state.status == ViewStatus.loading &&
                    state.companyWallet == null
                ? ViewStatus.loading
                : (state.status == ViewStatus.error
                    ? ViewStatus.error
                    : ViewStatus.success),
            errorMessage: state.errorMessage ?? 'İşletme kasası yüklenemedi.',
            onRetry: () => cubit.loadCompany(companyId),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PersonalContextBanner(
                    leftLabel: '$companyName • VKN: $taxNo',
                    trailing: _ModeSwitchPill(
                      icon: Icons.swap_horiz_rounded,
                      label: 'Kişisel Cüzdana Dön',
                      onTap: () {
                        context.read<AuthBloc>().add(
                          const AuthPanelModeToggled(isBusinessMode: false),
                        );
                        context.go(AppRoutes.home);
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  BusinessSafeHeroCard(
                    balanceKurus: state.balanceKurus,
                    isAdmin: authState.isAdmin,
                    corporateIban: corporateIban,
                    onTransferToAccount: () => showBusinessTransferToAccountSheet(
                      context: context,
                      cubit: cubit,
                      corporateIban: corporateIban,
                    ),
                    onTopUpBalance: () => showBusinessTopUpBalanceSheet(
                      context: context,
                      cubit: cubit,
                    ),
                  ),
                  const SizedBox(height: 16),
                  BusinessMetricsGrid(state: state),
                  const SizedBox(height: 18),
                  BusinessQuickActionsGrid(
                    pendingExpenseCount: state.pendingExpenseCount,
                  ),
                  const SizedBox(height: 18),
                  BusinessWeeklyCashflowCard(
                    state: state,
                    canApproveExpenses: authState.canApproveExpenses,
                    onSetPeriod: cubit.setPeriod,
                    onSelectBar: cubit.selectBar,
                  ),
                  const SizedBox(height: 18),
                  BusinessPendingExpensesCard(
                    featuredExpense: state.featuredExpense,
                    recentTransactions: state.recentTransactions,
                    canApproveExpenses: authState.canApproveExpenses,
                    isSubmitting: state.isSubmitting,
                    onInspectExpense: (exp) => showExpenseReceiptInspectDialog(
                      context: context,
                      expense: exp,
                      canApproveExpenses: authState.canApproveExpenses,
                      onApprove: () => cubit.approveExpense(
                        expense: exp,
                        actorRole: authState.role,
                        actorId: authState.user?.uid,
                      ),
                      onReject: () => cubit.rejectExpense(
                        expense: exp,
                        actorRole: authState.role,
                        actorId: authState.user?.uid,
                      ),
                    ),
                    onApproveExpense: (exp) => cubit.approveExpense(
                      expense: exp,
                      actorRole: authState.role,
                      actorId: authState.user?.uid,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (kDebugMode)
                    DemoSeedBannerCard(
                      title: 'Kasım 2026 Verilerini Yeniden Tohumla',
                      subtitle:
                          'İşletme kasasını, masrafları ve işlemleri başlangıç durumuna döndür.',
                      isBusy: state.isSubmitting,
                      onSeedPressed: cubit.seedDemoData,
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ModeSwitchPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ModeSwitchPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 13, color: AppColors.primaryTeal),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.darkNavy,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
