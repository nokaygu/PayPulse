import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_mode.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../domain/repositories/i_user_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Clean Architecture uyumlu kimlik doğrulama ve rol yönetimi BLoC'u.
/// Yalnızca Domain katmanındaki [IUserRepository] soyutlaması ile konuşur.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IUserRepository _userRepository;
  final bool _allowDemoSwitch;
  StreamSubscription<UserEntity?>? _authSubscription;

  AuthBloc({IUserRepository? userRepository, bool? allowDemoPersonaSwitch})
    : _userRepository = userRepository ?? UserRepository(),
      _allowDemoSwitch = allowDemoPersonaSwitch ?? AppMode.isDemoMode,
      super(const AuthState()) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthUserProfileLoaded>(_onUserProfileLoaded);
    on<AuthSessionCleared>(_onSessionCleared);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthDemoLoginRequested>(_onDemoLoginRequested);
    on<AuthRoleChanged>(_onRoleChanged);
    on<AuthPanelModeToggled>(_onPanelModeToggled);
    on<AuthProfileUpdated>(_onProfileUpdated);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthErrorCleared>(_onErrorCleared);
  }

  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authSubscription?.cancel();

    if (_allowDemoSwitch && state.status == AuthStatus.unknown) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          role: AppStrings.roleB2C,
          isBusinessMode: false,
          isSubmitting: false,
          clearError: true,
        ),
      );
    }

    _authSubscription = _userRepository.watchAuthUser().listen((user) {
      if (user == null) {
        add(const AuthSessionCleared());
      } else {
        add(AuthUserProfileLoaded(user));
      }
    });
  }

  void _onUserProfileLoaded(
    AuthUserProfileLoaded event,
    Emitter<AuthState> emit,
  ) {
    final user = event.user;
    emit(
      AuthState(
        status: AuthStatus.authenticated,
        user: user,
        role: user.role,
        isBusinessMode: user.canAccessBusinessPanel,
      ),
    );
  }

  void _onSessionCleared(AuthSessionCleared event, Emitter<AuthState> emit) {
    if (_allowDemoSwitch && state.isAuthenticated) {
      return;
    }
    emit(
      const AuthState(
        status: AuthStatus.unauthenticated,
        role: AppStrings.roleB2C,
        isBusinessMode: false,
      ),
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final user = await _userRepository.login(
        email: event.email.trim(),
        password: event.password,
      );
      if (user == null) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'Kullanıcı profili bulunamadı.',
          ),
        );
        return;
      }

      emit(
        AuthState(
          status: AuthStatus.authenticated,
          user: user,
          role: user.role,
          isBusinessMode: user.canAccessBusinessPanel,
        ),
      );
    } on AppException catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Giriş sırasında beklenmeyen bir hata oluştu.',
        ),
      );
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final user = await _userRepository.register(
        email: event.email.trim(),
        password: event.password,
        name: event.name.trim(),
        role: event.role,
        companyId: event.companyId,
      );
      if (user == null) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'Kayıt işlemi tamamlanamadı.',
          ),
        );
        return;
      }

      emit(
        AuthState(
          status: AuthStatus.authenticated,
          user: user,
          role: user.role,
          isBusinessMode: user.canAccessBusinessPanel,
        ),
      );
    } on AppException catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Kayıt sırasında beklenmeyen bir hata oluştu.',
        ),
      );
    }
  }

  Future<void> _onDemoLoginRequested(
    AuthDemoLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (!_allowDemoSwitch) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Demo girişi canlı modda kapalıdır.',
        ),
      );
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final demoUser = await _userRepository.getDemoUserByRole(event.role);
      if (demoUser == null) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'Seçilen demo profili bulunamadı.',
          ),
        );
        return;
      }

      emit(
        AuthState(
          status: AuthStatus.authenticated,
          user: demoUser,
          role: demoUser.role,
          isBusinessMode: demoUser.canAccessBusinessPanel,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Demo girişi başlatılamadı.',
        ),
      );
    }
  }

  Future<void> _onRoleChanged(
    AuthRoleChanged event,
    Emitter<AuthState> emit,
  ) async {
    // Güvenlik: Canlı modda istemci üzerinden rol yükseltmeye izin verilmez.
    if (!_allowDemoSwitch) return;

    final demoUser = await _userRepository.getDemoUserByRole(event.role);
    if (demoUser != null) {
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: demoUser,
          role: demoUser.role,
          isBusinessMode: demoUser.canAccessBusinessPanel,
          isSubmitting: false,
          clearError: true,
        ),
      );
      return;
    }

    final canAccessBusiness =
        event.role == AppStrings.roleAdmin ||
        event.role == AppStrings.roleEmployee;
    emit(
      state.copyWith(
        role: event.role,
        isBusinessMode: canAccessBusiness,
        clearError: true,
      ),
    );
  }

  void _onPanelModeToggled(
    AuthPanelModeToggled event,
    Emitter<AuthState> emit,
  ) {
    if (!state.canAccessBusinessPanel) {
      emit(state.copyWith(isBusinessMode: false));
      return;
    }

    final targetMode = event.isBusinessMode ?? !state.isBusinessMode;
    emit(state.copyWith(isBusinessMode: targetMode));
  }

  Future<void> _onProfileUpdated(
    AuthProfileUpdated event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = state.user;
    if (currentUser == null) return;

    final updated = currentUser.copyWith(
      name: event.name,
      verificationLevel: event.verificationLevel,
      monthlyLimit: event.monthlyLimit,
      spentThisMonth: event.spentThisMonth,
      hasB2BAccess: event.hasB2BAccess,
      companyId: event.companyId,
    );

    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      await _userRepository.updateUserProfile(updated);
      emit(
        state.copyWith(
          user: updated,
          role: updated.role,
          isSubmitting: false,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Profil güncellenemedi.',
        ),
      );
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _userRepository.logout();
    emit(
      const AuthState(
        status: AuthStatus.unauthenticated,
        role: AppStrings.roleB2C,
        isBusinessMode: false,
      ),
    );
  }

  void _onErrorCleared(AuthErrorCleared event, Emitter<AuthState> emit) {
    emit(state.copyWith(clearError: true));
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
