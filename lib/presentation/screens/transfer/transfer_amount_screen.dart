import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/formatters/currency_and_card_formatters.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/financial_amount.dart';
import '../../../core/validators/financial_validators.dart';
import '../../../domain/repositories/i_wallet_repository.dart';
import '../auth/bloc/auth_bloc.dart';
import '../../widgets/custom_numpad_widget.dart';
import '../../widgets/role_switch_app_bar.dart';
import 'bloc/transfer_cubits.dart';

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
            child: Form(
              key: cubit.formKey,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.primaryTeal,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Alıcı: $recipientName',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.darkNavy,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                recipientIban,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: const Color(0xFF64748B),
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gönderilecek Tutar',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₺${state.amountText}',
                    style: AppTextStyles.numericBalance.copyWith(
                      fontSize: 40,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Kullanılabilir TRY Bakiye: $balanceStr',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: const Color(0xFF065F46),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: cubit.amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [TurkishCurrencyInputFormatter()],
                    onChanged: cubit.syncFromTextField,
                    decoration: InputDecoration(
                      labelText: 'Tutar (TL)',
                      prefixText: '₺ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (val) => FinancialValidators.amount(
                      val,
                      balanceKurus: state.senderWallet != null
                          ? state.balanceKurus
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: cubit.descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Transfer Açıklaması',
                      hintText: 'Örn: Kira ödemesi',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (state.validationError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      state.validationError!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.expenseRed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  CustomNumpadWidget(
                    onDigitPressed: cubit.appendDigit,
                    onBackspacePressed: cubit.backspace,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        if (!(cubit.formKey.currentState?.validate() ??
                            false)) {
                          return;
                        }
                        final kurus = cubit.validateAndExtractKurus();
                        if (kurus == null) return;
                        context.push(
                          AppRoutes.fastTransfer,
                          extra: <String, dynamic>{
                            'recipientIban': recipientIban,
                            'recipientName': recipientName,
                            'amountInKurus': kurus,
                            'description':
                                cubit.descriptionController.text.trim().isEmpty
                                ? 'FAST Transfer'
                                : cubit.descriptionController.text.trim(),
                          },
                        );
                      },
                      child: const Text(
                        'Onay Adımına Geç (Adım 3/4) →',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
