import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/formatters/currency_and_card_formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'cubit/virtual_pos_cubit.dart';
import 'cubit/virtual_pos_state.dart';

class VirtualPosScreen extends StatelessWidget {
  const VirtualPosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VirtualPosCubit(),
      child: const _VirtualPosView(),
    );
  }
}

class _VirtualPosView extends StatefulWidget {
  const _VirtualPosView();

  @override
  State<_VirtualPosView> createState() => _VirtualPosViewState();
}

class _VirtualPosViewState extends State<_VirtualPosView> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '3.750,00');
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sanal POS Terminali', style: AppTextStyles.headlineSmall),
        centerTitle: true,
      ),
      body: BlocConsumer<VirtualPosCubit, VirtualPosState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppLightColors.error,
              ),
            );
          }
          if (state.status == VirtualPosStatus.success) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Tahsilat Başarılı!'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Referans No: ${state.transactionRef}'),
                    const SizedBox(height: 8),
                    Text(
                      'Net Hesaba Aktarılan: ₺${state.netInLira.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                actions: [
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.read<VirtualPosCubit>().reset();
                      _amountController.text = '3.750,00';
                    },
                    child: const Text('Yeni Tahsilat'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Terminal Başlık Rozeti
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
                          Icons.point_of_sale_rounded,
                          color: AppLightColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nova Tasarım Ltd. Sanal POS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'Sabit Komisyon Oranı: %1,39',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 1. Tutar Girişi
                Text(
                  'Tahsilat Tutarı',
                  style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  inputFormatters: [CurrencyInputFormatter()],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    prefixText: '₺ ',
                    border: OutlineInputBorder(),
                    hintText: '0,00',
                  ),
                  onChanged: (val) {
                    context.read<VirtualPosCubit>().amountChanged(val);
                  },
                ),
                const SizedBox(height: 24),

                // 2. Taksit Seçenekleri
                Text(
                  'Ödeme / Taksit Seçeneği',
                  style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SegmentedButton<InstallmentOption>(
                  segments: InstallmentOption.values.map((opt) {
                    return ButtonSegment<InstallmentOption>(
                      value: opt,
                      label: Text(opt.label),
                    );
                  }).toList(),
                  selected: {state.selectedInstallment},
                  onSelectionChanged: (selected) {
                    context
                        .read<VirtualPosCubit>()
                        .installmentChanged(selected.first);
                  },
                ),
                const SizedBox(height: 24),

                // 3. Finansal Hesaplama Özeti (logic.md: %1,39 komisyon ve Net Hesaba Geçecek: ₺3.697,88)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _CalcRow(
                        label: 'Çekim Tutarı (Brüt)',
                        value: '₺${state.grossInLira.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 12),
                      _CalcRow(
                        label: 'İşlem Komisyonu (%1,39)',
                        value: '-₺${state.commissionInLira.toStringAsFixed(2)}',
                        isNegative: true,
                      ),
                      if (state.selectedInstallment.count > 1) ...[
                        const SizedBox(height: 12),
                        _CalcRow(
                          label: 'Aylık Taksit Tutarı (${state.selectedInstallment.count} Ay)',
                          value: '₺${state.installmentMonthlyInLira.toStringAsFixed(2)}',
                        ),
                      ],
                      const Divider(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Net Hesaba Geçecek',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'Valör: Ertesi Gün (T+1)',
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                          Text(
                            '₺${state.netInLira.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 4. Tahsil Et Butonu
                FilledButton.icon(
                  onPressed: state.isProcessing
                      ? null
                      : () => context.read<VirtualPosCubit>().submitPayment(),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: state.isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.qr_code_scanner_rounded),
                  label: Text(
                    state.isProcessing
                        ? 'İşlem Yapılıyor...'
                        : 'Kart ile Çek / QR Tahsilat Başlat',
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
}

class _CalcRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isNegative;

  const _CalcRow({
    required this.label,
    required this.value,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isNegative ? Colors.redAccent : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

