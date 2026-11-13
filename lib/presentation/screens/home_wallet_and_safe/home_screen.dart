import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/formatters/currency_and_card_formatters.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/financial_amount.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/repositories/i_company_repository.dart';
import '../../../domain/repositories/i_expense_repository.dart';
import '../../../domain/repositories/i_transaction_repository.dart';
import '../../../domain/repositories/i_user_repository.dart';
import '../../../domain/repositories/i_wallet_repository.dart';
import '../../widgets/dark_gradient_hero_card.dart';
import '../../widgets/four_state_view.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../../widgets/transaction_list_tile_widget.dart';
import '../../widgets/weekly_bar_chart.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import '../auth/bloc/auth_state.dart';
import 'bloc/business_overview_cubit.dart';
import 'bloc/home_wallet_cubit.dart';

// =============================================================================
// 1. BİREYSEL CÜZDAN ANA EKRANI (B2C & Çalışanlar için Kişisel Bakiye Görünümü)
// =============================================================================
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
          if (msg != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: state.isErrorAction
                    ? AppColors.warningOrange
                    : AppColors.primaryGreen,
              ),
            );
            cubit.clearActionMessage();
          }
        },
        builder: (context, state) {
          final ibanStr = state.wallet?.iban ?? fallbackIban;

          return FourStateView(
            status: state.status == ViewStatus.loading && state.wallet == null
                ? ViewStatus.loading
                : state.status == ViewStatus.error
                ? ViewStatus.error
                : ViewStatus.success,
            errorMessage: state.errorMessage ?? 'Cüzdan verileri yüklenemedi.',
            onRetry: cubit.refresh,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Üst Rol Geçiş & Profil Bandı
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE).withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryTeal,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '$currentUserName • ${state.wallet?.walletId ?? 'PP-849201'}',
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.darkNavy,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (canAccessBusinessPanel)
                          GestureDetector(
                            onTap: () {
                              context.read<AuthBloc>().add(
                                const AuthPanelModeToggled(
                                  isBusinessMode: true,
                                ),
                              );
                              context.go(AppRoutes.businessOverview);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFCBD5E1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.business_center_outlined,
                                    size: 13,
                                    color: AppColors.primaryTeal,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'İşletme Paneline Geç',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.darkNavy,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Container(
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 1. Çoklu Para Birimli Ana Cüzdan Kartı (DarkGradientHeroCard)
                  DarkGradientHeroCard(
                    title: 'KULLANILABİLİR CÜZDAN BAKİYESİ',
                    mainAmount: state.formattedActiveBalance,
                    subtitle: '7/24 Anında FAST & Karekod Hazır',
                    topRightBadge: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final curr in const ['TRY', 'USD', 'EUR']) ...[
                          _CurrencyChip(
                            currency: curr,
                            isSelected: state.selectedCurrency == curr,
                            onTap: () => cubit.selectCurrency(curr),
                          ),
                          const SizedBox(width: 4),
                        ],
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          onPressed: cubit.toggleHideBalance,
                          icon: Icon(
                            state.hideBalance
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF5EEAD4),
                            size: 19,
                          ),
                        ),
                      ],
                    ),
                    bottomChild: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  ibanStr,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontFamily: 'monospace',
                                    fontSize: 10.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(text: ibanStr),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('FAST IBAN kopyalandı.'),
                                    ),
                                  );
                                },
                                child: const Icon(
                                  Icons.copy_rounded,
                                  size: 15,
                                  color: Color(0xFF5EEAD4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5EEAD4),
                                  foregroundColor: AppColors.darkNavy,
                                  minimumSize: const Size(0, 44),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () =>
                                    context.push(AppRoutes.fastTransfer),
                                icon: const Icon(Icons.bolt_rounded, size: 18),
                                label: const Text(
                                  'FAST Gönder',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.08,
                                  ),
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.18),
                                  ),
                                  minimumSize: const Size(0, 44),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => context.go(AppRoutes.qr),
                                icon: const Icon(
                                  Icons.qr_code_rounded,
                                  size: 18,
                                ),
                                label: const Text(
                                  'QR ile Öde',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 2. Canlı Cüzdan Hareketleri (FourStateView Entegrasyonu)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Son Cüzdan Hareketleri',
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkNavy,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.transactions),
                        child: Text(
                          'Tümünü Gör >',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: FourStateView(
                      status: state.transactionsViewStatus,
                      emptyMessage: 'Henüz kayıtlı cüzdan hareketi bulunmuyor.',
                      onRetry: cubit.refresh,
                      child: Column(
                        children: [
                          for (
                            int i = 0;
                            i < state.transactions.take(3).length;
                            i++
                          ) ...[
                            if (i > 0)
                              const Divider(
                                height: 1,
                                color: Color(0xFFF1F5F9),
                              ),
                            _TransactionTileItem(tx: state.transactions[i]),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // 3. Jüri Sunumu Seed & Canlı Test Paneli (Debug)
                  if (kDebugMode) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.cloud_upload_outlined,
                            color: AppColors.primaryTeal,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kasım 2026 Verilerini Yenile',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.darkNavy,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Sunum verilerini yenileyin veya geliştirici konsolunu açın.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: const Color(0xFF64748B),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkNavy,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 36),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            onPressed: state.isSeeding
                                ? null
                                : cubit.seedDemoData,
                            child: Text(
                              state.isSeeding ? '...' : 'Seed Bas',
                              style: const TextStyle(fontSize: 11.5),
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            tooltip: 'Firebase Test Konsolu',
                            onPressed: () =>
                                context.push(AppRoutes.developerConsole),
                            icon: const Icon(
                              Icons.developer_mode_rounded,
                              size: 20,
                              color: AppColors.darkNavy,
                            ),
                          ),
                        ],
                      ),
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

class _CurrencyChip extends StatelessWidget {
  final String currency;
  final bool isSelected;
  final VoidCallback onTap;

  const _CurrencyChip({
    required this.currency,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF5EEAD4)
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          currency,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected ? AppColors.darkNavy : Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 10.5,
          ),
        ),
      ),
    );
  }
}

