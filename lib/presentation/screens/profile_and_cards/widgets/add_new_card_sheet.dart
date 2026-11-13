import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/formatters/currency_and_card_formatters.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/validators/financial_validators.dart';
import '../bloc/cards_management_cubit.dart';
import 'card_choice_chip_item.dart';

Future<void> showAddNewCardSheet(
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
    builder: (bottomCtx) => AddNewCardSheet(
      cubit: cubit,
      isDark: isDark,
      onClose: () => Navigator.of(bottomCtx).pop(),
    ),
  );
}

class AddNewCardSheet extends StatelessWidget {
  final CardsManagementCubit cubit;
  final bool isDark;
  final VoidCallback onClose;

  const AddNewCardSheet({
    super.key,
    required this.cubit,
    required this.isDark,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CardsManagementCubit, CardsManagementState>(
      bloc: cubit,
      builder: (sheetCtx, state) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Form(
              key: cubit.addCardFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AddCardSheetHeader(isDark: isDark, onClose: onClose),
                  const SizedBox(height: 16),
                  _CardTypeAndColorSection(
                    cubit: cubit,
                    state: state,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _CardInputFieldsSection(
                    cubit: cubit,
                    state: state,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _CardThemeAndPermissionsSection(
                    cubit: cubit,
                    state: state,
                    isDark: isDark,
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
                        if (cubit.createCardFromDraft()) onClose();
                      },
                      child: Text(
                        '${state.draftCardType} Oluştur',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AddCardSheetHeader extends StatelessWidget {
  final bool isDark;
  final VoidCallback onClose;

  const _AddCardSheetHeader({required this.isDark, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Yeni PayPulse Kartı Oluştur',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.darkNavy,
                ),
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
        Text(
          'İhtiyacınıza uygun kart tipini seçin, limitinizi ve tercihlerinizi belirleyin.',
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _CardTypeAndColorSection extends StatelessWidget {
  final CardsManagementCubit cubit;
  final CardsManagementState state;
  final bool isDark;

  const _CardTypeAndColorSection({
    required this.cubit,
    required this.state,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KART TİPİ',
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CardChoiceChipItem(
                label: 'Sanal Kart',
                icon: Icons.credit_card_rounded,
                isSelected: state.draftCardType == 'Sanal Kart',
                isDark: isDark,
                onTap: () => cubit.setDraftCardType('Sanal Kart'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CardChoiceChipItem(
                label: 'Metal Kart',
                icon: Icons.shield_rounded,
                isSelected: state.draftCardType == 'Metal Kart',
                isDark: isDark,
                onTap: () => cubit.setDraftCardType('Metal Kart'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CardChoiceChipItem(
                label: 'Ticari Ek Kart',
                icon: Icons.business_center_rounded,
                isSelected: state.draftCardType == 'Ticari Ek Kart',
                isDark: isDark,
                onTap: () => cubit.setDraftCardType('Ticari Ek Kart'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CardInputFieldsSection extends StatelessWidget {
  final CardsManagementCubit cubit;
  final CardsManagementState state;
  final bool isDark;

  const _CardInputFieldsSection({
    required this.cubit,
    required this.state,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.darkNavy;
    final labelColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: cubit.cardTitleController,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            labelText: 'Kart Adı / Etiketi (Örn: Alışveriş Kartı)',
            labelStyle: TextStyle(color: labelColor),
            prefixIcon: const Icon(Icons.badge_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: cubit.cardHolderController,
          validator: FinancialValidators.cardHolder,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            labelText: 'Kart Üzerinde Yazacak İsim',
            labelStyle: TextStyle(color: labelColor),
            prefixIcon: const Icon(Icons.person_outline_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: cubit.cardNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [CardNumberInputFormatter()],
                validator: FinancialValidators.cardNumber,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Kart Numarası',
                  labelStyle: TextStyle(color: labelColor),
                  prefixIcon: const Icon(Icons.credit_card_rounded),
                  suffixIcon: IconButton(
                    tooltip: 'Yeni Numara Üret',
                    icon: const Icon(Icons.autorenew_rounded),
                    onPressed: cubit.regenerateDraftCardNumber,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: cubit.cardExpiryController,
                keyboardType: TextInputType.number,
                inputFormatters: [ExpiryDateInputFormatter()],
                validator: FinancialValidators.expiry,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'SKT (AA/YY)',
                  labelStyle: TextStyle(color: labelColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: cubit.cardLimitController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) {
            final amount = int.tryParse((v ?? '').trim());
            if (amount == null || amount <= 0) {
              return 'Geçerli bir aylık limit giriniz.';
            }
            return null;
          },
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            labelText: 'Aylık Harcama Limiti (₺)',
            labelStyle: TextStyle(color: labelColor),
            prefixIcon: const Icon(Icons.tune_rounded),
            suffixText: 'TL',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: const ['5000', '15000', '30000', '50000', '100000']
              .map(
                (limitStr) => ActionChip(
                  label: Text('₺$limitStr'),
                  labelStyle: TextStyle(fontSize: 11, color: textColor),
                  backgroundColor: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFF1F5F9),
                  onPressed: () => cubit.setDraftLimitPreset(limitStr),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _CardThemeAndPermissionsSection extends StatelessWidget {
  final CardsManagementCubit cubit;
  final CardsManagementState state;
  final bool isDark;

  const _CardThemeAndPermissionsSection({
    required this.cubit,
    required this.state,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.darkNavy;
    final labelColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KART TEMASI & RENGİ',
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(CardsManagementCubit.cardGradients.length, (
            idx,
          ) {
            final isSel = state.draftColorIndex == idx;
            return GestureDetector(
              onTap: () => cubit.setDraftColorIndex(idx),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: CardsManagementCubit.cardGradients[idx],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSel ? AppColors.primaryTeal : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: [
                    if (isSel)
                      BoxShadow(
                        color: AppColors.primaryTeal.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                  ],
                ),
                child: isSel
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Text(
          'BAĞLANACAK HESAP / BAKİYE KAYNAĞI',
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: state.draftLinkedAccount,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark
                ? const Color(0xFF0F172A)
                : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFCBD5E1),
              ),
            ),
          ),
          items: [
            'PayPulse TRY FAST Cüzdanı',
            ...state.bankAccounts.map((b) => b.bankName),
          ].map((name) {
            return DropdownMenuItem<String>(
              value: name,
              child: Text(
                name,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) cubit.setDraftLinkedAccount(val);
          },
        ),
        const SizedBox(height: 16),
        Text(
          'KART GÜVENLİK VE İŞLEM İZİNLERİ',
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 4),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'İnternet (E-Ticaret) Harcamaları',
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: const Text('Online alışveriş ve abonelik ödemeleri'),
          value: state.draftAllowOnline,
          activeThumbColor: AppColors.primaryTeal,
          onChanged: cubit.setDraftAllowOnline,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Yurt Dışı İşlemleri',
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: const Text('Uluslararası sitelerde ve seyahatlerde geçerlilik'),
          value: state.draftAllowInternational,
          activeThumbColor: AppColors.primaryTeal,
          onChanged: cubit.setDraftAllowInternational,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Temassız ve POS Ödemeleri',
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: const Text('Fiziksel POS cihazlarında temassız işlem'),
          value: state.draftAllowContactless,
          activeThumbColor: AppColors.primaryTeal,
          onChanged: cubit.setDraftAllowContactless,
        ),
      ],
    );
  }
}

