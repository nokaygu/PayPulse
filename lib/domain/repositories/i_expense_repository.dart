import '../entities/expense_entity.dart';

abstract class IExpenseRepository {
  Future<List<ExpenseEntity>> getAllExpenses();
  Future<ExpenseEntity?> getExpenseById(String expenseId);
  Stream<List<ExpenseEntity>> watchEmployeeExpenses(String employeeId);
  Stream<List<ExpenseEntity>> watchCompanyExpenses(String companyId);
  Future<void> createExpense(ExpenseEntity expense);
  Future<void> approveExpense({
    required String expenseId,
    String? accountingCode,
  });
  Future<void> rejectExpense({
    required String expenseId,
    required String reason,
  });
}
