class AuthErrorMessages {
  AuthErrorMessages._();

  static String fromCode(String code) => fromFirebaseCode(code);

  static String fromFirebaseCode(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Bu e-posta adresine kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Hatalı e-posta veya şifre girdiniz.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda.';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6-8 karakter giriniz.';
      case 'invalid-email':
        return 'Geçersiz e-posta formatı.';
      case 'user-disabled':
        return 'Bu kullanıcı hesabı devre dışı bırakılmış.';
      case 'network-request-failed':
        return 'Ağ bağlantısı hatası. Lütfen internetinizi kontrol edin.';
      default:
        return 'Bir kimlik doğrulama hatası oluştu ($code).';
    }
  }
}
