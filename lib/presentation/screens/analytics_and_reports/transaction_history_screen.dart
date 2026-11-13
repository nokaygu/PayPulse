import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/i_transaction_repository.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import 'bloc/transaction_history_cubit.dart';
import 'widgets/highlighted_fast_card.dart';
import 'widgets/transaction_grouped_list_section.dart';
import 'widgets/transaction_net_summary_hero_card.dart';
import 'widgets/transaction_search_and_filter_bar.dart';

/// İşlem Geçmişi ve Akıllı Ekstre Ekranı (`StatelessWidget` + `TransactionHistoryCubit`).
class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionHistoryCubit>(
      create: (ctx) {
        final uid = ctx.read<AuthBloc>().state.user?.uid ?? '';
        return TransactionHistoryCubit(
          transactionRepository: ctx.read<ITransactionRepository>(),
        )..watchUser(uid);
      },
      child: const _TransactionHistoryBody(),
    );
  }
}

class _TransactionHistoryBody extends StatelessWidget {
  const _TransactionHistoryBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TransactionHistoryCubit>();

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => prev.user?.uid != curr.user?.uid,
      listener: (ctx, authState) {
        ctx.read<TransactionHistoryCubit>().watchUser(
          authState.user?.uid ?? '',
        );
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const RoleSwitchAppBar(isBusinessMode: false),
        body: BlocBuilder<TransactionHistoryCubit, TransactionHistoryState>(
          builder: (context, state) {
            final latestFast = state.latestFastTransaction;

            return RefreshIndicator(
              onRefresh: cubit.refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TransactionNetSummaryHeroCard(state: state),
                    const SizedBox(height: 14),
                    TransactionSearchAndFilterBar(cubit: cubit, state: state),
                    const SizedBox(height: 14),
                    if (latestFast != null) ...[
                      HighlightedFastCard(
                        transaction: latestFast,
                        isIncoming: state.isIncomingTransaction(latestFast),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TransactionGroupedListSection(cubit: cubit, state: state),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
