import 'package:firebase_auth/firebase_auth.dart';

import '../../core/config/app_mode.dart';
import '../../core/constants/app_strings.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/auth_error_messages.dart';
import '../../core/utils/firestore_seeder.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../datasources/remote/firebase_auth_datasource.dart';
import '../datasources/remote/firebase_firestore_datasource.dart';
import '../datasources/remote/firebase_notification_datasource.dart';
import '../datasources/remote/local_demo_data_service.dart';
import '../models/user_model.dart';

/// Clean Architecture Data Katmanı: Kimlik ve Kullanıcı Profili Deposu ([UserRepository])
class UserRepository implements IUserRepository {
  final FirebaseAuthDatasource? _authDatasource;
  final FirebaseFirestoreDatasource _firestoreDatasource;
  final FirebaseNotificationDatasource? _notificationDatasource;
  final LocalDemoDataService _demoDataService;

  UserRepository({
    FirebaseAuthDatasource? authDatasource,
    FirebaseFirestoreDatasource? firestoreDatasource,
    FirebaseNotificationDatasource? notificationDatasource,
    LocalDemoDataService? demoDataService,
  }) : _authDatasource =
           authDatasource ??
           (AppMode.isLiveFirebase ? FirebaseAuthDatasource() : null),
       _firestoreDatasource =
           firestoreDatasource ?? FirebaseFirestoreDatasource(),
       _notificationDatasource =
           notificationDatasource ??
           (AppMode.isLiveFirebase ? FirebaseNotificationDatasource() : null),
       _demoDataService = demoDataService ?? LocalDemoDataService.instance;

  @override
  Future<List<UserEntity>> getAllUsers() async {
    final list = await _firestoreDatasource.getAllUsers();
    return list.map((u) => u.toEntity()).toList();
  }

  @override
  Future<UserEntity?> getUserById(String uid) async {
    final model = await _firestoreDatasource.getUserProfile(uid);
    return model?.toEntity();
  }

  @override
  Stream<UserEntity?> watchAuthUser() {
    if (AppMode.isDemoMode || _authDatasource == null) {
      return const Stream<UserEntity?>.empty();
    }

    return _authDatasource.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final profile = await _firestoreDatasource.getUserProfile(
          firebaseUser.uid,
        );
        if (profile != null) {
          return profile.toEntity();
        }
      } catch (_) {}

      return UserEntity(
        uid: firebaseUser.uid,
        name:
            firebaseUser.displayName ??
            firebaseUser.email?.split('@').first ??
            'Kullanıcı',
        email: firebaseUser.email ?? '',
        role: AppStrings.roleB2C,
      );
    });
  }

  @override
  Future<UserEntity?> login({
    required String email,
    required String password,
  }) async {
    if (AppMode.isDemoMode || _authDatasource == null) {
      return getDemoUserByRole(AppStrings.roleB2C);
    }

    try {
      final credential = await _authDatasource.login(email, password);
      final user = credential.user;
      if (user == null) return null;

      await _notificationDatasource?.saveTokenToFirestore();
      final profile = await getUserById(user.uid);
      return profile ??
          UserEntity(
            uid: user.uid,
            name: user.displayName ?? email.split('@').first,
            email: user.email ?? email,
            role: AppStrings.roleB2C,
          );
    } on FirebaseAuthException catch (e) {
      throw AppException(AuthErrorMessages.fromCode(e.code), code: e.code);
    }
  }

  @override
  Future<UserEntity?> register({
    required String email,
    required String password,
    required String name,
    String role = AppStrings.roleB2C,
    String? companyId,
  }) async {
    if (AppMode.isDemoMode || _authDatasource == null) {
      return getDemoUserByRole(role);
    }

    try {
      final credential = await _authDatasource.register(
        email,
        password,
        name: name,
        role: role,
        companyId: companyId,
      );
      final user = credential.user;
      if (user == null) return null;

      await _notificationDatasource?.saveTokenToFirestore();
      final profile = await getUserById(user.uid);
      return profile ??
          UserEntity(
            uid: user.uid,
            name: name,
            email: user.email ?? email,
            role: role,
            companyId: companyId,
            hasB2BAccess: role != AppStrings.roleB2C,
          );
    } on FirebaseAuthException catch (e) {
      throw AppException(AuthErrorMessages.fromCode(e.code), code: e.code);
    }
  }

  @override
  Future<void> logout() async {
    if (AppMode.isDemoMode || _authDatasource == null) return;

    final currentUid = _authDatasource.getCurrentUser()?.uid;
    if (currentUid != null) {
      await _notificationDatasource?.deleteTokenOnLogout(currentUid);
    }
    await _authDatasource.logout();
  }

  @override
  Future<UserEntity?> getDemoUserByRole(String role) async {
    final String uid;
    if (role == AppStrings.roleAdmin) {
      uid = AppStrings.demoAdminUid;
    } else if (role == AppStrings.roleEmployee) {
      uid = AppStrings.demoEmployeeUid;
    } else {
      uid = AppStrings.demoB2CUid;
    }
    final user = _demoDataService.getUserProfile(uid);
    return user?.toEntity();
  }

  @override
  Future<void> createUserProfile(UserEntity user) {
    return _firestoreDatasource.createUserProfile(UserModel.fromEntity(user));
  }

  @override
  Future<void> updateUserProfile(UserEntity user) {
    return _firestoreDatasource.updateUserProfile(UserModel.fromEntity(user));
  }

  @override
  Future<void> updateFcmToken(String uid, String token) {
    return _firestoreDatasource.updateFcmToken(uid, token);
  }

  @override
  Future<void> deleteFcmToken(String uid) {
    return _firestoreDatasource.deleteFcmToken(uid);
  }

  @override
  Future<void> seedDemoData() async {
    await FirestoreSeeder().seedAll();
  }
}
