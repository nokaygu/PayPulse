//Müşteriden beklenen, link veya QR ile atılmış "Tahsilat Talebi" modeli.

class PaymentRequestModel {
  final String requestId;
  final String merchantId; // companyId
  final int amount; // Kuruş
  final String currency; // 'TRY'
  final String status; // 'pending', 'completed', 'cancelled'
  final String description;

  PaymentRequestModel({
    required this.requestId,
    required this.merchantId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.description,
  });

  factory PaymentRequestModel.fromJson(Map<String, dynamic> json) {
    return PaymentRequestModel(
      requestId: json['requestId'] as String,
      merchantId: json['merchantId'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String,
      status: json['status'] as String,
      description: json['description'] as String,
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
    };
  }
}