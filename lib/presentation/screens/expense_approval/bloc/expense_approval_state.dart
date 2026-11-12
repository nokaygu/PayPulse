enum ExpenseApprovalStatus { initial, loading, success, batchSuccess, failure }

enum ApprovalBadgeType {
  aiOcr,      // AI-OCR %98 Doğrulandı
  limitAlert, // Departman Temsil Limiti Sınırında %99 Doluluk
  ctoSigned,  // CTO İmzalı Ön Onaylı
}

class PendingExpenseItem {
  final String expenseId;
  final String employeeName;
  final String role;
  final String category;
  final int amountKurus;
  final int vatAmountKurus; // KDV Tutarı
  final String date;
  final ApprovalBadgeType badgeType;
  final String badgeText;
  final bool isApproved;
  final bool isRejected;

  const PendingExpenseItem({
    required this.expenseId,
    required this.employeeName,
    required this.role,
    required this.category,
    required this.amountKurus,
    required this.vatAmountKurus,
    required this.date,
    required this.badgeType,
    required this.badgeText,
    this.isApproved = false,
    this.isRejected = false,
  });

  double get amountInLira => amountKurus / 100.0;
  double get vatInLira => vatAmountKurus / 100.0;

  PendingExpenseItem copyWith({
    bool? isApproved,
    bool? isRejected,
  }) {
    return PendingExpenseItem(
      expenseId: expenseId,
      employeeName: employeeName,
      role: role,
      category: category,
      amountKurus: amountKurus,
      vatAmountKurus: vatAmountKurus,
      date: date,
      badgeType: badgeType,
      badgeText: badgeText,
      isApproved: isApproved ?? this.isApproved,
      isRejected: isRejected ?? this.isRejected,
    );
  }
}

class ExpenseApprovalState {
  final ExpenseApprovalStatus status;
  final List<PendingExpenseItem> expenses;
  final String? batchReferenceNo;
  final String? erpIntegrationNo;
  final String? blockchainTimestampHash;
  final String? errorMessage;
  final String? successMessage;

  const ExpenseApprovalState({
    this.status = ExpenseApprovalStatus.initial,
    this.expenses = const [],
    this.batchReferenceNo,
    this.erpIntegrationNo,
    this.blockchainTimestampHash,
    this.errorMessage,
    this.successMessage,
  });

  bool get isLoading => status == ExpenseApprovalStatus.loading;
  bool get isBatchSuccess => status == ExpenseApprovalStatus.batchSuccess;

  /// Bekleyen masraflar listesi
  List<PendingExpenseItem> get pendingItems =>
      expenses.where((e) => !e.isApproved && !e.isRejected).toList();

  /// Bekleyen toplam masraf tutarı (kuruş)
  int get totalPendingKurus =>
      pendingItems.fold(0, (sum, item) => sum + item.amountKurus);

  double get totalPendingLira => totalPendingKurus / 100.0;

  /// logic.md: KDV indirimi hesabı (+₺648,40)
  int get totalVatDeductionKurus =>
      pendingItems.fold(0, (sum, item) => sum + item.vatAmountKurus);

  double get totalVatDeductionLira => totalVatDeductionKurus / 100.0;

  ExpenseApprovalState copyWith({
    ExpenseApprovalStatus? status,
    List<PendingExpenseItem>? expenses,
    String? batchReferenceNo,
    String? erpIntegrationNo,
    String? blockchainTimestampHash,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
  }) {
    return ExpenseApprovalState(
      status: status ?? this.status,
      expenses: expenses ?? this.expenses,
      batchReferenceNo: batchReferenceNo ?? this.batchReferenceNo,
      erpIntegrationNo: erpIntegrationNo ?? this.erpIntegrationNo,
      blockchainTimestampHash:
          blockchainTimestampHash ?? this.blockchainTimestampHash,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

