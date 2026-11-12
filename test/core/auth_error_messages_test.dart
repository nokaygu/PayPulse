import 'package:flutter_test/flutter_test.dart';
import 'package:pay_pulse/core/errors/auth_error_messages.dart';

void main() {
  group('AuthErrorMessages', () {
    test('Bilinen Firebase hata kodlarını Türkçe mesaja çevirir', () {
      expect(
        AuthErrorMessages.fromFirebaseCode('user-not-found'),
        'Bu e-posta adresine kayıtlı kullanıcı bulunamadı.',
      );
      expect(
        AuthErrorMessages.fromFirebaseCode('wrong-password'),
        'Hatalı e-posta veya şifre girdiniz.',
      );
      expect(
        AuthErrorMessages.fromFirebaseCode('email-already-in-use'),
        'Bu e-posta adresi zaten kullanımda.',
      );
    });

    test('Bilinmeyen kod için varsayılan mesaj üretir', () {
      final msg = AuthErrorMessages.fromFirebaseCode('unknown-error-code');
      expect(msg, contains('unknown-error-code'));
    });
  });
}
