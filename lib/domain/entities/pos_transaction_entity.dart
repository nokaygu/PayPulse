import '../../core/utils/equatable.dart';

/// Sanal POS işlem ve tahsilatlarını temsil eden Domain Entity sınıfı.
class PosTransactionEntity extends Equatable {
  final String posTxId;
  final String terminalId;
  final String customerName;
  final double grossAmount; // örn: 3750.00 TL
  final double commissionRate; // örn: 1.39 (%1,39)
  final double commissionAmount; // örn: 52.12 TL
  final double netAmount; // örn: 3697.88 TL
  final DateTime timestamp;
  final String cardMasked; // örn: '5401 **** **** 8421'
  final String status; // 'Başarılı', 'İade'

  PosTransactionEntity({
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

  PosTransactionEntity copyWith({
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
    return PosTransactionEntity(
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

