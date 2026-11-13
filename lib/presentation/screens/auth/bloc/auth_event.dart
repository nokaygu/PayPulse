import '../../../../domain/entities/user_entity.dart';

sealed class AuthEvent {
  const AuthEvent();
}

/// Firebase oturum ve Firestore kullanıcı rolü dinlemesini başlatır.
final class AuthSubscriptionRequested extends AuthEvent {
  const AuthSubscriptionRequested();
}

/// Firestore'dan yüklenen gerçek kullanıcı profilini duruma kaydeder.
final class AuthUserProfileLoaded extends AuthEvent {
  final UserEntity user;

  const AuthUserProfileLoaded(this.user);
}

/// Bireysel Cüzdan <-> İşletme Paneli görünüm modunu değiştirir.
final class AuthPanelModeToggled extends AuthEvent {
  final bool? isBusinessMode;

  const AuthPanelModeToggled({this.isBusinessMode});
}

/// Kullanıcı rolünü ('b2c', 'employee', 'admin') günceller veya simüle eder.
final class AuthRoleChanged extends AuthEvent {
  final String role;

  const AuthRoleChanged(this.role);
}

/// Jüri sunumu ve hızlı demo girişi için Firebase kimlik doğrulaması olmadan oturumu aktif hale getirir.
final class AuthDemoLoginRequested extends AuthEvent {
  final String role; // 'b2c' veya 'admin'

  const AuthDemoLoginRequested(this.role);
}

/// Mevcut oturumu kapatır.
final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
