//Müşteriden beklenen, link veya QR ile atılmış "Tahsilat Talebi" modeli.

class PaymentRequestModel {
  final String requestId;
  final String merchantId; // companyId
  final int amount; // Kuruş
  final String currency; // 'TRY', 'USD', 'EUR'
  final String status; // 'pending', 'completed', 'cancelled'
  final String description;
  final String? payerId;
  final String? txId;
  final DateTime? completedAt;

  PaymentRequestModel({
    required this.requestId,
    required this.merchantId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.description,
    this.payerId,
    this.txId,
    this.completedAt,
  });

  factory PaymentRequestModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedCompletedAt;
    final rawDate = json['completedAt'];
    if (rawDate != null && rawDate.runtimeType.toString().contains('Timestamp')) {
      parsedCompletedAt = (rawDate as dynamic).toDate();
    } else if (rawDate is String) {
      parsedCompletedAt = DateTime.tryParse(rawDate);
    }

    return PaymentRequestModel(
      requestId: json['requestId'] as String? ?? '',
      merchantId: json['merchantId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'TRY',
      status: json['status'] as String? ?? 'pending',
      description: json['description'] as String? ?? '',
      payerId: json['payerId'] as String?,
      txId: json['txId'] as String?,
      completedAt: parsedCompletedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'merchantId': merchantId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'description': description,
      if (payerId != null) 'payerId': payerId,
      if (txId != null) 'txId': txId,
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
    };
  }
}
