class AuthValidator {
  AuthValidator._();

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email boş bırakılamaz';
      }

    final regex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    );

    if (!regex.hasMatch(email)) {
      return 'Geçerli bir e-posta giriniz';
    }
    return null;
  }

  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Şifre boş bırakılamaz';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty){ 
      return 'Şifre boş bırakılamaz';
    }
    
    if (value.length < 8) {
      return 'Şifre en az 8 karakter olmalıdır';
    }
    return null;
  }
}
