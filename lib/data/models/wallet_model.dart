
//"Bakiye negatife düşemez ve kuruş kaybı olamaz" kuralı gereği bakiyeleri kuruş cinsinden (int) tutan model.

class WalletModel {
  final String walletId;
  final String ownerId; // userId veya companyId olabilir
  final int balanceTl; // Kuruş bazında (Örn: 150.50 TL -> 15050)
  final int balanceUsd;
  final int balanceEur;

  WalletModel({
    required this.walletId,
    required this.ownerId,
    required this.balanceTl,
    required this.balanceUsd,
    required this.balanceEur,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      walletId: json['walletId'] as String,
      ownerId: json['ownerId'] as String,
      balanceTl: json['balanceTl'] as int? ?? 0,
      balanceUsd: json['balanceUsd'] as int? ?? 0,
      balanceEur: json['balanceEur'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'walletId': walletId,
      'ownerId': ownerId,
      'balanceTl': balanceTl,
      'balanceUsd': balanceUsd,
      'balanceEur': balanceEur,
    };
  }
}