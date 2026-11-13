import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/analytics_and_crashlytics/app_analytics_service.dart';
import '../../../core/config/app_mode.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../models/company_model.dart';
import '../../models/expense_model.dart';
import '../../models/notification_model.dart';
import '../../models/payment_request_model.dart';
import '../../models/safe_recipient_model.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';
import '../../models/wallet_model.dart';
import 'local_demo_data_service.dart';

class FirebaseFirestoreDatasource {
  final FirebaseFirestore? _customFirestore;
  final FirebaseAuth? _customAuth;

  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;
  FirebaseAuth get _auth => _customAuth ?? FirebaseAuth.instance;

  FirebaseFirestoreDatasource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _customFirestore = firestore,
       _customAuth = auth;

  // =========================================================================
  // 1. GERİYE DÖNÜK TEST METOTLARI (home.dart vb. testlerin bozulmaması için)
  // =========================================================================

  Future<void> addUser(String uid, String name, String email) async {
    await _firestore.collection('test_users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final document = await _firestore.collection('test_users').doc(uid).get();
    return document.data();
  }

  Future<void> updateUser(String uid, String newName) async {
    await _firestore.collection('test_users').doc(uid).update({
      'name': newName,
    });
  }

  Future<void> deleteUser(String uid) async {
    await _firestore.collection('test_users').doc(uid).delete();
  }

  // =========================================================================
  // 2. KULLANICI PROFİLİ VE FCM İŞLEMLERİ
  // =========================================================================

  Future<void> createUserProfile(UserModel user) async {
    await _firestore
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .set(user.toJson());
  }

  Future<UserModel?> getUserProfile(String uid) async {
    if (AppMode.isDemoMode) {
      return LocalDemoDataService.instance.getUserProfile(uid);
    }

    final document = await _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return UserModel.fromJson(document.data()!);
  }

  Future<void> updateFcmToken(String uid, String token) async {
    if (kIsWeb || !Platform.isAndroid) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.uid != uid) {
      throw StateError(
        'Yalnızca oturum açmış kullanıcı kendi token bilgisini güncelleyebilir.',
      );
    }

    await _firestore.collection(FirestoreCollections.users).doc(uid).update({
      'fcmToken': token,
    });
  }

  Future<void> deleteFcmToken(String uid) async {
    // macOS, iOS veya Web platformlarından çıkış yapıldığında
    // kullanıcının gerçek Android cihazına ait FCM token'ı yanlışlıkla silinmemelidir!
    if (kIsWeb || !Platform.isAndroid) {
      debugPrint(
        'macOS/iOS/Web çıkışında Android FCM token silinmesi güvenle atlandı.',
      );
      return;
    }

    final currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.uid != uid) {
      throw StateError(
        'Yalnızca oturum açmış kullanıcı kendi token bilgisini silebilir.',
      );
    }

