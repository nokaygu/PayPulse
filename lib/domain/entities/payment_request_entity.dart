import '../../core/utils/equatable.dart';

/// Link veya QR tahsilat talebini temsil eden saf Domain Entity sınıfı.
class PaymentRequestEntity extends Equatable {
  final String requestId;
  final String merchantId;
  final int amount;
  final String currency;
  final String status;
  final String description;
  final String? payerId;
  final String? txId;
  final DateTime? completedAt;

  const PaymentRequestEntity({
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

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  double get amountInMajorUnit => amount / 100.0;

  PaymentRequestEntity copyWith({
    String? requestId,
    String? merchantId,
    int? amount,
    String? currency,
    String? status,
    String? description,
    String? payerId,
    String? txId,
    DateTime? completedAt,
  }) {
    return PaymentRequestEntity(
      requestId: requestId ?? this.requestId,
      merchantId: merchantId ?? this.merchantId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      description: description ?? this.description,
      payerId: payerId ?? this.payerId,
      txId: txId ?? this.txId,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
    requestId,
    merchantId,
    amount,
    currency,
    status,
    description,
    payerId,
    txId,
    completedAt,
  ];
}

