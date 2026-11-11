
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

class FirebaseFirestoreDatasource {

  // Firestore veritabanına erişim sağlar.
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Yeni bir kullanıcı belgesi oluşturur.
  Future<void> addUser(
    String uid,
    String name,
    String email,
  ) async {
    await _firestore.collection('test_users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Kullanıcı belgesini getirir.
  Future<Map<String, dynamic>?> getUser(String uid) async {
    final document = await _firestore
        .collection('test_users')
        .doc(uid)
        .get();

    return document.data();
  }

  // Kullanıcının adını günceller.
  Future<void> updateUser(
    String uid,
    String newName,
  ) async {
    await _firestore
        .collection('test_users')
        .doc(uid)
        .update({
          'name': newName,
        });
  }

  // Kullanıcı belgesini siler.
  Future<void> deleteUser(String uid) async {
    await _firestore
        .collection('test_users')
        .doc(uid)
        .delete();
  }


  // Kullanıcı profilini Firestore'a kaydeder.
  Future<void> createUserProfile(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toJson());
  }

  // Kullanıcı profilini Firestore'dan getirir.
  Future<UserModel?> getUserProfile(String uid) async {
    final document = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    if (!document.exists) {
      return null;
    }

    return UserModel.fromJson(document.data()!);
  }

}
