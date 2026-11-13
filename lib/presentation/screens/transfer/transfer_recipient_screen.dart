import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/validators/financial_validators.dart';
import '../../../domain/entities/safe_recipient_entity.dart';
import '../../../domain/repositories/i_transaction_repository.dart';
import '../../widgets/four_state_view.dart';
import '../../widgets/role_switch_app_bar.dart';
import 'bloc/transfer_cubits.dart';

class TransferRecipientScreen extends StatelessWidget {
  const TransferRecipientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransferRecipientCubit>(
      create: (ctx) => TransferRecipientCubit(
        transactionRepository: ctx.read<ITransactionRepository>(),
      )..loadRecipients(),
      child: const _TransferRecipientView(),
    );
  }
}

class _TransferRecipientView extends StatelessWidget {
  const _TransferRecipientView();

  void _proceedWithRecipient(
    BuildContext context, {
    required String name,
    required String iban,
  }) {
    context.push(
      AppRoutes.transferAmount,
      extra: <String, dynamic>{
        'recipientName': name,
        'recipientIban': iban,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TransferRecipientCubit>();

    return Scaffold(
      appBar: const RoleSwitchAppBar(
        customTitle: 'Alıcı Seçimi (1/4)',
        showBackButton: true,
      ),
      body: BlocBuilder<TransferRecipientCubit, TransferRecipientState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '7/24 FAST Para Gönder',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kayıtlı alıcı seçin veya TR IBAN doğrulamasıyla yeni alıcı girin.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),

                // Yeni IBAN ile Gönder Formu
                Container(
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
                            prefixIcon: const Icon(
                              Icons.account_balance_outlined,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: cubit.lookupIban,
                          validator: FinancialValidators.iban,
                        ),
                        const SizedBox(height: 10),
                        if (state.lookedUpRecipient != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
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
                                    'PayPulse Rehber Doğrulaması: ${state.lookedUpRecipient!.maskedName}',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: const Color(0xFF065F46),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                              if (!(cubit.formKey.currentState?.validate() ??
                                  false)) {
                                return;
                              }
                              _proceedWithRecipient(
                                context,
                                name: cubit.nameController.text.trim(),
                                iban: FinancialValidators.normalizeIban(
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
                ),
                const SizedBox(height: 20),

                // Kayıtlı Alıcılar Bölümü
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
                          (recipient) => _RecipientCard(
                            recipient: recipient,
                            onTap: () => _proceedWithRecipient(
                              context,
                              name: recipient.maskedName,
                              iban: recipient.iban,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RecipientCard extends StatelessWidget {
  final SafeRecipientEntity recipient;
  final VoidCallback onTap;

  const _RecipientCard({required this.recipient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final initials = recipient.maskedName.isNotEmpty
        ? recipient.maskedName
            .split(' ')
            .where((p) => p.isNotEmpty)
            .take(2)
            .map((p) => p[0].toUpperCase())
            .join()
        : 'PP';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFD1FAE5),
          child: Text(
            initials,
            style: const TextStyle(
              color: Color(0xFF065F46),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        title: Text(
          recipient.maskedName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          recipient.iban,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
