/// Bakiyeleri kuruş cinsinden tutan ve negatif bakiye ile kuruş kaybını engelleyen saf Domain Entity sınıfı.
class WalletEntity {
  final String walletId;
  final String ownerId; // userId veya companyId olabilir
  final int balanceTl; // Kuruş bazında (Örn: 150.50 TL -> 15050)
  final int balanceUsd; // Cent bazında
  final int balanceEur; // Cent bazında
  final String? iban;

  const WalletEntity({
    required this.walletId,
    required this.ownerId,
    required this.balanceTl,
    required this.balanceUsd,
    required this.balanceEur,
    this.iban,
  });

  double get balanceTlInLira => balanceTl / 100.0;

  double get balanceUsdInDollar => balanceUsd / 100.0;

  double get balanceEurInEuro => balanceEur / 100.0;

  bool get hasIban => iban != null && iban!.trim().isNotEmpty;

  /// Negatif bakiye kalkanı: Gönderilecek tutar pozitif ve TL bakiyesi yeterli mi?
  bool canAffordTl(int amountInKurus) {
    return amountInKurus > 0 && balanceTl >= amountInKurus;
  }

  /// Bakiye yeterliyse düşülmüş yeni [WalletEntity] döner, yetersizse [StateError] fırlatır.
  WalletEntity deductTl(int amountInKurus) {
    if (amountInKurus <= 0) {
      throw ArgumentError.value(
        amountInKurus,
        'amountInKurus',
        'İşlem tutarı sıfırdan büyük olmalıdır.',
      );
    }
    if (!canAffordTl(amountInKurus)) {
      throw StateError('Yetersiz TL bakiyesi: bakiye negatife düşemez.');
    }

    return copyWith(balanceTl: balanceTl - amountInKurus);
  }

  WalletEntity copyWith({
    String? walletId,
    String? ownerId,
    int? balanceTl,
    int? balanceUsd,
    int? balanceEur,
    String? iban,
  }) {
    return WalletEntity(
      walletId: walletId ?? this.walletId,
      ownerId: ownerId ?? this.ownerId,
      balanceTl: balanceTl ?? this.balanceTl,
      balanceUsd: balanceUsd ?? this.balanceUsd,
      balanceEur: balanceEur ?? this.balanceEur,
      iban: iban ?? this.iban,
    );
  }
}