    await _firestore.collection(FirestoreCollections.users).doc(uid).update({
      'fcmToken': FieldValue.delete(),
    });
  }

  // =========================================================================
  // 3. CÜZDAN VE CANLI DİNLEME (WATCH) İŞLEMLERİ
  // =========================================================================

  Future<void> createWallet(WalletModel wallet) async {
    await _firestore
        .collection(FirestoreCollections.wallets)
        .doc(wallet.walletId)
        .set(wallet.toJson());
  }

  Future<WalletModel?> getWallet(String walletId) async {
    if (AppMode.isDemoMode) {
      return LocalDemoDataService.instance.getWallet(walletId);
    }

    final document = await _firestore
        .collection(FirestoreCollections.wallets)
        .doc(walletId)
        .get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return WalletModel.fromJson(document.data()!);
  }

  /// Kullanıcının kendi cüzdanını canlı dinleyen Stream metodu.
  Stream<WalletModel?> watchWallet(String walletId) {
    if (AppMode.isDemoMode) {
      return LocalDemoDataService.instance.watchWallet(walletId);
    }

    return _firestore
        .collection(FirestoreCollections.wallets)
        .doc(walletId)
        .snapshots()
        .map((document) {
          if (!document.exists || document.data() == null) {
            return null;
          }
          return WalletModel.fromJson(document.data()!);
        });
  }

  /// Kullanıcı ID'si üzerinden cüzdanı canlı dinler.
  Stream<WalletModel?> watchUserWallet(String userId) {
    if (AppMode.isDemoMode) {
      return LocalDemoDataService.instance.watchUserWallet(userId);
    }

    return watchWallet('wallet_$userId');
  }

  // =========================================================================
  // 4. ATOMİK FAST TRANSFERİ (runTransaction)
  // =========================================================================

  /// Şartname Kural 1 & Güvenlik Kuralı: Atomik FAST Para Transferi
  /// Gönderen kullanıcının giriş yapmış kullanıcı olduğu doğrulanır.
  /// Gönderen bakiyesinden düşer, alıcı bakiyesine ekler ve işlem kaydını (TransactionModel)
  /// aynı atomik blok içinde oluşturur. İşlem sonrasında alıcıya deterministik bildirim üretir.
  Future<TransactionModel> executeFastTransfer({
    required String senderUserId,
    required String receiverUserId,
    required int amountKurus,
    String currency = 'TRY',
    String? targetIban,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.uid != senderUserId) {
      throw StateError(
        'Güvenlik İhlali: Gönderici, oturum açmış kullanıcı ile eşleşmiyor.',
      );
    }

    // Doğrulama 1: Pozitif tutar kontrolü (Kuruş kaybı veya negatif transfer engeli)
    if (amountKurus <= 0) {
      throw ArgumentError('Transfer tutarı sıfırdan büyük olmalıdır.');
    }

    // Doğrulama 2: Kendine transfer engeli
    if (senderUserId == receiverUserId) {
      throw ArgumentError('Kendinize para transferi yapamazsınız.');
    }

    var normalizedCurrency = currency.toUpperCase();
    if (normalizedCurrency == 'TL') {
      normalizedCurrency = 'TRY';
    }
    if (!['TRY', 'USD', 'EUR'].contains(normalizedCurrency)) {
      throw ArgumentError('Desteklenmeyen para birimi: $currency');
    }

    final senderWalletRef = _firestore
        .collection(FirestoreCollections.wallets)
        .doc('wallet_$senderUserId');
    final receiverWalletRef = _firestore
        .collection(FirestoreCollections.wallets)
        .doc('wallet_$receiverUserId');

    final txId =
        'tx_fast_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
    final txRef = _firestore
        .collection(FirestoreCollections.transactions)
        .doc(txId);

    final transactionRecord = await _firestore.runTransaction<TransactionModel>((
      transaction,
    ) async {
      // Okuma SADECE gönderici cüzdanı için yapılır (Alıcı bakiyesi gizlilik gereği okunmaz)
      final senderSnapshot = await transaction.get(senderWalletRef);

      if (!senderSnapshot.exists || senderSnapshot.data() == null) {
        throw Exception('Gönderici cüzdanı bulunamadı.');
      }

      final senderData = senderSnapshot.data()!;

      // Para birimine göre bakiye alanı seçimi
      final String balanceField;
      final int senderBalance;

      if (normalizedCurrency == 'TRY') {
        balanceField = 'balanceTl';
        senderBalance = senderData['balanceTl'] as int? ?? 0;
      } else if (normalizedCurrency == 'USD') {
        balanceField = 'balanceUsd';
        senderBalance = senderData['balanceUsd'] as int? ?? 0;
      } else if (normalizedCurrency == 'EUR') {
        balanceField = 'balanceEur';
        senderBalance = senderData['balanceEur'] as int? ?? 0;
      } else {
        throw ArgumentError('Desteklenmeyen para birimi: $currency');
      }

      // Doğrulama 3: Yetersiz bakiye kontrolü (Bakiye negatife düşemez)
      if (senderBalance < amountKurus) {
        throw Exception(
          'Yetersiz bakiye. Mevcut bakiye: ${(senderBalance / 100).toStringAsFixed(2)}, '
          'Transfer tutarı: ${(amountKurus / 100).toStringAsFixed(2)}',
        );
      }

      // Yeni gönderici bakiyesinin hesaplanması
      final updatedSenderBalance = senderBalance - amountKurus;

      final txRecord = TransactionModel(
        txId: txId,
        senderId: senderUserId,
        receiverId: receiverUserId,
        amount: amountKurus,
        currency: normalizedCurrency,
        timestamp: DateTime.now(),
        type: 'fast',
        targetIban: targetIban,
        status: 'Başarılı',
      );

      // Atomik yazma işlemleri: Göndericiden düşülür, alıcıya atomic increment yapılır
      transaction.update(senderWalletRef, {
        balanceField: updatedSenderBalance,
        'lastTxId': txId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(receiverWalletRef, {
        balanceField: FieldValue.increment(amountKurus),
        'lastTxId': txId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(txRef, txRecord.toJson());

      return txRecord;
    });

    // ================= BİLDİRİM & ANALYTICS TETİKLEME =================
    // Finansal işlem başarıyla tamamlandıktan sonra bildirim üretilir (mükerrerliği önlemek için deterministik ID kullanılır)
    try {
      // 1. Alıcıya para transferi bildirimi (Firestore Rules ile tam uyumlu sabit metinler)
      await createNotification(
        NotificationModel(
          notificationId: 'notif_tx_$txId',
          userId: receiverUserId,
          title: 'Para Transferi Alındı',
          body: 'Yeni FAST transferiniz var. İşlem geçmişini kontrol edin.',
          type: 'transfer_received',
          createdAt: DateTime.now(),
          relatedId: txId,
        ),
      );

      // 2. Şüpheli / Yüksek Tutarlı İşlem Güvenlik Bildirimi (Yalnızca TRY ve >= 50.000 TL = 5.000.000 kuruş)
      if (normalizedCurrency == 'TRY' && amountKurus >= 5000000) {
        await createNotification(
          NotificationModel(
            notificationId: 'notif_fraud_$txId',
            userId: senderUserId,
            title: 'Yüksek Tutarlı Transfer Onayı',
            body: 'Yüksek tutarlı FAST işleminizi kontrol edin.',
            type: 'fraud_alert',
            createdAt: DateTime.now(),
            relatedId: txId,
          ),
        );
      }

      await AppAnalyticsService.logWalletTransfer(
        currency: normalizedCurrency,
        amountKurus: amountKurus,
      );
    } catch (e) {
      debugPrint('FAST transfer bildirim oluşturma hatası: $e');
    }

    return transactionRecord;
  }

  /// IBAN üzerinden alıcıyı bularak FAST transferini gerçekleştirir.
  Future<TransactionModel> executeFastTransferByIban({
    required String senderUserId,
    required String targetIban,
    required int amountKurus,
    String currency = 'TRY',
  }) async {
    if (AppMode.isDemoMode) {
      return await LocalDemoDataService.instance.executeFastTransferByIban(
        senderUserId: senderUserId,
        targetIban: targetIban,
        amountKurus: amountKurus,
        currency: currency,
      );
    }

    final recipient = await findRecipientByIban(targetIban);
    if (recipient == null) {
      throw Exception(
        'Belirtilen IBAN numarasına ait geçerli bir hesap bulunamadı.',
      );
    }

    return await executeFastTransfer(
      senderUserId: senderUserId,
      receiverUserId: recipient.userId,
      amountKurus: amountKurus,
      currency: currency,
      targetIban: recipient.iban,
    );
  }

  // =========================================================================
  // 5. GÜVENLİ ALICI ARAMA (Directory Projection: 'recipients' Koleksiyonu)
  // =========================================================================

  /// Yeni kullanıcı veya cüzdan oluştuğunda genel dizine yalnızca güvenli,
  /// maskelenmiş isim ve IBAN kaydı ekler. Bakiye, e-posta veya FCM token İÇERMEZ.
  Future<void> registerRecipient({
    required String iban,
    required String userId,
    required String fullName,
  }) async {
    final normalizedIban = iban.replaceAll(RegExp(r'\s'), '').toUpperCase();
    final masked = maskName(fullName);

    await _firestore
        .collection(FirestoreCollections.recipients)
        .doc(normalizedIban)
        .set({
          'iban': normalizedIban,
          'userId': userId,
          'maskedName': masked,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  /// Güvenli IBAN araması: Başka kullanıcıların users veya wallets belgelerine
  /// dokunmadan, SADECE 'recipients' dizininden teyit amaçlı maskeli isim çeker.
  Future<SafeRecipientModel?> findRecipientByIban(String rawIban) async {
    if (AppMode.isDemoMode) {
      return LocalDemoDataService.instance.findRecipientByIban(rawIban);
    }

    final normalizedIban = rawIban.replaceAll(RegExp(r'\s'), '').toUpperCase();

    final docSnapshot = await _firestore
        .collection(FirestoreCollections.recipients)
        .doc(normalizedIban)
        .get();

    if (!docSnapshot.exists || docSnapshot.data() == null) {
      return null;
    }

    final data = docSnapshot.data()!;
    return SafeRecipientModel(
      userId: data['userId'] as String? ?? '',
      maskedName: data['maskedName'] as String? ?? 'PayPulse Kullanıcısı',
      iban: normalizedIban,
    );
  }

  /// İsim maskeleme yardımcısı: "Deniz Aksoy" -> "D**** A****"
  static String maskName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Kullanıcı';

    final words = trimmed.split(RegExp(r'\s+'));
    return words
        .map((word) {
          if (word.length <= 1) return word;
          return '${word[0]}${'*' * (word.length - 1)}';
        })
        .join(' ');
  }

  // =========================================================================
  // 6. CANLI İŞLEM GEÇMİŞİ (TRANSACTIONS STREAMS)
  // =========================================================================

  Future<TransactionModel?> getTransaction(String txId) async {
    if (AppMode.isDemoMode) {
      return LocalDemoDataService.instance.getTransaction(txId);
    }

    final document = await _firestore
        .collection(FirestoreCollections.transactions)
        .doc(txId)
        .get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return TransactionModel.fromJson(document.data()!);
  }

  Future<List<TransactionModel>> getSentTransactions(String userId) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.transactions)
        .where('senderId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromJson(doc.data()))
        .toList();
  }

  /// Kullanıcının taraf olduğu (hem gelen hem giden) tüm işlemleri canlı dinler.
  Stream<List<TransactionModel>> watchUserTransactions(String userId) {
    if (AppMode.isDemoMode) {
      return LocalDemoDataService.instance.watchUserTransactions(userId);
    }

    return _firestore
        .collection(FirestoreCollections.transactions)
        .where(
          Filter.or(
            Filter('senderId', isEqualTo: userId),
            Filter('receiverId', isEqualTo: userId),
          ),
        )
        .snapshots()
        .map((snapshot) {
          final transactions = snapshot.docs
              .map((doc) => TransactionModel.fromJson(doc.data()))
              .toList();
          transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return transactions;
        });
  }

  /// Yalnızca gönderilen işlemleri canlı dinler.
  Stream<List<TransactionModel>> watchSentTransactions(String userId) {
    if (AppMode.isDemoMode) {
      return LocalDemoDataService.instance.watchSentTransactions(userId);
    }

    return _firestore
        .collection(FirestoreCollections.transactions)
        .where('senderId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => TransactionModel.fromJson(doc.data()))
              .toList();
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return list;
        });
  }

  /// Yalnızca gelen işlemleri canlı dinler.
  Stream<List<TransactionModel>> watchReceivedTransactions(String userId) {
    if (AppMode.isDemoMode) {
      return LocalDemoDataService.instance.watchReceivedTransactions(userId);
    }

    return _firestore
        .collection(FirestoreCollections.transactions)
        .where('receiverId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => TransactionModel.fromJson(doc.data()))
              .toList();
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return list;
        });
  }

  // =========================================================================
  // 7. MASRAF YÖNETİMİ VE ONAY/RET YAŞAM DÖNGÜSÜ
  // =========================================================================

  Future<void> createExpense(ExpenseModel expense) async {
    if (AppMode.isDemoMode) {
      return await LocalDemoDataService.instance.createExpense(expense);
    }

    final currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.uid != expense.employeeId) {
      throw StateError(
        'Çalışan yalnızca kendi adına masraf talebi oluşturabilir.',
      );
    }

    if (expense.amount <= 0) {
      throw ArgumentError('Masraf tutarı sıfırdan büyük olmalıdır.');
    }

    if (expense.vatAmount < 0 || expense.vatAmount > expense.amount) {
      throw ArgumentError(
        'KDV tutarı negatif olamaz veya toplam tutarı aşamaz.',
      );
    }

    await _firestore
        .collection(FirestoreCollections.expenses)
        .doc(expense.expenseId)
        .set(expense.toJson());

    // Şirket yöneticilerine yeni masraf bildirimi oluşturma (Deterministik ID)
    try {
      final companyDoc = await _firestore
          .collection(FirestoreCollections.companies)
          .doc(expense.companyId)
          .get();

      if (companyDoc.exists && companyDoc.data() != null) {
        final adminIds = List<String>.from(
          companyDoc.data()!['adminIds'] ?? [],
        );
        for (final adminId in adminIds) {
          await createNotification(
            NotificationModel(
              notificationId: 'notif_exp_created_${expense.expenseId}_$adminId',
              userId: adminId,
              title: 'Yeni Masraf Onay Talebi',
              body: 'Yeni bir masraf talebi var. Masraf ekranını kontrol edin.',
              type: 'expense_created',
              createdAt: DateTime.now(),
              relatedId: expense.expenseId,
            ),
          );
        }
      }

      await AppAnalyticsService.logExpenseCreated(amountKurus: expense.amount);
    } catch (e) {
      debugPrint('Masraf oluşturma bildirimi hatası: $e');
    }
  }

  Future<ExpenseModel?> getExpense(String expenseId) async {
    if (AppMode.isDemoMode) {
      return LocalDemoDataService.instance.getExpense(expenseId);
    }

    final document = await _firestore
        .collection(FirestoreCollections.expenses)
        .doc(expenseId)
        .get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return ExpenseModel.fromJson(document.data()!);
  }

  /// Çalışanın kendi masraflarını anlık dinler.
  Stream<List<ExpenseModel>> watchEmployeeExpenses(String employeeId) {
    if (AppMode.isDemoMode) {
      return LocalDemoDataService.instance.watchEmployeeExpenses(employeeId);
    }

    return _firestore
        .collection(FirestoreCollections.expenses)
        .where('employeeId', isEqualTo: employeeId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ExpenseModel.fromJson(doc.data()))
              .toList();
        });
  }

  /// Şirket yöneticisinin şirketine ait tüm masrafları anlık dinlemesi.
  Stream<List<ExpenseModel>> watchCompanyExpenses(String companyId) {
    if (AppMode.isDemoMode) {
      return LocalDemoDataService.instance.watchCompanyExpenses(companyId);
    }

    return _firestore
        .collection(FirestoreCollections.expenses)
        .where('companyId', isEqualTo: companyId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ExpenseModel.fromJson(doc.data()))
              .toList();
        });
  }

  /// Şartname Kural 3: Şirket Masraf Onay Masası (İdempotent & Atomik Çift Taraflı Transfer)
  /// Şirket kasasından düşer, çalışana ekler, mükerrer onayı engeller ve yönetici yetkisini doğrular.
  /// Onay sonrasında çalışana bildirim üretir.
  Future<void> approveExpense({
    required String expenseId,
    String? accountingCode,
  }) async {
    if (AppMode.isDemoMode) {
      return await LocalDemoDataService.instance.approveExpense(
        expenseId: expenseId,
        accountingCode: accountingCode,
      );
    }

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('İşlem için oturum açılması gereklidir.');
    }

    final expenseRef = _firestore
        .collection(FirestoreCollections.expenses)
        .doc(expenseId);

    late String resolvedEmployeeId;

    await _firestore.runTransaction((transaction) async {
      final expenseSnapshot = await transaction.get(expenseRef);

      if (!expenseSnapshot.exists || expenseSnapshot.data() == null) {
        throw Exception('Masraf kaydı bulunamadı.');
      }

      final expenseData = expenseSnapshot.data()!;
      final currentStatus = expenseData['status'] as String? ?? '';

      // 1. İdempotency Koruması: Sadece 'pending' masraflar onaylanabilir
      if (currentStatus != 'pending') {
        throw StateError(
          'Bu masraf daha önce işleme alınmış (Mevcut Durum: $currentStatus). Yeniden onaylanamaz.',
        );
      }

      final companyId = expenseData['companyId'] as String;
      final employeeId = expenseData['employeeId'] as String;
      final amount = expenseData['amount'] as int;
      resolvedEmployeeId = employeeId;

      // 2. Şirket Yöneticisi Yetki Doğrulaması
      final companyRef = _firestore
          .collection(FirestoreCollections.companies)
          .doc(companyId);
      final companySnapshot = await transaction.get(companyRef);

      if (!companySnapshot.exists || companySnapshot.data() == null) {
        throw Exception('İlgili şirket kaydı bulunamadı.');
      }

      final adminIds = List<String>.from(
        companySnapshot.data()!['adminIds'] ?? [],
      );
      if (!adminIds.contains(currentUser.uid)) {
        throw StateError(
          'Yetkisiz İşlem: Bu şirketin masraflarını yalnızca yetkili yöneticileri onaylayabilir.',
        );
      }

      // 3. Cüzdan Okumaları
      final companyWalletRef = _firestore
          .collection(FirestoreCollections.wallets)
          .doc('wallet_$companyId');
      final employeeWalletRef = _firestore
          .collection(FirestoreCollections.wallets)
          .doc('wallet_$employeeId');

      final companyWalletSnapshot = await transaction.get(companyWalletRef);

      if (!companyWalletSnapshot.exists ||
          companyWalletSnapshot.data() == null) {
        throw Exception(
          'Şirket cüzdanı bulunamadı. Şirket kasası tanımlı olmalıdır.',
        );
      }

      final companyBalanceTl =
          companyWalletSnapshot.data()!['balanceTl'] as int? ?? 0;

      // 4. Şirket Bakiyesi Yeterlilik Kontrolü
      if (companyBalanceTl < amount) {
        throw Exception(
          'Şirket cüzdanında yetersiz bakiye! Mevcut Kasa: ${(companyBalanceTl / 100).toStringAsFixed(2)} TL, '
          'Masraf Tutarı: ${(amount / 100).toStringAsFixed(2)} TL',
        );
      }

      // 5. Yeni Şirket Bakiyesi
      final updatedCompanyBalance = companyBalanceTl - amount;

      final txId =
          'tx_exp_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
      final txRef = _firestore
          .collection(FirestoreCollections.transactions)
          .doc(txId);

      final transactionRecord = TransactionModel(
        txId: txId,
        senderId: companyId,
        receiverId: employeeId,
        amount: amount,
        currency: 'TRY',
        timestamp: DateTime.now(),
        type: 'expense_reimbursement',
        relatedId: expenseId,
        status: 'Başarılı',
      );

      final updateData = <String, dynamic>{
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': currentUser.uid,
        'txId': txId,
      };
      if (accountingCode != null) {
        updateData['accountingCode'] = accountingCode;
      }

      // Atomik Yazmalar: Şirket kasasından düşülür, personel cüzdanına FieldValue.increment yapılır
      transaction.update(expenseRef, updateData);
      transaction.update(companyWalletRef, {
        'balanceTl': updatedCompanyBalance,
        'lastTxId': txId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(employeeWalletRef, {
        'balanceTl': FieldValue.increment(amount),
        'lastTxId': txId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(txRef, transactionRecord.toJson());
    });

    // Çalışana avans/iade bildirimi üretme (Deterministik ID)
    try {
      await createNotification(
        NotificationModel(
          notificationId: 'notif_exp_app_$expenseId',
          userId: resolvedEmployeeId,
          title: 'Masrafınız Onaylandı',
          body: 'Masraf talebiniz onaylandı. Masraf ekranını kontrol edin.',
          type: 'expense_approved',
          createdAt: DateTime.now(),
          relatedId: expenseId,
        ),
      );

      await AppAnalyticsService.logExpenseApproved(status: 'approved');
    } catch (e) {
      debugPrint('Masraf onay bildirimi hatası: $e');
    }
  }

  /// Masraf Reddetme: Transaction içinde yönetici yetkisini doğrular, gerekçeli ret uygular ve bildirim üretir.
  Future<void> rejectExpense({
    required String expenseId,
    required String reason,
  }) async {
    if (AppMode.isDemoMode) {
      return await LocalDemoDataService.instance.rejectExpense(
        expenseId: expenseId,
        rejectReason: reason,
      );
    }

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('İşlem için oturum açılması gereklidir.');
    }

    final trimmedReason = reason.trim();
    if (trimmedReason.isEmpty) {
      throw ArgumentError('Masraf red gerekçesi boş bırakılamaz.');
    }

    final expenseRef = _firestore
        .collection(FirestoreCollections.expenses)
        .doc(expenseId);

    late String resolvedEmployeeId;

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(expenseRef);
      if (!snapshot.exists || snapshot.data() == null) {
        throw Exception('Masraf kaydı bulunamadı.');
      }

      final expenseData = snapshot.data()!;
      final currentStatus = expenseData['status'] as String? ?? '';
      if (currentStatus != 'pending') {
        throw StateError(
          'Yalnızca onay bekleyen masraflar reddedilebilir. Mevcut Durum: $currentStatus',
        );
      }

      final companyId = expenseData['companyId'] as String;
      resolvedEmployeeId = expenseData['employeeId'] as String;

      final companyRef = _firestore
          .collection(FirestoreCollections.companies)
          .doc(companyId);
      final companySnapshot = await transaction.get(companyRef);

      if (!companySnapshot.exists || companySnapshot.data() == null) {
        throw Exception('İlgili şirket kaydı bulunamadı.');
      }

      final adminIds = List<String>.from(
        companySnapshot.data()!['adminIds'] ?? [],
      );
      if (!adminIds.contains(currentUser.uid)) {
        throw StateError(
          'Yetkisiz İşlem: Masrafı yalnızca şirket yöneticileri reddedebilir.',
        );
      }

      transaction.update(expenseRef, {
        'status': 'rejected',
        'rejectReason': trimmedReason,
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectedBy': currentUser.uid,
      });
    });

    // Çalışana gerekçeli ret bildirimi oluşturma (Deterministik ID)
    try {
      await createNotification(
        NotificationModel(
          notificationId: 'notif_exp_rej_$expenseId',
          userId: resolvedEmployeeId,
          title: 'Masraf Talebiniz Reddedildi',
          body: 'Masraf talebiniz reddedildi. Masraf ekranını kontrol edin.',
          type: 'expense_rejected',
          createdAt: DateTime.now(),
          relatedId: expenseId,
        ),
      );

      await AppAnalyticsService.logExpenseRejected();
    } catch (e) {
      debugPrint('Masraf ret bildirimi hatası: $e');
    }
  }

  // =========================================================================
  // 8. ŞİRKET, SANAL POS VE TAHSİLAT TALEBİ İŞLEMLERİ
  // =========================================================================

  Future<void> createCompany(CompanyModel company) async {
    await _firestore
        .collection(FirestoreCollections.companies)
        .doc(company.companyId)
        .set(company.toJson());
  }

  Future<CompanyModel?> getCompany(String companyId) async {
    if (AppMode.isDemoMode) {
      return LocalDemoDataService.instance.getCompany(companyId);
    }

    final document = await _firestore
        .collection(FirestoreCollections.companies)
        .doc(companyId)
        .get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return CompanyModel.fromJson(document.data()!);
  }

  /// Yardımcı: Para birimine karşılık gelen cüzdan bakiye alanını döndürür.
  static String getBalanceField(String currency) {
    final c = currency.toUpperCase();
    if (c == 'USD') return 'balanceUsd';
    if (c == 'EUR') return 'balanceEur';
    return 'balanceTl';
  }

  /// POS Tahsilatı (1): QR Kod ile Cüzdandan Ödeme
  /// Müşteri cüzdanından tutar düşülür, şirket kasasına atomic increment ile eklenir.
  Future<TransactionModel> executeQrWalletPayment({
    required String companyId,
    required String payerUserId,
    required int amountKurus,
    String currency = 'TRY',
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.uid != payerUserId) {
      throw StateError(
        'Yetkisiz Ödeme: Ödeme yapan kullanıcı oturum sahibi ile uyuşmuyor.',
      );
    }

    if (amountKurus <= 0) {
      throw ArgumentError('Tahsilat tutarı sıfırdan büyük olmalıdır.');
    }

    var normalizedCurrency = currency.toUpperCase();
    if (normalizedCurrency == 'TL') {
      normalizedCurrency = 'TRY';
    }
    if (!['TRY', 'USD', 'EUR'].contains(normalizedCurrency)) {
      throw ArgumentError('Desteklenmeyen para birimi: $currency');
    }

    final balanceField = getBalanceField(normalizedCurrency);
    final payerWalletRef = _firestore
        .collection(FirestoreCollections.wallets)
        .doc('wallet_$payerUserId');
    final companyWalletRef = _firestore
        .collection(FirestoreCollections.wallets)
        .doc('wallet_$companyId');

    final txId =
        'tx_pos_qr_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
    final txRef = _firestore
        .collection(FirestoreCollections.transactions)
        .doc(txId);

    final txRecord = await _firestore.runTransaction<TransactionModel>((
      transaction,
    ) async {
      // Okuma SADECE müşteri cüzdanı için yapılır (Şirket cüzdanı gizlilik ve kural gereği okunmaz)
      final payerWalletSnap = await transaction.get(payerWalletRef);

      if (!payerWalletSnap.exists || payerWalletSnap.data() == null) {
        throw Exception('Müşteri cüzdanı bulunamadı.');
      }

      final payerBalance = payerWalletSnap.data()![balanceField] as int? ?? 0;

      if (payerBalance < amountKurus) {
        throw Exception(
          'Yetersiz müşteri bakiyesi. İşlem gerçekleştirilemedi.',
        );
      }

      final record = TransactionModel(
        txId: txId,
        senderId: payerUserId,
        receiverId: companyId,
        amount: amountKurus,
        currency: normalizedCurrency,
        timestamp: DateTime.now(),
        type: 'qr_pos_payment',
        status: 'Başarılı',
      );

      transaction.update(payerWalletRef, {
        balanceField: payerBalance - amountKurus,
        'lastTxId': txId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(companyWalletRef, {
        balanceField: FieldValue.increment(amountKurus),
        'lastTxId': txId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(txRef, record.toJson());

      return record;
    });

    await AppAnalyticsService.logPosPayment(
      type: 'qr_wallet',
      currency: normalizedCurrency,
    );
    return txRecord;
  }

  /// POS Tahsilatı (2): Kart ile Ödeme (Eğitim Amaçlı POS Simülasyonu)
  /// Firestore güvenlik kuralları istemciden karşılıksız bakiye üretilmesini engeller.
  /// Bu işlem güvenli backend (Webhook / Cloud Functions) gerektirir; istemcide yerel slip simülasyonu olarak çalışır.
  Future<TransactionModel> executeCardPosPayment({
    required String companyId,
    required String maskedCardNumber,
    required int amountKurus,
    String currency = 'TRY',
  }) async {
    if (AppMode.isDemoMode) {
      return await LocalDemoDataService.instance.executeCardPosPayment(
        companyId: companyId,
        maskedCardNumber: maskedCardNumber,
        amountKurus: amountKurus,
        currency: currency,
      );
    }

    if (amountKurus <= 0) {
      throw ArgumentError('Tahsilat tutarı sıfırdan büyük olmalıdır.');
    }

    var normalizedCurrency = currency.toUpperCase();
    if (normalizedCurrency == 'TL') {
      normalizedCurrency = 'TRY';
    }
    if (!['TRY', 'USD', 'EUR'].contains(normalizedCurrency)) {
      throw ArgumentError('Desteklenmeyen para birimi: $currency');
    }

    final txId =
        'tx_pos_card_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';

    final record = TransactionModel(
      txId: txId,
      senderId: 'CARD:$maskedCardNumber',
      receiverId: companyId,
      amount: amountKurus,
      currency: normalizedCurrency,
      timestamp: DateTime.now(),
      type: 'card_pos_payment',
      title: 'Sanal POS Kart Tahsilatı (Simülasyon)',
      category: 'POS Tahsilat',
      isExpense: false,
      status: 'Başarılı',
    );

    await AppAnalyticsService.logPosPayment(
      type: 'card_pos',
      currency: normalizedCurrency,
    );
    return record;
  }

  Future<void> createPaymentRequest(PaymentRequestModel request) async {
    await _firestore
        .collection(FirestoreCollections.paymentRequests)
        .doc(request.requestId)
        .set(request.toJson());
  }

  Future<PaymentRequestModel?> getPaymentRequest(String requestId) async {
    final document = await _firestore
        .collection(FirestoreCollections.paymentRequests)
        .doc(requestId)
        .get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return PaymentRequestModel.fromJson(document.data()!);
  }

  /// Ödeme Talebini Cüzdan ile Tamamlama (Tek Seferlik Ödeme Akışı)
  /// Talep durumu 'pending' ise müşteriden düşer, şirkete aktarır ve durumu 'completed' yapar.
  Future<TransactionModel> completePaymentRequestWithWallet({
    required String requestId,
    required String payerUserId,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.uid != payerUserId) {
      throw StateError(
        'Yetkisiz İşlem: Ödemeyi yalnızca oturum sahibi müşteri gerçekleştirebilir.',
      );
    }

    final requestRef = _firestore
        .collection(FirestoreCollections.paymentRequests)
        .doc(requestId);

    final txRecord = await _firestore.runTransaction<TransactionModel>((
      transaction,
    ) async {
      final requestSnap = await transaction.get(requestRef);
      if (!requestSnap.exists || requestSnap.data() == null) {
        throw Exception('Ödeme talebi bulunamadı.');
      }

      final requestData = requestSnap.data()!;
      final status = requestData['status'] as String? ?? '';
      if (status != 'pending') {
        throw StateError(
          'Bu ödeme talebi daha önce tamamlanmış veya iptal edilmiş.',
        );
      }

      final assignedPayerId = requestData['payerId'] as String?;
      if (assignedPayerId != null &&
          assignedPayerId.isNotEmpty &&
          assignedPayerId != payerUserId) {
        throw StateError(
          'Bu ödeme talebi yalnızca belirlenen kullanıcı tarafından ödenebilir.',
        );
      }

      final amount = requestData['amount'] as int;
      final rawCurrency = requestData['currency'] as String? ?? 'TRY';
      var normalizedCurrency = rawCurrency.toUpperCase();
      if (normalizedCurrency == 'TL') {
        normalizedCurrency = 'TRY';
      }
      if (!['TRY', 'USD', 'EUR'].contains(normalizedCurrency)) {
        throw ArgumentError('Desteklenmeyen para birimi: $rawCurrency');
      }

      final balanceField = getBalanceField(normalizedCurrency);
      final merchantId = requestData['merchantId'] as String;

      final payerWalletRef = _firestore
          .collection(FirestoreCollections.wallets)
          .doc('wallet_$payerUserId');
      final merchantWalletRef = _firestore
          .collection(FirestoreCollections.wallets)
          .doc('wallet_$merchantId');

      final payerWalletSnap = await transaction.get(payerWalletRef);

      if (!payerWalletSnap.exists || payerWalletSnap.data() == null) {
        throw Exception('Müşteri cüzdanı bulunamadı.');
      }

      final payerBalance = payerWalletSnap.data()![balanceField] as int? ?? 0;

      if (payerBalance < amount) {
        throw Exception('Yetersiz bakiye. Ödeme talebi gerçekleştirilemedi.');
      }

      final txId =
          'tx_paylink_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
      final txRef = _firestore
          .collection(FirestoreCollections.transactions)
          .doc(txId);

      final record = TransactionModel(
        txId: txId,
        senderId: payerUserId,
        receiverId: merchantId,
        amount: amount,
        currency: normalizedCurrency,
        timestamp: DateTime.now(),
        type: 'payment_link',
        relatedId: requestId,
        status: 'Başarılı',
      );

      transaction.update(requestRef, {
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'payerId': payerUserId,
        'txId': txId,
      });
      transaction.update(payerWalletRef, {
        balanceField: payerBalance - amount,
        'lastTxId': txId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(merchantWalletRef, {
        balanceField: FieldValue.increment(amount),
        'lastTxId': txId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(txRef, record.toJson());

      return record;
    });

    await AppAnalyticsService.logPosPayment(
      type: 'payment_link',
      currency: 'TRY',
    );
    return txRecord;
  }

  // =========================================================================
  // 9. UYGULAMA İÇİ BİLDİRİMLER (NOTIFICATIONS) - MACOS & CROSS-PLATFORM
  // =========================================================================

  /// Yeni bildirim oluşturur. Deterministik ID kullanımı sayesinde mükerrer bildirim engellenir.
  Future<void> createNotification(NotificationModel notification) async {
    await _firestore
        .collection(FirestoreCollections.notifications)
        .doc(notification.notificationId)
        .set(notification.toJson(), SetOptions(merge: true));
  }

  /// Kullanıcının bildirimlerini gerçek zamanlı dinler (En yeniden en eskiye).
  Stream<List<NotificationModel>> watchUserNotifications(String userId) {
    if (AppMode.isDemoMode) {
      return LocalDemoDataService.instance.watchUserNotifications(userId);
    }

    return _firestore
        .collection(FirestoreCollections.notifications)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => NotificationModel.fromJson(doc.data()))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  /// Bildirimi okundu olarak işaretler (isRead: true).
  Future<void> markNotificationAsRead(String notificationId) async {
    if (AppMode.isDemoMode) {
      return await LocalDemoDataService.instance.markNotificationAsRead(
        notificationId,
      );
    }

    await _firestore
        .collection(FirestoreCollections.notifications)
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Kullanıcının okunmamış bildirim sayısını anlık dinler.
  Stream<int> watchUnreadNotificationCount(String userId) {
    if (AppMode.isDemoMode) {
      return LocalDemoDataService.instance.watchUnreadNotificationCount(userId);
    }

    return _firestore
        .collection(FirestoreCollections.notifications)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
