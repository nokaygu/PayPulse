import 'package:flutter/material.dart';

import '../../../../core/formatters/currency_and_card_formatters.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../bloc/ocr_verification_cubit.dart';

/// OCR doğrulama formu içindeki KDV oranı, KDV tutarı ve masraf kategorisi seçicisi.
class OcrVatAndCategorySelector extends StatelessWidget {
  final OcrVerificationCubit cubit;
  final OcrVerificationState state;

  const OcrVatAndCategorySelector({
    super.key,
    required this.cubit,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KDV Oranı',
          style: AppTextStyles.labelSmall.copyWith(
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: OcrVerificationState.vatRates.map((rate) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('%$rate'),
                selected: state.selectedVatRate == rate,
                onSelected: (_) => cubit.selectVatRate(rate),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: cubit.vatController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [TurkishCurrencyInputFormatter()],
          decoration: const InputDecoration(
            labelText: 'Ayrıştırılan KDV Tutarı',
            prefixText: '₺ ',
          ),
          validator: (v) {
            final vatKurus = FinancialAmount.parse(v) ?? 0;
            final totalKurus =
                FinancialAmount.parse(cubit.amountController.text) ?? 0;
            if (vatKurus < 0 || vatKurus > totalKurus) {
              return 'KDV toplam tutarı aşamaz.';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        Text(
          'Masraf Kategorisi',
          style: AppTextStyles.labelSmall.copyWith(
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: OcrVerificationState.categories.map((cat) {
            return ChoiceChip(
              label: Text(cat),
              selected: state.selectedCategory == cat,
              selectedColor: const Color(0xFFD1FAE5),
              onSelected: (_) => cubit.selectCategory(cat),
            );
          }).toList(),
        ),
      ],
    );
  }
}

