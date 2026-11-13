import '../entities/user_entity.dart';

/// Clean Architecture Domain Katmanı: Kimlik ve Kullanıcı Profili Sözleşmesi
abstract class IUserRepository {
  Future<List<UserEntity>> getAllUsers();
  Future<UserEntity?> getUserById(String uid);
  Stream<UserEntity?> watchAuthUser();
  Future<UserEntity?> login({
    required String email,
    required String password,
  });
  Future<UserEntity?> register({
    required String email,
    required String password,
    required String name,
    String role = 'b2c',
    String? companyId,
  });
  Future<void> logout();
  Future<UserEntity?> getDemoUserByRole(String role);
  Future<void> createUserProfile(UserEntity user);
  Future<void> updateUserProfile(UserEntity user);
  Future<void> updateFcmToken(String uid, String token);
  Future<void> deleteFcmToken(String uid);
  Future<void> seedDemoData();
}
