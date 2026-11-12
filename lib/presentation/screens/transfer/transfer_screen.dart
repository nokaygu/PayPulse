import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatters/currency_and_card_formatters.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/financial_amount.dart';
import '../home_wallet_and_safe/bloc/wallet_bloc.dart';
import '../home_wallet_and_safe/bloc/wallet_event.dart';
import 'bloc/transfer_bloc.dart';
import 'bloc/transfer_event.dart';
import 'bloc/transfer_state.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransferBloc(),
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

    return Scaffold(
      appBar: AppBar(
        title: Text('FAST Para Transferi', style: AppTextStyles.headlineSmall),
        centerTitle: true,
      ),
      body: BlocConsumer<TransferBloc, TransferState>(
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
            // Cüzdan bakiyesini de BLoC üzerinden güncelle
            context.read<WalletBloc>().add(
                  WalletTransferRequested(
                    targetIban: state.receipt!.recipientIban,
                    amountInKurus: state.receipt!.amountKurus,
                    description: state.receipt!.description,
                  ),
                );

            // Dekont ekranına yönlendir
            context.go(
              '/home/transfer/receipt/${state.receipt!.transactionId}',
              extra: state.receipt,
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Gönderici Bakiye Kartı
                Container(
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
                ),
                const SizedBox(height: 20),

                // 2. Alıcı Adı Soyadı
                TextFormField(
                  controller: _recipientController,
                  decoration: InputDecoration(
                    labelText: 'Alıcı Adı Soyadı / Ünvanı',
                    hintText: 'Örn: Ahmet Yılmaz',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    errorText: state.recipientError,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    context.read<TransferBloc>().add(TransferRecipientChanged(val));
                  },
                ),
                const SizedBox(height: 16),

                // 3. IBAN Numarası
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
                  onChanged: (val) {
                    context.read<TransferBloc>().add(TransferIbanChanged(val));
                  },
                ),
                const SizedBox(height: 16),

                // 4. Gönderilecek Tutar
                TextFormField(
                  controller: _amountController,
                  inputFormatters: [CurrencyInputFormatter()],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Transfer Tutarı (TL)',
                    hintText: '0,00',
                    prefixText: '₺ ',
                    prefixIcon: const Icon(Icons.payments_outlined),
                    errorText: state.amountError,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    context.read<TransferBloc>().add(TransferAmountChanged(val));
                  },
                ),
                const SizedBox(height: 12),

                // Hızlı Tutar Çipleri
                Wrap(
                  spacing: 8,
                  children: [
                    _QuickChip(
                      label: '+₺250',
                      kurus: 25000,
                      onTap: () => _applyQuickAmount(25000),
                    ),
                    _QuickChip(
                      label: '+₺500',
                      kurus: 50000,
                      onTap: () => _applyQuickAmount(50000),
                    ),
                    _QuickChip(
                      label: '+₺1.000',
                      kurus: 100000,
                      onTap: () => _applyQuickAmount(100000),
                    ),
                    _QuickChip(
                      label: '+₺2.500',
                      kurus: 250000,
                      onTap: () => _applyQuickAmount(250000),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 5. Açıklama
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama (İsteğe bağlı)',
                    hintText: 'Örn: Kira ödemesi',
                    prefixIcon: Icon(Icons.notes_rounded),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    context.read<TransferBloc>().add(TransferDescriptionChanged(val));
                  },
                ),
                const SizedBox(height: 32),

                // Gönder Butonu
                FilledButton.icon(
                  onPressed: state.isSubmitting
                      ? null
                      : () {
                          context.read<TransferBloc>().add(
                                TransferSubmitted(
                                  currentBalanceKurus: currentBalanceKurus,
                                ),
                              );
                        },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: state.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    state.isSubmitting ? 'Transfer Ediliyor...' : 'FAST ile Gönder',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _applyQuickAmount(int kurus) {
    context.read<TransferBloc>().add(TransferQuickAmountSelected(kurus));
    _amountController.text = FinancialAmount.format(kurus);
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final int kurus;
  final VoidCallback onTap;

  const _QuickChip({
    required this.label,
    required this.kurus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppLightColors.surfaceContainerLowest,
      side: const BorderSide(color: AppLightColors.outlineVariant),
    );
  }
}

