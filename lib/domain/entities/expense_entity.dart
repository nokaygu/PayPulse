import '../../core/utils/equatable.dart';

/// Çalışanın oluşturduğu masraf fişi ve onay/red iş kurallarını yöneten saf Domain Entity sınıfı.
class ExpenseEntity extends Equatable {
  final String expenseId;
  final String employeeId;
  final String employeeName;
  final String merchantTitle;
  final String category;
  final String companyId;
  final int amount; // KDV dahil toplam tutar (Kuruş)
  final int vatAmount; // KDV tutarı (Kuruş)
  final String receiptImageUrl;
  final String status; // 'pending' (ONAY_BEKLIYOR), 'approved' (ONAYLANDI), 'rejected' (REDDEDILDI)
  final String? rejectReason;
  final DateTime date;
  final String accountingCode;

  const ExpenseEntity({
    required this.expenseId,
    required this.employeeId,
    this.employeeName = '',
    this.merchantTitle = '',
    this.category = 'Genel',
    required this.companyId,
    required this.amount,
    required this.vatAmount,
    required this.receiptImageUrl,
    required this.status,
    this.rejectReason,
    DateTime? date,
    this.accountingCode = '770.01',
  }) : date = date ?? const _ConstDateTime();

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

  bool get isPending => status == 'pending' || status == 'ONAY_BEKLIYOR';
  bool get isApproved => status == 'approved' || status == 'ONAYLANDI';
  bool get isRejected => status == 'rejected' || status == 'REDDEDILDI';

  bool canBeReviewedByAdmin(String userRole) {
    return isPending && (userRole == 'admin' || userRole == 'manager');
  }

  ExpenseEntity copyWith({
    String? expenseId,
    String? employeeId,
    String? employeeName,
    String? merchantTitle,
    String? category,
    String? companyId,
    int? amount,
    int? vatAmount,
    String? receiptImageUrl,
    String? status,
    String? rejectReason,
    DateTime? date,
    String? accountingCode,
  }) {
    return ExpenseEntity(
      expenseId: expenseId ?? this.expenseId,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      merchantTitle: merchantTitle ?? this.merchantTitle,
      category: category ?? this.category,
      companyId: companyId ?? this.companyId,
      amount: amount ?? this.amount,
      vatAmount: vatAmount ?? this.vatAmount,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      status: status ?? this.status,
      rejectReason: rejectReason ?? this.rejectReason,
      date: date ?? this.date,
      accountingCode: accountingCode ?? this.accountingCode,
    );
  }

  @override
  List<Object?> get props => [
        expenseId,
        employeeId,
        employeeName,
        merchantTitle,
        category,
        companyId,
        amount,
        vatAmount,
        receiptImageUrl,
        status,
        rejectReason,
        date,
        accountingCode,
      ];
}

class _ConstDateTime implements DateTime {
  const _ConstDateTime();

  @override
  dynamic noSuchMethod(Invocation invocation) => DateTime.now();
}

typedef ExpenseItemEntity = ExpenseEntity;
