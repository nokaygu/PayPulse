import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import 'bloc/cards_management_cubit.dart';
import 'widgets/add_new_bank_sheet.dart';
import 'widgets/add_new_card_sheet.dart';
import 'widgets/bank_accounts_section.dart';
import 'widgets/cards_section_body.dart';

export 'bloc/cards_management_cubit.dart' show BankAccountItem, CardItem;

/// Kayıtlı Banka ve Sanal/Fiziksel Kartlar Yönetim Ekranı.
class CardsManagementScreen extends StatelessWidget {
  const CardsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final holderName = context.read<AuthBloc>().state.user?.name;

    return BlocProvider<CardsManagementCubit>(
      create: (_) => CardsManagementCubit(initialHolderName: holderName),
      child: const _CardsManagementView(),
    );
  }
}

class _CardsManagementView extends StatelessWidget {
  const _CardsManagementView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final primaryTextColor = isDark ? Colors.white : AppColors.darkNavy;
    final secondaryTextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) => prev.user?.name != curr.user?.name,
          listener: (ctx, authState) {
            ctx.read<CardsManagementCubit>().syncHolderName(
              authState.user?.name,
            );
          },
        ),
        BlocListener<CardsManagementCubit, CardsManagementState>(
          listenWhen: (prev, curr) =>
              prev.feedbackMessage != curr.feedbackMessage &&
              curr.feedbackMessage != null,
          listener: (ctx, state) {
            final msg = state.feedbackMessage!;
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(msg),
                duration: const Duration(seconds: 2),
                backgroundColor:
                    state.isSuccessFeedback ? AppColors.primaryTeal : null,
              ),
            );
            ctx.read<CardsManagementCubit>().clearFeedback();
          },
        ),
      ],
      child: BlocBuilder<CardsManagementCubit, CardsManagementState>(
        builder: (context, state) {
          final cubit = context.read<CardsManagementCubit>();

          return Scaffold(
            backgroundColor: scaffoldBg,
            appBar: const RoleSwitchAppBar(
              isBusinessMode: false,
              showBackButton: true,
              customTitle: 'Kayıtlı Banka ve Kartlarım',
              customSubtitle: 'Fiziksel & Sanal Kart Yönetimi',
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardsSectionBody(
                    cubit: cubit,
                    state: state,
                    isDark: isDark,
                    cardBg: cardBg,
                    cardBorder: cardBorder,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    onAddCardPressed: () {
                      cubit.prepareAddCardDraft();
                      showAddNewCardSheet(context, cubit);
                    },
                  ),
                  const SizedBox(height: 20),
                  BankAccountsSection(
                    cubit: cubit,
                    bankAccounts: state.bankAccounts,
                    isDark: isDark,
                    cardBg: cardBg,
                    cardBorder: cardBorder,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    onAddBankPressed: () {
                      cubit.prepareAddBankDraft();
                      showAddNewBankSheet(context, cubit);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
