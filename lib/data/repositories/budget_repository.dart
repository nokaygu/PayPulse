import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/i_budget_repository.dart';
import '../datasources/remote/firebase_firestore_datasource.dart';

class BudgetRepository implements IBudgetRepository {
  final FirebaseFirestoreDatasource _firestoreDatasource;

  BudgetRepository({FirebaseFirestoreDatasource? firestoreDatasource})
    : _firestoreDatasource =
          firestoreDatasource ?? FirebaseFirestoreDatasource();

  @override
  Future<List<BudgetCategoryEntity>> getBudgetCategories({
    required String userId,
    required String period,
    int periodOffset = 0,
  }) async {
    final list = await _firestoreDatasource.getBudgetCategories(
      userId: userId,
      period: period,
      periodOffset: periodOffset,
    );
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<SavingsGoalEntity?> getSavingsGoal({required String userId}) async {
    final model = await _firestoreDatasource.getSavingsGoal(userId: userId);
    return model?.toEntity();
  }
}

