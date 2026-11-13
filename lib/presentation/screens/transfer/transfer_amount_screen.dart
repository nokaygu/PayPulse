import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/financial_amount.dart';
import '../../../domain/repositories/i_wallet_repository.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../auth/bloc/auth_bloc.dart';
import 'bloc/transfer_cubits.dart';
import 'widgets/transfer_amount_entry_card.dart';

/// FAST Transfer Tutar Girişi Ekranı (Adım 2/4 - `StatelessWidget`).
class TransferAmountScreen extends StatelessWidget {
  final String recipientIban;
  final String recipientName;

  const TransferAmountScreen({
    super.key,
    this.recipientIban = 'TR34 0006 2000 0001 2345 6789 01',
    this.recipientName = 'Zeynep Kaya',
  });

  @override
  Widget build(BuildContext context) {
    final senderUserId =
        context.watch<AuthBloc>().state.user?.uid ?? AppStrings.demoB2CUid;

    return BlocProvider<TransferAmountCubit>(
      create: (ctx) =>
          TransferAmountCubit(walletRepository: ctx.read<IWalletRepository>())
            ..watchSenderWallet(senderUserId),
      child: _TransferAmountView(
        recipientIban: recipientIban,
        recipientName: recipientName,
      ),
    );
  }
}

class _TransferAmountView extends StatelessWidget {
  final String recipientIban;
  final String recipientName;

  const _TransferAmountView({
    required this.recipientIban,
    required this.recipientName,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TransferAmountCubit>();

    return Scaffold(
      appBar: const RoleSwitchAppBar(
        customTitle: 'Tutar Girişi (2/4)',
        showBackButton: true,
      ),
      body: BlocBuilder<TransferAmountCubit, TransferAmountState>(
        builder: (context, state) {
          final balanceStr = state.isWalletLoading && state.senderWallet == null
              ? 'Yükleniyor...'
              : FinancialAmount.format(state.balanceKurus);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: TransferAmountEntryCard(
              cubit: cubit,
              state: state,
              recipientName: recipientName,
              recipientIban: recipientIban,
              balanceLabel: balanceStr,
              onProceed: () {
                if (!(cubit.formKey.currentState?.validate() ?? false)) return;
                final kurus = cubit.validateAndExtractKurus();
                if (kurus == null) return;
                final rawDesc = cubit.descriptionController.text.trim();
                context.push(
                  AppRoutes.fastTransfer,
                  extra: <String, dynamic>{
                    'recipientIban': recipientIban,
                    'recipientName': recipientName,
                    'amountInKurus': kurus,
                    'description': rawDesc.isEmpty ? 'FAST Transfer' : rawDesc,
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
