import 'package:flutter/material.dart';

import '../../../../core/formatters/currency_and_card_formatters.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/validators/financial_validators.dart';
import '../../../widgets/custom_numpad_widget.dart';
import '../bloc/transfer_cubits.dart';

/// Transfer tutar giriş ekranı için alıcı özeti, tutar/açıklama ve numpad kartı.
class TransferAmountEntryCard extends StatelessWidget {
  final TransferAmountCubit cubit;
  final TransferAmountState state;
  final String recipientName;
  final String recipientIban;
  final String balanceLabel;
  final VoidCallback onProceed;

  const TransferAmountEntryCard({
    super.key,
    required this.cubit,
    required this.state,
    required this.recipientName,
    required this.recipientIban,
    required this.balanceLabel,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: cubit.formKey,
      child: Column(
        children: [
          _RecipientBanner(
            recipientName: recipientName,
            recipientIban: recipientIban,
          ),
          const SizedBox(height: 16),
          _AmountPreviewBadge(
            amountText: state.amountText,
            balanceLabel: balanceLabel,
          ),
          const SizedBox(height: 14),
          _AmountAndDescriptionFields(cubit: cubit, state: state),
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
              onPressed: onProceed,
              child: const Text(
                'Onay Adımına Geç (Adım 3/4) →',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipientBanner extends StatelessWidget {
  final String recipientName;
  final String recipientIban;

  const _RecipientBanner({
    required this.recipientName,
    required this.recipientIban,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
    );
  }
}

class _AmountPreviewBadge extends StatelessWidget {
  final String amountText;
  final String balanceLabel;

  const _AmountPreviewBadge({
    required this.amountText,
    required this.balanceLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Gönderilecek Tutar',
          style: AppTextStyles.bodyMedium.copyWith(
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '₺$amountText',
          style: AppTextStyles.numericBalance.copyWith(
            fontSize: 40,
            color: AppColors.darkNavy,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Kullanılabilir TRY Bakiye: $balanceLabel',
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

class _AmountAndDescriptionFields extends StatelessWidget {
  final TransferAmountCubit cubit;
  final TransferAmountState state;

  const _AmountAndDescriptionFields({
    required this.cubit,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: cubit.amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [TurkishCurrencyInputFormatter()],
          onChanged: cubit.syncFromTextField,
          decoration: InputDecoration(
            labelText: 'Tutar (TL)',
            prefixText: '₺ ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (val) => FinancialValidators.amount(
            val,
            balanceKurus: state.senderWallet != null ? state.balanceKurus : null,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: cubit.descriptionController,
          decoration: InputDecoration(
            labelText: 'Transfer Açıklaması',
            hintText: 'Örn: Kira ödemesi',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

