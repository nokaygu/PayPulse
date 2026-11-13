import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pay_pulse/core/constants/app_strings.dart';
import 'package:pay_pulse/core/errors/app_exception.dart';
import 'package:pay_pulse/data/repositories/user_repository.dart';
import 'package:pay_pulse/domain/entities/user_entity.dart';
import 'package:pay_pulse/domain/repositories/i_user_repository.dart';
import 'package:pay_pulse/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:pay_pulse/presentation/screens/auth/bloc/auth_event.dart';
import 'package:pay_pulse/presentation/screens/auth/bloc/auth_state.dart';

class _FakeUserRepository implements IUserRepository {
  final StreamController<UserEntity?> _authController =
      StreamController<UserEntity?>.broadcast();
  UserEntity? nextLoginUser;
  AppException? loginException;
  UserEntity? lastUpdatedUser;

  static const _demoUsers = <String, UserEntity>{
    AppStrings.roleB2C: UserEntity(
      uid: AppStrings.demoB2CUid,
      name: 'Deniz Aksoy',
      email: 'deniz@paypulse.app',
      role: AppStrings.roleB2C,
    ),
    AppStrings.roleEmployee: UserEntity(
      uid: AppStrings.demoEmployeeUid,
      name: 'Ahmet Yılmaz',
      email: 'ahmet@techsolutions.com',
      role: AppStrings.roleEmployee,
      companyId: AppStrings.defaultCompanyId,
      hasB2BAccess: true,
    ),
    AppStrings.roleAdmin: UserEntity(
      uid: AppStrings.demoAdminUid,
      name: 'Selin Kaya',
      email: 'selin@techsolutions.com',
      role: AppStrings.roleAdmin,
      companyId: AppStrings.defaultCompanyId,
      hasB2BAccess: true,
    ),
  };

  @override
  Future<List<UserEntity>> getAllUsers() async => _demoUsers.values.toList();

  @override
  Future<UserEntity?> getUserById(String uid) async =>
      _demoUsers.values.where((u) => u.uid == uid).firstOrNull;

  @override
  Stream<UserEntity?> watchAuthUser() => _authController.stream;

  @override
  Future<UserEntity?> login({
    required String email,
    required String password,
  }) async {
    if (loginException != null) throw loginException!;
    return nextLoginUser ?? _demoUsers[AppStrings.roleB2C];
  }

  @override
  Future<UserEntity?> register({
    required String email,
    required String password,
    required String name,
    String role = AppStrings.roleB2C,
    String? companyId,
  }) async {
    return UserEntity(
      uid: 'uid_new',
      name: name,
      email: email,
      role: role,
      companyId: companyId,
      hasB2BAccess: role != AppStrings.roleB2C,
    );
  }

  @override
  Future<void> logout() async {}

  @override
  Future<UserEntity?> getDemoUserByRole(String role) async => _demoUsers[role];

  @override
  Future<void> createUserProfile(UserEntity user) async {}

  @override
  Future<void> updateUserProfile(UserEntity user) async {
    lastUpdatedUser = user;
  }

  @override
  Future<void> updateFcmToken(String uid, String token) async {}

  @override
  Future<void> deleteFcmToken(String uid) async {}

  @override
  Future<void> seedDemoData() async {}

  Future<void> dispose() => _authController.close();
}

