import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/financial_amount.dart';
import '../../../domain/repositories/i_payment_request_repository.dart';
import '../../../domain/repositories/i_transaction_repository.dart';
import '../../../domain/repositories/i_wallet_repository.dart';
import '../../widgets/four_state_view.dart';
import '../auth/bloc/auth_bloc.dart';
import 'bloc/transfer_cubits.dart';
import 'widgets/fraud_confirmation_dialog.dart';
import 'widgets/transfer_payment_request_card.dart';
import 'widgets/transfer_security_notice_card.dart';
import 'widgets/transfer_step_indicator.dart';
import 'widgets/transfer_summary_details_card.dart';

/// 7/24 FAST Para Transferi Onay (Adım 3/4) ve `/pay/:requestId` Deep Link Ekranı.
class TransferSummaryScreen extends StatelessWidget {
  final String recipientIban;
  final String recipientName;
  final int amountInKurus;
  final String description;
  final String? paymentRequestId;

  const TransferSummaryScreen({
    super.key,
    this.recipientIban = 'TR34 0006 2000 0001 2345 6789 01',
    this.recipientName = 'Zeynep Kaya',
    this.amountInKurus = 150000,
    this.description = 'FAST Para Transferi',
    this.paymentRequestId,
  });

  @override
  Widget build(BuildContext context) {
    final senderUserId =
        context.watch<AuthBloc>().state.user?.uid ?? AppStrings.demoB2CUid;
    final senderName =
        context.watch<AuthBloc>().state.user?.name ?? 'PayPulse Kullanıcısı';

    return BlocProvider<TransferSummaryCubit>(
      create: (ctx) => TransferSummaryCubit(
        walletRepository: ctx.read<IWalletRepository>(),
        transactionRepository: ctx.read<ITransactionRepository>(),
        paymentRequestRepository: ctx.read<IPaymentRequestRepository>(),
        recipientIban: recipientIban,
        recipientName: recipientName,
        amountInKurus: amountInKurus,
        description: description,
        paymentRequestId: paymentRequestId,
      )..initialize(senderUserId: senderUserId),
      child: _TransferSummaryView(
        senderUserId: senderUserId,
        senderName: senderName,
      ),
    );
  }
}

class _TransferSummaryView extends StatelessWidget {
  final String senderUserId;
  final String senderName;

  const _TransferSummaryView({
    required this.senderUserId,
    required this.senderName,
  });

  Future<void> _handleFraudPrompt(
    BuildContext context,
    TransferSummaryCubit cubit,
    int amountInKurus,
  ) async {
    final confirmed = await FraudConfirmationDialog.show(context, amountInKurus);
    if (confirmed == true) {
      await cubit.confirmTransfer(
        senderUserId: senderUserId,
        fraudConfirmed: true,
      );
    } else {
      cubit.dismissFraudPrompt();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TransferSummaryCubit>();

    return BlocConsumer<TransferSummaryCubit, TransferSummaryState>(
      listener: (context, state) {
        if (state.requiresFraudDialog) {
          _handleFraudPrompt(context, cubit, state.amountInKurus);
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.expenseRed,
              content: Text(state.errorMessage!),
            ),
          );
          cubit.clearError();
        } else if (state.completedTransaction != null) {
          final tx = state.completedTransaction!;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.primaryGreen,
              content: Text('TCMB FAST transferi anında tamamlandı!'),
            ),
          );
          context.go('/home/transfer/receipt/${tx.txId}');
        }
      },
      builder: (context, state) {
        final senderBalanceText = state.senderWallet != null
            ? FinancialAmount.format(state.senderWallet!.balanceTl)
            : 'Bakiye doğrulanıyor...';

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: FourStateView(
              status: state.loadStatus,
              errorMessage:
                  state.errorMessage ?? 'Transfer özeti yüklenemedi.',
              emptyMessage: 'Ödeme talebi bulunamadı veya süresi doldu.',
              onRetry: () => cubit.initialize(senderUserId: senderUserId),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TransferStepIndicator(
                      isPaymentRequestFlow: state.isPaymentRequestFlow,
                      onBack: () => context.canPop()
                          ? context.pop()
                          : context.go(AppRoutes.home),
                    ),
                    const SizedBox(height: 16),
                    TransferPaymentRequestCard(
                      amountInKurus: state.amountInKurus,
                    ),
                    const SizedBox(height: 16),
                    TransferSummaryDetailsCard(
                      senderName: senderName,
                      senderBalanceText: senderBalanceText,
                      recipientName: state.recipientName,
                      recipientIban: state.recipientIban,
                      description: state.description,
                    ),
                    const SizedBox(height: 14),
                    TransferSecurityNoticeCard(
                      isAboveFraudThreshold: state.isAboveFraudThreshold,
                      rulesAccepted: state.rulesAccepted,
                      isSubmitting: state.isSubmitting,
                      onRulesChanged: cubit.setRulesAccepted,
                      onConfirm: () =>
                          cubit.confirmTransfer(senderUserId: senderUserId),
                      onCancel: () => context.go(AppRoutes.home),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
