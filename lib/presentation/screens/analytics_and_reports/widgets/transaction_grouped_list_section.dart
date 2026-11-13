import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../widgets/four_state_view.dart';
import '../../../widgets/transaction_list_tile_widget.dart';
import '../bloc/transaction_history_cubit.dart';

/// Tarih gruplu işlem listesi ve resmi hesap ekstresi indirme bölümü.
class TransactionGroupedListSection extends StatelessWidget {
  final TransactionHistoryCubit cubit;
  final TransactionHistoryState state;

  const TransactionGroupedListSection({
    super.key,
    required this.cubit,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilter =
        state.searchQuery.isNotEmpty ||
        state.selectedFilter != TransactionFilterType.all ||
        state.hasActiveAdvancedFilters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FourStateView(
          status: state.listStatus,
          errorMessage: state.errorMessage ?? 'İşlem geçmişi yüklenemedi.',
          emptyMessage: hasFilter
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
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          for (int i = 0; i < group.items.length; i++) ...[
                            if (i > 0)
                              const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            _TransactionItemTile(
                              transaction: group.items[i],
                              isIncome: state.isIncomingTransaction(
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
      ],
    );
  }
}

class _TransactionItemTile extends StatelessWidget {
  final TransactionEntity transaction;
  final bool isIncome;

  const _TransactionItemTile({
    required this.transaction,
    required this.isIncome,
  });

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

  @override
  Widget build(BuildContext context) {
    final amountPrefix = isIncome ? '+' : '-';
    final amountText = '$amountPrefix${FinancialAmount.format(transaction.amount)}';
    final timeFormatted =
        '${transaction.timestamp.hour.toString().padLeft(2, '0')}:${transaction.timestamp.minute.toString().padLeft(2, '0')}';

    return TransactionListTileWidget(
      title: transaction.title.isEmpty ? 'PayPulse İşlemi' : transaction.title,
      badgeText: _badgeTextFor(transaction),
      badgeBgColor: isIncome
          ? const Color(0xFFD1FAE5)
          : const Color(0xFFF1F5F9),
      badgeTextColor: isIncome
          ? const Color(0xFF065F46)
          : const Color(0xFF475569),
      subtitle: '${transaction.category} • $timeFormatted',
      amountText: amountText,
      isIncome: isIncome,
      statusOrNoteText: transaction.status,
      statusTextColor: isIncome
          ? AppColors.primaryTeal
          : const Color(0xFF64748B),
      icon: _iconFor(transaction, isIncome),
      iconBgColor: isIncome
          ? const Color(0xFFD1FAE5)
          : const Color(0xFFF1F5F9),
      iconColor: isIncome ? AppColors.primaryTeal : AppColors.darkNavy,
      onTap: () => context.push(
        AppRoutes.fastReceipt.replaceFirst(':txId', transaction.txId),
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

