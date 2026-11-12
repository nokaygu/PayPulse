import '../../core/utils/equatable.dart';
import '../../domain/entities/pos_transaction_entity.dart';

/// Sanal POS tahsilat ve komisyon hesaplarını tutan DTO modeli.
class PosTransactionModel extends Equatable {
  final String posTxId;
  final String terminalId;
  final String customerName;
  final double grossAmount;
  final double commissionRate;
  final double commissionAmount;
  final double netAmount;
  final DateTime timestamp;
  final String cardMasked;
  final String status;

  PosTransactionModel({
    required this.posTxId,
    required this.terminalId,
    required this.customerName,
    required this.grossAmount,
    this.commissionRate = 1.39,
    double? commissionAmount,
    double? netAmount,
    DateTime? timestamp,
    this.cardMasked = '5401 **** **** 8421',
    this.status = 'Başarılı',
  })  : commissionAmount = commissionAmount ?? (grossAmount * (commissionRate / 100)),
        netAmount = netAmount ?? (grossAmount - (grossAmount * (commissionRate / 100))),
        timestamp = timestamp ?? DateTime.now();

  factory PosTransactionModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedTime;
    if (json['timestamp'] is String) {
      parsedTime = DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now();
    } else {
      parsedTime = DateTime.now();
    }

    final double gross = (json['grossAmount'] as num?)?.toDouble() ?? 0.0;
    final double rate = (json['commissionRate'] as num?)?.toDouble() ?? 1.39;
    final double comm = (json['commissionAmount'] as num?)?.toDouble() ?? (gross * (rate / 100));
    final double net = (json['netAmount'] as num?)?.toDouble() ?? (gross - comm);

    return PosTransactionModel(
      posTxId: json['posTxId'] as String? ?? '',
      terminalId: json['terminalId'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      grossAmount: gross,
      commissionRate: rate,
      commissionAmount: comm,
      netAmount: net,
      timestamp: parsedTime,
      cardMasked: json['cardMasked'] as String? ?? '5401 **** **** 8421',
      status: json['status'] as String? ?? 'Başarılı',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posTxId': posTxId,
      'terminalId': terminalId,
      'customerName': customerName,
      'grossAmount': grossAmount,
      'commissionRate': commissionRate,
      'commissionAmount': commissionAmount,
      'netAmount': netAmount,
      'timestamp': timestamp.toIso8601String(),
      'cardMasked': cardMasked,
      'status': status,
    };
  }

  PosTransactionEntity toEntity() {
    return PosTransactionEntity(
      posTxId: posTxId,
      terminalId: terminalId,
      customerName: customerName,
      grossAmount: grossAmount,
      commissionRate: commissionRate,
      commissionAmount: commissionAmount,
      netAmount: netAmount,
      timestamp: timestamp,
      cardMasked: cardMasked,
      status: status,
    );
  }

  factory PosTransactionModel.fromEntity(PosTransactionEntity entity) {
    return PosTransactionModel(
      posTxId: entity.posTxId,
      terminalId: entity.terminalId,
      customerName: entity.customerName,
      grossAmount: entity.grossAmount,
      commissionRate: entity.commissionRate,
      commissionAmount: entity.commissionAmount,
      netAmount: entity.netAmount,
      timestamp: entity.timestamp,
      cardMasked: entity.cardMasked,
      status: entity.status,
    );
  }

  PosTransactionModel copyWith({
    String? posTxId,
    String? terminalId,
    String? customerName,
    double? grossAmount,
    double? commissionRate,
    double? commissionAmount,
    double? netAmount,
    DateTime? timestamp,
    String? cardMasked,
    String? status,
  }) {
    return PosTransactionModel(
      posTxId: posTxId ?? this.posTxId,
      terminalId: terminalId ?? this.terminalId,
      customerName: customerName ?? this.customerName,
      grossAmount: grossAmount ?? this.grossAmount,
      commissionRate: commissionRate ?? this.commissionRate,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      netAmount: netAmount ?? this.netAmount,
      timestamp: timestamp ?? this.timestamp,
      cardMasked: cardMasked ?? this.cardMasked,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        posTxId,
        terminalId,
        customerName,
        grossAmount,
        commissionRate,
        commissionAmount,
        netAmount,
        timestamp,
        cardMasked,
        status,
      ];
}

