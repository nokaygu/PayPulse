class AppLimits {
  AppLimits._();

  /// Tek seferlik transferde ek güvenlik / fraud uyarısı eşiği: 50.000,00 TL (5.000.000 kuruş).
  static const int fraudLimitInKurus = 5000000;

  /// Dinamik TR Karekod geçerlilik ve yenilenme süresi (saniye - PayPulseQrPayload.defaultTtlSeconds ile uyumlu).
  static const int qrCountdownSeconds = 48;

  /// En düşük FAST transfer tutarı: 1,00 TL (100 kuruş).
  static const int minTransferKurus = 100;

  /// Tek işlem üst sınırı: 999.999.999,99 TL.
  static const int maxTransactionKurus = 99999999999;

  /// Sanal POS komisyon oranı (baz puan: %1,39 = 139 / 10000).
  static const int posCommissionBps = 139;

  /// Sanal POS desteklenen taksit seçenekleri.
  static const List<int> posInstallmentOptions = [1, 3, 6];
}
