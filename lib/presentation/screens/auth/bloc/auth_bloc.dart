import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_mode.dart';
import '../../../../core/utils/firestore_seeder.dart';
import '../../../../data/datasources/remote/firebase_auth_datasource.dart';
import '../../../../data/datasources/remote/firebase_firestore_datasource.dart';
import '../../../../data/models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuthDatasource? _authDatasource;
  final FirebaseFirestoreDatasource? _firestoreDatasource;

  AuthBloc({
    FirebaseAuthDatasource? authDatasource,
    FirebaseFirestoreDatasource? firestoreDatasource,
  }) : _authDatasource = authDatasource ??
           (AppMode.isLiveFirebase ? FirebaseAuthDatasource() : null),
       _firestoreDatasource = firestoreDatasource ??
           (AppMode.isLiveFirebase ? FirebaseFirestoreDatasource() : null),
       super(const AuthState()) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthUserProfileLoaded>(_onUserProfileLoaded);
    on<AuthPanelModeToggled>(_onPanelModeToggled);
    on<AuthRoleChanged>(_onRoleChanged);
    on<AuthDemoLoginRequested>(_onDemoLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (AppMode.isDemoMode || _authDatasource == null) {
      // macOS Demo Modu: Firebase Auth Keychain erişimi atlanır.
      return;
    }

    await emit.forEach<User?>(
      _authDatasource!.authStateChanges(),
      onData: (firebaseUser) {
        if (firebaseUser == null) {
          if (state.user?.uid.startsWith('demo_') == true ||
              state.user?.uid == FirestoreSeeder.mockUser.uid) {
            return state;
          }
          return state.copyWith(
            status: AuthStatus.unauthenticated,
            clearUser: true,
          );
        }

        final initialUser = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ??
              firebaseUser.email?.split('@').first ??
              'Kullanıcı',
          email: firebaseUser.email ?? '',
          role: state.role,
        );
        _loadUserProfile(firebaseUser);
        return state.copyWith(
          status: AuthStatus.authenticated,
          user: initialUser,
        );
      },
      onError: (_, _) {
        if (state.user?.uid.startsWith('demo_') == true ||
            state.user?.uid == FirestoreSeeder.mockUser.uid) {
          return state;
        }
        return state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
        );
      },
    );
  }

  Future<void> _loadUserProfile(User firebaseUser) async {
    try {
      final profile = await _firestoreDatasource?.getUserProfile(
        firebaseUser.uid,
      );
      if (profile != null && !isClosed) {
        add(AuthUserProfileLoaded(profile));
      } else if (!isClosed) {
        add(
          AuthUserProfileLoaded(
            UserModel(
              uid: firebaseUser.uid,
              name: firebaseUser.displayName ??
                  firebaseUser.email?.split('@').first ??
                  'Kullanıcı',
              email: firebaseUser.email ?? '',
              role: 'b2c',
            ),
          ),
        );
      }
    } catch (_) {
      // Firestore profili henüz yoksa mevcut rol korunur.
    }
  }

  void _onUserProfileLoaded(
    AuthUserProfileLoaded event,
    Emitter<AuthState> emit,
  ) {
    emit(
      state.copyWith(
        user: event.user,
        role: event.user.role,
        isBusinessMode: event.user.role == 'b2c' ? false : state.isBusinessMode,
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

  void _onRoleChanged(AuthRoleChanged event, Emitter<AuthState> emit) {
    if (AppMode.isDemoMode) {
      add(AuthDemoLoginRequested(event.role));
      return;
    }

    final currentUser = state.user;
    if (currentUser == null) {
      // Oturum açılmamışsa rol değişikliği ile Firebase Auth güvenliği bypass edilemez.
      emit(state.copyWith(role: event.role, isBusinessMode: false));
      return;
    }

    final updatedUser = UserModel(
      uid: currentUser.uid,
      name: currentUser.name,
      email: currentUser.email,
      role: event.role,
      companyId: event.role == 'b2c' ? null : currentUser.companyId,
      hasB2BAccess: event.role != 'b2c' && currentUser.companyId != null,
    );

    emit(
      state.copyWith(
        user: updatedUser,
        role: event.role,
        isBusinessMode: event.role == 'b2c' ? false : state.isBusinessMode,
      ),
    );
  }

  void _onDemoLoginRequested(
    AuthDemoLoginRequested event,
    Emitter<AuthState> emit,
  ) {
    final UserModel demoUser;
    final bool isBusiness;
    if (event.role == 'admin') {
      isBusiness = true;
      demoUser = const UserModel(
        uid: 'user_admin_ali',
        name: 'Ali Yılmaz',
        email: 'ali.yilmaz@paypulse.com',
        role: 'admin',
        companyId: 'comp_paypulse_tech',
        customerNo: 'PP-ADMIN-001',
        verificationLevel: 3,
        iban: 'TR92 0006 2000 8492 0100 0000 03',
        monthlyLimit: 100000.0,
        spentThisMonth: 12000.0,
        hasB2BAccess: true,
      );
    } else if (event.role == 'employee') {
      isBusiness = true;
      demoUser = const UserModel(
        uid: 'user_employee_ahmet',
        name: 'Ahmet Yılmaz',
        email: 'ahmet.yilmaz@paypulse.com',
        role: 'employee',
        companyId: 'comp_paypulse_tech',
        customerNo: 'PP-EMP-002',
        verificationLevel: 2,
        iban: 'TR18 0006 2000 8492 0100 0000 02',
        monthlyLimit: 15000.0,
        spentThisMonth: 3200.0,
        hasB2BAccess: true,
      );
    } else {
      isBusiness = false;
      demoUser = const UserModel(
        uid: 'user_deniz_aksoy',
        name: 'Deniz Aksoy',
        email: 'deniz.aksoy@paypulse.com',
        role: 'b2c',
        customerNo: 'PP-849201',
        verificationLevel: 2,
        iban: 'TR42 0006 2000 8492 0100 0000 01',
        monthlyLimit: 25000.0,
        spentThisMonth: 18420.0,
        hasB2BAccess: false,
      );
    }

    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
        user: demoUser,
        role: event.role,
        isBusinessMode: isBusiness,
      ),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (!AppMode.isDemoMode && _authDatasource != null) {
      try {
        await _authDatasource!.logout();
      } catch (_) {}
    }
    emit(
      const AuthState(
        status: AuthStatus.unauthenticated,
        role: 'b2c',
        isBusinessMode: false,
      ),
    );
  }
}
