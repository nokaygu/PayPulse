import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/equatable.dart';
import '../../../../domain/entities/user_entity.dart';

/// Uygulamanın aktif kimlik doğrulama yaşam döngüsü durumu.
enum AuthStatus { unknown, authenticated, unauthenticated }

/// AuthBloc tarafından yönetilen değişmez (immutable) kimlik ve rol durumu.
class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String role;
  final bool isBusinessMode;
  final bool isSubmitting;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.role = AppStrings.roleB2C,
    this.isBusinessMode = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;

  bool get isAdmin => role == AppStrings.roleAdmin;

  bool get isEmployee => role == AppStrings.roleEmployee;

  bool get canAccessBusinessPanel =>
      isAdmin || isEmployee || (user?.canAccessBusinessPanel ?? false);

  bool get canApproveExpenses => isAdmin;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    bool clearUser = false,
    String? role,
    bool? isBusinessMode,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      role: role ?? this.role,
      isBusinessMode: isBusinessMode ?? this.isBusinessMode,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    role,
    isBusinessMode,
    isSubmitting,
    errorMessage,
  ];
}
