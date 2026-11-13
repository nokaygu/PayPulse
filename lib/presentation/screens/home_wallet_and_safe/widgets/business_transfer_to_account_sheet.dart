import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/formatters/currency_and_card_formatters.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../bloc/business_overview_cubit.dart';

Future<void> showBusinessTransferToAccountSheet({
  required BuildContext context,
  required BusinessOverviewCubit cubit,
  required String corporateIban,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => BusinessTransferToAccountSheet(
      cubit: cubit,
      corporateIban: corporateIban,
      onClose: () => Navigator.pop(ctx),
    ),
  );
}

class BusinessTransferToAccountSheet extends StatelessWidget {
  final BusinessOverviewCubit cubit;
  final String corporateIban;
  final VoidCallback onClose;

  const BusinessTransferToAccountSheet({
    super.key,
    required this.cubit,
    required this.corporateIban,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusinessOverviewCubit, BusinessOverviewState>(
      bloc: cubit,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ticari Hesaba Aktar',
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Şirket kullanılabilir bakiyesinden ticari banka hesabınıza anında FAST/EFT yapın.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Aktarılacak Tutar (₺)',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: cubit.transferAmountController,
                keyboardType: TextInputType.number,
                inputFormatters: [TurkishCurrencyInputFormatter()],
                decoration: InputDecoration(
                  prefixText: '₺ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [500000, 1000000, 2500000, 5000000].map((kurus) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(FinancialAmount.format(kurus)),
                        onPressed: () => cubit.setTransferPresetKurus(kurus),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
              _CorporateTargetBankCard(corporateIban: corporateIban),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: state.isSubmitting
                      ? null
                      : () async {
                          final ok = await cubit.transferToBankAccount();
                          if (ok && context.mounted) onClose();
                        },
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text(
                    'Transferi Onayla',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CorporateTargetBankCard extends StatelessWidget {
  final String corporateIban;

  const _CorporateTargetBankCard({required this.corporateIban});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_rounded,
            color: AppColors.primaryTeal,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hedef Ticari Banka Hesabı',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: AppColors.darkNavy,
                  ),
                ),
                Text(
                  corporateIban,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Color(0xFF64748B),
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

