import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_limits.dart';
import '../../../core/formatters/currency_and_card_formatters.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/financial_amount.dart';
import '../home_wallet_and_safe/bloc/wallet_bloc.dart';
import '../home_wallet_and_safe/bloc/wallet_event.dart';
import 'cubit/fast_transfer_cubit.dart';
import 'cubit/fast_transfer_state.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FastTransferCubit(),
      child: const _TransferView(),
    );
  }
}

class _TransferView extends StatefulWidget {
  const _TransferView();

  @override
  State<_TransferView> createState() => _TransferViewState();
}

class _TransferViewState extends State<_TransferView> {
  final _recipientController = TextEditingController();
  final _ibanController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _recipientController.dispose();
    _ibanController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletState = context.watch<WalletBloc>().state;
    final currentBalanceKurus = walletState.wallet?.balanceTl ?? 2450000;
    final balanceTl = (currentBalanceKurus / 100.0).toStringAsFixed(2);

    return BlocConsumer<FastTransferCubit, FastTransferState>(
      listener: (context, state) {
        if (state.generalError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.generalError!),
              backgroundColor: AppLightColors.error,
            ),
          );
        }

        if (state.isSuccess && state.receipt != null) {
          // Bakiye güncelle
          context.read<WalletBloc>().add(
                WalletTransferRequested(
                  targetIban: state.receipt!.recipientIban,
                  amountInKurus: state.receipt!.amountKurus,
                  description: state.receipt!.description,
                ),
              );

          // Dekont rotasına yönlendir
          context.go(
            '/home/transfer/receipt/${state.receipt!.transactionId}',
            extra: state.receipt,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _stepTitle(state.currentStep),
              style: AppTextStyles.headlineSmall,
            ),
            centerTitle: true,
            leading: state.currentStep != TransferStep.step1Recipient
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () =>
                        context.read<FastTransferCubit>().previousStep(),
                  )
                : null,
          ),
          body: Column(
            children: [
              // 4 Adımlı İlerleme Çubuğu
              _StepIndicator(currentStep: state.currentStep),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Üst Bakiye & FAST Rozeti
                      _BalanceHeaderCard(balanceTl: balanceTl),
                      const SizedBox(height: 20),

                      // Aktif Adımın İçeriği
                      if (state.currentStep == TransferStep.step1Recipient)
                        _buildStep1(context, state),
                      if (state.currentStep == TransferStep.step2Amount)
                        _buildStep2(context, state, currentBalanceKurus),
                      if (state.currentStep == TransferStep.step3Summary)
                        _buildStep3(context, state, currentBalanceKurus),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _stepTitle(TransferStep step) {
    switch (step) {
      case TransferStep.step1Recipient:
        return 'Alıcı Belirle (1/4)';
      case TransferStep.step2Amount:
        return 'FAST Tutar Belirle (2/4)';
      case TransferStep.step3Summary:
        return 'Transfer Özeti & Onay (3/4)';
      case TransferStep.step4Receipt:
        return 'Transfer Tamamlandı (4/4)';
    }
  }

  // 1. Adım: Alıcı & IBAN
  Widget _buildStep1(BuildContext context, FastTransferState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _recipientController,
          decoration: InputDecoration(
            labelText: 'Alıcı Adı Soyadı / Ünvanı',
            hintText: 'Örn: Ahmet Yılmaz',
            prefixIcon: const Icon(Icons.person_outline_rounded),
            errorText: state.recipientError,
            border: const OutlineInputBorder(),
          ),
          onChanged: (val) =>
              context.read<FastTransferCubit>().recipientChanged(val),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _ibanController,
          inputFormatters: [IbanInputFormatter()],
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: 'Alıcı IBAN Numarası',
            hintText: 'TR00 0000 0000 0000 0000 0000 00',
            prefixIcon: const Icon(Icons.credit_card_rounded),
            errorText: state.ibanError,
            border: const OutlineInputBorder(),
          ),
          onChanged: (val) =>
              context.read<FastTransferCubit>().ibanChanged(val),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: state.canProceedStep1
              ? () => context.read<FastTransferCubit>().nextStep()
              : null,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text('Tutar Belirlemeye Geç'),
        ),
      ],
    );
  }

  // 2. Adım: Tutar Belirleme (+100, +250, Tüm Bakiye)
  Widget _buildStep2(
    BuildContext context,
    FastTransferState state,
    int balanceKurus,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _amountController,
          inputFormatters: [CurrencyInputFormatter()],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Transfer Tutarı (TL)',
            hintText: '0,00',
            prefixText: '₺ ',
            prefixIcon: const Icon(Icons.payments_outlined),
            errorText: state.amountError ?? state.limitError,
            border: const OutlineInputBorder(),
          ),
          onChanged: (val) =>
              context.read<FastTransferCubit>().amountChanged(val, balanceKurus),
        ),
        const SizedBox(height: 12),

        // logic.md: Hızlı tutar ekleme +100, +250, Tüm Bakiye hesaplaması
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ActionChip(
              label: const Text('+₺100'),
              onPressed: () {
                context
                    .read<FastTransferCubit>()
                    .addQuickAmount(10000, balanceKurus);
                _amountController.text = FinancialAmount.format(
                  state.amountKurus + 10000,
                );
              },
            ),
            ActionChip(
              label: const Text('+₺250'),
              onPressed: () {
                context
                    .read<FastTransferCubit>()
                    .addQuickAmount(25000, balanceKurus);
                _amountController.text = FinancialAmount.format(
                  state.amountKurus + 25000,
                );
              },
            ),
            ActionChip(
              avatar: const Icon(Icons.all_inclusive_rounded, size: 16),
              label: const Text('Tüm Bakiye'),
              onPressed: () {
                context.read<FastTransferCubit>().setAllBalance(balanceKurus);
                _amountController.text = FinancialAmount.format(balanceKurus);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _descController,
          decoration: const InputDecoration(
            labelText: 'Açıklama (İsteğe bağlı)',
            hintText: 'Örn: Kira / Hizmet bedeli',
            prefixIcon: Icon(Icons.notes_rounded),
            border: OutlineInputBorder(),
          ),
          onChanged: (val) =>
              context.read<FastTransferCubit>().descriptionChanged(val),
        ),
        const SizedBox(height: 24),

        FilledButton.icon(
          onPressed: state.canProceedStep2
              ? () => context.read<FastTransferCubit>().nextStep()
              : null,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text('Özete İlerle'),
        ),
      ],
    );
  }

  // 3. Adım: Özet & Onay
  Widget _buildStep3(
    BuildContext context,
    FastTransferState state,
    int balanceKurus,
  ) {
    final amountTl = FinancialAmount.format(state.amountKurus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppLightColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppLightColors.outlineVariant),
          ),
          child: Column(
            children: [
              _SummaryRow(label: 'Alıcı', value: state.recipientName),
              const Divider(height: 20),
              _SummaryRow(label: 'Alıcı IBAN', value: state.recipientIban),
              const Divider(height: 20),
              _SummaryRow(label: 'Açıklama', value: state.description.isEmpty ? 'FAST Transferi' : state.description),
              const Divider(height: 20),
              _SummaryRow(label: 'İşlem Ücreti', value: '₺0,00 (Ücretsiz)'),
              const Divider(height: 20),
              _SummaryRow(
                label: 'Toplam Tutar',
                value: '₺$amountTl',
                isHighlight: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: state.isLoading
              ? null
              : () => context
                  .read<FastTransferCubit>()
                  .submitTransfer(balanceKurus),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          icon: state.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_circle_rounded),
          label: Text(
            state.isLoading ? 'Gönderiliyor...' : 'FAST ile Transferi Onayla',
          ),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final TransferStep currentStep;

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final stepIndex = currentStep.index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= stepIndex;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              decoration: BoxDecoration(
                color: isActive ? AppLightColors.primary : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BalanceHeaderCard extends StatelessWidget {
  final String balanceTl;

  const _BalanceHeaderCard({required this.balanceTl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppLightColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppLightColors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppLightColors.primaryFixed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppLightColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kullanılabilir TL Bakiye',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '₺$balanceTl',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppLightColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '7/24 FAST',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 16 : 13,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: isHighlight ? AppLightColors.primary : AppLightColors.onSurface,
          ),
        ),
      ],
    );
  }
}
