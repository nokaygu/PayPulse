import '../../core/constants/app_strings.dart';
import '../entities/expense_entity.dart';
import '../repositories/i_expense_repository.dart';

/// Personel masraf taleplerini RBAC ve tek seferlik işlem (idempotency) kurallarıyla onaylar veya reddeder.
class ApproveOrRejectExpenseUseCase {
  final IExpenseRepository _expenseRepository;

  const ApproveOrRejectExpenseUseCase(this._expenseRepository);

  Future<void> approve({
    required ExpenseEntity expense,
    required String actorRole,
    String? actorId,
    String? accountingCode,
  }) async {
    if (!expense.canBeReviewedByAdmin(actorRole)) {
      if (!expense.isPending) {
        throw StateError('Bu masraf daha önce işleme alınmıştır.');
      }
      throw StateError(AppStrings.unauthorizedOperationError);
    }

    await _expenseRepository.approveExpense(
      expenseId: expense.expenseId,
      accountingCode: accountingCode ?? expense.accountingCode,
      approvedBy: actorId,
    );
  }

  Future<void> reject({
    required ExpenseEntity expense,
    required String actorRole,
    required String rejectReason,
    String? actorId,
  }) async {
    if (!expense.canBeReviewedByAdmin(actorRole)) {
      if (!expense.isPending) {
        throw StateError('Bu masraf daha önce işleme alınmıştır.');
      }
      throw StateError(AppStrings.unauthorizedOperationError);
    }

    final trimmed = rejectReason.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Red gerekçesi boş bırakılamaz.');
    }

    await _expenseRepository.rejectExpense(
      expenseId: expense.expenseId,
      rejectReason: trimmed,
      rejectedBy: actorId,
    );
  }
}

