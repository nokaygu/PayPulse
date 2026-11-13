import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/financial_amount.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/repositories/i_transaction_repository.dart';
import '../../widgets/four_state_view.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../../widgets/transaction_list_tile_widget.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import 'bloc/transaction_history_cubit.dart';

/// İşlem Geçmişi ve Akıllı Ekstre Ekranı (Stateless + TransactionHistoryCubit)
class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionHistoryCubit>(
      create: (ctx) {
        final uid = ctx.read<AuthBloc>().state.user?.uid ?? '';
        return TransactionHistoryCubit(
          transactionRepository: ctx.read<ITransactionRepository>(),
        )..watchUser(uid);
      },
      child: const _TransactionHistoryBody(),
    );
  }
}

class _TransactionHistoryBody extends StatelessWidget {
  const _TransactionHistoryBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TransactionHistoryCubit>();

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => prev.user?.uid != curr.user?.uid,
      listener: (ctx, authState) {
        ctx.read<TransactionHistoryCubit>().watchUser(
          authState.user?.uid ?? '',
        );
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const RoleSwitchAppBar(isBusinessMode: false),
        body: BlocBuilder<TransactionHistoryCubit, TransactionHistoryState>(
          builder: (context, state) {
            final latestFast = state.latestFastTransaction;

            return RefreshIndicator(
              onRefresh: cubit.refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Aylık Net Bakiye Değişimi Özet Kartı
                    _NetSummaryHeroCard(state: state),
                    const SizedBox(height: 14),

                    // 2. Arama Çubuğu + Sıfırlama Butonu
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
                                    'İsim, IBAN, kategori veya tutar ara...',
                                hintStyle: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xFF94A3B8),
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: Color(0xFF64748B),
                                  size: 20,
                                ),
                                suffixIcon: state.searchQuery.isNotEmpty
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
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: cubit.resetFilters,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: AppColors.darkNavy,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 3. Filtre Çipleri
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: TransactionFilterType.values.map((filter) {
                          final isSelected = state.selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () => cubit.setFilter(filter),
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.darkNavy
                                      : Colors.white,
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
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF475569),
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 4. Dinamik Son FAST Gönderimi Vurgu Kartı
                    if (latestFast != null) ...[
                      _HighlightedFastCard(
                        transaction: latestFast,
                        isIncoming: state.isIncomingTransaction(latestFast),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 5. 4-State Yönetimli Gruplanmış İşlem Listesi
                    FourStateView(
                      status: state.listStatus,
                      errorMessage:
                          state.errorMessage ?? 'İşlem geçmişi yüklenemedi.',
                      emptyMessage: state.searchQuery.isNotEmpty ||
                              state.selectedFilter != TransactionFilterType.all
                          ? 'Seçili arama/filtre kriterine uygun işlem bulunamadı.'
                          : 'Henüz kayıtlı işlem hareketiniz bulunmuyor.',
                      onRetry: cubit.refresh,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: state.groupedTransactions.map((group) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _GroupHeader(
                                  title: group.dateLabel,
                                  netText: group.formattedNet,
                                  isPositive: group.netKurus >= 0,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      for (
                                        int i = 0;
                                        i < group.items.length;
                                        i++
                                      ) ...[
                                        if (i > 0)
                                          const Divider(
                                            height: 1,
                                            color: Color(0xFFF1F5F9),
                                          ),
                                        _buildTransactionTile(
                                          context,
                                          group.items[i],
                                          state.isIncomingTransaction(
                                            group.items[i],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // 6. Resmi Hesap Ekstresi İndir Butonu
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.darkNavy,
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Resmi Hesap Ekstresi (${state.filteredTransactions.length} işlem) hazırlandı.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.description_outlined, size: 18),
                        label: Text(
                          'Resmi Hesap Ekstresi İndir (PDF / Excel)',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.darkNavy,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransactionTile(
    BuildContext context,
    TransactionEntity tx,
    bool isIncome,
  ) {
    final amountPrefix = isIncome ? '+' : '-';
    final amountText = '$amountPrefix${FinancialAmount.format(tx.amount)}';
    final badge = _badgeTextFor(tx);
    final timeFormatted =
        '${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}';

    return TransactionListTileWidget(
      title: tx.title.isEmpty ? 'PayPulse İşlemi' : tx.title,
      badgeText: badge,
      badgeBgColor: isIncome
          ? const Color(0xFFD1FAE5)
          : const Color(0xFFF1F5F9),
      badgeTextColor: isIncome
          ? const Color(0xFF065F46)
          : const Color(0xFF475569),
      subtitle: '${tx.category} • $timeFormatted',
      amountText: amountText,
      isIncome: isIncome,
      statusOrNoteText: tx.status,
      statusTextColor: isIncome
          ? AppColors.primaryTeal
          : const Color(0xFF64748B),
      icon: _iconFor(tx, isIncome),
      iconBgColor: isIncome
          ? const Color(0xFFD1FAE5)
          : const Color(0xFFF1F5F9),
      iconColor: isIncome ? AppColors.primaryTeal : AppColors.darkNavy,
      onTap: () => context.push(
        AppRoutes.fastReceipt.replaceFirst(':txId', tx.txId),
      ),
    );
  }

  String _badgeTextFor(TransactionEntity tx) {
    if (tx.isFastTransfer) return 'FAST';
    if (tx.isPosPayment) return 'QR / POS';
    if (tx.isWalletDeposit) return 'Cüzdan';
    if (tx.type == 'salary') return 'Maaş / EFT';
    if (tx.type == 'subscription') return 'Abonelik';
    if (tx.type == 'bill') return 'Fatura';
    return 'Transfer';
  }

  IconData _iconFor(TransactionEntity tx, bool isIncome) {
    if (tx.isPosPayment) return Icons.qr_code_rounded;
    if (tx.type == 'salary') return Icons.business_rounded;
    if (tx.type == 'subscription') return Icons.tv_rounded;
    if (tx.type == 'bill') return Icons.bolt_outlined;
    return isIncome ? Icons.south_west_rounded : Icons.north_east_rounded;
  }
}

class _NetSummaryHeroCard extends StatelessWidget {
  final TransactionHistoryState state;

  const _NetSummaryHeroCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.heroCardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavy.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AYLIK NET BAKİYE DEĞİŞİMİ',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 9.5,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    state.formattedNetChange,
                    style: AppTextStyles.numericBalance.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${state.transactions.length} Kayıtlı İşlem',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Expanded(
                  child: _MiniFlowBox(
                    icon: Icons.south_west_rounded,
                    iconColor: AppColors.primaryGreen,
                    label: 'Gelen',
                    amount: state.formattedTotalIncome,
                    amountColor: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _MiniFlowBox(
                    icon: Icons.north_east_rounded,
                    iconColor: const Color(0xFFF87171),
                    label: 'Giden',
                    amount: state.formattedTotalExpense,
                    amountColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniFlowBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String amount;
  final Color amountColor;

  const _MiniFlowBox({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.amount,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: iconColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: AppTextStyles.labelLarge.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightedFastCard extends StatelessWidget {
  final TransactionEntity transaction;
  final bool isIncoming;

  const _HighlightedFastCard({
    required this.transaction,
    required this.isIncoming,
  });

  @override
  Widget build(BuildContext context) {
    final prefix = isIncoming ? '+' : '-';
    final amountText = '$prefix${FinancialAmount.format(transaction.amount)}';

    return InkWell(
      onTap: () => context.push(
        AppRoutes.fastReceipt.replaceFirst(':txId', transaction.txId),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryGreen, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: AppColors.primaryTeal,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'SON FAST İŞLEMİ',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryTeal,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          transaction.status,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFF065F46),
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.title.isEmpty
                        ? 'FAST Transfer'
                        : transaction.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  Text(
                    '${transaction.category} • ${transaction.txId}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 11.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amountText,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isIncoming
                        ? AppColors.primaryTeal
                        : AppColors.darkNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Dekont >',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryTeal,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String title;
  final String netText;
  final bool isPositive;

  const _GroupHeader({
    required this.title,
    required this.netText,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.labelSmall.copyWith(
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        Text(
          netText,
          style: AppTextStyles.labelMedium.copyWith(
            color: isPositive ? AppColors.primaryTeal : AppColors.darkNavy,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
