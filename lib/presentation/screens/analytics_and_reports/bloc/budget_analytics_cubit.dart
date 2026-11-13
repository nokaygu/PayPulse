import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../domain/entities/budget_entity.dart';
import '../../../../domain/repositories/i_budget_repository.dart';
import '../../../widgets/budget_donut_chart.dart';
import '../../../widgets/four_state_view.dart';

class BudgetAnalyticsState extends Equatable {
  static const List<String> periodLabels = ['Haftalık', 'Aylık', 'Yıllık'];
  static const int minPeriodOffset = -11;
  static const int maxPeriodOffset = 0;
  static const List<String> _monthNames = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  final ViewStatus status;
  final String activeUserId;
  final int selectedPeriodIndex;
  final int periodOffset;
  final bool onlyWarningsFilter;
  final bool sortDescendingBySpent;
  final List<BudgetCategoryEntity> categories;
  final SavingsGoalEntity? savingsGoal;
  final String? errorMessage;

  const BudgetAnalyticsState({
    this.status = ViewStatus.loading,
    this.activeUserId = '',
    this.selectedPeriodIndex = 1,
    this.periodOffset = 0,
    this.onlyWarningsFilter = false,
    this.sortDescendingBySpent = false,
    this.categories = const [],
    this.savingsGoal,
    this.errorMessage,
  });

  String get selectedPeriodLabel =>
      periodLabels[selectedPeriodIndex.clamp(0, periodLabels.length - 1)];

  bool get canGoPrevious => periodOffset > minPeriodOffset;

  bool get canGoNext => periodOffset < maxPeriodOffset;

  bool get isCurrentPeriod => periodOffset == 0;

  bool get hasActiveFilter => onlyWarningsFilter || sortDescendingBySpent;

  String get dynamicDateLabel {
    if (selectedPeriodIndex == 0) {
      final rawWeekIndex = 3 + periodOffset; // 0..3 -> 1..4. Hafta (Kasım 2026)
      final monthDelta = (rawWeekIndex / 4).floor();
      final weekInMonth = ((rawWeekIndex % 4) + 4) % 4 + 1;
      final date = DateTime(2026, 11 + monthDelta, 1);
      return '$weekInMonth. Hafta • ${_monthNames[date.month - 1]} ${date.year}';
    }
    if (selectedPeriodIndex == 2) {
      final year = 2026 + periodOffset;
      return '$year (Yıllık)';
    }
    final date = DateTime(2026, 11 + periodOffset, 1);
    return '${_monthNames[date.month - 1]} ${date.year} ($selectedPeriodLabel)';
  }

  List<BudgetCategoryEntity> get visibleCategories {
    var list = onlyWarningsFilter
        ? categories.where((c) => c.isLimitWarning).toList()
        : List<BudgetCategoryEntity>.from(categories);
    if (sortDescendingBySpent) {
      list.sort((a, b) => b.spentAmount.compareTo(a.spentAmount));
    }
    return list;
  }

  double get totalSpentTl =>
      categories.fold<double>(0.0, (sum, c) => sum + c.spentAmount);

  double get totalAllocatedTl =>
      categories.fold<double>(0.0, (sum, c) => sum + c.allocatedAmount);

  double get remainingTl =>
      (totalAllocatedTl - totalSpentTl).clamp(0.0, double.infinity);

  double get remainingRatio => totalAllocatedTl > 0
      ? (remainingTl / totalAllocatedTl).clamp(0.0, 1.0)
      : 0.0;

  double get spentRatio => totalAllocatedTl > 0
      ? (totalSpentTl / totalAllocatedTl).clamp(0.0, 1.0)
      : 0.0;

  int get remainingPercent => (remainingRatio * 100).round();

  String get formattedRemainingTl => formatTl(remainingTl);

  String get formattedTotalSpentTl => formatTl(totalSpentTl);

  String get formattedTotalAllocatedTl => formatTl(totalAllocatedTl);

  String get compactCenterSpent {
    if (totalSpentTl >= 1000) {
      return '₺${(totalSpentTl / 1000).toStringAsFixed(1)}k';
    }
    return '₺${totalSpentTl.round()}';
  }

  List<BudgetCategoryEntity> get warningCategories =>
      categories.where((c) => c.isLimitWarning).toList();

  List<DonutChartItem> get donutItems => categories.map((c) {
    final pct = c.percentage > 0 ? c.percentage.round() : 0;
    return DonutChartItem(
      label: '${c.title.split(' ').first} (%$pct)',
      percentage: c.percentage,
      color: parseHexColor(c.colorHex),
    );
  }).toList();

  static String formatTl(double tlAmount) {
    return FinancialAmount.format((tlAmount * 100).round());
  }

