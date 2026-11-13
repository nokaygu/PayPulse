import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../widgets/four_state_view.dart';
import '../bloc/transfer_cubits.dart';
import 'recipient_card.dart';

/// Kayıtlı hızlı alıcılar arama ve listeleme bölümü (`StatelessWidget`).
class SavedRecipientsSection extends StatelessWidget {
  final TransferRecipientCubit cubit;
  final TransferRecipientState state;
  final void Function(String name, String iban) onSelectRecipient;

  const SavedRecipientsSection({
    super.key,
    required this.cubit,
    required this.state,
    required this.onSelectRecipient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kayıtlı Hızlı Alıcılar',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavy,
              ),
            ),
            Text(
              '${state.filteredRecipients.length} Kişi',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            hintText: 'İsim veya IBAN ile ara...',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
          onChanged: cubit.updateSearch,
        ),
        const SizedBox(height: 12),
        FourStateView(
          status: state.status,
          errorMessage: state.errorMessage ?? 'Alıcılar yüklenemedi.',
          emptyMessage: 'Henüz kayıtlı güvenli alıcı bulunmuyor.',
          onRetry: cubit.loadRecipients,
          child: Column(
            children: state.filteredRecipients
                .map(
                  (recipient) => RecipientCard(
                    recipient: recipient,
                    onTap: () => onSelectRecipient(
                      recipient.maskedName,
                      recipient.iban,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

