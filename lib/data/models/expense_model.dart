import '../../core/utils/equatable.dart';
import '../../domain/entities/expense_entity.dart';

/// Şirket çalışanının oluşturduğu masraf onay/red döngüsünü yöneten model.
class ExpenseModel extends Equatable {
  final String expenseId;
  final String employeeId;
  final String employeeName;
  final String merchantTitle;
  final String category;
  final String companyId;
  final int amount; // Kuruş
  final int vatAmount; // Kuruş
  final String receiptImageUrl;
  final String status; // 'pending' (ONAY_BEKLIYOR), 'approved', 'rejected'
  final String? rejectReason;
  final DateTime date;
  final String accountingCode;

  ExpenseModel({
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
  }) : date = date ?? DateTime.now();

  double get amountInLira => amount / 100.0;
  double get vatAmountInLira => vatAmount / 100.0;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    if (json['date'] is String) {
      parsedDate = DateTime.tryParse(json['date'] as String) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return ExpenseModel(
      expenseId: json['expenseId'] as String? ?? '',
      employeeId: json['employeeId'] as String? ?? '',
      employeeName: json['employeeName'] as String? ?? '',
      merchantTitle: json['merchantTitle'] as String? ?? '',
      category: json['category'] as String? ?? 'Genel',
      companyId: json['companyId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      vatAmount: (json['vatAmount'] as num?)?.toInt() ?? 0,
      receiptImageUrl: json['receiptImageUrl'] as String? ?? '',
      status: json['status'] as String? ?? 'ONAY_BEKLIYOR',
      rejectReason: json['rejectReason'] as String?,
      date: parsedDate,
      accountingCode: json['accountingCode'] as String? ?? '770.01',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expenseId': expenseId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'merchantTitle': merchantTitle,
      'category': category,
      'companyId': companyId,
      'amount': amount,
      'vatAmount': vatAmount,
      'receiptImageUrl': receiptImageUrl,
      'status': status,
      if (rejectReason != null) 'rejectReason': rejectReason,
      'date': date.toIso8601String(),
      'accountingCode': accountingCode,
    };
  }

  ExpenseEntity toEntity() {
    return ExpenseEntity(
      expenseId: expenseId,
      employeeId: employeeId,
      employeeName: employeeName,
      merchantTitle: merchantTitle,
      category: category,
      companyId: companyId,
      amount: amount,
      vatAmount: vatAmount,
      receiptImageUrl: receiptImageUrl,
      status: status,
      rejectReason: rejectReason,
      date: date,
      accountingCode: accountingCode,
    );
  }

  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      expenseId: entity.expenseId,
      employeeId: entity.employeeId,
      employeeName: entity.employeeName,
      merchantTitle: entity.merchantTitle,
      category: entity.category,
      companyId: entity.companyId,
      amount: entity.amount,
      vatAmount: entity.vatAmount,
      receiptImageUrl: entity.receiptImageUrl,
      status: entity.status,
      rejectReason: entity.rejectReason,
      date: entity.date,
      accountingCode: entity.accountingCode,
    );
  }

  ExpenseModel copyWith({
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
    return ExpenseModel(
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

typedef ExpenseItemModel = ExpenseModel;
