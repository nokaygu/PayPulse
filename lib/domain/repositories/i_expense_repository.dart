import '../entities/expense_entity.dart';

/// Clean Architecture Domain Katmanı: Personel Masraf Yönetimi Sözleşmesi
abstract class IExpenseRepository {
  Future<List<ExpenseEntity>> getAllExpenses();
  Future<ExpenseEntity?> getExpenseById(String expenseId);
  Stream<List<ExpenseEntity>> watchEmployeeExpenses(String employeeId);
  Stream<List<ExpenseEntity>> watchCompanyExpenses(String companyId);
  Future<void> createExpense(ExpenseEntity expense);
  Future<void> approveExpense({
    required String expenseId,
    String? accountingCode,
    String? approvedBy,
  });
  Future<void> rejectExpense({
    required String expenseId,
    required String rejectReason,
    String? rejectedBy,
  });
  Future<String> uploadReceiptImage({
    required String localFilePath,
    required String expenseId,
  });
}
