import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_limits.dart';
import '../../../../core/formatters/currency_and_card_formatters.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../core/validators/financial_validators.dart';
import '../bloc/virtual_pos_cubit.dart';

/// Sanal POS Luhn doğrulamalı kart bilgileri formu ve taksit seçicisi.
class PosCardPaymentFormCard extends StatelessWidget {
  final VirtualPosCubit cubit;
  final VirtualPosState state;

  const PosCardPaymentFormCard({
    super.key,
    required this.cubit,
    required this.state,
  });

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
            _InstallmentOptionsRow(
              selectedInstallment: state.selectedInstallment,
              formattedAmount: state.formattedAmount,
              installmentAmountKurus: state.installmentAmountKurus,
              onSelect: cubit.selectInstallment,
            ),
          ],
        ),
      ),
    );
  }
}

class _InstallmentOptionsRow extends StatelessWidget {
  final int selectedInstallment;
  final String formattedAmount;
  final int Function(int) installmentAmountKurus;
  final ValueChanged<int> onSelect;

  const _InstallmentOptionsRow({
    required this.selectedInstallment,
    required this.formattedAmount,
    required this.installmentAmountKurus,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AppLimits.posInstallmentOptions.map((count) {
        final selected = selectedInstallment == count;
        final perInstallment = FinancialAmount.format(
          installmentAmountKurus(count),
        );
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: count == AppLimits.posInstallmentOptions.last ? 0 : 8,
            ),
            child: InkWell(
              onTap: () => onSelect(count),
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
                        color: selected ? Colors.white : AppColors.darkNavy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      count == 1 ? formattedAmount : '${count}x $perInstallment',
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
    );
  }
}

