/// Sanal POS ve QR tahsilat taleplerinin komisyon ve süre kurallarını tutan Domain Entity sınıfı.
class PaymentRequestEntity {
  /// Görseldeki standart Sanal POS komisyon oranı (%1,39 -> on binde 139).
  static const int defaultCommissionBasisPoints = 139;

  /// QR tahsilat linkinin geçerlilik süresi (60 saniye).
  static const int qrValiditySeconds = 60;

  final String requestId;
  final String merchantId; // companyId
  final int amount; // Kuruş
  final String currency; // 'TRY'
  final String status; // 'pending', 'completed', 'cancelled'
  final String description;

  const PaymentRequestEntity({
    required this.requestId,
    required this.merchantId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.description,
  });

  bool get isPending => status == 'pending';

  bool get isCompleted => status == 'completed';

  bool get isCancelled => status == 'cancelled';

  /// Ödeme talebi hala tahsil edilebilir durumda mı?
  bool get isPayable => isPending && amount > 0;

  /// Kuruş kaybı olmadan %1,39 POS işlem komisyonu (Örn: 3.750,00 TL -> 52,12 TL).
  int get commissionInKurus => (amount * defaultCommissionBasisPoints) ~/ 10000;

  /// Komisyon kesintisi sonrası üye işyerinin hesabına geçecek net tutar (Kuruş).
  int get netMerchantPayoutInKurus => amount - commissionInKurus;

  double get amountInMajorUnit => amount / 100.0;

  double get commissionInMajorUnit => commissionInKurus / 100.0;

  double get netMerchantPayoutInMajorUnit => netMerchantPayoutInKurus / 100.0;

  /// QR oluşturma zamanından itibaren 60 saniye geçtiyse süresi dolmuştur.
  bool isQrExpired(DateTime createdAt, DateTime now) {
    return now.difference(createdAt).inSeconds >= qrValiditySeconds;
  }

  PaymentRequestEntity copyWith({
    String? requestId,
    String? merchantId,
    int? amount,
    String? currency,
    String? status,
    String? description,
  }) {
    return PaymentRequestEntity(
      requestId: requestId ?? this.requestId,
      merchantId: merchantId ?? this.merchantId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      description: description ?? this.description,
    );
  }
}
