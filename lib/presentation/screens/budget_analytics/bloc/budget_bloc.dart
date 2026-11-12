import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/budget_entity.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  String? _currentUserId;

  BudgetBloc() : super(const BudgetState()) {
    on<BudgetLoadRequested>(_onLoadRequested);
    on<BudgetMonthlyQuotaUpdated>(_onQuotaUpdated);
    on<SavingsDepositRequested>(_onSavingsDepositRequested);
    on<BudgetRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    BudgetLoadRequested event,
    Emitter<BudgetState> emit,
  ) async {
    _currentUserId = event.userId;
    emit(state.copyWith(status: BudgetStatus.loading, clearError: true));

    try {
      // Simülasyon / Repository verisi: 25.000 TL bütçe, 18.420 TL harcanan
      const initialBudget = BudgetEntity(
        monthlyQuotaInKurus: 2500000, // 25.000,00 TL
        spentInKurus: 1842000,        // 18.420,00 TL
        categories: [
          BudgetCategoryItem(
            categoryId: 'cat_market',
            title: 'Market & Gıda',
            quotaInKurus: 800000,
            spentInKurus: 773640, // %96.7 limit uyarısı
          ),
          BudgetCategoryItem(
            categoryId: 'cat_transport',
            title: 'Ulaşım',
            quotaInKurus: 500000,
            spentInKurus: 442080,
          ),
          BudgetCategoryItem(
            categoryId: 'cat_bills',
            title: 'Faturalar',
            quotaInKurus: 400000,
            spentInKurus: 331560,
          ),
          BudgetCategoryItem(
            categoryId: 'cat_food',
            title: 'Yeme & İçme',
            quotaInKurus: 300000,
            spentInKurus: 184200,
          ),
          BudgetCategoryItem(
            categoryId: 'cat_other',
            title: 'Diğer',
            quotaInKurus: 500000,
            spentInKurus: 110520,
          ),
        ],
        savingsGoalTitle: 'Yeni Laptop (M4 Pro)',
        savingsTargetInKurus: 8000000, // 80.000 TL
        savingsCurrentInKurus: 6400000, // 64.000 TL (%80)
      );

      emit(state.copyWith(
        status: BudgetStatus.success,
        budget: initialBudget,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BudgetStatus.failure,
        errorMessage: 'Bütçe verileri yüklenirken hata oluştu: $e',
      ));
    }
  }

  void _onQuotaUpdated(
    BudgetMonthlyQuotaUpdated event,
    Emitter<BudgetState> emit,
  ) {
    final current = state.budget;
    if (current == null) return;

    final updated = current.copyWith(
      monthlyQuotaInKurus: event.newQuotaInKurus,
    );

    emit(state.copyWith(
      budget: updated,
      successMessage: 'Bütçe kotası güncellendi.',
    ));
  }

  void _onSavingsDepositRequested(
    SavingsDepositRequested event,
    Emitter<BudgetState> emit,
  ) {
    final current = state.budget;
    if (current == null) return;

    final newSavings = current.savingsCurrentInKurus + event.amountInKurus;
    final updated = current.copyWith(
      savingsCurrentInKurus: newSavings,
    );

    emit(state.copyWith(
      budget: updated,
      successMessage: 'Tasarruf hedefinize katkı sağlandı!',
    ));
  }

  void _onRefreshRequested(
    BudgetRefreshRequested event,
    Emitter<BudgetState> emit,
  ) {
    if (_currentUserId != null) {
      add(BudgetLoadRequested(_currentUserId!));
    }
  }
}

