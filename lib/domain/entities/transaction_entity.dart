import '../../core/utils/equatable.dart';

/// Sistemdeki tüm gerçekleşmiş finansal hareketleri (FAST, POS, Cüzdan) temsil eden Domain Entity sınıfı.
class TransactionEntity extends Equatable {
  static const int fraudLimitInKurus = 5000000; // 50.000,00 TL

  final String txId;
  final String senderId;
  final String receiverId;
  final int amount; // Kuruş bazında (örn: 150000 = 1.500,00 TL)
  final String currency; // 'TRY', 'USD', 'EUR'
  final DateTime timestamp;
  final String type; // 'fast', 'pos_payment', 'wallet_deposit', 'salary', 'subscription', 'bill'
  final String? targetIban;
  final String
  title; // örn: 'Zeynep Kaya', 'Espresso Lab', 'TechSolutions Maaş'
  final String category; // örn: 'FAST Transfer', 'Kahve & İçecek', 'Maaş', 'Market', 'Fatura'
  final bool isExpense; // true: Giden (-), false: Gelen (+)
  final String dateGroup; // 'BUGÜN, 11 KASIM', 'DÜN, 10 KASIM', 'GEÇEN HAFTA'
  final String status; // 'Başarılı', 'Beklemede', 'İptal'
  final String? relatedId;

  const TransactionEntity({
    required this.txId,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.currency,
    required this.timestamp,
    required this.type,
    this.targetIban,
    this.title = '',
    this.category = 'Genel',
    this.isExpense = true,
    this.dateGroup = 'BUGÜN, 11 KASIM',
    this.status = 'Başarılı',
    this.relatedId,
  });

  /// TL / Ana birim cinsinden tutar (örn: 1500.00)
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
    String? title,
    String? category,
    bool? isExpense,
    String? dateGroup,
    String? status,
    String? relatedId,
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
      title: title ?? this.title,
      category: category ?? this.category,
      isExpense: isExpense ?? this.isExpense,
      dateGroup: dateGroup ?? this.dateGroup,
      status: status ?? this.status,
      relatedId: relatedId ?? this.relatedId,
    );
  }

  @override
  List<Object?> get props => [
    txId,
    senderId,
    receiverId,
    amount,
    currency,
    timestamp,
    type,
    targetIban,
    title,
    category,
    isExpense,
    dateGroup,
    status,
    relatedId,
  ];
}
