import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/repositories/i_transaction_repository.dart';
import '../../widgets/role_switch_app_bar.dart';
import 'bloc/transfer_cubits.dart';
import 'widgets/saved_recipients_section.dart';
import 'widgets/transfer_iban_input_card.dart';

/// 7/24 FAST Alıcı Seçim Ekranı (Adım 1/4 - `StatelessWidget`).
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
                TransferIbanInputCard(
                  cubit: cubit,
                  state: state,
                  onContinue: (name, iban) =>
                      _proceedWithRecipient(context, name: name, iban: iban),
                ),
                const SizedBox(height: 20),
                SavedRecipientsSection(
                  cubit: cubit,
                  state: state,
                  onSelectRecipient: (name, iban) =>
                      _proceedWithRecipient(context, name: name, iban: iban),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
