import '../../core/utils/equatable.dart';
import '../../domain/entities/transaction_entity.dart';

/// Finansal hareketleri temsil eden DTO model sınıfı.
class TransactionModel extends Equatable {
  final String txId;
  final String senderId;
  final String receiverId;
  final int amount; // Kuruş bazında
  final String currency; // 'TRY', 'USD', 'EUR'
  final DateTime timestamp;
  final String type; // 'fast', 'pos_payment', 'wallet_deposit', 'salary', 'bill', 'expense_reimbursement', etc.
  final String? targetIban;
  final String title;
  final String category;
  final bool isExpense;
  final String dateGroup;
  final String status;
  final String? relatedId;

  const TransactionModel({
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

  double get amountInMajorUnit => amount / 100.0;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final rawTimestamp = json['timestamp'];
    DateTime parsedDate;
    if (rawTimestamp is String) {
      parsedDate = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
    } else if (rawTimestamp != null &&
        rawTimestamp.runtimeType.toString().contains('Timestamp')) {
      parsedDate = (rawTimestamp as dynamic).toDate();
    } else {
      parsedDate = DateTime.now();
    }

    return TransactionModel(
      txId: json['txId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      receiverId: json['receiverId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'TRY',
      timestamp: parsedDate,
      type: json['type'] as String? ?? 'fast',
      targetIban: json['targetIban'] as String?,
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'Genel',
      isExpense: json['isExpense'] as bool? ?? true,
      dateGroup: json['dateGroup'] as String? ?? 'BUGÜN, 11 KASIM',
      status: json['status'] as String? ?? 'Başarılı',
      relatedId: json['relatedId'] as String?,
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
      if (targetIban != null) 'targetIban': targetIban,
      'title': title,
      'category': category,
      'isExpense': isExpense,
      'dateGroup': dateGroup,
      'status': status,
      if (relatedId != null) 'relatedId': relatedId,
    };
  }

  TransactionEntity toEntity() {
    return TransactionEntity(
      txId: txId,
      senderId: senderId,
      receiverId: receiverId,
      amount: amount,
      currency: currency,
      timestamp: timestamp,
      type: type,
      targetIban: targetIban,
      title: title,
      category: category,
      isExpense: isExpense,
      dateGroup: dateGroup,
      status: status,
      relatedId: relatedId,
    );
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      txId: entity.txId,
      senderId: entity.senderId,
      receiverId: entity.receiverId,
      amount: entity.amount,
      currency: entity.currency,
      timestamp: entity.timestamp,
      type: entity.type,
      targetIban: entity.targetIban,
      title: entity.title,
      category: entity.category,
      isExpense: entity.isExpense,
      dateGroup: entity.dateGroup,
      status: entity.status,
      relatedId: entity.relatedId,
    );
  }

  TransactionModel copyWith({
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
    return TransactionModel(
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
