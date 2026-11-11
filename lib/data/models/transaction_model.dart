//Sistemdeki tüm gerçekleşmiş finansal hareketlerin (FAST, POS) tek kaynağı.

class TransactionModel {
  final String txId;
  final String senderId;
  final String receiverId;
  final int amount; // Kuruş bazında
  final String currency; // 'TRY', 'USD', 'EUR'
  final DateTime timestamp;
  final String type; // 'fast', 'pos_payment', 'wallet_deposit'

  TransactionModel({
    required this.txId,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.currency,
    required this.timestamp,
    required this.type,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      txId: json['txId'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String), // Firestore Timestamp çevrimi eklenebilir
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'txId': txId,
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'currency': currency,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }
}