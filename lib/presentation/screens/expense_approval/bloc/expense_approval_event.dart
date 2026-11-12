sealed class ExpenseApprovalEvent {
  const ExpenseApprovalEvent();
}

/// Bekleyen masraf taleplerini yükler.
final class ExpenseApprovalLoadRequested extends ExpenseApprovalEvent {
  const ExpenseApprovalLoadRequested();
}

/// Tek bir masrafı onaylar.
final class ExpenseSingleApproved extends ExpenseApprovalEvent {
  final String expenseId;

  const ExpenseSingleApproved(this.expenseId);
}

/// Tek bir masrafı reddeder.
final class ExpenseSingleRejected extends ExpenseApprovalEvent {
  final String expenseId;
  final String reason;

  const ExpenseSingleRejected({
    required this.expenseId,
    this.reason = 'Departman bütçesi uygun görülmedi.',
  });
}

/// Tüm bekleyen masrafları toplu onaylar (₺3.890,50).
final class ExpenseBatchApproved extends ExpenseApprovalEvent {
  const ExpenseBatchApproved();
}

