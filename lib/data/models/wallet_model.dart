import '../../domain/entities/wallet_entity.dart';

/// "Bakiye negatife düşemez ve kuruş kaybı olamaz" kuralı gereği bakiyeleri kuruş cinsinden (int) tutan model.
class WalletModel {
  final String walletId;
  final String ownerId; // userId veya companyId olabilir
  final int balanceTl; // Kuruş bazında (Örn: 150.50 TL -> 15050)
  final int balanceUsd;
  final int balanceEur;
  final String? iban;

  const WalletModel({
    required this.walletId,
    required this.ownerId,
    required this.balanceTl,
    required this.balanceUsd,
    required this.balanceEur,
    this.iban,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      walletId: json['walletId'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      balanceTl: (json['balanceTl'] as num?)?.toInt() ?? 0,
      balanceUsd: (json['balanceUsd'] as num?)?.toInt() ?? 0,
      balanceEur: (json['balanceEur'] as num?)?.toInt() ?? 0,
      iban: json['iban'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'walletId': walletId,
      'ownerId': ownerId,
      'balanceTl': balanceTl,
      'balanceUsd': balanceUsd,
      'balanceEur': balanceEur,
      if (iban != null) 'iban': iban,
    };
  }

  WalletEntity toEntity() {
    return WalletEntity(
      walletId: walletId,
      ownerId: ownerId,
      balanceTl: balanceTl,
      balanceUsd: balanceUsd,
      balanceEur: balanceEur,
      iban: iban,
    );
  }

  factory WalletModel.fromEntity(WalletEntity entity) {
    return WalletModel(
      walletId: entity.walletId,
      ownerId: entity.ownerId,
      balanceTl: entity.balanceTl,
      balanceUsd: entity.balanceUsd,
      balanceEur: entity.balanceEur,
      iban: entity.iban,
    );
  }

  WalletModel copyWith({
    String? walletId,
    String? ownerId,
    int? balanceTl,
    int? balanceUsd,
    int? balanceEur,
    String? iban,
  }) {
    return WalletModel(
      walletId: walletId ?? this.walletId,
      ownerId: ownerId ?? this.ownerId,
      balanceTl: balanceTl ?? this.balanceTl,
      balanceUsd: balanceUsd ?? this.balanceUsd,
      balanceEur: balanceEur ?? this.balanceEur,
      iban: iban ?? this.iban,
    );
  }
}
