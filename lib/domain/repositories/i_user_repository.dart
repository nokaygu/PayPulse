import '../../data/models/user_model.dart';

abstract class IUserRepository {
  Future<List<UserModel?>> getAllUsers();
  Future<UserModel?> getUserById(String uid);
  // IUrunServisi soyut sınıfının kapanış parantezi
}
