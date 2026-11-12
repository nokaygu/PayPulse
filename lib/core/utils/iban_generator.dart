/// Simülasyon amaçlı, ISO 7064 Mod 97-10 ve TR IBAN standartlarına uygun
/// 26 karakterlik geçerli IBAN üreten yardımcı sınıf.
class IbanGenerator {
  IbanGenerator._();

  /// Verilen kullanıcı ID'sine veya rastgele bir tohum değerine göre
  /// 26 haneli geçerli bir TR IBAN'ı oluşturur.
  static String generateForUser(String uid) {
    // PayPulse Banka Kodu (5 hane) + Rezerv (1 hane) = '009990'
    const bankPrefix = '009990';

    // UID'den 16 haneli deterministik/sayısal hesap numarası türet
    final hash = uid.hashCode.abs().toString();
    final paddedHash = hash.padLeft(16, '7').substring(0, 16);

    final bban = '$bankPrefix$paddedHash'; // 22 hane

    // TR için harf kodları: T = 29, R = 27 -> '2927'
    final checkCalculationInput = '${bban}292700';

    var remainder = 0;
    for (final rune in checkCalculationInput.runes) {
      final digit = rune - 48; // ASCII '0' = 48
      remainder = (remainder * 10 + digit) % 97;
    }

    final checksum = 98 - remainder;
    final checkDigits = checksum < 10 ? '0$checksum' : checksum.toString();

    return 'TR$checkDigits$bban';
  }
}
