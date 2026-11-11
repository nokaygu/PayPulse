
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user_model.dart';
import 'firebase_firestore_datasource.dart';

class FirebaseAuthDatasource {
  // Firebase Authentication servisine erişim sağlar.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firestore kullanıcı profili işlemleri için kullanılır.
  final FirebaseFirestoreDatasource _firestoreService =
      FirebaseFirestoreDatasource();

  // E-posta ve şifre ile yeni kullanıcı oluşturur.
  // Başarılı olursa Firestore'a kullanıcı profilini kaydeder.
  Future<UserCredential> register(
    String email,
    String password, {
    String name = 'Kullanıcı',
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        final userModel = UserModel(
          uid: user.uid,
          name: name,
          email: user.email ?? email,
          role: 'b2c',
          companyId: null,
        );

        await _firestoreService.createUserProfile(userModel);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  // E-posta ve şifre ile giriş yapar.
  Future<UserCredential> login(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Kullanıcının oturumunu kapatır.
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Giriş yapmış kullanıcıyı döndürür.
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Kullanıcının giriş ve çıkış durumunu dinler.
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }


}
