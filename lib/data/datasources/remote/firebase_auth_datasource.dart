import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthDatasource {
  // Firebase Authentication servisine erişim sağlar.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // E-posta ve şifre ile yeni kullanıcı oluşturur.
  Future<UserCredential> register(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  // E-posta ve şifre ile giriş yapar.
  Future<UserCredential> login(String email, String password) async {
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
