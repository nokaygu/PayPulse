/// Sistemdeki tüm gerçekleşmiş finansal hareketleri (FAST, POS, Cüzdan Yükleme) temsil eden Domain Entity sınıfı.
class TransactionEntity {
  static const int fraudLimitInKurus = 5000000; // 50.000,00 TL

  final String txId;
  final String senderId;
  final String receiverId;
  final int amount; // Kuruş bazında
  final String currency; // 'TRY', 'USD', 'EUR'
  final DateTime timestamp;
  final String type; // 'fast', 'pos_payment', 'wallet_deposit'
  final String? targetIban;

  const TransactionEntity({
    required this.txId,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.currency,
    required this.timestamp,
    required this.type,
    this.targetIban,
  });

  double get amountInMajorUnit => amount / 100.0;

  bool get isFastTransfer => type == 'fast';

  bool get isPosPayment => type == 'pos_payment';

  bool get isWalletDeposit => type == 'wallet_deposit';

  /// Fraud alarm kalkanı: 50.000,00 TL (5.000.000 kuruş) ve üzeri işlemler ek doğrulama gerektirir.
  bool get requiresFraudCheck => amount >= fraudLimitInKurus;

  /// Verilen kullanıcı/kurum ID'sine göre gelen (+) işlem mi?
  bool isIncomingFor(String ownerId) => receiverId == ownerId;

  /// Verilen kullanıcı/kurum ID'sine göre giden (-) işlem mi?
  bool isOutgoingFor(String ownerId) =>
      senderId == ownerId && receiverId != ownerId;

  TransactionEntity copyWith({
    String? txId,
    String? senderId,
    String? receiverId,
    int? amount,
    String? currency,
    DateTime? timestamp,
    String? type,
    String? targetIban,
  }) {
    return TransactionEntity(
      txId: txId ?? this.txId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      targetIban: targetIban ?? this.targetIban,
    );
  }
}

