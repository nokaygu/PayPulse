import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_pulse/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:pay_pulse/data/datasources/remote/firebase_firestore_datasource.dart';
import 'package:pay_pulse/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:pay_pulse/presentation/screens/auth/bloc/auth_event.dart';
import 'package:pay_pulse/presentation/screens/auth/bloc/auth_state.dart';

class MockFirebaseAuthDatasource implements FirebaseAuthDatasource {
  @override
  Stream<User?> authStateChanges() => const Stream.empty();

  @override
  Future<void> logout() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockFirebaseFirestoreDatasource implements FirebaseFirestoreDatasource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AuthBloc Demo Girişi ve Rol Testleri', () {
    late MockFirebaseAuthDatasource mockAuth;
    late MockFirebaseFirestoreDatasource mockFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuthDatasource();
      mockFirestore = MockFirebaseFirestoreDatasource();
    });

    test('Hızlı B2C demo girişi isAuthenticated durumunu ve Deniz Aksoy kullanıcısını yükler', () async {
      final authBloc = AuthBloc(
        authDatasource: mockAuth,
        firestoreDatasource: mockFirestore,
      );

      authBloc.add(const AuthDemoLoginRequested('b2c'));

      await expectLater(
        authBloc.stream,
        emits(predicate<AuthState>((state) {
          return state.isAuthenticated &&
              state.role == 'b2c' &&
              state.user?.name == 'Deniz Aksoy' &&
              !state.isBusinessMode;
        })),
      );

      await authBloc.close();
    });

    test('Hızlı B2B Admin demo girişi isAuthenticated durumunu ve Yönetici kullanıcısını yükler', () async {
      final authBloc = AuthBloc(
        authDatasource: mockAuth,
        firestoreDatasource: mockFirestore,
      );

      authBloc.add(const AuthDemoLoginRequested('admin'));

      await expectLater(
        authBloc.stream,
        emits(predicate<AuthState>((state) {
          return state.isAuthenticated &&
              state.role == 'admin' &&
              state.canAccessBusinessPanel &&
              state.isBusinessMode;
        })),
      );

      await authBloc.close();
    });

    test('Demo girişinden sonra çıkış yapıldığında unauthenticated durumuna döner', () async {
      final authBloc = AuthBloc(
        authDatasource: mockAuth,
        firestoreDatasource: mockFirestore,
      );

      authBloc.add(const AuthDemoLoginRequested('b2c'));
      await expectLater(
        authBloc.stream,
        emits(predicate<AuthState>((s) => s.isAuthenticated)),
      );

      authBloc.add(const AuthLogoutRequested());
      await expectLater(
        authBloc.stream,
        emits(predicate<AuthState>((s) => !s.isAuthenticated && s.user == null)),
      );

      await authBloc.close();
    });
  });
}
