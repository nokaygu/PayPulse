import '../../../../core/constants/app_strings.dart';
import '../../../../domain/entities/user_entity.dart';

/// AuthBloc tarafından işlenen kimlik doğrulama ve RBAC olayları.
sealed class AuthEvent {
  const AuthEvent();
}

/// Uygulama başlangıcında kimlik doğrulama durum akışını başlatır.
final class AuthSubscriptionRequested extends AuthEvent {
  const AuthSubscriptionRequested();
}

/// Kullanıcı profili repodan yüklendiğinde durumu günceller.
final class AuthUserProfileLoaded extends AuthEvent {
  final UserEntity user;
  const AuthUserProfileLoaded(this.user);
}

/// Akış null kullanıcı bildirdiğinde oturumu temizler.
final class AuthSessionCleared extends AuthEvent {
  const AuthSessionCleared();
}

/// E-posta ve şifre ile canlı/demo giriş talebi.
final class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});
}

/// Yeni kullanıcı kayıt talebi.
final class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String role;
  final String? companyId;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    this.role = AppStrings.roleB2C,
    this.companyId,
  });
}

/// Demo modunda seçilen persona (b2c / employee / admin) ile tek tık giriş yapar.
final class AuthDemoLoginRequested extends AuthEvent {
  final String role;
  const AuthDemoLoginRequested(this.role);
}

/// YALNIZCA Demo modunda personel/yönetici/bireysel persona değişimi yapar.
final class AuthRoleChanged extends AuthEvent {
  final String role;
  const AuthRoleChanged(this.role);
}

/// Yetkili kullanıcılar için Bireysel <-> Kurumsal panel görünümü arasında geçiş yapar.
final class AuthPanelModeToggled extends AuthEvent {
  final bool? isBusinessMode;
  const AuthPanelModeToggled({this.isBusinessMode});
}

/// Kullanıcının profil bilgilerini veya KYC/limit alanlarını günceller.
final class AuthProfileUpdated extends AuthEvent {
  final String? name;
  final int? verificationLevel;
  final double? monthlyLimit;
  final double? spentThisMonth;
  final bool? hasB2BAccess;
  final String? companyId;

  const AuthProfileUpdated({
    this.name,
    this.verificationLevel,
    this.monthlyLimit,
    this.spentThisMonth,
    this.hasB2BAccess,
    this.companyId,
  });
}

/// Oturumu kapatma talebi.
final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Ekranda gösterilen son hata mesajını temizler.
final class AuthErrorCleared extends AuthEvent {
  const AuthErrorCleared();
}
