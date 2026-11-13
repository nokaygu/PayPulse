import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../domain/repositories/i_transaction_repository.dart';
import '../../widgets/four_state_view.dart';
import '../../widgets/role_switch_app_bar.dart';
import 'bloc/transfer_cubits.dart';
import 'widgets/transfer_receipt_content.dart';

/// 7/24 FAST İşlem Dekontu Ekranı (Adım 4/4 - `StatelessWidget`).
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
              child: state.transaction == null
                  ? const SizedBox.shrink()
                  : TransferReceiptContent(
                      txId: txId,
                      transaction: state.transaction!,
                      onGoHome: () => context.go(AppRoutes.home),
                    ),
            );
          },
        ),
      ),
    );
  }
}
