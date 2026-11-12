import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_pulse/core/formatters/currency_and_card_formatters.dart';

void main() {
  TextEditingValue value(String text) {
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  test('Kart numarası dörderli gruplanır', () {
    final formatter = CardNumberInputFormatter();

    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      value('5400829138478912'),
    );

    expect(result.text, '5400 8291 3847 8912');
  });

  test('16 rakamdan uzun kart girişi reddedilir', () {
    final formatter = CardNumberInputFormatter();
    final previous = value('4242 4242 4242 4242');

    final result = formatter.formatEditUpdate(
      previous,
      value('4242 4242 4242 42421'),
    );

    expect(result, previous);
  });

  test('Son kullanma tarihi biçimlendirilir', () {
    final formatter = ExpiryDateInputFormatter();

    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      value('0828'),
    );

    expect(result.text, '08 / 28');
  });

  test('Tutar virgülden sonra en fazla iki rakam kabul eder', () {
    final formatter = TurkishCurrencyInputFormatter();
    final previous = value('1500,25');

    final result = formatter.formatEditUpdate(previous, value('1500,253'));

    expect(result, previous);
  });

  test('Tutar alanına harf girilemez', () {
    final formatter = TurkishCurrencyInputFormatter();
    final previous = value('1500');

    final result = formatter.formatEditUpdate(previous, value('1500a'));

    expect(result, previous);
  });
}
