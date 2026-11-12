/// Uygulama Genel Limitleri ve Finansal Sabitler
abstract final class AppLimits {
  AppLimits._();

  /// Tek seferlik FAST transfer üst limiti: 20.000,00 TL (kuruş cinsinden)
  static const int singleFastLimitKurus = 2000000;

  /// Günlük FAST transfer üst limiti: 50.000,00 TL (kuruş cinsinden)
  static const int dailyFastLimitKurus = 5000000;

  /// Aylık FAST transfer üst limiti: 250.000,00 TL (kuruş cinsinden)
  static const int monthlyFastLimitKurus = 25000000;

  /// Sanal POS işlem komisyon oranı: %1,39
  static const double posCommissionRate = 0.0139;

  /// QR Kod yenilenme geri sayım süresi (saniye)
  static const int qrTimeoutSeconds = 60;
}
