import 'dart:async';
import 'dart:math';

import '../../../core/utils/firestore_seeder.dart';
import '../../models/company_model.dart';
import '../../models/expense_model.dart';
import '../../models/notification_model.dart';
import '../../models/safe_recipient_model.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';
import '../../models/wallet_model.dart';

/// PayPulse Yerel Demo Veri Servisi (In-Memory Centralized Reactive Service)
/// macOS ve çevrimdışı sunum ortamında Apple hesabı, Keychain ve Firebase bağlantısı
/// gerektirmeden tam işlevli, reaktif ve tutarlı finansal simülasyon sağlar.
class LocalDemoDataService {
  LocalDemoDataService._internal() {
    _initData();
  }

  static final LocalDemoDataService instance = LocalDemoDataService._internal();

  // ================= 1. REAKTİF STREAM CONTROLLER'LAR =================
  final StreamController<Map<String, WalletModel>> _walletsController =
      StreamController<Map<String, WalletModel>>.broadcast();
  final StreamController<List<TransactionModel>> _transactionsController =
      StreamController<List<TransactionModel>>.broadcast();
  final StreamController<List<ExpenseModel>> _expensesController =
      StreamController<List<ExpenseModel>>.broadcast();
  final StreamController<List<NotificationModel>> _notificationsController =
      StreamController<List<NotificationModel>>.broadcast();

  // ================= 2. MERKEZİ BELLEK VERİLERİ (STATE) =================
  final Map<String, UserModel> _users = {};
  final Map<String, CompanyModel> _companies = {};
  final Map<String, WalletModel> _wallets = {};
  final Map<String, SafeRecipientModel> _recipients = {};
  final List<TransactionModel> _transactions = [];
  final List<ExpenseModel> _expenses = [];
  final List<NotificationModel> _notifications = [];

