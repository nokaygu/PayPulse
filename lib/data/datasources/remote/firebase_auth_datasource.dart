import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/utils/iban_generator.dart';
import '../../models/user_model.dart';
import '../../models/wallet_model.dart';
import 'firebase_firestore_datasource.dart';

class FirebaseAuthDatasource {
  // Firebase Authentication servisine erişim sağlar.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firestore kullanıcı profili ve cüzdan işlemleri için kullanılır.
  final FirebaseFirestoreDatasource _firestoreService =
      FirebaseFirestoreDatasource();

  // E-posta ve şifre ile yeni kullanıcı oluşturur.
  // Başarılı olursa Firestore'a kullanıcı profilini, sıfır bakiyeli cüzdanı ve
  // güvenli alıcı dizini (recipients) kaydını ekler.
  Future<UserCredential> register(
    String email,
    String password, {
    String name = 'Kullanıcı',
    String role = 'b2c',
    String? companyId,
  }) async {
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
        role: role,
        companyId: companyId,
      );

      await _firestoreService.createUserProfile(userModel);

      // Kullanıcıya ait cüzdan kontrolü: Mevcut cüzdanın üzerine yazılmasını engelle.
      final walletId = 'wallet_${user.uid}';
      final existingWallet = await _firestoreService.getWallet(walletId);

      if (existingWallet == null) {
        final generatedIban = IbanGenerator.generateForUser(user.uid);
        final newWallet = WalletModel(
          walletId: walletId,
          ownerId: user.uid,
          balanceTl: 0,
          balanceUsd: 0,
          balanceEur: 0,
          iban: generatedIban,
        );

        await _firestoreService.createWallet(newWallet);

        // Güvenli alıcı rehberine (recipients) sadece maskeli isim ve IBAN ekle
        await _firestoreService.registerRecipient(
          iban: generatedIban,
          userId: user.uid,
          fullName: name,
        );
      }
    }

    return userCredential;
  }

  // E-posta ve şifre ile giriş yapar.
  // Giriş sonrasında kullanıcının cüzdanı yoksa (eski hesaplar için) güvenle oluşturur.
  Future<UserCredential> login(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      final walletId = 'wallet_${user.uid}';
      final existingWallet = await _firestoreService.getWallet(walletId);
      if (existingWallet == null) {
        final generatedIban = IbanGenerator.generateForUser(user.uid);
        final newWallet = WalletModel(
          walletId: walletId,
          ownerId: user.uid,
          balanceTl: 0,
          balanceUsd: 0,
          balanceEur: 0,
          iban: generatedIban,
        );
        await _firestoreService.createWallet(newWallet);
        await _firestoreService.registerRecipient(
          iban: generatedIban,
          userId: user.uid,
          fullName: user.displayName ?? 'PayPulse Kullanıcısı',
        );
      }
    }

    return userCredential;
  }

  // Kullanıcının oturumunu kapatır.
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Giriş yapmış mevcut kullanıcıyı getirir.
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Kullanıcının oturum durumunu anlık dinler.
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}
