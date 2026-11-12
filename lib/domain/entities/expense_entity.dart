/// Çalışanın oluşturduğu masraf fişi ve onay/red iş kurallarını yöneten saf Domain Entity sınıfı.
class ExpenseEntity {
  final String expenseId;
  final String employeeId;
  final String companyId;
  final int amount; // KDV dahil toplam tutar (Kuruş)
  final int vatAmount; // KDV tutarı (Kuruş)
  final String receiptImageUrl;
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectReason;

  const ExpenseEntity({
    required this.expenseId,
    required this.employeeId,
    required this.companyId,
    required this.amount,
    required this.vatAmount,
    required this.receiptImageUrl,
    required this.status,
    this.rejectReason,
  });

  /// KDV hariç net gider matrahı (Kuruş).
  int get netAmountInKurus => amount > vatAmount ? amount - vatAmount : 0;

  double get amountInLira => amount / 100.0;

  double get vatAmountInLira => vatAmount / 100.0;

  /// Matrah üzerinden yaklaşık KDV oranı yüzdesi (Örn: %20, %10, %1).
  int get estimatedVatRate {
    final net = netAmountInKurus;
    if (net <= 0 || vatAmount <= 0) return 0;
    return ((vatAmount * 100) / net).round();
  }

  bool get isPending => status == 'pending';

  bool get isApproved => status == 'approved';

  bool get isRejected => status == 'rejected';

  /// Sadece bekleyen masraflar ve 'admin' rolündeki yöneticiler tarafından onaylanabilir/reddedilebilir.
  bool canBeReviewedByAdmin(String userRole) {
    return isPending && userRole == 'admin';
  }

  ExpenseEntity copyWith({
    String? expenseId,
    String? employeeId,
    String? companyId,
    int? amount,
    int? vatAmount,
    String? receiptImageUrl,
    String? status,
    String? rejectReason,
  }) {
    return ExpenseEntity(
      expenseId: expenseId ?? this.expenseId,
      employeeId: employeeId ?? this.employeeId,
      companyId: companyId ?? this.companyId,
      amount: amount ?? this.amount,
      vatAmount: vatAmount ?? this.vatAmount,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      status: status ?? this.status,
      rejectReason: rejectReason ?? this.rejectReason,
    );
  }
}

