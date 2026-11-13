import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/validators/financial_validators.dart';
import '../bloc/cards_management_cubit.dart';

Future<void> showAddNewBankSheet(
  BuildContext context,
  CardsManagementCubit cubit,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomCtx) => AddNewBankSheet(
      cubit: cubit,
      isDark: isDark,
      onClose: () => Navigator.of(bottomCtx).pop(),
    ),
  );
}

class AddNewBankSheet extends StatelessWidget {
  final CardsManagementCubit cubit;
  final bool isDark;
  final VoidCallback onClose;

  const AddNewBankSheet({
    super.key,
    required this.cubit,
    required this.isDark,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.darkNavy;
    final labelColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return BlocBuilder<CardsManagementCubit, CardsManagementState>(
      bloc: cubit,
      builder: (sheetCtx, state) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: cubit.addBankFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Yeni Banka Hesabı (IBAN) Bağla',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark ? Colors.white : const Color(0xFF64748B),
                      ),
                      onPressed: onClose,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Adınıza kayıtlı vadesiz TL hesabınızı FAST transferleri için bağlayın.',
                  style: TextStyle(color: labelColor, fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: cubit.bankNameController,
                  validator: (v) {
                    if (v == null || v.trim().length < 2) {
                      return 'Banka adını giriniz.';
                    }
                    return null;
                  },
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Banka Adı (Örn: Akbank Vadesiz TRY)',
                    labelStyle: TextStyle(color: labelColor),
                    prefixIcon: const Icon(Icons.account_balance_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: cubit.ibanController,
                  validator: FinancialValidators.iban,
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'IBAN (TR...)',
                    labelStyle: TextStyle(color: labelColor),
                    prefixIcon: const Icon(Icons.credit_card_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: state.draftBankAccountType,
                  dropdownColor: isDark
                      ? const Color(0xFF1E293B)
                      : Colors.white,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Hesap Türü',
                    labelStyle: TextStyle(color: labelColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Bireysel FAST Hesabı',
                      child: Text('Bireysel FAST Hesabı'),
                    ),
                    DropdownMenuItem(
                      value: 'Maaş ve Birikim Hesabı',
                      child: Text('Maaş ve Birikim Hesabı'),
                    ),
                    DropdownMenuItem(
                      value: 'Ticari / Şirket Hesabı',
                      child: Text('Ticari / Şirket Hesabı'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) cubit.setDraftBankAccountType(val);
                  },
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (cubit.linkBankAccountFromDraft()) onClose();
                    },
                    child: const Text(
                      'Hesabı Bağla',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

