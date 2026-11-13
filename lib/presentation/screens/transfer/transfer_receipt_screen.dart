import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/utils/financial_amount.dart';
import '../../../domain/repositories/i_transaction_repository.dart';
import '../../widgets/four_state_view.dart';
import '../../widgets/receipt_summary_card_widget.dart';
import '../../widgets/role_switch_app_bar.dart';
import 'bloc/transfer_cubits.dart';

class TransferReceiptScreen extends StatelessWidget {
  final String txId;

  const TransferReceiptScreen({super.key, this.txId = 'FAST-2026-88412'});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransferReceiptCubit>(
      create: (ctx) => TransferReceiptCubit(
        transactionRepository: ctx.read<ITransactionRepository>(),
      )..loadTransaction(txId),
      child: _TransferReceiptView(txId: txId),
    );
  }
}

class _TransferReceiptView extends StatelessWidget {
  final String txId;

  const _TransferReceiptView({required this.txId});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TransferReceiptCubit>();

    return Scaffold(
      appBar: const RoleSwitchAppBar(
        customTitle: 'İşlem Dekontu (4/4)',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<TransferReceiptCubit, TransferReceiptState>(
          builder: (context, state) {
            return FourStateView(
              status: state.status,
              errorMessage: state.errorMessage ?? 'Dekont yüklenemedi.',
              emptyMessage: 'Dekont kaydı bulunamadı ($txId).',
              onRetry: () => cubit.loadTransaction(txId),
              child: Builder(
                builder: (context) {
                  final tx = state.transaction;
                  if (tx == null) return const SizedBox.shrink();

                  final String amountFormatted = FinancialAmount.format(
                    tx.amount,
                  );
                  final String senderStr = tx.senderId.isNotEmpty
                      ? 'Cüzdan (${tx.senderId})'
                      : 'PayPulse Cüzdanı';
                  final String recipientStr = tx.title.isNotEmpty
                      ? tx.title
                      : 'Alıcı';
                  final String ibanStr =
                      tx.targetIban ?? 'PayPulse FAST Transferi';
                  final String dateStr =
                      '${tx.timestamp.day}.${tx.timestamp.month.toString().padLeft(2, '0')}.${tx.timestamp.year}, '
                      '${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}';

                  return Column(
                    children: [
                      ReceiptSummaryCardWidget(
                        title: 'FAST Transferi Tamamlandı!',
                        amountText: amountFormatted,
                        badgeLabel: '✓ TCMB FAST • Anında İletildi',
                        details: {
                          'Sorgu / Dekont No': txId,
                          'Gönderen': senderStr,
                          'Alıcı Ad Soyad': recipientStr,
                          'Alıcı Banka / IBAN': ibanStr,
                          'İşlem Tarihi': dateStr,
                          'İşlem Ücreti': '₺0,00 (Ücretsiz)',
                          'Açıklama': tx.category,
                        },
                        onDownloadPdf: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '$txId numaralı PDF dekont hazırlandı.',
                              ),
                            ),
                          );
                        },
                        onShare: () {},
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.home),
                        child: const Text('Ana Sayfaya Dön'),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
