import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/datasources/remote/firebase_auth_datasource.dart';
import '../../../../data/datasources/remote/firebase_firestore_datasource.dart';
import '../../../../data/models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuthDatasource _authDatasource;
  final FirebaseFirestoreDatasource _firestoreDatasource;

  AuthBloc({
    FirebaseAuthDatasource? authDatasource,
    FirebaseFirestoreDatasource? firestoreDatasource,
  }) : _authDatasource = authDatasource ?? FirebaseAuthDatasource(),
       _firestoreDatasource =
           firestoreDatasource ?? FirebaseFirestoreDatasource(),
       super(const AuthState()) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthPanelModeToggled>(_onPanelModeToggled);
    on<AuthRoleChanged>(_onRoleChanged);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    await emit.forEach<User?>(
      _authDatasource.authStateChanges(),
      onData: (firebaseUser) {
        if (firebaseUser == null) {
          return state.copyWith(
            status: AuthStatus.unauthenticated,
            clearUser: true,
          );
        }

        _loadUserProfile(firebaseUser);
        return state.copyWith(status: AuthStatus.authenticated);
      },
      onError: (_, _) =>
          state.copyWith(status: AuthStatus.unauthenticated, clearUser: true),
    );
  }

  Future<void> _loadUserProfile(User firebaseUser) async {
    try {
      final profile = await _firestoreDatasource.getUserProfile(
        firebaseUser.uid,
      );
      if (profile != null && !isClosed) {
        add(AuthRoleChanged(profile.role));
      }
    } catch (_) {
      // Firestore profili henüz yoksa mevcut rol korunur.
    }
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
    final currentUser = state.user;
    final updatedUser = currentUser != null
        ? UserModel(
            uid: currentUser.uid,
            name: currentUser.name,
            email: currentUser.email,
            role: event.role,
            companyId: event.role == 'b2c'
                ? null
                : (currentUser.companyId ?? 'company_001'),
          )
        : null;

    emit(
      state.copyWith(
        user: updatedUser,
        role: event.role,
        isBusinessMode: event.role == 'b2c' ? false : state.isBusinessMode,
      ),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authDatasource.logout();
    emit(
      const AuthState(
        status: AuthStatus.unauthenticated,
        role: 'b2c',
        isBusinessMode: false,
      ),
    );
  }
}
