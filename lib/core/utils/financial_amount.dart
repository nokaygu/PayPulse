class FinancialAmount {
  FinancialAmount._();

  // Ekran girişleri için üst sınır:
  // 999.999.999,99 TL.
  static const maxInputKurus = 99999999999;

  static int? parse(String? value) {
    if (value == null) return null;

    final text = value.trim();

    // 1500,00 veya 1.500,00 kabul edilir.
    final valid = RegExp(
      r'^(?:[0-9]{1,9}|[0-9]{1,3}(?:\.[0-9]{3}){1,2})'
      r'(?:,[0-9]{1,2})?$',
    );

    if (!valid.hasMatch(text)) return null;

    final parts = text.replaceAll('.', '').split(',');
    final lira = int.tryParse(parts[0]);

    if (lira == null) return null;

    final fraction = parts.length == 2 ? parts[1].padRight(2, '0') : '00';

    final kurus = lira * 100 + int.parse(fraction);

    if (kurus > maxInputKurus) return null;

    return kurus;
  }

  static String input(int kurus) {
    if (kurus < 0 || kurus > maxInputKurus) {
      throw ArgumentError('Tutar giriş sınırları dışında.');
    }

    return '${kurus ~/ 100},'
        '${(kurus % 100).toString().padLeft(2, '0')}';
  }

  static String format(int kurus) {
    final absolute = kurus.abs();
    final digits = (absolute ~/ 100).toString();
    final grouped = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        grouped.write('.');
      }

      grouped.write(digits[i]);
    }

    final fraction = (absolute % 100).toString().padLeft(2, '0');

    return '${kurus < 0 ? '-' : ''}₺$grouped,$fraction';
  }

  static int balanceAfter({
    required int balanceKurus,
    required int amountKurus,
  }) {
    if (balanceKurus < 0) {
      throw ArgumentError('Bakiye negatif olamaz.');
    }

    if (amountKurus <= 0) {
      throw ArgumentError('Tutar sıfırdan büyük olmalıdır.');
    }

    if (amountKurus > balanceKurus) {
      throw StateError('Yetersiz bakiye.');
    }

    return balanceKurus - amountKurus;
  }

  // %1,39 = 139 / 10000.
  // Pozitif tutarlarda en yakın kuruşa yuvarlanır.
  static int posCommission(int amountKurus) {
    if (amountKurus < 0 || amountKurus > maxInputKurus) {
      throw ArgumentError('Geçersiz komisyon tutarı.');
    }

    return (amountKurus * 139 + 5000) ~/ 10000;
  }

  static String inWords(int kurus) {
    if (kurus < 0 || kurus > maxInputKurus) {
      throw ArgumentError('Tutar giriş sınırları dışında.');
    }

    final lira = kurus ~/ 100;
    final fraction = kurus % 100;

    final result = '${_number(lira)} Türk Lirası';

    if (fraction == 0) return result;

    return '$result ${_number(fraction)} Kuruş';
  }

  static String _number(int number) {
    if (number == 0) return 'Sıfır';

    final groups = <String>[];
    final millions = number ~/ 1000000;
    final thousands = (number ~/ 1000) % 1000;
    final remainder = number % 1000;

    if (millions > 0) {
      groups.add('${_underThousand(millions)} Milyon');
    }

    if (thousands > 0) {
      groups.add(thousands == 1 ? 'Bin' : '${_underThousand(thousands)} Bin');
    }

    if (remainder > 0) {
      groups.add(_underThousand(remainder));
    }

    return groups.join(' ');
  }

  static String _underThousand(int number) {
    const ones = [
      '',
      'Bir',
      'İki',
      'Üç',
      'Dört',
      'Beş',
      'Altı',
      'Yedi',
      'Sekiz',
      'Dokuz',
    ];

    const tens = [
      '',
      'On',
      'Yirmi',
      'Otuz',
      'Kırk',
      'Elli',
      'Altmış',
      'Yetmiş',
      'Seksen',
      'Doksan',
    ];

    final words = <String>[];
    final hundreds = number ~/ 100;

    if (hundreds > 0) {
      if (hundreds > 1) words.add(ones[hundreds]);
      words.add('Yüz');
    }

    final ten = (number ~/ 10) % 10;
    final one = number % 10;

    if (ten > 0) words.add(tens[ten]);
    if (one > 0) words.add(ones[one]);

    return words.join(' ');
  }
}
