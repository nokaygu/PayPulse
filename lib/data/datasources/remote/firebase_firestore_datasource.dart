import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user_model.dart';
import '../../models/wallet_model.dart';
import '../../models/expense_model.dart';
import '../../models/transaction_model.dart';
import '../../models/company_model.dart';

class FirebaseFirestoreDatasource {
  // Firestore veritabanına erişim sağlar.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Yeni bir kullanıcı belgesi oluşturur.
  Future<void> addUser(String uid, String name, String email) async {
    await _firestore.collection('test_users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Kullanıcı belgesini getirir.
  Future<Map<String, dynamic>?> getUser(String uid) async {
    final document = await _firestore.collection('test_users').doc(uid).get();

    return document.data();
  }

  // Kullanıcının adını günceller.
  Future<void> updateUser(String uid, String newName) async {
    await _firestore.collection('test_users').doc(uid).update({
      'name': newName,
    });
  }

  // Kullanıcı belgesini siler.
  Future<void> deleteUser(String uid) async {
    await _firestore.collection('test_users').doc(uid).delete();
  }

  // Kullanıcı profilini Firestore'a kaydeder.
  Future<void> createUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toJson());
  }

  // Kullanıcı profilini Firestore'dan getirir.
  Future<UserModel?> getUserProfile(String uid) async {
    final document = await _firestore.collection('users').doc(uid).get();

    if (!document.exists) {
      return null;
    }

    return UserModel.fromJson(document.data()!);
  }

  // Yeni bir cüzdan belgesini Firestore'a kaydeder.
  Future<void> createWallet(WalletModel wallet) async {
    await _firestore
        .collection('wallets')
        .doc(wallet.walletId)
        .set(wallet.toJson());
  }

  // Firestore'dan cüzdan bilgilerini getirir.
  Future<WalletModel?> getWallet(String walletId) async {
    final document = await _firestore.collection('wallets').doc(walletId).get();

    if (!document.exists) {
      return null;
    }

    return WalletModel.fromJson(document.data()!);
  }

  // Kullanıcının FCM token değerini Firestore'a kaydeder.
  Future<void> updateFcmToken(String uid, String token) async {
    await _firestore.collection('users').doc(uid).update({'fcmToken': token});
  }

  // Kullanıcı çıkış yaptığında FCM token alanını siler.
  Future<void> deleteFcmToken(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'fcmToken': FieldValue.delete(),
    });
  }

  // Yeni masraf talebini Firestore'a kaydeder.
  Future<void> createExpense(ExpenseModel expense) async {
    await _firestore
        .collection('expenses')
        .doc(expense.expenseId)
        .set(expense.toJson());
  }

  // Masraf talebini Firestore'dan getirir.
  Future<ExpenseModel?> getExpense(String expenseId) async {
    final document = await _firestore
        .collection('expenses')
        .doc(expenseId)
        .get();

    if (!document.exists) {
      return null;
    }

    return ExpenseModel.fromJson(document.data()!);
  }

  // Çalışanın masraf taleplerini anlık dinler.
  Stream<List<ExpenseModel>> watchEmployeeExpenses(String employeeId) {
    return _firestore
        .collection('expenses')
        .where('employeeId', isEqualTo: employeeId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ExpenseModel.fromJson(doc.data()))
              .toList();
        });
  }

  // İşlem kaydını Firestore'dan getirir.
  Future<TransactionModel?> getTransaction(String txId) async {
    final document = await _firestore
        .collection('transactions')
        .doc(txId)
        .get();

    if (!document.exists) {
      return null;
    }

    return TransactionModel.fromJson(document.data()!);
  }

  // Kullanıcının gönderdiği işlemleri getirir.
  Future<List<TransactionModel>> getSentTransactions(String userId) async {
    final snapshot = await _firestore
        .collection('transactions')
        .where('senderId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromJson(doc.data()))
        .toList();
  }

  // Yeni şirket bilgilerini Firestore'a kaydeder.
  Future<void> createCompany(CompanyModel company) async {
    await _firestore
        .collection('companies')
        .doc(company.companyId)
        .set(company.toJson());
  }

  // Şirket bilgilerini Firestore'dan getirir.
  Future<CompanyModel?> getCompany(String companyId) async {
    final document = await _firestore
        .collection('companies')
        .doc(companyId)
        .get();

    if (!document.exists) {
      return null;
    }

    return CompanyModel.fromJson(document.data()!);
  }
}
