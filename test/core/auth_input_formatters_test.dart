import 'package:flutter_test/flutter_test.dart';
import 'package:pay_pulse/core/formatters/auth_input_formatters.dart';

void main() {
  group('EmailInputFormatter', () {
    test('Boşluk karakterlerini engeller', () {
      final formatter = EmailInputFormatter();
      const oldValue = TextEditingValue(text: 'user@test.com');
      const newValue = TextEditingValue(text: 'user @test.com');

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, 'user@test.com');
    });

    test('Boşluk içermeyen geçerli girişi kabul eder', () {
      final formatter = EmailInputFormatter();
      const oldValue = TextEditingValue(text: 'user');
      const newValue = TextEditingValue(text: 'user@');

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, 'user@');
    });
  });
}
