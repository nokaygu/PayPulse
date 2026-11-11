//Şirket çalışanının oluşturduğu masraf onay/red döngüsünü yöneten model.

class ExpenseModel {
  final String expenseId;
  final String employeeId;
  final String companyId;
  final int amount; // Kuruş
  final int vatAmount; // Kuruş
  final String receiptImageUrl;
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectReason;

  ExpenseModel({
    required this.expenseId,
    required this.employeeId,
    required this.companyId,
    required this.amount,
    required this.vatAmount,
    required this.receiptImageUrl,
    required this.status,
    this.rejectReason,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      expenseId: json['expenseId'] as String,
      employeeId: json['employeeId'] as String,
      companyId: json['companyId'] as String,
      amount: json['amount'] as int,
      vatAmount: json['vatAmount'] as int,
      receiptImageUrl: json['receiptImageUrl'] as String,
      status: json['status'] as String,
      rejectReason: json['rejectReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expenseId': expenseId,
      'employeeId': employeeId,
      'companyId': companyId,
      'amount': amount,
      'vatAmount': vatAmount,
      'receiptImageUrl': receiptImageUrl,
      'status': status,
      if (rejectReason != null) 'rejectReason': rejectReason,
    };
  }
}