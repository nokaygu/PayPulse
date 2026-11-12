import '../utils/financial_amount.dart';

class FinancialValidators {
  FinancialValidators._();

  static String normalizeCard(String value) {
    return value.replaceAll(RegExp(r'\s'), '');
  }

  static String normalizeIban(String value) {
    return value.replaceAll(RegExp(r'\s'), '').toUpperCase();
  }

  static bool isLuhnValid(String value) {
    final card = normalizeCard(value);

    if (!RegExp(r'^[0-9]{16}$').hasMatch(card)) return false;

    // Matematiksel olarak Luhn'u geçen fakat kullanılmaması
    // gereken tümü sıfır değerini reddet.
    if (card == '0000000000000000') return false;

    var sum = 0;
    var shouldDouble = false;

    for (var i = card.length - 1; i >= 0; i--) {
      var digit = int.parse(card[i]);

      if (shouldDouble) {
        digit *= 2;

        if (digit > 9) digit -= 9;
      }

      sum += digit;
      shouldDouble = !shouldDouble;
    }

    return sum % 10 == 0;
  }

  static String? cardNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kart numarası gerekli.';
    }

    if (!RegExp(r'^[0-9]{16}$').hasMatch(normalizeCard(value))) {
      return 'Kart numarası 16 haneli olmalıdır.';
    }

    if (!isLuhnValid(value)) {
      return 'Kart numarası geçersiz.';
    }

    return null;
  }

  static String? iban(String? value) {
    final normalized = normalizeIban(value ?? '');

    if (!RegExp(r'^TR[0-9]{24}$').hasMatch(normalized)) {
      return 'IBAN, TR ile başlamalı ve 26 karakter olmalıdır.';
    }

    final rearranged =
        '${normalized.substring(4)}${normalized.substring(0, 4)}';

    var remainder = 0;

    for (final rune in rearranged.runes) {
      final converted = rune >= 65 && rune <= 90
          ? (rune - 55).toString()
          : String.fromCharCode(rune);

      for (final digit in converted.runes) {
        remainder = (remainder * 10 + digit - 48) % 97;
      }
    }

    if (remainder != 1) {
      return 'IBAN kontrol numarası geçersiz.';
    }

    return null;
  }

  static String? amount(
    String? value, {
    int? balanceKurus,
  }) {
    final amountKurus = FinancialAmount.parse(value);

    if (amountKurus == null) {
      return 'Geçerli bir tutar giriniz. Örnek: 1.500,00';
    }

    if (amountKurus <= 0) {
      return 'Tutar sıfırdan büyük olmalıdır.';
    }

    if (balanceKurus != null && amountKurus > balanceKurus) {
      return 'Tutar kullanılabilir bakiyeyi aşamaz.';
    }

    return null;
  }

  static String? cardHolder(String? value) {
    final name = value?.trim() ?? '';

    if (name.length < 3) {
      return 'Kart üzerindeki adı giriniz.';
    }

    return null;
  }

  static String? expiry(
    String? value, {
    DateTime? now,
  }) {
    final match = RegExp(
      r'^([0-9]{2})\s*/\s*([0-9]{2})$',
    ).firstMatch(value?.trim() ?? '');

    if (match == null) {
      return 'Tarihi AA / YY biçiminde giriniz.';
    }

    final month = int.parse(match.group(1)!);
    final year = 2000 + int.parse(match.group(2)!);
    final current = now ?? DateTime.now();

    if (month < 1 || month > 12) {
      return 'Geçerli bir ay giriniz.';
    }

    if (year < current.year ||
        (year == current.year && month < current.month)) {
      return 'Kartın son kullanma tarihi geçmiş.';
    }

    return null;
  }

  static String? cvv(String? value) {
    if (!RegExp(r'^[0-9]{3}$').hasMatch(value ?? '')) {
      return 'CVV 3 haneli olmalıdır.';
    }

    return null;
  }
}