sealed class BudgetEvent {
  const BudgetEvent();
}

/// Bütçe ve analitik verilerini yükler.
final class BudgetLoadRequested extends BudgetEvent {
  final String userId;

  const BudgetLoadRequested(this.userId);
}

/// Aylık toplam harcama bütçesi limitini günceller.
final class BudgetMonthlyQuotaUpdated extends BudgetEvent {
  final int newQuotaInKurus;

  const BudgetMonthlyQuotaUpdated(this.newQuotaInKurus);
}

/// Akıllı tasarruf hedefine para ekler.
final class SavingsDepositRequested extends BudgetEvent {
  final int amountInKurus;

  const SavingsDepositRequested(this.amountInKurus);
}

/// Bütçe ekranını manuel yeniler.
final class BudgetRefreshRequested extends BudgetEvent {
  const BudgetRefreshRequested();
}

