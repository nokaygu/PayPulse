import 'package:flutter_test/flutter_test.dart';
import 'package:pay_pulse/core/validators/auth_validator.dart';

void main() {
  group('AuthValidator', () {
    test('Geçerli e-posta adresleri kabul edilir', () {
      expect(AuthValidator.validateEmail('test@example.com'), isNull);
      expect(
        AuthValidator.validateEmail('user.name+tag@sub.domain.org'),
        isNull,
      );
    });

    test('Geçersiz veya boş e-posta adresleri hata döndürür', () {
      expect(AuthValidator.validateEmail(''), 'Email boş bırakılamaz');
      expect(AuthValidator.validateEmail(null), 'Email boş bırakılamaz');
      expect(
        AuthValidator.validateEmail('gecersiz-email'),
        'Geçerli bir e-posta giriniz',
      );
      expect(
        AuthValidator.validateEmail('test@'),
        'Geçerli bir e-posta giriniz',
      );
    });

    test('Şifre uzunluk doğrulaması', () {
      expect(AuthValidator.validatePassword('12345678'), isNull);
      expect(
        AuthValidator.validatePassword('1234567'),
        'Şifre en az 8 karakter olmalıdır',
      );
      expect(AuthValidator.validatePassword(''), 'Şifre boş bırakılamaz');
      expect(AuthValidator.validatePassword(null), 'Şifre boş bırakılamaz');
    });

    test('Giriş şifresi boşluk kontrolü', () {
      expect(AuthValidator.validateLoginPassword('anypass'), isNull);
      expect(AuthValidator.validateLoginPassword(''), 'Şifre boş bırakılamaz');
      expect(
        AuthValidator.validateLoginPassword(null),
        'Şifre boş bırakılamaz',
      );
    });
  });
}