  static Color parseHexColor(String hex) {
    final clean = hex.replaceFirst('#', '').trim();
    if (clean.length == 6) {
      final parsed = int.tryParse('FF$clean', radix: 16);
      if (parsed != null) return Color(parsed);
    } else if (clean.length == 8) {
      final parsed = int.tryParse(clean, radix: 16);
      if (parsed != null) return Color(parsed);
    }
    return AppColors.darkNavy;
  }

  BudgetAnalyticsState copyWith({
    ViewStatus? status,
    String? activeUserId,
    int? selectedPeriodIndex,
    int? periodOffset,
    bool? onlyWarningsFilter,
    bool? sortDescendingBySpent,
    List<BudgetCategoryEntity>? categories,
    SavingsGoalEntity? savingsGoal,
    bool clearSavingsGoal = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BudgetAnalyticsState(
      status: status ?? this.status,
      activeUserId: activeUserId ?? this.activeUserId,
      selectedPeriodIndex: selectedPeriodIndex ?? this.selectedPeriodIndex,
      periodOffset: periodOffset ?? this.periodOffset,
      onlyWarningsFilter: onlyWarningsFilter ?? this.onlyWarningsFilter,
      sortDescendingBySpent:
          sortDescendingBySpent ?? this.sortDescendingBySpent,
      categories: categories ?? this.categories,
      savingsGoal: clearSavingsGoal ? null : (savingsGoal ?? this.savingsGoal),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    activeUserId,
    selectedPeriodIndex,
    periodOffset,
    onlyWarningsFilter,
    sortDescendingBySpent,
    categories,
    savingsGoal,
    errorMessage,
  ];
}

class BudgetAnalyticsCubit extends Cubit<BudgetAnalyticsState> {
  final IBudgetRepository _budgetRepo;

  BudgetAnalyticsCubit({required IBudgetRepository budgetRepository})
    : _budgetRepo = budgetRepository,
      super(const BudgetAnalyticsState());

  Future<void> load({
    required String userId,
    int? periodIndex,
    int? periodOffset,
  }) async {
    final targetPeriodIndex = periodIndex ?? state.selectedPeriodIndex;
    final targetOffset = (periodOffset ?? state.periodOffset).clamp(
      BudgetAnalyticsState.minPeriodOffset,
      BudgetAnalyticsState.maxPeriodOffset,
    );
    final periodLabel = BudgetAnalyticsState
        .periodLabels[targetPeriodIndex.clamp(0, 2)];

    emit(
      state.copyWith(
        status: ViewStatus.loading,
        activeUserId: userId,
        selectedPeriodIndex: targetPeriodIndex,
        periodOffset: targetOffset,
        clearError: true,
      ),
    );

    try {
      final results = await Future.wait<dynamic>([
        _budgetRepo.getBudgetCategories(
          userId: userId,
          period: periodLabel,
          periodOffset: targetOffset,
        ),
        _budgetRepo.getSavingsGoal(userId: userId),
      ]);

      final categories = results[0] as List<BudgetCategoryEntity>;
      final savingsGoal = results[1] as SavingsGoalEntity?;

      emit(
        state.copyWith(
          status: categories.isEmpty && savingsGoal == null
              ? ViewStatus.empty
              : ViewStatus.success,
          categories: categories,
          savingsGoal: savingsGoal,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ViewStatus.error,
          errorMessage: 'Bütçe analitik verileri yüklenemedi.',
        ),
      );
    }
  }

  Future<void> selectPeriod(int index) async {
    if (index == state.selectedPeriodIndex &&
        state.periodOffset == 0 &&
        state.status == ViewStatus.success) {
      return;
    }
    await load(
      userId: state.activeUserId,
      periodIndex: index,
      periodOffset: 0,
    );
  }

  Future<void> previousPeriod() async {
    if (!state.canGoPrevious) return;
    await load(
      userId: state.activeUserId,
      periodIndex: state.selectedPeriodIndex,
      periodOffset: state.periodOffset - 1,
    );
  }

  Future<void> nextPeriod() async {
    if (!state.canGoNext) return;
    await load(
      userId: state.activeUserId,
      periodIndex: state.selectedPeriodIndex,
      periodOffset: state.periodOffset + 1,
    );
  }

  void setOnlyWarningsFilter(bool value) {
    emit(state.copyWith(onlyWarningsFilter: value));
  }

  void setSortDescendingBySpent(bool value) {
    emit(state.copyWith(sortDescendingBySpent: value));
  }

  Future<void> resetFiltersAndPeriod() async {
    emit(
      state.copyWith(
        onlyWarningsFilter: false,
        sortDescendingBySpent: false,
      ),
    );
    await load(
      userId: state.activeUserId,
      periodIndex: state.selectedPeriodIndex,
      periodOffset: 0,
    );
  }

  Future<void> refresh() async {
    await load(
      userId: state.activeUserId,
      periodIndex: state.selectedPeriodIndex,
      periodOffset: state.periodOffset,
    );
  }
}

