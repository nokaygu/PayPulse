import 'package:flutter/material.dart';

import '../../../../core/formatters/currency_and_card_formatters.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/virtual_pos_cubit.dart';

/// Sanal POS tahsilat tutarı ve sipariş açıklaması giriş kartı.
class PosAmountEntryCard extends StatelessWidget {
  final VirtualPosCubit cubit;

  const PosAmountEntryCard({super.key, required this.cubit});

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
              Expanded(
                child: Text(
                  'TAHSİL EDİLECEK TUTAR (TL)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
              Expanded(
                child: _QuickAddButton(
                  label: '+₺500',
                  onTap: () => cubit.addQuickAmountKurus(50000),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickAddButton(
                  label: '+₺1.000',
                  onTap: () => cubit.addQuickAmountKurus(100000),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickAddButton(
                  label: '+₺5.000',
                  onTap: () => cubit.addQuickAmountKurus(500000),
                ),
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
    return InkWell(
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
    );
  }
}