class _TransactionTileItem extends StatelessWidget {
  final TransactionEntity tx;

  const _TransactionTileItem({required this.tx});

  @override
  Widget build(BuildContext context) {
    final bool isIncome = !tx.isExpense;
    final String amountFormatted = isIncome
        ? '+${FinancialAmount.format(tx.amount)}'
        : '-${FinancialAmount.format(tx.amount)}';

    return TransactionListTileWidget(
      title: tx.title.isNotEmpty
          ? tx.title
          : (tx.targetIban ?? 'FAST Transferi'),
      badgeText: tx.type.toUpperCase(),
      badgeBgColor: isIncome
          ? const Color(0xFFD1FAE5)
          : const Color(0xFFE0F2FE),
      badgeTextColor: isIncome
          ? const Color(0xFF065F46)
          : const Color(0xFF0369A1),
      subtitle:
          '${tx.category} • ${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}',
      amountText: amountFormatted,
      isIncome: isIncome,
      statusOrNoteText: tx.status,
      icon: isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
      iconBgColor: isIncome
          ? const Color(0xFFD1FAE5)
          : const Color(0xFFF1F5F9),
      iconColor: isIncome ? AppColors.primaryGreen : AppColors.darkNavy,
      onTap: () => context.push('/home/transfer/receipt/${tx.txId}'),
    );
  }
}

