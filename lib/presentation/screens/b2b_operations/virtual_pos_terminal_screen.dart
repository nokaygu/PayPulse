import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/config/app_mode.dart';
import '../../../core/constants/app_limits.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/formatters/currency_and_card_formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/financial_amount.dart';
import '../../../core/validators/financial_validators.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/repositories/i_transaction_repository.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import 'bloc/virtual_pos_cubit.dart';

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
            _showSlipDialog(ctx, tx);
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
                  // Başlık Kutusu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
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
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.darkNavy,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
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
                  ),
                  const SizedBox(height: 14),

                  // Sekmeler: Kredi / Banka Kartı | PayPulse QR Tahsilat
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _PosTabPill(
                          label: 'Kredi / Banka Kartı',
                          icon: Icons.credit_card_rounded,
                          selected: state.isCardTab,
                          onTap: () => cubit.setTab(isCard: true),
                        ),
                        _PosTabPill(
                          label: 'PayPulse QR Tahsilat',
                          icon: Icons.qr_code_rounded,
                          selected: !state.isCardTab,
                          onTap: () => cubit.setTab(isCard: false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 1. Tahsil Edilecek Tutar Kartı
                  _AmountEntryCard(cubit: cubit, state: state),
                  const SizedBox(height: 14),

                  if (state.isCardTab) ...[
                    // 2. Koyu Sanal POS Kart Önizlemesi
                    _PosCardPreview(state: state),
                    const SizedBox(height: 14),

                    // 3. Luhn Doğrulamalı Kart Bilgileri Formu & Taksit Seçimi
                    _CardPaymentFormCard(cubit: cubit, state: state),
                    const SizedBox(height: 14),

                    // 4. Komisyon & Net Hesaba Geçecek Tutar
                    _CommissionSummaryCard(state: state),
                    const SizedBox(height: 14),

                    // 5. Tahsilatı Tamamla Butonu
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
                        onPressed: state.isProcessing
                            ? null
                            : () => cubit.submitCardPayment(
                                actor: authState.user,
                                companyId: companyId,
                              ),
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
                        onPressed: () => cubit.setTab(isCard: false),
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
                  ] else ...[
                    // PayPulse QR Tahsilat Sekmesi
                    _QrPaymentCard(
                      companyId: companyId,
                      state: state,
                      onSimulateQrPay: AppMode.isDemoMode
                          ? () => cubit.submitQrPayment(
                              companyId: companyId,
                              payerUserId: AppStrings.demoB2CUid,
                            )
                          : null,
                      onBackToCard: () => cubit.setTab(isCard: true),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Bugünkü POS İşlemleri / Canlı Z Raporu
                  InkWell(
                    onTap: () => _showZReportBottomSheet(context, state),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.receipt_long_rounded,
                            color: AppColors.darkNavy,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bugünkü POS İşlemleri',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.darkNavy,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '${state.posTransactions.length} İşlem • ${FinancialAmount.format((state.zReportTotalTl * 100).round())}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: const Color(0xFF64748B),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Z Raporu >',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primaryTeal,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
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

  void _showSlipDialog(BuildContext context, TransactionEntity tx) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen),
            SizedBox(width: 8),
            Text('POS Tahsilatı Başarılı'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SlipRow(label: 'İşlem Referans:', value: tx.txId),
            _SlipRow(
              label: 'Tahsil Edilen Tutar:',
              value: FinancialAmount.format(tx.amount),
            ),
            _SlipRow(label: 'Kategori:', value: tx.category),
            _SlipRow(label: 'Durum:', value: tx.status),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showZReportBottomSheet(BuildContext context, VirtualPosState state) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'POS GÜN SONU Z RAPORU',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavy,
              ),
            ),
            Text(
              'Toplam ${state.posTransactions.length} POS İşlemi • Net Hesaba Geçen: ${FinancialAmount.format((state.zReportNetTl * 100).round())}',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),
            if (state.posTransactions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('Bugün henüz POS tahsilatı gerçekleşmedi.'),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: state.posTransactions.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final item = state.posTransactions[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        item.customerName,
                        style: AppTextStyles.labelLarge,
                      ),
                      subtitle: Text('${item.posTxId} • ${item.cardMasked}'),
                      trailing: Text(
                        FinancialAmount.format(
                          (item.grossAmount * 100).round(),
                        ),
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SlipRow extends StatelessWidget {
  final String label;
  final String value;

  const _SlipRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF64748B),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.darkNavy,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _PosTabPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PosTabPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? AppColors.darkNavy : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: selected
                        ? AppColors.darkNavy
                        : const Color(0xFF64748B),
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountEntryCard extends StatelessWidget {
  final VirtualPosCubit cubit;
  final VirtualPosState state;

  const _AmountEntryCard({required this.cubit, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TAHSİL EDİLECEK TUTAR (TL)',
                style: AppTextStyles.labelSmall.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
              InkWell(
                onTap: cubit.clearAmount,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '↺ Temizle',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: const Color(0xFFB91C1C),
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: cubit.amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [TurkishCurrencyInputFormatter()],
            onChanged: cubit.onAmountTextChanged,
            style: AppTextStyles.numericBalance.copyWith(
              fontSize: 28,
              color: AppColors.darkNavy,
            ),
            decoration: const InputDecoration(
              prefixText: '₺ ',
              hintText: '0,00',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _QuickAddButton(
                label: '+₺500',
                onTap: () => cubit.addQuickAmountKurus(50000),
              ),
              const SizedBox(width: 8),
              _QuickAddButton(
                label: '+₺1.000',
                onTap: () => cubit.addQuickAmountKurus(100000),
              ),
              const SizedBox(width: 8),
              _QuickAddButton(
                label: '+₺5.000',
                onTap: () => cubit.addQuickAmountKurus(500000),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: cubit.descriptionController,
            decoration: const InputDecoration(
              labelText: 'Sipariş / Fatura Açıklaması',
              prefixIcon: Icon(Icons.description_outlined, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.darkNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _PosCardPreview extends StatelessWidget {
  final VirtualPosState state;

  const _PosCardPreview({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroCardGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PAYPULSE SANAL POS',
                style: AppTextStyles.labelSmall.copyWith(
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 1.0,
                ),
              ),
              Icon(
                state.isCardLuhnValid
                    ? Icons.verified_rounded
                    : Icons.credit_card_rounded,
                color: state.isCardLuhnValid
                    ? AppColors.primaryGreen
                    : Colors.white54,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            state.cardNumberPreview,
            style: AppTextStyles.headlineSmall.copyWith(
              color: Colors.white,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KART SAHİBİ',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontSize: 9,
                      ),
                    ),
                    Text(
                      state.cardHolderPreview,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'SKT',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: const Color(0xFF94A3B8),
                      fontSize: 9,
                    ),
                  ),
                  Text(
                    state.expiryPreview,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardPaymentFormCard extends StatelessWidget {
  final VirtualPosCubit cubit;
  final VirtualPosState state;

  const _CardPaymentFormCard({required this.cubit, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Form(
        key: cubit.cardFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kart Bilgileri',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                  ),
                ),
                Text(
                  state.isCardLuhnValid
                      ? '✓ Luhn Doğrulandı'
                      : 'Luhn Korumalı',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: state.isCardLuhnValid
                        ? AppColors.primaryTeal
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: cubit.cardHolderController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Kart Sahibi Adı Soyadı',
                hintText: 'Örn: Mehmet Can Özkan',
              ),
              validator: FinancialValidators.cardHolder,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: cubit.cardNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CardNumberInputFormatter(),
              ],
              decoration: const InputDecoration(
                labelText: 'Kart Numarası (16 Hane)',
                hintText: '5400 8291 3847 8912',
              ),
              validator: FinancialValidators.cardNumber,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: cubit.expiryController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ExpiryDateInputFormatter()],
                    decoration: const InputDecoration(
                      labelText: 'Son Kullanma (AA/YY)',
                      hintText: '08/28',
                    ),
                    validator: FinancialValidators.expiry,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: cubit.cvvController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'CVV / CVC',
                      hintText: '•••',
                    ),
                    validator: FinancialValidators.cvv,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Taksit Seçimi',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  'Vade Farksız',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: AppLimits.posInstallmentOptions.map((count) {
                final selected = state.selectedInstallment == count;
                final perInstallment = FinancialAmount.format(
                  state.installmentAmountKurus(count),
                );
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: count == AppLimits.posInstallmentOptions.last
                          ? 0
                          : 8,
                    ),
                    child: InkWell(
                      onTap: () => cubit.selectInstallment(count),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 6,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.darkNavy
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.darkNavy
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              count == 1 ? 'Tek Çekim' : '$count Taksit',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: selected
                                    ? Colors.white
                                    : AppColors.darkNavy,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              count == 1
                                  ? state.formattedAmount
                                  : '${count}x $perInstallment',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: selected
                                    ? const Color(0xFF5EEAD4)
                                    : const Color(0xFF64748B),
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommissionSummaryCard extends StatelessWidget {
  final VirtualPosState state;

  const _CommissionSummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _SlipRow(
            label:
                'POS Hizmet Komisyonu (%${state.commissionRatePercent.toStringAsFixed(2)})',
            value: '-${state.formattedCommission}',
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Kasaya Geçecek Tutar',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.darkNavy,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                state.formattedNetAmount,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QrPaymentCard extends StatelessWidget {
  final String companyId;
  final VirtualPosState state;
  final VoidCallback? onSimulateQrPay;
  final VoidCallback onBackToCard;

  const _QrPaymentCard({
    required this.companyId,
    required this.state,
    required this.onSimulateQrPay,
    required this.onBackToCard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Karekod ile Tahsilat',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '● Tarama Bekleniyor',
                      style: TextStyle(
                        color: Color(0xFFB45309),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: QrImageView(
                  data: state.qrPayload(companyId),
                  version: QrVersions.auto,
                  size: 180,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Müşteri PayPulse QR okuyucu ile ${state.formattedAmount} tutarındaki ödemeyi onaylayabilir.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _CommissionSummaryCard(state: state),
        const SizedBox(height: 14),
        if (onSimulateQrPay != null) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: state.isProcessing ? null : onSimulateQrPay,
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: Text(
                state.isProcessing
                    ? 'QR Ödeme Doğrulanıyor...'
                    : 'Müşteri Ödemesini Tamamla (${state.formattedAmount})',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
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
            onPressed: onBackToCard,
            icon: const Icon(Icons.credit_card_rounded, size: 18),
            label: const Text(
              'Kart ile Çekim Ekranına Dön',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
