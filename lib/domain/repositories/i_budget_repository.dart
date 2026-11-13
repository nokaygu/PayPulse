import '../entities/budget_entity.dart';

/// Clean Architecture Domain Katmanı: Bütçe Analitiği ve Birikim Hedefi Sözleşmesi
abstract class IBudgetRepository {
  Future<List<BudgetCategoryEntity>> getBudgetCategories({
    required String userId,
    required String period,
  });
  Future<SavingsGoalEntity?> getSavingsGoal({required String userId});
}