  // ================= 3. BAŞLANGIÇ VERİLERİNİN YÜKLENMESİ =================
  void _initData() {
    // 1. Kullanıcılar
    // Bireysel Kullanıcı (B2C)
    const b2cUser = UserModel(
      uid: 'user_deniz_aksoy',
      name: 'Deniz Aksoy',
      email: 'deniz.aksoy@paypulse.com',
      role: 'b2c',
      customerNo: 'PP-849201',
      verificationLevel: 2,
      iban: 'TR42 0006 2000 8492 0100 0000 01',
      monthlyLimit: 25000.0,
      spentThisMonth: 18420.0,
      hasB2BAccess: false,
    );

    // Şirket Çalışanı (Employee)
    const employeeUser = UserModel(
      uid: 'user_employee_ahmet',
      name: 'Ahmet Yılmaz',
      email: 'ahmet.yilmaz@paypulse.com',
      role: 'employee',
      companyId: 'comp_paypulse_tech',
      customerNo: 'PP-EMP-002',
      verificationLevel: 2,
      iban: 'TR18 0006 2000 8492 0100 0000 02',
      monthlyLimit: 15000.0,
      spentThisMonth: 3200.0,
      hasB2BAccess: true,
    );

    // Şirket Yöneticisi (Admin)
    const adminUser = UserModel(
      uid: 'user_admin_ali',
      name: 'Ali Yılmaz',
      email: 'ali.yilmaz@paypulse.com',
      role: 'admin',
      companyId: 'comp_paypulse_tech',
      customerNo: 'PP-ADMIN-001',
      verificationLevel: 3,
      iban: 'TR92 0006 2000 8492 0100 0000 03',
      monthlyLimit: 100000.0,
      spentThisMonth: 12000.0,
      hasB2BAccess: true,
    );

    _users[b2cUser.uid] = b2cUser;
    _users['demo_admin_user'] = adminUser;
    _users[employeeUser.uid] = employeeUser;
    _users[adminUser.uid] = adminUser;

    // 2. Şirket
    final company = CompanyModel(
      companyId: 'comp_paypulse_tech',
      name: 'PayPulse Teknoloji A.Ş.',
      adminIds: ['user_admin_ali', 'demo_admin_user'],
      corporateIban: 'TR10 0006 2000 8492 0100 0000 00',
      taxNumber: '1234567890',
    );
    _companies[company.companyId] = company;
    _companies['comp_techsolutions_01'] = CompanyModel(
      companyId: 'comp_techsolutions_01',
      name: 'PayPulse Teknoloji A.Ş.',
      adminIds: ['user_admin_ali', 'demo_admin_user'],
      corporateIban: 'TR10 0006 2000 8492 0100 0000 00',
      taxNumber: '1234567890',
    );

    // 3. Cüzdanlar
    // B2C Cüzdanı: 12.500 TL (1.250.000 kuruş), 500 USD (50.000), 300 EUR (30.000)
    final b2cWallet = const WalletModel(
      walletId: 'wallet_user_deniz_aksoy',
      ownerId: 'user_deniz_aksoy',
      balanceTl: 1250000,
      balanceUsd: 50000,
      balanceEur: 30000,
      iban: 'TR42 0006 2000 8492 0100 0000 01',
    );

    // Çalışan Cüzdanı: 5.000 TL (500.000 kuruş)
    final empWallet = const WalletModel(
      walletId: 'wallet_user_employee_ahmet',
      ownerId: 'user_employee_ahmet',
      balanceTl: 500000,
      balanceUsd: 0,
      balanceEur: 0,
      iban: 'TR18 0006 2000 8492 0100 0000 02',
    );

    // Yönetici Kişisel Cüzdanı: 10.000 TL (1.000.000 kuruş)
    final adminWallet = const WalletModel(
      walletId: 'wallet_user_admin_ali',
      ownerId: 'user_admin_ali',
      balanceTl: 1000000,
      balanceUsd: 0,
      balanceEur: 0,
      iban: 'TR92 0006 2000 8492 0100 0000 03',
    );

    // Şirket Kasası: 245.800 TL (24.580.000 kuruş)
    final compSafeWallet = const WalletModel(
      walletId: 'wallet_comp_paypulse_tech',
      ownerId: 'comp_paypulse_tech',
      balanceTl: 24580000,
      balanceUsd: 0,
      balanceEur: 0,
      iban: 'TR10 0006 2000 8492 0100 0000 00',
    );

    _wallets[b2cWallet.walletId] = b2cWallet;
    _wallets['wallet_user_b2c_001'] = b2cWallet;
    _wallets[empWallet.walletId] = empWallet;
    _wallets[adminWallet.walletId] = adminWallet;
    _wallets['wallet_demo_admin_user'] = adminWallet;
    _wallets[compSafeWallet.walletId] = compSafeWallet;
    _wallets['wallet_comp_techsolutions_01'] = compSafeWallet;

    // 4. Güvenli IBAN Alıcı Rehberi (Directory)
    _registerRecipient('TR420006200084920100000001', 'user_deniz_aksoy', 'Deniz Aksoy');
    _registerRecipient('TR180006200084920100000002', 'user_employee_ahmet', 'Ahmet Yılmaz');
    _registerRecipient('TR920006200084920100000003', 'user_admin_ali', 'Ali Yılmaz');
    _registerRecipient('TR100006200084920100000000', 'comp_paypulse_tech', 'PayPulse Teknoloji A.Ş.');
    _registerRecipient('TR560006200011223344550001', 'user_zeynep_kaya', 'Zeynep Kaya');
    _registerRecipient('TR340006200099887766550001', 'user_mert_can', 'Mert Can');

    // 5. Başlangıç İşlemleri (Mock Transactions)
    _transactions.addAll(FirestoreSeeder.mockTransactions);

    // 6. Başlangıç Masrafları (Demo Expenses)
    _expenses.addAll([
      ExpenseModel(
        expenseId: 'exp_001',
        employeeId: 'user_employee_ahmet',
        employeeName: 'Ahmet Yılmaz',
        merchantTitle: 'Teknosa Bilgisayar Ekipmanı',
        category: 'Donanım & Ofis',
        companyId: 'comp_paypulse_tech',
        amount: 320000, // 3.200,00 TL
        vatAmount: 64000, // 640,00 TL
        receiptImageUrl: 'https://images.unsplash.com/photo-1554415707-9e4966a642ed',
        status: 'pending',
        date: DateTime.now().subtract(const Duration(hours: 3)),
        accountingCode: '770.01',
      ),
      ExpenseModel(
        expenseId: 'exp_002',
        employeeId: 'user_employee_ahmet',
        employeeName: 'Ahmet Yılmaz',
        merchantTitle: 'Müşteri Öğle Yemeği (Midpoint)',
        category: 'Yemek & Temsil',
        companyId: 'comp_paypulse_tech',
        amount: 85000, // 850,00 TL
        vatAmount: 8500, // 85,00 TL
        receiptImageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5',
        status: 'pending',
        date: DateTime.now().subtract(const Duration(days: 1)),
        accountingCode: '770.02',
      ),
      ExpenseModel(
        expenseId: 'exp_003',
        employeeId: 'user_employee_ahmet',
        employeeName: 'Ahmet Yılmaz',
        merchantTitle: 'Şehir İçi Taksi Ulaşım',
        category: 'Ulaşım',
        companyId: 'comp_paypulse_tech',
        amount: 35000, // 350,00 TL
        vatAmount: 0,
        receiptImageUrl: '',
        status: 'approved',
        date: DateTime.now().subtract(const Duration(days: 3)),
        accountingCode: '770.03',
      ),
      ExpenseModel(
        expenseId: 'exp_004',
        employeeId: 'user_employee_ahmet',
        employeeName: 'Ahmet Yılmaz',
        merchantTitle: 'Yazılım Lisansı & Eklenti',
        category: 'Yazılım & SaaS',
        companyId: 'comp_paypulse_tech',
        amount: 145000, // 1.450,00 TL
        vatAmount: 24167,
        receiptImageUrl: '',
        status: 'rejected',
        rejectReason: 'Şirket ön onayı bulunmayan yazılım aboneliği.',
        date: DateTime.now().subtract(const Duration(days: 4)),
        accountingCode: '770.04',
      ),
    ]);

    // comp_techsolutions_01 için de eşleştir
    final techExpenses = _expenses.map((e) => ExpenseModel(
      expenseId: '${e.expenseId}_tech',
      employeeId: e.employeeId,
      employeeName: e.employeeName,
      merchantTitle: e.merchantTitle,
      category: e.category,
      companyId: 'comp_techsolutions_01',
      amount: e.amount,
      vatAmount: e.vatAmount,
      receiptImageUrl: e.receiptImageUrl,
      status: e.status,
      rejectReason: e.rejectReason,
      date: e.date,
      accountingCode: e.accountingCode,
    )).toList();
    _expenses.addAll(techExpenses);

    // 7. Başlangıç Bildirimleri
    _notifications.addAll([
      NotificationModel(
        notificationId: 'notif_init_1',
        userId: 'user_deniz_aksoy',
        title: 'PayPulse Demo Moduna Hoş Geldiniz',
        body: 'macOS üzerinde güvenli yerel demo ortamı devrede. Bakiyeniz: ₺12.500,00',
        type: 'general',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      NotificationModel(
        notificationId: 'notif_init_2',
        userId: 'user_admin_ali',
        title: 'Yeni Masraf Onay Bekliyor',
        body: 'Ahmet Yılmaz ₺3.200,00 tutarında "Teknosa Bilgisayar Ekipmanı" masrafı iletti.',
        type: 'expense_created',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        relatedId: 'exp_001',
      ),
      NotificationModel(
        notificationId: 'notif_init_3',
        userId: 'demo_admin_user',
        title: 'Yeni Masraf Onay Bekliyor',
        body: 'Ahmet Yılmaz ₺3.200,00 tutarında "Teknosa Bilgisayar Ekipmanı" masrafı iletti.',
        type: 'expense_created',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        relatedId: 'exp_001',
      ),
    ]);
  }

  /// Tüm demo verilerini Kasım 2026 başlangıç durumuna sıfırlar ve yayınlar
  void resetOrSeedData() {
    _users.clear();
    _companies.clear();
    _wallets.clear();
    _recipients.clear();
    _transactions.clear();
    _expenses.clear();
    _notifications.clear();
    _initData();
    _walletsController.add(Map.from(_wallets));
    _transactionsController.add(List.from(_transactions));
    _expensesController.add(List.from(_expenses));
    _notificationsController.add(List.from(_notifications));
  }

  void _registerRecipient(String iban, String userId, String fullName) {
    final normalized = iban.replaceAll(RegExp(r'\s'), '').toUpperCase();
    final words = fullName.trim().split(RegExp(r'\s+'));
    final masked = words.map((w) => w.length <= 1 ? w : '${w[0]}${'*' * (w.length - 1)}').join(' ');
    _recipients[normalized] = SafeRecipientModel(
      userId: userId,
      maskedName: masked,
      iban: normalized,
    );
  }

  // ================= 4. KULLANICI & ŞİRKET İŞLEMLERİ =================
  UserModel? getUserProfile(String uid) {
    if (_users.containsKey(uid)) return _users[uid];
    if (uid == 'user_deniz_aksoy' || uid == 'user_b2c_001') return _users['user_deniz_aksoy'];
    if (uid == 'user_admin_ali' || uid == 'demo_admin_user') return _users['user_admin_ali'];
    if (uid == 'user_employee_ahmet') return _users['user_employee_ahmet'];
    return null;
  }

  CompanyModel? getCompany(String companyId) {
    return _companies[companyId] ?? _companies['comp_paypulse_tech'];
  }

  // ================= 5. CÜZDAN METOTLARI & REAKTİF AKIŞLAR =================
  WalletModel? getWallet(String walletId) {
    return _wallets[walletId] ??
        _wallets['wallet_user_deniz_aksoy'] ??
        FirestoreSeeder.mockWallet;
  }

  WalletModel? getUserWallet(String userId) {
    if (_wallets.containsKey('wallet_$userId')) {
      return _wallets['wallet_$userId'];
    }
    if (userId == 'user_deniz_aksoy' || userId == 'user_b2c_001') {
      return _wallets['wallet_user_deniz_aksoy'];
    }
    if (userId == 'user_admin_ali' || userId == 'demo_admin_user') {
      return _wallets['wallet_user_admin_ali'];
    }
    if (userId == 'user_employee_ahmet') {
      return _wallets['wallet_user_employee_ahmet'];
    }
    return _wallets['wallet_user_deniz_aksoy'];
  }

  Stream<WalletModel?> watchWallet(String walletId) {
    // İlk değeri anında yayar, ardından değişiklikleri dinler
    return Stream<WalletModel?>.value(getWallet(walletId))
        .concatWith([
          _walletsController.stream.map((wallets) => wallets[walletId] ?? getWallet(walletId)),
        ]);
  }

  Stream<WalletModel?> watchUserWallet(String userId) {
    final String resolvedWalletId;
    if (userId == 'comp_paypulse_tech' || userId == 'comp_techsolutions_01') {
      resolvedWalletId = 'wallet_comp_paypulse_tech';
    } else if (userId == 'user_admin_ali' || userId == 'demo_admin_user') {
      resolvedWalletId = 'wallet_user_admin_ali';
    } else if (userId == 'user_employee_ahmet') {
      resolvedWalletId = 'wallet_user_employee_ahmet';
    } else {
      resolvedWalletId = 'wallet_user_deniz_aksoy';
    }

    return Stream<WalletModel?>.value(getWallet(resolvedWalletId))
        .concatWith([
          _walletsController.stream.map((wallets) => wallets[resolvedWalletId] ?? getWallet(resolvedWalletId)),
        ]);
  }

  void updateWallet(WalletModel wallet) {
    _wallets[wallet.walletId] = wallet;
    _walletsController.add(Map.unmodifiable(_wallets));
  }

  // ================= 6. FAST PARA TRANSFERİ (İŞLEMSİ) =================
  SafeRecipientModel? findRecipientByIban(String rawIban) {
    final normalized = rawIban.replaceAll(RegExp(r'\s'), '').toUpperCase();
    return _recipients[normalized];
  }

  Future<TransactionModel> executeFastTransferByIban({
    required String senderUserId,
    required String targetIban,
    required int amountKurus,
    String currency = 'TRY',
  }) async {
    final normalizedIban = targetIban.replaceAll(RegExp(r'\s'), '').toUpperCase();
    final recipient = findRecipientByIban(normalizedIban);

    if (recipient == null) {
      throw Exception('Belirtilen IBAN numarasına ait geçerli bir hesap bulunamadı.');
    }

    if (amountKurus <= 0) {
      throw ArgumentError('Transfer tutarı sıfırdan büyük olmalıdır.');
    }

    // Gönderen cüzdanını bul
    final senderWallet = getUserWallet(senderUserId);
    if (senderWallet == null) {
      throw Exception('Gönderici cüzdanı bulunamadı.');
    }

    if (senderWallet.balanceTl < amountKurus) {
      throw Exception(
        'Yetersiz bakiye! Mevcut: ₺${(senderWallet.balanceTl / 100).toStringAsFixed(2)}, '
        'Transfer: ₺${(amountKurus / 100).toStringAsFixed(2)}',
      );
    }

    // Bakiyeleri güncelle
    final updatedSenderWallet = WalletModel(
      walletId: senderWallet.walletId,
      ownerId: senderWallet.ownerId,
      balanceTl: senderWallet.balanceTl - amountKurus,
      balanceUsd: senderWallet.balanceUsd,
      balanceEur: senderWallet.balanceEur,
      iban: senderWallet.iban,
    );
    _wallets[senderWallet.walletId] = updatedSenderWallet;

    // Alıcı yerel demo sistemindeyse alıcı bakiyesini de artır
    final receiverUserId = recipient.userId;
    final receiverWallet = getUserWallet(receiverUserId);
    if (receiverWallet != null) {
      final updatedReceiverWallet = WalletModel(
        walletId: receiverWallet.walletId,
        ownerId: receiverWallet.ownerId,
        balanceTl: receiverWallet.balanceTl + amountKurus,
        balanceUsd: receiverWallet.balanceUsd,
        balanceEur: receiverWallet.balanceEur,
        iban: receiverWallet.iban,
      );
      _wallets[receiverWallet.walletId] = updatedReceiverWallet;
    }

    // İşlem kaydını oluştur
    final txId = 'PP-FAST-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999)}';
    final senderTx = TransactionModel(
      txId: txId,
      senderId: senderUserId,
      receiverId: receiverUserId,
      amount: amountKurus,
      currency: currency,
      timestamp: DateTime.now(),
      type: 'fast',
      targetIban: targetIban,
      title: recipient.maskedName,
      category: 'FAST Para Transferi',
      isExpense: true,
      dateGroup: 'BUGÜN, ${DateTime.now().day} KASIM',
      status: 'Başarılı',
    );

    _transactions.insert(0, senderTx);

    // Alıcı için de gelen transfer kaydı ekle
    if (receiverWallet != null) {
      final receiverTx = TransactionModel(
        txId: '${txId}_rec',
        senderId: senderUserId,
        receiverId: receiverUserId,
        amount: amountKurus,
        currency: currency,
        timestamp: DateTime.now(),
        type: 'fast',
        targetIban: senderWallet.iban,
        title: _users[senderUserId]?.name ?? 'Deniz Aksoy',
        category: 'FAST Para Girişi',
        isExpense: false,
        dateGroup: 'BUGÜN, ${DateTime.now().day} KASIM',
        status: 'Başarılı',
      );
      _transactions.insert(0, receiverTx);
    }

    // Bildirim oluştur
    _notifications.insert(
      0,
      NotificationModel(
        notificationId: 'notif_tx_${DateTime.now().millisecondsSinceEpoch}',
        userId: senderUserId,
        title: 'FAST Transfer Başarılı',
        body: '${recipient.maskedName} adlı alıcıya ₺${(amountKurus / 100).toStringAsFixed(2)} aktarıldı.',
        type: 'transfer_sent',
        isRead: false,
        createdAt: DateTime.now(),
        relatedId: txId,
      ),
    );

    if (receiverWallet != null) {
      _notifications.insert(
        0,
        NotificationModel(
          notificationId: 'notif_tx_rec_${DateTime.now().millisecondsSinceEpoch}',
          userId: receiverUserId,
          title: 'Hesabınıza Para Geldi',
          body: '${_users[senderUserId]?.name ?? "Deniz Aksoy"} size ₺${(amountKurus / 100).toStringAsFixed(2)} FAST transferi gönderdi.',
          type: 'transfer_received',
          isRead: false,
          createdAt: DateTime.now(),
          relatedId: txId,
        ),
      );
    }

    // Reaktif yayınla
    _walletsController.add(Map.unmodifiable(_wallets));
    _transactionsController.add(List.unmodifiable(_transactions));
    _notificationsController.add(List.unmodifiable(_notifications));

    return senderTx;
  }

  // ================= 7. MASRAF YÖNETİMİ (ONAY/RED DÖNGÜSÜ) =================
  ExpenseModel? getExpense(String expenseId) {
    try {
      return _expenses.firstWhere((e) => e.expenseId == expenseId);
    } catch (_) {
      return null;
    }
  }

  Future<void> createExpense(ExpenseModel expense) async {
    _expenses.insert(0, expense);

    // Şirket yöneticilerine bildirim oluştur
    for (final adminId in ['user_admin_ali', 'demo_admin_user']) {
      _notifications.insert(
        0,
        NotificationModel(
          notificationId: 'notif_exp_${DateTime.now().millisecondsSinceEpoch}_$adminId',
          userId: adminId,
          title: 'Yeni Masraf Onay Bekliyor',
          body: '${expense.employeeName} ₺${expense.amountInLira.toStringAsFixed(2)} tutarında "${expense.merchantTitle}" masrafı iletti.',
          type: 'expense_created',
          isRead: false,
          createdAt: DateTime.now(),
          relatedId: expense.expenseId,
        ),
      );
    }

    _expensesController.add(List.unmodifiable(_expenses));
    _notificationsController.add(List.unmodifiable(_notifications));
  }

  Future<void> approveExpense({
    required String expenseId,
    String? accountingCode,
    String? approvedBy,
  }) async {
    final index = _expenses.indexWhere((e) => e.expenseId == expenseId);
    if (index == -1) {
      throw Exception('Masraf kaydı bulunamadı.');
    }

    final expense = _expenses[index];
    if (expense.status != 'pending') {
      throw StateError(
        'Bu masraf daha önce işleme alınmış (${expense.status}). Yeniden onaylanamaz.',
      );
    }

    // Şirket kasasını kontrol et
    final companyWallet = _wallets['wallet_comp_paypulse_tech'] ??
        _wallets['wallet_comp_techsolutions_01'];
    if (companyWallet == null) {
      throw Exception('Şirket kasası cüzdanı bulunamadı.');
    }

    if (companyWallet.balanceTl < expense.amount) {
      throw Exception(
        'Şirket kasasında yetersiz bakiye! Mevcut Kasa: ₺${(companyWallet.balanceTl / 100).toStringAsFixed(2)}, '
        'Masraf: ₺${(expense.amount / 100).toStringAsFixed(2)}',
      );
    }

    // 1. Şirket kasasından düş
    final updatedCompWallet = WalletModel(
      walletId: companyWallet.walletId,
      ownerId: companyWallet.ownerId,
      balanceTl: companyWallet.balanceTl - expense.amount,
      balanceUsd: companyWallet.balanceUsd,
      balanceEur: companyWallet.balanceEur,
      iban: companyWallet.iban,
    );
    _wallets[companyWallet.walletId] = updatedCompWallet;
    _wallets['wallet_comp_techsolutions_01'] = updatedCompWallet;

    // 2. Personel cüzdanına ekle
    final employeeWallet = getUserWallet(expense.employeeId);
    if (employeeWallet != null) {
      final updatedEmpWallet = WalletModel(
        walletId: employeeWallet.walletId,
        ownerId: employeeWallet.ownerId,
        balanceTl: employeeWallet.balanceTl + expense.amount,
        balanceUsd: employeeWallet.balanceUsd,
        balanceEur: employeeWallet.balanceEur,
        iban: employeeWallet.iban,
      );
      _wallets[employeeWallet.walletId] = updatedEmpWallet;
    }

    // 3. Masraf durumunu güncelle
    final approvedExpense = ExpenseModel(
      expenseId: expense.expenseId,
      employeeId: expense.employeeId,
      employeeName: expense.employeeName,
      merchantTitle: expense.merchantTitle,
      category: expense.category,
      companyId: expense.companyId,
      amount: expense.amount,
      vatAmount: expense.vatAmount,
      receiptImageUrl: expense.receiptImageUrl,
      status: 'approved',
      date: expense.date,
      accountingCode: accountingCode ?? expense.accountingCode,
    );
    _expenses[index] = approvedExpense;

    // 4. İşlem geçmişine masraf geri ödemesi kaydı ekle
    final txId = 'PP-EXP-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999)}';
    _transactions.insert(
      0,
      TransactionModel(
        txId: txId,
        senderId: expense.companyId,
        receiverId: expense.employeeId,
        amount: expense.amount,
        currency: 'TRY',
        timestamp: DateTime.now(),
        type: 'expense_reimbursement',
        title: '${expense.merchantTitle} (Masraf İadesi)',
        category: 'Masraf İadesi',
        isExpense: false,
        dateGroup: 'BUGÜN, ${DateTime.now().day} KASIM',
        status: 'Başarılı',
        relatedId: expenseId,
      ),
    );

    // 5. Personele bildirim gönder
    _notifications.insert(
      0,
      NotificationModel(
        notificationId: 'notif_appr_${DateTime.now().millisecondsSinceEpoch}',
        userId: expense.employeeId,
        title: 'Masrafınız Onaylandı! ✅',
        body: '${expense.merchantTitle} için ₺${expense.amountInLira.toStringAsFixed(2)} tutarındaki masraf şirket kasasından ödendi.',
        type: 'expense_approved',
        isRead: false,
        createdAt: DateTime.now(),
        relatedId: expenseId,
      ),
    );

    // Reaktif yayınla
    _walletsController.add(Map.unmodifiable(_wallets));
    _expensesController.add(List.unmodifiable(_expenses));
    _transactionsController.add(List.unmodifiable(_transactions));
    _notificationsController.add(List.unmodifiable(_notifications));
  }

  Future<void> rejectExpense({
    required String expenseId,
    required String rejectReason,
    String? rejectedBy,
  }) async {
    final index = _expenses.indexWhere((e) => e.expenseId == expenseId);
    if (index == -1) {
      throw Exception('Masraf kaydı bulunamadı.');
    }

    final expense = _expenses[index];
    if (expense.status != 'pending') {
      throw StateError(
        'Bu masraf daha önce işleme alınmış (${expense.status}). Yeniden reddedilemez.',
      );
    }

    final rejectedExpense = ExpenseModel(
      expenseId: expense.expenseId,
      employeeId: expense.employeeId,
      employeeName: expense.employeeName,
      merchantTitle: expense.merchantTitle,
      category: expense.category,
      companyId: expense.companyId,
      amount: expense.amount,
      vatAmount: expense.vatAmount,
      receiptImageUrl: expense.receiptImageUrl,
      status: 'rejected',
      rejectReason: rejectReason,
      date: expense.date,
      accountingCode: expense.accountingCode,
    );
    _expenses[index] = rejectedExpense;

    // Personele bildirim
    _notifications.insert(
      0,
      NotificationModel(
        notificationId: 'notif_rej_${DateTime.now().millisecondsSinceEpoch}',
        userId: expense.employeeId,
        title: 'Masrafınız Reddedildi ❌',
        body: '${expense.merchantTitle} masrafı onaylanmadı. Gerekçe: $rejectReason',
        type: 'expense_rejected',
        isRead: false,
        createdAt: DateTime.now(),
        relatedId: expenseId,
      ),
    );

    _expensesController.add(List.unmodifiable(_expenses));
    _notificationsController.add(List.unmodifiable(_notifications));
  }

  // ================= 8. SANAL POS TAHİLAT İŞLEMLERİ =================
  Future<TransactionModel> executeCardPosPayment({
    required String companyId,
    required String maskedCardNumber,
    required int amountKurus,
    String currency = 'TRY',
  }) async {
    if (amountKurus <= 0) {
      throw ArgumentError('Tahsilat tutarı sıfırdan büyük olmalıdır.');
    }

    // %1.39 komisyon hesabı
    final commission = (amountKurus * 139) ~/ 10000;
    final netAmount = amountKurus - commission;

    // Şirket kasasına net tutarı ekle
    final compWallet = _wallets['wallet_comp_paypulse_tech'] ??
        _wallets['wallet_comp_techsolutions_01'];
    if (compWallet != null) {
      final updatedCompWallet = WalletModel(
        walletId: compWallet.walletId,
        ownerId: compWallet.ownerId,
        balanceTl: compWallet.balanceTl + netAmount,
        balanceUsd: compWallet.balanceUsd,
        balanceEur: compWallet.balanceEur,
        iban: compWallet.iban,
      );
      _wallets[compWallet.walletId] = updatedCompWallet;
      _wallets['wallet_comp_techsolutions_01'] = updatedCompWallet;
    }

    final txId = 'PP-POS-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999)}';
    final tx = TransactionModel(
      txId: txId,
      senderId: 'CARD:$maskedCardNumber',
      receiverId: companyId,
      amount: amountKurus,
      currency: currency,
      timestamp: DateTime.now(),
      type: 'card_pos_payment',
      title: 'Sanal POS Tahsilatı ($maskedCardNumber)',
      category: 'POS Tahsilat',
      isExpense: false,
      dateGroup: 'BUGÜN, ${DateTime.now().day} KASIM',
      status: 'Başarılı',
    );

    _transactions.insert(0, tx);

    // Şirket yöneticilerine bildirim
    for (final adminId in ['user_admin_ali', 'demo_admin_user']) {
      _notifications.insert(
        0,
        NotificationModel(
          notificationId: 'notif_pos_${DateTime.now().millisecondsSinceEpoch}_$adminId',
          userId: adminId,
          title: 'Sanal POS Tahsilatı Başarılı 💳',
          body: '₺${(amountKurus / 100).toStringAsFixed(2)} tahsil edildi. Net ₺${(netAmount / 100).toStringAsFixed(2)} kasaya aktarıldı (%1.39 komisyon).',
          type: 'general',
          isRead: false,
          createdAt: DateTime.now(),
          relatedId: txId,
        ),
      );
    }

    _walletsController.add(Map.unmodifiable(_wallets));
    _transactionsController.add(List.unmodifiable(_transactions));
    _notificationsController.add(List.unmodifiable(_notifications));

    return tx;
  }

  // ================= 9. İŞLEM GEÇMİŞİ & SORGULAR =================
  TransactionModel? getTransaction(String txId) {
    try {
      return _transactions.firstWhere((t) => t.txId == txId);
    } catch (_) {
      return null;
    }
  }

  Stream<List<TransactionModel>> watchUserTransactions(String userId) {
    List<TransactionModel> filter() {
      if (userId == 'user_deniz_aksoy' || userId == 'user_b2c_001') {
        return _transactions
            .where((t) => t.senderId == 'user_deniz_aksoy' || t.receiverId == 'user_deniz_aksoy' || t.senderId == 'user_b2c_001')
            .toList();
      }
      return _transactions
          .where((t) => t.senderId == userId || t.receiverId == userId)
          .toList();
    }

    return Stream<List<TransactionModel>>.value(filter()).concatWith([
      _transactionsController.stream.map((_) => filter()),
    ]);
  }

  Stream<List<TransactionModel>> watchSentTransactions(String userId) {
    return watchUserTransactions(userId).map((list) => list.where((t) => t.senderId == userId).toList());
  }

  Stream<List<TransactionModel>> watchReceivedTransactions(String userId) {
    return watchUserTransactions(userId).map((list) => list.where((t) => t.receiverId == userId).toList());
  }

  // ================= 10. MASRAFLAR DİNLEME =================
  Stream<List<ExpenseModel>> watchCompanyExpenses(String companyId) {
    List<ExpenseModel> filter() => List<ExpenseModel>.from(_expenses);
    return Stream<List<ExpenseModel>>.value(filter()).concatWith([
      _expensesController.stream.map((_) => filter()),
    ]);
  }

  Stream<List<ExpenseModel>> watchEmployeeExpenses(String employeeId) {
    List<ExpenseModel> filter() =>
        _expenses.where((e) => e.employeeId == employeeId).toList();
    return Stream<List<ExpenseModel>>.value(filter()).concatWith([
      _expensesController.stream.map((_) => filter()),
    ]);
  }

  // ================= 11. BİLDİRİMLER =================
  Stream<List<NotificationModel>> watchUserNotifications(String userId) {
    List<NotificationModel> filter() {
      return _notifications
          .where((n) => n.userId == userId || (userId.startsWith('demo_') && n.userId == 'user_admin_ali'))
          .toList();
    }

    return Stream<List<NotificationModel>>.value(filter()).concatWith([
      _notificationsController.stream.map((_) => filter()),
    ]);
  }

  Stream<int> watchUnreadNotificationCount(String userId) {
    return watchUserNotifications(userId).map(
      (list) => list.where((n) => !n.isRead).length,
    );
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
    if (index != -1) {
      final old = _notifications[index];
      _notifications[index] = NotificationModel(
        notificationId: old.notificationId,
        userId: old.userId,
        title: old.title,
        body: old.body,
        type: old.type,
        isRead: true,
        createdAt: old.createdAt,
        relatedId: old.relatedId,
      );
      _notificationsController.add(List.unmodifiable(_notifications));
    }
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == userId) {
        final old = _notifications[i];
        _notifications[i] = NotificationModel(
          notificationId: old.notificationId,
          userId: old.userId,
          title: old.title,
          body: old.body,
          type: old.type,
          isRead: true,
          createdAt: old.createdAt,
          relatedId: old.relatedId,
        );
      }
    }
    _notificationsController.add(List.unmodifiable(_notifications));
  }
}

/// Basit Stream birleştirme yardımcısı
extension StreamConcatExtension<T> on Stream<T> {
  Stream<T> concatWith(Iterable<Stream<T>> others) async* {
    yield* this;
    for (final s in others) {
      yield* s;
    }
  }
}