// =============================================================================
// 2. İŞLETME KASASI & YÖNETİM PANELİ (B2B Admin & Employee için Safe Overview)
// =============================================================================
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
          if (msg != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: state.isErrorAction
                    ? AppColors.expenseRed
                    : AppColors.primaryGreen,
              ),
            );
            cubit.clearActionMessage();
          }
        },
        builder: (context, state) {
          final companyName =
              state.company?.name ?? AppStrings.defaultCompanyName;
          final taxNo = state.company?.taxNumber ?? '6320984112';
          final corporateIban =
              state.company?.corporateIban ??
              state.companyWallet?.iban ??
              'TR89 0006 2000 0001 9845 2819 01';
          final featuredExpense = state.featuredExpense;

          return FourStateView(
            status:
                state.status == ViewStatus.loading &&
                    state.companyWallet == null
                ? ViewStatus.loading
                : state.status == ViewStatus.error
                ? ViewStatus.error
                : ViewStatus.success,
            errorMessage: state.errorMessage ?? 'İşletme kasası yüklenemedi.',
            onRetry: () => cubit.loadCompany(companyId),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Üst Şerit: VKN + Kişisel Cüzdana Dön
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE).withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryTeal,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '$companyName • VKN: $taxNo',
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.darkNavy,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            context.read<AuthBloc>().add(
                              const AuthPanelModeToggled(isBusinessMode: false),
                            );
                            context.go(AppRoutes.home);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.swap_horiz_rounded,
                                  size: 14,
                                  color: AppColors.primaryTeal,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Kişisel Cüzdana Dön',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.darkNavy,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 1. Kullanılabilir İşletme Bakiyesi Hero Kartı (DarkGradientHeroCard)
                  DarkGradientHeroCard(
                    title: 'KULLANILABİLİR İŞLETME BAKİYESİ (TRY)',
                    mainAmount: FinancialAmount.format(state.balanceKurus),
                    subtitle: authState.isAdmin
                        ? 'Yönetici Kasası • Anlık Takas Aktif'
                        : 'Kurumsal Personel Görünümü',
                    topRightBadge: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '● Aktif Hesap',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: const Color(0xFF5EEAD4),
                          fontSize: 10,
                        ),
                      ),
                    ),
                    bottomChild: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ana Ticari IBAN',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: const Color(0xFF94A3B8),
                                        fontSize: 10,
                                      ),
                                    ),
                                    Text(
                                      corporateIban,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: Colors.white,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(
                                      text: corporateIban.replaceAll(' ', ''),
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Ticari IBAN kopyalandı.'),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Kopyala',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (authState.isAdmin) ...[
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5EEAD4),
                                    foregroundColor: AppColors.darkNavy,
                                    minimumSize: const Size(0, 42),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => _showTransferToAccountSheet(
                                    context,
                                    cubit,
                                    corporateIban,
                                  ),
                                  icon: const Icon(
                                    Icons.output_rounded,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Hesaba Aktar',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.08,
                                    ),
                                    side: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                    ),
                                    minimumSize: const Size(0, 42),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () =>
                                      _showTopUpBalanceSheet(context, cubit),
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Bakiye Yükle',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. 2x2 Gerçek Zamanlı Finansal Metrik Kartları
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.trending_up_rounded,
                          badge: '+%18',
                          badgeIsGreen: true,
                          title: 'Bugünkü Tahsilat',
                          amount: FinancialAmount.format(
                            state.todayTransactionsKurus,
                          ),
                          subtitle: 'POS & FAST toplamı',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.calendar_month_outlined,
                          badge: '${state.posTransactions.length} POS',
                          badgeIsGreen: true,
                          title: 'POS Hacmi',
                          amount: FinancialAmount.format(state.posTotalKurus),
                          subtitle: 'Onaylı kart işlemleri',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.fact_check_outlined,
                          badge: '${state.pendingExpenseCount} Bekleyen',
                          badgeIsGreen: state.pendingExpenseCount == 0,
                          title: 'Masraf Talepleri',
                          amount: '${state.expenses.length} Fiş',
                          subtitle: 'Personel harcamaları',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.percent_rounded,
                          badge: '%1,39 Ort.',
                          badgeIsGreen: false,
                          title: 'Komisyon Kesintisi',
                          amount: FinancialAmount.format(
                            state.totalCommissionKurus,
                          ),
                          subtitle: '${state.posTransactions.length} işlem',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 3. Hızlı İşlemler (2x2 Grid)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hızlı İşlemler',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      Text(
                        'Kurumsal Kısa Yollar',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionBox(
                          icon: Icons.point_of_sale_rounded,
                          badgeText: 'ÖNE ÇIKAN',
                          badgeBg: const Color(0xFF065F46),
                          badgeFg: Colors.white,
                          title: 'POS ile Tahsilat',
                          subtitle: 'Sanal ve Temassız POS',
                          isHighlighted: true,
                          onTap: () => context.go(AppRoutes.businessPos),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickActionBox(
                          icon: Icons.document_scanner_outlined,
                          badgeText: 'Akıllı OCR',
                          badgeBg: const Color(0xFFE0F2FE),
                          badgeFg: AppColors.darkNavy,
                          title: 'Fatura Tara',
                          subtitle: 'Gider fişini anında işle',
                          isHighlighted: false,
                          onTap: () => context.push(AppRoutes.businessOcrScan),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionBox(
                          icon: Icons.fact_check_outlined,
                          badgeText: '● ${state.pendingExpenseCount} Bekleyen',
                          badgeBg: const Color(0xFFFEE2E2),
                          badgeFg: const Color(0xFFDC2626),
                          title: 'Masraf Onayları',
                          subtitle: 'Personel harcamaları',
                          isHighlighted: false,
                          onTap: () => context.go(AppRoutes.businessExpenses),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickActionBox(
                          icon: Icons.link_rounded,
                          badgeText: '→',
                          badgeBg: const Color(0xFFF1F5F9),
                          badgeFg: AppColors.darkNavy,
                          title: 'Ödeme Linki',
                          subtitle: 'WhatsApp & SMS Paylaş',
                          isHighlighted: false,
                          onTap: () => context.push('/pay/LNK-4402'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 4. Ciro ve Tahsilat Trendi Kartı (WeeklyBarChart Entegrasyonu)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ciro ve Tahsilat Trendi',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkNavy,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  state.periodIndex == 0
                                      ? 'Canlı Günlük Akış'
                                      : (state.periodIndex == 1
                                            ? 'Kasım 2026 Haftalık'
                                            : '2026 Yıllık Trend'),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: const Color(0xFF64748B),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  _SmallToggle(
                                    text: 'Günlük',
                                    active: state.periodIndex == 0,
                                    onTap: () => cubit.setPeriod(0),
                                  ),
                                  _SmallToggle(
                                    text: 'Haftalık',
                                    active: state.periodIndex == 1,
                                    onTap: () => cubit.setPeriod(1),
                                  ),
                                  _SmallToggle(
                                    text: 'Aylık',
                                    active: state.periodIndex == 2,
                                    onTap: () => cubit.setPeriod(2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        WeeklyBarChart(
                          points: state.chartPoints,
                          maxHeight: 110,
                          onBarTap: cubit.selectBar,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  state.chartSummaryText,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.darkNavy,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (authState.canApproveExpenses)
                                GestureDetector(
                                  onTap: () =>
                                      context.go(AppRoutes.businessReports),
                                  child: Text(
                                    'Raporu Aç',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.primaryTeal,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 5. Son Tahsilat ve Masraf Hareketleri (Gerçek Repo Verisi)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Son Tahsilat ve Onaylar',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.businessExpenses),
                        child: Text(
                          'Tümünü Gör >',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        if (featuredExpense != null) ...[
                          TransactionListTileWidget(
                            title: featuredExpense.employeeName,
                            badgeText: featuredExpense.isPending
                                ? 'Onay Bekliyor'
                                : (featuredExpense.isApproved
                                      ? 'Onaylandı'
                                      : 'Reddedildi'),
                            badgeBgColor: featuredExpense.isApproved
                                ? const Color(0xFFD1FAE5)
                                : (featuredExpense.isRejected
                                      ? const Color(0xFFFEE2E2)
                                      : const Color(0xFFE0F2FE)),
                            badgeTextColor: featuredExpense.isApproved
                                ? const Color(0xFF065F46)
                                : (featuredExpense.isRejected
                                      ? const Color(0xFF991B1B)
                                      : AppColors.darkNavy),
                            subtitle:
                                'Masraf: ${featuredExpense.merchantTitle} • ${featuredExpense.category}',
                            amountText: FinancialAmount.format(
                              featuredExpense.amount,
                            ),
                            isIncome: false,
                            statusOrNoteText: featuredExpense.accountingCode,
                            icon: Icons.receipt_long_outlined,
                            iconBgColor: featuredExpense.isApproved
                                ? const Color(0xFF0F766E)
                                : AppColors.darkNavy,
                            iconColor: Colors.white,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(0, 36),
                                      side: const BorderSide(
                                        color: Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    onPressed: () => _showReceiptInspectDialog(
                                      context,
                                      cubit,
                                      featuredExpense,
                                    ),
                                    child: const Text(
                                      'Fişi İncele',
                                      style: TextStyle(fontSize: 11.5),
                                    ),
                                  ),
                                ),
                                if (authState.canApproveExpenses) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            featuredExpense.isPending
                                            ? const Color(0xFF0F766E)
                                            : const Color(0xFF64748B),
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(0, 36),
                                      ),
                                      onPressed:
                                          (!featuredExpense.isPending ||
                                              state.isSubmitting)
                                          ? null
                                          : () => cubit.approveExpense(
                                              expense: featuredExpense,
                                              actorRole: authState.role,
                                              actorId: authState.user?.uid,
                                            ),
                                      child: Text(
                                        featuredExpense.isPending
                                            ? '✓ Onayla'
                                            : 'İşlem Tamam',
                                        style: const TextStyle(fontSize: 11.5),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        for (
                          int i = 0;
                          i < state.recentTransactions.take(2).length;
                          i++
                        ) ...[
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          _TransactionTileItem(tx: state.recentTransactions[i]),
                        ],
                        if (featuredExpense == null &&
                            state.recentTransactions.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: Text('Kurumsal hareket bulunamadı.'),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 6. Demo Verilerini Yenile Paneli (Debug)
                  if (kDebugMode)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.cloud_upload_outlined,
                            color: AppColors.primaryTeal,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kasım 2026 Verilerini Yeniden Tohumla',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.darkNavy,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'İşletme kasasını, masrafları ve işlemleri başlangıç durumuna döndür.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: const Color(0xFF64748B),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkNavy,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 36),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            onPressed: state.isSubmitting
                                ? null
                                : cubit.seedDemoData,
                            child: const Text(
                              'Seed Bas',
                              style: TextStyle(fontSize: 11.5),
                            ),
                          ),
                        ],
                      ),
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

  void _showTransferToAccountSheet(
    BuildContext context,
    BusinessOverviewCubit cubit,
    String corporateIban,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => BlocProvider<BusinessOverviewCubit>.value(
        value: cubit,
        child: BlocBuilder<BusinessOverviewCubit, BusinessOverviewState>(
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ticari Hesaba Aktar',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Şirket kullanılabilir bakiyesinden ticari banka hesabınıza anında FAST/EFT yapın.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aktarılacak Tutar (₺)',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: cubit.transferAmountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [TurkishCurrencyInputFormatter()],
                    decoration: InputDecoration(
                      prefixText: '₺ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [500000, 1000000, 2500000, 5000000].map((kurus) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            label: Text(FinancialAmount.format(kurus)),
                            onPressed: () =>
                                cubit.setTransferPresetKurus(kurus),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.account_balance_rounded,
                          color: AppColors.primaryTeal,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hedef Ticari Banka Hesabı',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                  color: AppColors.darkNavy,
                                ),
                              ),
                              Text(
                                corporateIban,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkNavy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: state.isSubmitting
                          ? null
                          : () async {
                              final ok = await cubit.transferToBankAccount();
                              if (ok && ctx.mounted) Navigator.pop(ctx);
                            },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text(
                        'Transferi Onayla',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showTopUpBalanceSheet(
    BuildContext context,
    BusinessOverviewCubit cubit,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => BlocProvider<BusinessOverviewCubit>.value(
        value: cubit,
        child: BlocBuilder<BusinessOverviewCubit, BusinessOverviewState>(
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Şirket Kasasına Bakiye Yükle',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [1000000, 2500000, 5000000, 10000000].map((
                      kurus,
                    ) {
                      final isSelected = state.topUpAmountKurus == kurus;
                      return ChoiceChip(
                        label: Text(FinancialAmount.format(kurus)),
                        selected: isSelected,
                        selectedColor: const Color(0xFF5EEAD4),
                        onSelected: (_) => cubit.setTopUpAmountKurus(kurus),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: state.selectedTopUpMethod.startsWith('Banka')
                            ? AppColors.primaryTeal
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    leading: const Icon(
                      Icons.account_balance,
                      color: AppColors.primaryTeal,
                    ),
                    title: const Text('Banka Havalesi / FAST'),
                    trailing: state.selectedTopUpMethod.startsWith('Banka')
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.primaryTeal,
                          )
                        : null,
                    onTap: () => cubit.setTopUpMethod('Banka Havalesi / FAST'),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: state.selectedTopUpMethod.startsWith('Kurumsal')
                            ? AppColors.primaryTeal
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    leading: const Icon(
                      Icons.credit_card,
                      color: AppColors.primaryTeal,
                    ),
                    title: const Text('Kurumsal Şirket Kredi Kartı'),
                    trailing: state.selectedTopUpMethod.startsWith('Kurumsal')
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.primaryTeal,
                          )
                        : null,
                    onTap: () =>
                        cubit.setTopUpMethod('Kurumsal Şirket Kredi Kartı'),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: state.isSubmitting
                          ? null
                          : () async {
                              final ok = await cubit.topUpBalance();
                              if (ok && ctx.mounted) Navigator.pop(ctx);
                            },
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: Text(
                        'Bakiye Yükle (${FinancialAmount.format(state.topUpAmountKurus)})',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showReceiptInspectDialog(
    BuildContext context,
    BusinessOverviewCubit cubit,
    ExpenseEntity expense,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
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
          if (authState.canApproveExpenses && expense.isPending) ...[
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.expenseRed),
              onPressed: () {
                cubit.rejectExpense(
                  expense: expense,
                  actorRole: authState.role,
                  actorId: authState.user?.uid,
                );
                Navigator.pop(ctx);
              },
              child: const Text('Reddet'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                cubit.approveExpense(
                  expense: expense,
                  actorRole: authState.role,
                  actorId: authState.user?.uid,
                );
                Navigator.pop(ctx);
              },
              child: const Text('✓ Onayla'),
            ),
          ] else
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Kapat'),
            ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String badge;
  final bool badgeIsGreen;
  final String title;
  final String amount;
  final String subtitle;

  const _MetricCard({
    required this.icon,
    required this.badge,
    required this.badgeIsGreen,
    required this.title,
    required this.amount,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: AppColors.darkNavy),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeIsGreen
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: badgeIsGreen
                        ? const Color(0xFF065F46)
                        : const Color(0xFF475569),
                    fontSize: 9.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.darkNavy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF94A3B8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionBox extends StatelessWidget {
  final IconData icon;
  final String badgeText;
  final Color badgeBg;
  final Color badgeFg;
  final String title;
  final String subtitle;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _QuickActionBox({
    required this.icon,
    required this.badgeText,
    required this.badgeBg,
    required this.badgeFg,
    required this.title,
    required this.subtitle,
    required this.isHighlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isHighlighted
              ? const Color(0xFFCCFBF1).withValues(alpha: 0.55)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isHighlighted
                ? const Color(0xFF5EEAD4)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? const Color(0xFF0F766E)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isHighlighted ? Colors.white : AppColors.darkNavy,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: badgeFg,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallToggle extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const _SmallToggle({
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: AppTextStyles.labelSmall.copyWith(
            color: active ? AppColors.darkNavy : const Color(0xFF64748B),
            fontSize: 9.5,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
