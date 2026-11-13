import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../bloc/business_overview_cubit.dart';

Future<void> showBusinessTopUpBalanceSheet({
  required BuildContext context,
  required BusinessOverviewCubit cubit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => BusinessTopUpBalanceSheet(
      cubit: cubit,
      onClose: () => Navigator.pop(ctx),
    ),
  );
}

class BusinessTopUpBalanceSheet extends StatelessWidget {
  final BusinessOverviewCubit cubit;
  final VoidCallback onClose;

  const BusinessTopUpBalanceSheet({
    super.key,
    required this.cubit,
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
                    'Şirket Kasasına Bakiye Yükle',
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
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [1000000, 2500000, 5000000, 10000000].map((kurus) {
                  return ChoiceChip(
                    label: Text(FinancialAmount.format(kurus)),
                    selected: state.topUpAmountKurus == kurus,
                    selectedColor: const Color(0xFF5EEAD4),
                    onSelected: (_) => cubit.setTopUpAmountKurus(kurus),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              _TopUpMethodTile(
                icon: Icons.account_balance,
                title: 'Banka Havalesi / FAST',
                isSelected: state.selectedTopUpMethod.startsWith('Banka'),
                onTap: () => cubit.setTopUpMethod('Banka Havalesi / FAST'),
              ),
              const SizedBox(height: 8),
              _TopUpMethodTile(
                icon: Icons.credit_card,
                title: 'Kurumsal Şirket Kredi Kartı',
                isSelected: state.selectedTopUpMethod.startsWith('Kurumsal'),
                onTap: () =>
                    cubit.setTopUpMethod('Kurumsal Şirket Kredi Kartı'),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: state.isSubmitting
                      ? null
                      : () async {
                          final ok = await cubit.topUpBalance();
                          if (ok && context.mounted) onClose();
                        },
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: Text(
                    'Bakiye Yükle (${FinancialAmount.format(state.topUpAmountKurus)})',
                    style: const TextStyle(fontWeight: FontWeight.w800),
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

class _TopUpMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TopUpMethodTile({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primaryTeal : const Color(0xFFE2E8F0),
        ),
      ),
      leading: Icon(icon, color: AppColors.primaryTeal),
      title: Text(title),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primaryTeal)
          : null,
      onTap: onTap,
    );
  }
}

