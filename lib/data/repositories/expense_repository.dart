import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/i_expense_repository.dart';
import '../datasources/remote/firebase_firestore_datasource.dart';
import '../models/expense_model.dart';

/// Clean Architecture Data Katmanı: Personel Masraf Yönetim Deposu ([ExpenseRepository])
class ExpenseRepository implements IExpenseRepository {
  final FirebaseFirestoreDatasource _firestoreDatasource;

  ExpenseRepository({FirebaseFirestoreDatasource? firestoreDatasource})
    : _firestoreDatasource =
          firestoreDatasource ?? FirebaseFirestoreDatasource();

  @override
  Future<List<ExpenseEntity>> getAllExpenses() async {
    final list = await _firestoreDatasource.getAllExpenses();
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<ExpenseEntity?> getExpenseById(String expenseId) async {
    final model = await _firestoreDatasource.getExpense(expenseId);
    return model?.toEntity();
  }

  @override
  Stream<List<ExpenseEntity>> watchEmployeeExpenses(String employeeId) {
    return _firestoreDatasource
        .watchEmployeeExpenses(employeeId)
        .map((list) => list.map((e) => e.toEntity()).toList());
  }

  @override
  Stream<List<ExpenseEntity>> watchCompanyExpenses(String companyId) {
    return _firestoreDatasource
        .watchCompanyExpenses(companyId)
        .map((list) => list.map((e) => e.toEntity()).toList());
  }

  @override
  Future<void> createExpense(ExpenseEntity expense) {
    return _firestoreDatasource.createExpense(ExpenseModel.fromEntity(expense));
  }

  @override
  Future<void> approveExpense({
    required String expenseId,
    String? accountingCode,
    String? approvedBy,
  }) {
    return _firestoreDatasource.approveExpense(
      expenseId: expenseId,
      accountingCode: accountingCode,
    );
  }

  @override
  Future<void> rejectExpense({
    required String expenseId,
    required String rejectReason,
    String? rejectedBy,
  }) {
    return _firestoreDatasource.rejectExpense(
      expenseId: expenseId,
      reason: rejectReason,
    );
  }

  @override
  Future<String> uploadReceiptImage({
    required String localFilePath,
    required String expenseId,
  }) {
    return _firestoreDatasource.uploadReceiptImage(
      localFilePath: localFilePath,
      expenseId: expenseId,
    );
  }
}
