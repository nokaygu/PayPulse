import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/analytics_and_crashlytics/app_analytics_service.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../models/company_model.dart';
import '../../models/expense_model.dart';
import '../../models/notification_model.dart';
import '../../models/payment_request_model.dart';
import '../../models/safe_recipient_model.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';
import '../../models/wallet_model.dart';

class FirebaseFirestoreDatasource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseFirestoreDatasource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

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

    final normalizedCurrency = currency.toUpperCase();
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
      // Okumalar önce yapılmalıdır (Firestore kuralları gereği)
      final senderSnapshot = await transaction.get(senderWalletRef);
      final receiverSnapshot = await transaction.get(receiverWalletRef);

      if (!senderSnapshot.exists || senderSnapshot.data() == null) {
        throw Exception('Gönderici cüzdanı bulunamadı.');
      }

      if (!receiverSnapshot.exists || receiverSnapshot.data() == null) {
        throw Exception('Alıcı cüzdanı bulunamadı.');
      }

      final senderData = senderSnapshot.data()!;
      final receiverData = receiverSnapshot.data()!;

      // Para birimine göre bakiye alanı seçimi
      final String balanceField;
      final int senderBalance;
      final int receiverBalance;

      if (normalizedCurrency == 'TRY' || normalizedCurrency == 'TL') {
        balanceField = 'balanceTl';
        senderBalance = senderData['balanceTl'] as int? ?? 0;
        receiverBalance = receiverData['balanceTl'] as int? ?? 0;
      } else if (normalizedCurrency == 'USD') {
        balanceField = 'balanceUsd';
        senderBalance = senderData['balanceUsd'] as int? ?? 0;
        receiverBalance = receiverData['balanceUsd'] as int? ?? 0;
      } else if (normalizedCurrency == 'EUR') {
        balanceField = 'balanceEur';
        senderBalance = senderData['balanceEur'] as int? ?? 0;
        receiverBalance = receiverData['balanceEur'] as int? ?? 0;
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

      // Yeni bakiyelerin hesaplanması
      final updatedSenderBalance = senderBalance - amountKurus;
      final updatedReceiverBalance = receiverBalance + amountKurus;

      final txRecord = TransactionModel(
        txId: txId,
        senderId: senderUserId,
        receiverId: receiverUserId,
        amount: amountKurus,
        currency: normalizedCurrency,
        timestamp: DateTime.now(),
        type: 'fast',
        targetIban: targetIban,
      );

      // Atomik yazma işlemleri (aynı anda commit edilir)
      transaction.update(senderWalletRef, {
        balanceField: updatedSenderBalance,
        'lastTxId': txId,
      });
      transaction.update(receiverWalletRef, {
        balanceField: updatedReceiverBalance,
        'lastTxId': txId,
      });
      transaction.set(txRef, txRecord.toJson());

      return txRecord;
    });

    // ================= BİLDİRİM & ANALYTICS TETİKLEME =================
    // Finansal işlem başarıyla tamamlandıktan sonra bildirim üretilir (mükerrerliği önlemek için deterministik ID kullanılır)
    try {
      // 1. Alıcıya para transferi bildirimi
      await createNotification(
        NotificationModel(
          notificationId: 'notif_tx_$txId',
          userId: receiverUserId,
          title: 'Para Transferi Alındı',
          body:
              '${(amountKurus / 100).toStringAsFixed(2)} $normalizedCurrency tutarında FAST transferi cüzdanınıza ulaştı.',
          type: 'transfer_received',
          createdAt: DateTime.now(),
          relatedId: txId,
        ),
      );

      // 2. Şüpheli / Yüksek Tutarlı İşlem Güvenlik Bildirimi (> 50.000 TL = 5.000.000 kuruş)
      if (amountKurus >= 5000000) {
        await createNotification(
          NotificationModel(
            notificationId: 'notif_fraud_$txId',
            userId: senderUserId,
            title: 'Yüksek Tutarlı Transfer Onayı',
            body:
                '${(amountKurus / 100).toStringAsFixed(2)} $normalizedCurrency tutarındaki yüksek FAST transferiniz başarıyla tamamlandı.',
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
              body:
                  'Çalışan tarafından ${(expense.amount / 100).toStringAsFixed(2)} TL tutarında yeni masraf fişi onaya sunuldu.',
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
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('İşlem için oturum açılması gereklidir.');
    }

    final expenseRef = _firestore
        .collection(FirestoreCollections.expenses)
        .doc(expenseId);

    late String resolvedEmployeeId;
    late int resolvedAmount;

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
      resolvedAmount = amount;

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
      final employeeWalletSnapshot = await transaction.get(employeeWalletRef);

      if (!companyWalletSnapshot.exists ||
          companyWalletSnapshot.data() == null) {
        throw Exception(
          'Şirket cüzdanı bulunamadı. Şirket kasası tanımlı olmalıdır.',
        );
      }

      if (!employeeWalletSnapshot.exists ||
          employeeWalletSnapshot.data() == null) {
        throw Exception('Çalışanın cüzdan kaydı bulunamadı.');
      }

      final companyBalanceTl =
          companyWalletSnapshot.data()!['balanceTl'] as int? ?? 0;
      final employeeBalanceTl =
          employeeWalletSnapshot.data()!['balanceTl'] as int? ?? 0;

      // 4. Şirket Bakiyesi Yeterlilik Kontrolü
      if (companyBalanceTl < amount) {
        throw Exception(
          'Şirket cüzdanında yetersiz bakiye! Mevcut Kasa: ${(companyBalanceTl / 100).toStringAsFixed(2)} TL, '
          'Masraf Tutarı: ${(amount / 100).toStringAsFixed(2)} TL',
        );
      }

      // 5. Yeni Bakiyeler
      final updatedCompanyBalance = companyBalanceTl - amount;
      final updatedEmployeeBalance = employeeBalanceTl + amount;

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
      );

      final updateData = <String, dynamic>{
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': currentUser.uid,
      };
      if (accountingCode != null) {
        updateData['accountingCode'] = accountingCode;
      }

      // Atomik Yazmalar:
      transaction.update(expenseRef, updateData);
      transaction.update(companyWalletRef, {
        'balanceTl': updatedCompanyBalance,
      });
      transaction.update(employeeWalletRef, {
        'balanceTl': updatedEmployeeBalance,
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
          body:
              '${(resolvedAmount / 100).toStringAsFixed(2)} TL tutarındaki masraf talebiniz onaylandı ve cüzdan bakiyenize iade edildi.',
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
          body: 'Masraf talebiniz onaylanmadı. Gerekçe: $trimmedReason',
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
  /// Müşteri cüzdanından tutar düşülür, şirket kasasına eklenir. Atomik transaction ile işlenir.
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

    final balanceField = getBalanceField(currency);
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
      final payerWalletSnap = await transaction.get(payerWalletRef);
      final companyWalletSnap = await transaction.get(companyWalletRef);

      if (!payerWalletSnap.exists || payerWalletSnap.data() == null) {
        throw Exception('Müşteri cüzdanı bulunamadı.');
      }
      if (!companyWalletSnap.exists || companyWalletSnap.data() == null) {
        throw Exception('Şirket cüzdanı bulunamadı.');
      }

      final payerBalance = payerWalletSnap.data()![balanceField] as int? ?? 0;
      final companyBalance =
          companyWalletSnap.data()![balanceField] as int? ?? 0;

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
        currency: currency.toUpperCase(),
        timestamp: DateTime.now(),
        type: 'qr_pos_payment',
      );

      transaction.update(payerWalletRef, {
        balanceField: payerBalance - amountKurus,
      });
      transaction.update(companyWalletRef, {
        balanceField: companyBalance + amountKurus,
      });
      transaction.set(txRef, record.toJson());

      return record;
    });

    await AppAnalyticsService.logPosPayment(
      type: 'qr_wallet',
      currency: currency,
    );
    return txRecord;
  }

  /// POS Tahsilatı (2): Kart ile Ödeme (Eğitim Amaçlı POS Simülasyonu)
  /// Dış banka/kredi kartı simülasyonudur; müşteri PayPulse cüzdanından bağımsızdır.
  /// Şirket kasasına doğru para biriminde tahsilat ekler ve slip logu oluşturur.
  Future<TransactionModel> executeCardPosPayment({
    required String companyId,
    required String maskedCardNumber,
    required int amountKurus,
    String currency = 'TRY',
  }) async {
    if (amountKurus <= 0) {
      throw ArgumentError('Tahsilat tutarı sıfırdan büyük olmalıdır.');
    }

    final balanceField = getBalanceField(currency);
    final companyWalletRef = _firestore
        .collection(FirestoreCollections.wallets)
        .doc('wallet_$companyId');

    final txId =
        'tx_pos_card_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
    final txRef = _firestore
        .collection(FirestoreCollections.transactions)
        .doc(txId);

    final txRecord = await _firestore.runTransaction<TransactionModel>((
      transaction,
    ) async {
      final walletSnapshot = await transaction.get(companyWalletRef);
      final currentBalance = walletSnapshot.exists
          ? (walletSnapshot.data()?[balanceField] as int? ?? 0)
          : 0;

      final newBalance = currentBalance + amountKurus;

      final record = TransactionModel(
        txId: txId,
        senderId: 'CARD:$maskedCardNumber',
        receiverId: companyId,
        amount: amountKurus,
        currency: currency.toUpperCase(),
        timestamp: DateTime.now(),
        type: 'card_pos_payment',
      );

      if (walletSnapshot.exists) {
        transaction.update(companyWalletRef, {balanceField: newBalance});
      } else {
        transaction.set(companyWalletRef, {
          'walletId': 'wallet_$companyId',
          'ownerId': companyId,
          'balanceTl': balanceField == 'balanceTl' ? newBalance : 0,
          'balanceUsd': balanceField == 'balanceUsd' ? newBalance : 0,
          'balanceEur': balanceField == 'balanceEur' ? newBalance : 0,
        });
      }

      transaction.set(txRef, record.toJson());
      return record;
    });

    await AppAnalyticsService.logPosPayment(
      type: 'card_pos',
      currency: currency,
    );
    return txRecord;
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

      final amount = requestData['amount'] as int;
      final currency = requestData['currency'] as String? ?? 'TRY';
      final merchantId = requestData['merchantId'] as String;
      final balanceField = getBalanceField(currency);

      final payerWalletRef = _firestore
          .collection(FirestoreCollections.wallets)
          .doc('wallet_$payerUserId');
      final merchantWalletRef = _firestore
          .collection(FirestoreCollections.wallets)
          .doc('wallet_$merchantId');

      final payerWalletSnap = await transaction.get(payerWalletRef);
      final merchantWalletSnap = await transaction.get(merchantWalletRef);

      if (!payerWalletSnap.exists || payerWalletSnap.data() == null) {
        throw Exception('Müşteri cüzdanı bulunamadı.');
      }
      if (!merchantWalletSnap.exists || merchantWalletSnap.data() == null) {
        throw Exception('İşletme cüzdanı bulunamadı.');
      }

      final payerBalance = payerWalletSnap.data()![balanceField] as int? ?? 0;
      final merchantBalance =
          merchantWalletSnap.data()![balanceField] as int? ?? 0;

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
        currency: currency.toUpperCase(),
        timestamp: DateTime.now(),
        type: 'payment_link',
      );

      transaction.update(requestRef, {
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'payerId': payerUserId,
      });
      transaction.update(payerWalletRef, {balanceField: payerBalance - amount});
      transaction.update(merchantWalletRef, {
        balanceField: merchantBalance + amount,
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
    await _firestore
        .collection(FirestoreCollections.notifications)
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Kullanıcının okunmamış bildirim sayısını anlık dinler.
  Stream<int> watchUnreadNotificationCount(String userId) {
    return _firestore
        .collection(FirestoreCollections.notifications)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