void main() {
  group('AuthBloc Demo Girişi, RBAC ve IUserRepository Testleri', () {
    test('Demo B2C girişi bireysel modda oturum açar', () async {
      final authBloc = AuthBloc(
        userRepository: UserRepository(),
        allowDemoPersonaSwitch: true,
      );

      authBloc.add(const AuthDemoLoginRequested(AppStrings.roleB2C));

      await expectLater(
        authBloc.stream,
        emitsThrough(
          predicate<AuthState>((state) {
            return state.isAuthenticated &&
                state.role == AppStrings.roleB2C &&
                !state.isBusinessMode &&
                !state.canAccessBusinessPanel &&
                state.user?.uid == AppStrings.demoB2CUid;
          }),
        ),
      );

      await authBloc.close();
    });

    test('Demo Admin girişi kurumsal yönetim ve onay yetkisi açar', () async {
      final authBloc = AuthBloc(
        userRepository: UserRepository(),
        allowDemoPersonaSwitch: true,
      );

      authBloc.add(const AuthDemoLoginRequested(AppStrings.roleAdmin));

      await expectLater(
        authBloc.stream,
        emitsThrough(
          predicate<AuthState>((state) {
            return state.isAuthenticated &&
                state.isAdmin &&
                state.canAccessBusinessPanel &&
                state.canApproveExpenses &&
                state.isBusinessMode &&
                state.user?.companyId == AppStrings.defaultCompanyId;
          }),
        ),
      );

      await authBloc.close();
    });

    test('Demo çıkış isteği durumu unauthenticated yapar', () async {
      final authBloc = AuthBloc(
        userRepository: UserRepository(),
        allowDemoPersonaSwitch: true,
      );

      authBloc.add(const AuthDemoLoginRequested(AppStrings.roleB2C));
      await expectLater(
        authBloc.stream,
        emitsThrough(predicate<AuthState>((s) => s.isAuthenticated)),
      );

      authBloc.add(const AuthLogoutRequested());
      await expectLater(
        authBloc.stream,
        emitsThrough(
          predicate<AuthState>(
            (s) =>
                s.status == AuthStatus.unauthenticated &&
                !s.isAuthenticated &&
                s.user == null,
          ),
        ),
      );

      await authBloc.close();
    });

    test('Canlı modda AuthRoleChanged ile rol yükseltme engellenir', () async {
      final repo = _FakeUserRepository();
      final authBloc = AuthBloc(
        userRepository: repo,
        allowDemoPersonaSwitch: false,
      );

      authBloc.add(
        AuthUserProfileLoaded(
          const UserEntity(
            uid: 'live_b2c',
            name: 'Live B2C',
            email: 'live@paypulse.app',
            role: AppStrings.roleB2C,
          ),
        ),
      );
      await expectLater(
        authBloc.stream,
        emits(predicate<AuthState>((s) => s.isAuthenticated && !s.isAdmin)),
      );

      authBloc.add(const AuthRoleChanged(AppStrings.roleAdmin));
      authBloc.add(const AuthPanelModeToggled(isBusinessMode: true));

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(authBloc.state.role, AppStrings.roleB2C);
      expect(authBloc.state.canAccessBusinessPanel, isFalse);
      expect(authBloc.state.isBusinessMode, isFalse);

      await authBloc.close();
      await repo.dispose();
    });

    test('Canlı modda yetkili B2B kullanıcı panel geçişi yapabilir', () async {
      final repo = _FakeUserRepository();
      final authBloc = AuthBloc(
        userRepository: repo,
        allowDemoPersonaSwitch: false,
      );

      authBloc.add(
        AuthUserProfileLoaded(
          const UserEntity(
            uid: 'live_admin',
            name: 'Live Admin',
            email: 'admin@company.com',
            role: AppStrings.roleAdmin,
            companyId: 'comp_1',
            hasB2BAccess: true,
          ),
        ),
      );
      await expectLater(
        authBloc.stream,
        emits(predicate<AuthState>((s) => s.isBusinessMode && s.isAdmin)),
      );

      authBloc.add(const AuthPanelModeToggled(isBusinessMode: false));
      await expectLater(
        authBloc.stream,
        emits(predicate<AuthState>((s) => !s.isBusinessMode && s.isAdmin)),
      );

      await authBloc.close();
      await repo.dispose();
    });

    test('AuthLoginRequested hata fırlattığında errorMessage state içine yazar', () async {
      final repo = _FakeUserRepository()
        ..loginException = const AppException(
          'Hatalı şifre. Lütfen tekrar deneyin.',
          code: 'wrong-password',
        );
      final authBloc = AuthBloc(
        userRepository: repo,
        allowDemoPersonaSwitch: false,
      );

      authBloc.add(
        const AuthLoginRequested(email: 'a@b.com', password: 'wrong'),
      );

      await expectLater(
        authBloc.stream,
        emitsThrough(
          predicate<AuthState>(
            (s) =>
                !s.isSubmitting &&
                s.errorMessage == 'Hatalı şifre. Lütfen tekrar deneyin.',
          ),
        ),
      );

      await authBloc.close();
      await repo.dispose();
    });
  });
}
