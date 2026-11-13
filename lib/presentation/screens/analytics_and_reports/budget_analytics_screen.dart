import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/i_budget_repository.dart';
import '../../widgets/four_state_view.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import 'bloc/budget_analytics_cubit.dart';
import 'widgets/budget_advice_card.dart';
import 'widgets/budget_category_breakdown_card.dart';
import 'widgets/budget_filter_sheet.dart';
import 'widgets/budget_period_tab_bar.dart';
import 'widgets/budget_quota_hero_card.dart';
import 'widgets/budget_savings_goal_card.dart';
import 'widgets/budget_weekly_trend_card.dart';

/// Bütçe ve Analitik Ekranı (`StatelessWidget` + `BudgetAnalyticsCubit`).
class BudgetAnalyticsScreen extends StatelessWidget {
  const BudgetAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BudgetAnalyticsCubit>(
      create: (ctx) {
        final uid = ctx.read<AuthBloc>().state.user?.uid ?? '';
        return BudgetAnalyticsCubit(
          budgetRepository: ctx.read<IBudgetRepository>(),
        )..load(userId: uid);
      },
      child: const _BudgetAnalyticsBody(),
    );
  }
}

class _BudgetAnalyticsBody extends StatelessWidget {
  const _BudgetAnalyticsBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BudgetAnalyticsCubit>();

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => prev.user?.uid != curr.user?.uid,
      listener: (ctx, authState) {
        ctx.read<BudgetAnalyticsCubit>().load(
          userId: authState.user?.uid ?? '',
        );
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const RoleSwitchAppBar(isBusinessMode: false),
        body: BlocBuilder<BudgetAnalyticsCubit, BudgetAnalyticsState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: cubit.refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BudgetPeriodTabBar(
                      periodLabels: BudgetAnalyticsState.periodLabels,
                      selectedPeriodIndex: state.selectedPeriodIndex,
                      dynamicDateLabel: state.dynamicDateLabel,
                      isCurrentPeriod: state.isCurrentPeriod,
                      canGoPrevious: state.canGoPrevious,
                      canGoNext: state.canGoNext,
                      hasActiveFilter: state.hasActiveFilter,
                      onSelectPeriod: cubit.selectPeriod,
                      onPreviousPeriod: cubit.previousPeriod,
                      onNextPeriod: cubit.nextPeriod,
                      onOpenFilter: () =>
                          BudgetFilterSheet.show(context, cubit: cubit),
                    ),
                    const SizedBox(height: 14),
                    FourStateView(
                      status: state.status,
                      errorMessage:
                          state.errorMessage ?? 'Bütçe verileri yüklenemedi.',
                      emptyMessage: 'Henüz tanımlı bütçe kategorisi bulunmuyor.',
                      onRetry: cubit.refresh,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BudgetQuotaHeroCard(state: state),
                          const SizedBox(height: 16),
                          BudgetWeeklyTrendCard(state: state),
                          const SizedBox(height: 16),
                          BudgetCategoryBreakdownCard(state: state),
                          const SizedBox(height: 16),
                          if (state.savingsGoal != null) ...[
                            BudgetSavingsGoalCard(goal: state.savingsGoal!),
                            const SizedBox(height: 16),
                          ],
                          BudgetAdviceCard(state: state),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
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
