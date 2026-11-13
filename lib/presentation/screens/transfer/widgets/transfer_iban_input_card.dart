import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/validators/financial_validators.dart';
import '../bloc/transfer_cubits.dart';

/// Yeni TR IBAN doğrulama ve manuel alıcı giriş kartı (`StatelessWidget`).
class TransferIbanInputCard extends StatelessWidget {
  final TransferRecipientCubit cubit;
  final TransferRecipientState state;
  final void Function(String name, String iban) onContinue;

  const TransferIbanInputCard({
    super.key,
    required this.cubit,
    required this.state,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Form(
        key: cubit.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'IBAN ile Gönder',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: cubit.ibanController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Alıcı TR IBAN',
                hintText: 'TR00 0000 0000 0000 0000 0000 00',
                prefixIcon: const Icon(Icons.account_balance_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: cubit.lookupIban,
              validator: FinancialValidators.iban,
            ),
            const SizedBox(height: 10),
            if (state.lookedUpRecipient != null)
              _VerifiedRecipientBanner(
                maskedName: state.lookedUpRecipient!.maskedName,
              ),
            TextFormField(
              controller: cubit.nameController,
              decoration: InputDecoration(
                labelText: 'Alıcı Adı / Unvanı',
                hintText: 'Örn: Zeynep Kaya',
                prefixIcon: const Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) => (v == null || v.trim().length < 2)
                  ? 'Alıcı adı en az 2 karakter olmalıdır.'
                  : null,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (!(cubit.formKey.currentState?.validate() ?? false)) {
                    return;
                  }
                  onContinue(
                    cubit.nameController.text.trim(),
                    FinancialValidators.normalizeIban(
                      cubit.ibanController.text,
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text(
                  'Bu Alıcı ile Devam Et',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerifiedRecipientBanner extends StatelessWidget {
  final String maskedName;

  const _VerifiedRecipientBanner({required this.maskedName});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_rounded,
            size: 16,
            color: Color(0xFF065F46),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'PayPulse Rehber Doğrulaması: $maskedName',
              style: AppTextStyles.labelSmall.copyWith(
                color: const Color(0xFF065F46),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

