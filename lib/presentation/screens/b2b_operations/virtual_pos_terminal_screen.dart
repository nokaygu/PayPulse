import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/app_mode.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/repositories/i_transaction_repository.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import 'bloc/virtual_pos_cubit.dart';
import 'widgets/pos_amount_entry_card.dart';
import 'widgets/pos_card_payment_form_card.dart';
import 'widgets/pos_card_preview.dart';
import 'widgets/pos_commission_summary_card.dart';
import 'widgets/pos_customer_qr_scanner_dialog.dart';
import 'widgets/pos_payment_slip_dialog.dart';
import 'widgets/pos_qr_payment_card.dart';
import 'widgets/pos_tab_switcher.dart';
import 'widgets/pos_z_report_sheet.dart';

/// Sanal POS Terminali Ekranı (Stateless + VirtualPosCubit + ExecutePosPaymentUseCase)
class VirtualPosTerminalScreen extends StatelessWidget {
  const VirtualPosTerminalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VirtualPosCubit>(
      create: (ctx) {
        final companyId =
            ctx.read<AuthBloc>().state.user?.companyId ??
            AppStrings.defaultCompanyId;
        return VirtualPosCubit(
          transactionRepository: ctx.read<ITransactionRepository>(),
        )..loadPosHistory(companyId);
      },
      child: const _VirtualPosTerminalBody(),
    );
  }
}

class _VirtualPosTerminalBody extends StatelessWidget {
  const _VirtualPosTerminalBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VirtualPosCubit>();

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) =>
              prev.user?.companyId != curr.user?.companyId,
          listener: (ctx, authState) {
            ctx.read<VirtualPosCubit>().loadPosHistory(
              authState.user?.companyId ?? AppStrings.defaultCompanyId,
            );
          },
        ),
        BlocListener<VirtualPosCubit, VirtualPosState>(
          listenWhen: (prev, curr) =>
              curr.completedTransaction != null &&
              prev.completedTransaction != curr.completedTransaction,
          listener: (ctx, state) {
            final tx = state.completedTransaction;
            if (tx == null) return;
            final qrShortToken = state.completedQrShortToken;
            showDialog<void>(
              context: ctx,
              builder: (_) => PosPaymentSlipDialog(
                tx: tx,
                qrShortToken: qrShortToken,
              ),
            );
            ctx.read<VirtualPosCubit>().clearCompletedTransaction();
          },
        ),
        BlocListener<VirtualPosCubit, VirtualPosState>(
          listenWhen: (prev, curr) =>
              curr.errorMessage != null &&
              prev.errorMessage != curr.errorMessage,
          listener: (ctx, state) {
            final msg = state.errorMessage;
            if (msg == null) return;
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: AppColors.expenseRed,
              ),
            );
            ctx.read<VirtualPosCubit>().clearError();
          },
        ),
        BlocListener<VirtualPosCubit, VirtualPosState>(
          listenWhen: (prev, curr) =>
              curr.infoMessage != null && prev.infoMessage != curr.infoMessage,
          listener: (ctx, state) {
            final msg = state.infoMessage;
            if (msg == null) return;
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
            ctx.read<VirtualPosCubit>().clearInfo();
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const RoleSwitchAppBar(isBusinessMode: true),
        body: BlocBuilder<VirtualPosCubit, VirtualPosState>(
          builder: (context, state) {
            final authState = context.watch<AuthBloc>().state;
            final companyId =
                authState.user?.companyId ?? AppStrings.defaultCompanyId;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _PosScreenHeader(),
                  const SizedBox(height: 14),
                  PosTabSwitcher(
                    isCardTab: state.isCardTab,
                    onTabSelected: (isCard) => cubit.setTab(isCard: isCard),
                  ),
                  const SizedBox(height: 14),
                  PosAmountEntryCard(cubit: cubit),
                  const SizedBox(height: 14),
                  if (state.isCardTab) ...[
                    PosCardPreview(state: state),
                    const SizedBox(height: 14),
                    PosCardPaymentFormCard(cubit: cubit, state: state),
                    const SizedBox(height: 14),
                    PosCommissionSummaryCard(state: state),
                    const SizedBox(height: 14),
                    _CardSubmitActionButtons(
                      state: state,
                      onSubmitCard: () => cubit.submitCardPayment(
                        actor: authState.user,
                        companyId: companyId,
                      ),
                      onSwitchToQr: () => cubit.setTab(isCard: false),
                    ),
                  ] else
                    PosQrPaymentCard(
                      companyId: companyId,
                      cubit: cubit,
                      state: state,
                      onSimulateQrPay: AppMode.isDemoMode
                          ? () => cubit.submitQrPayment(
                              companyId: companyId,
                              payerUserId: AppStrings.demoB2CUid,
                            )
                          : null,
                      onOpenCustomerScanner: () => _openCustomerQrModal(
                        context,
                        cubit: cubit,
                        companyId: companyId,
                      ),
                      onBackToCard: () => cubit.setTab(isCard: true),
                    ),
                  const SizedBox(height: 14),
                  PosZReportSummaryTile(
                    state: state,
                    onOpenSheet: () => _openZReportSheet(context, state),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openCustomerQrModal(
    BuildContext context, {
    required VirtualPosCubit cubit,
    required String companyId,
  }) {
    cubit.customerQrPasteController.clear();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PosCustomerQrScannerSheet(
        pasteController: cubit.customerQrPasteController,
        onQrCaptured: (rawQr) => cubit.processScannedCustomerQr(
          rawQr: rawQr,
          companyId: companyId,
        ),
      ),
    );
  }

  void _openZReportSheet(BuildContext context, VirtualPosState state) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PosZReportBottomSheet(state: state),
    );
  }
}

class _PosScreenHeader extends StatelessWidget {
  const _PosScreenHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KURUMSAL TAHSİLAT',
                style: AppTextStyles.labelSmall.copyWith(
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Sanal POS Terminali',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.darkNavy,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '3D Secure Aktif',
            style: AppTextStyles.labelSmall.copyWith(
              color: const Color(0xFF065F46),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CardSubmitActionButtons extends StatelessWidget {
  final VirtualPosState state;
  final VoidCallback onSubmitCard;
  final VoidCallback onSwitchToQr;

  const _CardSubmitActionButtons({
    required this.state,
    required this.onSubmitCard,
    required this.onSwitchToQr,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkNavy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: state.isProcessing ? null : onSubmitCard,
            icon: state.isProcessing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.lock_outline_rounded, size: 18),
            label: Text(
              state.isProcessing
                  ? 'POS Tahsilatı Yapılıyor...'
                  : 'Tahsilatı Tamamla (${state.formattedAmount}) →',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 10),
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
            onPressed: onSwitchToQr,
            icon: const Icon(
              Icons.qr_code_scanner_rounded,
              size: 18,
              color: AppColors.primaryTeal,
            ),
            label: const Text(
              'QR ile Müşteriye Ödet',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
