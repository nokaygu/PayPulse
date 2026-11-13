import '../../core/constants/app_strings.dart';
import '../entities/expense_entity.dart';
import '../entities/user_entity.dart';
import '../repositories/i_expense_repository.dart';

/// OCR veya manuel giriş ile oluşturulan personel masrafını iş kurallarına göre kaydeder.
class SubmitExpenseUseCase {
  final IExpenseRepository _expenseRepository;

  const SubmitExpenseUseCase(this._expenseRepository);

  Future<void> call({
    required ExpenseEntity expense,
    UserEntity? actor,
  }) async {
    if (actor != null && !actor.canAccessBusinessPanel) {
      throw StateError(AppStrings.unauthorizedOperationError);
    }

    if (expense.merchantTitle.trim().isEmpty) {
      throw ArgumentError('İşyeri/Tedarikçi adı boş bırakılamaz.');
    }

    if (expense.amount <= 0) {
      throw ArgumentError(AppStrings.invalidAmountError);
    }

    if (expense.vatAmount < 0 || expense.vatAmount > expense.amount) {
      throw ArgumentError('KDV tutarı toplam tutarı aşamaz veya negatif olamaz.');
    }

    await _expenseRepository.createExpense(expense);
  }
}

