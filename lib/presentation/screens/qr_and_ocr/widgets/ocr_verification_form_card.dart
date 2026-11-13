import 'package:flutter/material.dart';

import '../../../../core/formatters/currency_and_card_formatters.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/validators/financial_validators.dart';
import '../../../widgets/status_badge_widget.dart';
import '../bloc/ocr_verification_cubit.dart';
import 'ocr_vat_and_category_selector.dart';

/// AI-OCR ayrıştırma güven skoru ve düzenlenebilir fiş form kartı.
class OcrVerificationFormCard extends StatelessWidget {
  final OcrVerificationCubit cubit;
  final OcrVerificationState state;

  const OcrVerificationFormCard({
    super.key,
    required this.cubit,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final confidencePct = (state.confidence * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('AI-OCR Ayrıştırma Sonucu'),
              StatusBadgeWidget(
                label: '%$confidencePct Güven Skoru',
                type: BadgeType.success,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _OcrPrimaryFields(cubit: cubit),
          const SizedBox(height: 12),
          OcrVatAndCategorySelector(cubit: cubit, state: state),
          const SizedBox(height: 12),
          _OcrMetaFields(cubit: cubit),
          if (state.receiptImagePath.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ReceiptPathBanner(receiptImagePath: state.receiptImagePath),
          ],
        ],
      ),
    );
  }
}

class _OcrPrimaryFields extends StatelessWidget {
  final OcrVerificationCubit cubit;

  const _OcrPrimaryFields({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: cubit.merchantController,
          decoration: const InputDecoration(
            labelText: 'Tedarikçi / İşyeri Ünvanı',
            hintText: 'Örn: Petrol Ofisi A.Ş.',
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'İşyeri ünvanı zorunludur.';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: cubit.amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [TurkishCurrencyInputFormatter()],
          onChanged: cubit.onAmountChanged,
          decoration: const InputDecoration(
            labelText: 'Toplam Tutar (KDV Dahil)',
            prefixText: '₺ ',
            hintText: '0,00',
          ),
          validator: FinancialValidators.amount,
        ),
      ],
    );
  }
}

class _OcrMetaFields extends StatelessWidget {
  final OcrVerificationCubit cubit;

  const _OcrMetaFields({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: cubit.accountingCodeController,
            decoration: const InputDecoration(
              labelText: 'Hesap Planı Kodu',
              hintText: '770.01',
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: cubit.noteController,
            decoration: const InputDecoration(labelText: 'Açıklama (Opsiyonel)'),
          ),
        ),
      ],
    );
  }
}

class _ReceiptPathBanner extends StatelessWidget {
  final String receiptImagePath;

  const _ReceiptPathBanner({required this.receiptImagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.image_outlined,
            color: AppColors.primaryTeal,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Fiş Belgesi: $receiptImagePath',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF475569),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

