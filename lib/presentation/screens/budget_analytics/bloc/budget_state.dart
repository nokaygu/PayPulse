import '../../../../domain/entities/budget_entity.dart';

enum BudgetStatus { initial, loading, success, failure }

class BudgetState {
  final BudgetStatus status;
  final BudgetEntity? budget;
  final String? errorMessage;
  final String? successMessage;

  const BudgetState({
    this.status = BudgetStatus.initial,
    this.budget,
    this.errorMessage,
    this.successMessage,
  });

  bool get isLoading => status == BudgetStatus.loading;
  bool get isSuccess => status == BudgetStatus.success;
  bool get hasData => budget != null;

  BudgetState copyWith({
    BudgetStatus? status,
    BudgetEntity? budget,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return BudgetState(
      status: status ?? this.status,
      budget: budget ?? this.budget,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

