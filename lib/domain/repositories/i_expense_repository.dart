import '../models/expense_model.dart';
abstract class IExpenseRepository {
  Future<List<ExpenseModel?>> getAllExpenses();
  Future<ExpenseModel?> getExpenseById(String expenseId);
}