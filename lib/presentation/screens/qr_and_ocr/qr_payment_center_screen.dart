import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/repositories/i_payment_request_repository.dart';
import '../../../domain/repositories/i_transaction_repository.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../auth/bloc/auth_bloc.dart';
import 'bloc/qr_payment_cubit.dart';
import 'widgets/qr_mode_switcher.dart';
import 'widgets/qr_payment_dialogs.dart';
import 'widgets/scan_qr_card.dart';
import 'widgets/show_my_qr_card.dart';

/// B2C Dinamik QR Kod ile Öde & Tahsil Et Ekranı (Stateless + QrPaymentCubit + 48sn TR Karekod)
class QrPaymentCenterScreen extends StatelessWidget {
  const QrPaymentCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QrPaymentCubit>(
      create: (ctx) => QrPaymentCubit(
        paymentRequestRepository: ctx.read<IPaymentRequestRepository>(),
        transactionRepository: ctx.read<ITransactionRepository>(),
      ),
      child: const _QrPaymentCenterBody(),
    );
  }
}

class _QrPaymentCenterBody extends StatelessWidget {
  const _QrPaymentCenterBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<QrPaymentCubit>();

    return MultiBlocListener(
      listeners: [
        BlocListener<QrPaymentCubit, QrPaymentState>(
          listenWhen: (prev, curr) =>
              curr.navigateToPayRoute != null &&
              prev.navigateToPayRoute != curr.navigateToPayRoute,
          listener: (ctx, state) {
            final route = state.navigateToPayRoute;
            if (route == null) return;
            ctx.read<QrPaymentCubit>().clearNavigation();
            ctx.push(route);
          },
        ),
        BlocListener<QrPaymentCubit, QrPaymentState>(
          listenWhen: (prev, curr) =>
              curr.actionMessage != null &&
              prev.actionMessage != curr.actionMessage,
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
            ctx.read<QrPaymentCubit>().clearActionMessage();
          },
        ),
        BlocListener<QrPaymentCubit, QrPaymentState>(
          listenWhen: (prev, curr) =>
              curr.pendingZeroAmountQr != null &&
              prev.pendingZeroAmountQr != curr.pendingZeroAmountQr,
          listener: (ctx, state) {
            final pending = state.pendingZeroAmountQr;
            if (pending == null) return;
            final qrCubit = ctx.read<QrPaymentCubit>();
            final payerUserId =
                ctx.read<AuthBloc>().state.user?.uid ?? 'user_deniz_aksoy';
            showDialog<void>(
              context: ctx,
              barrierDismissible: false,
              builder: (dialogCtx) => QrZeroAmountDialog(
                parsedPayload: pending,
                controller: qrCubit.zeroAmountController,
                onCancel: () {
                  Navigator.of(dialogCtx).pop();
                  qrCubit.dismissZeroAmountPrompt();
                },
                onConfirmAmount: (amount) {
                  Navigator.of(dialogCtx).pop();
                  qrCubit.confirmZeroAmountQr(
                    amount,
                    payerUserId: payerUserId,
                  );
                },
              ),
            );
          },
        ),
        BlocListener<QrPaymentCubit, QrPaymentState>(
          listenWhen: (prev, curr) =>
              curr.completedReceipt != null &&
              prev.completedReceipt != curr.completedReceipt,
          listener: (ctx, state) {
            final receipt = state.completedReceipt;
            if (receipt == null) return;
            final qrCubit = ctx.read<QrPaymentCubit>();
            showDialog<void>(
              context: ctx,
              builder: (dialogCtx) => QrPaymentSuccessDialog(
                receipt: receipt,
                onClose: () {
                  Navigator.of(dialogCtx).pop();
                  qrCubit.clearCompletedReceipt();
                },
              ),
            );
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const RoleSwitchAppBar(isBusinessMode: false),
        body: BlocBuilder<QrPaymentCubit, QrPaymentState>(
          builder: (context, state) {
            final user = context.watch<AuthBloc>().state.user;
            final userId = user?.uid ?? 'user_deniz_aksoy';
            final userName = user?.name ?? 'Deniz Aksoy';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  QrModeSwitcher(
                    isShowQrMode: state.isShowQrMode,
                    onModeSelected: (showMyQr) =>
                        cubit.setMode(showMyQr: showMyQr),
                  ),
                  const SizedBox(height: 20),
                  if (state.isShowQrMode)
                    ShowMyQrCard(
                      cubit: cubit,
                      state: state,
                      userId: userId,
                      userName: userName,
                    )
                  else
                    ScanQrCard(
                      cubit: cubit,
                      state: state,
                      payerUserId: userId,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
