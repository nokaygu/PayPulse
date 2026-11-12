import '../../../../data/models/user_model.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String role; // 'b2c', 'employee', 'admin'
  final bool isBusinessMode;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.role = 'b2c',
    this.isBusinessMode = false,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// İşletme paneline sadece 'admin' ve 'employee' rolleri erişebilir.
  bool get canAccessBusinessPanel => role == 'admin' || role == 'employee';

  /// Toplu masraf onayı ve vergi/KDV raporlarına sadece 'admin' erişebilir.
  bool get isAdmin => role == 'admin';

  bool get isEmployee => role == 'employee';

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? role,
    bool? isBusinessMode,
    bool clearUser = false,
  }) {
    final nextRole = role ?? this.role;
    final canUseBusiness = nextRole == 'admin' || nextRole == 'employee';

    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      role: nextRole,
      isBusinessMode: canUseBusiness
          ? (isBusinessMode ?? this.isBusinessMode)
          : false,
    );
  }
}

