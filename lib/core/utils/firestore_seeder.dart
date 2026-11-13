import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_collections.dart';
import '../../data/models/user_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/budget_category_model.dart';
import '../../data/models/savings_goal_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/einvoice_model.dart';
import '../../data/models/pos_transaction_model.dart';
import '../../data/models/wallet_model.dart';

/// Jüri sunumu ve uygulama başlangıcı için Kasım 2026 test/mock verilerini
/// Firestore'a basan ve çevrimdışı fallback sağlayan tohumlama (Seed) servisi.
class FirestoreSeeder {
  final FirebaseFirestore _firestore;

  FirestoreSeeder({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // ================= 1. KASIM 2026 MOCK KULLANICI & CÜZDAN =================
  static const UserModel mockUser = UserModel(
    uid: 'user_deniz_aksoy',
    name: 'Deniz Aksoy',
    email: 'deniz.aksoy@paypulse.com',
    role: 'employee',
    companyId: 'comp_techsolutions_01',
    customerNo: 'PP-849201',
    verificationLevel: 2,
    iban: 'TR42 0006 2000 8492 0100 0000 01',
    monthlyLimit: 25000.0,
    spentThisMonth: 18420.0,
    hasB2BAccess: true,
  );

  static const WalletModel mockWallet = WalletModel(
    walletId: 'wallet_user_deniz_aksoy',
    ownerId: 'user_deniz_aksoy',
    balanceTl: 2335000, // +₺23.350,00
    balanceUsd: 125000, // $1.250,00
    balanceEur: 85000, // €850,00
    iban: 'TR42 0006 2000 8492 0100 0000 01',
  );

  // ================= 2. KASIM 2026 MOCK FİNANSAL İŞLEMLER =================
  // Net Değişim: +₺23.350,00 (Gelen: +₺34.250,00, Giden: -₺10.900,00)
  static final List<TransactionModel> mockTransactions = [
    // --- BUGÜN, 11 KASIM ---
    TransactionModel(
      txId: 'PP-FAST-20261111-849201',
      senderId: 'user_deniz_aksoy',
      receiverId: 'user_zeynep_kaya',
      title: 'Zeynep Kaya',
      category: 'FAST Para Transferi',
      amount: 150000, // 1.500,00 TL
      currency: 'TRY',
      timestamp: DateTime(2026, 11, 11, 14, 30),
      type: 'fast',
      targetIban: 'TR56 0006 2000 1122 3344 5500 01',
      isExpense: true,
      dateGroup: 'BUGÜN, 11 KASIM',
      status: 'Başarılı',
    ),
    TransactionModel(
      txId: 'PP-POS-20261111-194022',
      senderId: 'user_deniz_aksoy',
      receiverId: 'merchant_espresso_lab',
      title: 'Espresso Lab',
      category: 'Kahve & İçecek',
      amount: 18500, // 185,00 TL
      currency: 'TRY',
      timestamp: DateTime(2026, 11, 11, 10, 15),
      type: 'pos_payment',
      isExpense: true,
      dateGroup: 'BUGÜN, 11 KASIM',
      status: 'Başarılı',
    ),

    // --- DÜN, 10 KASIM ---
    TransactionModel(
      txId: 'PP-FAST-20261110-394011',
      senderId: 'user_mert_can',
      receiverId: 'user_deniz_aksoy',
      title: 'Mert Can',
      category: 'FAST Para Girişi',
      amount: 85000, // +850,00 TL
      currency: 'TRY',
      timestamp: DateTime(2026, 11, 10, 19, 45),
      type: 'fast',
      targetIban: 'TR42 0006 2000 8492 0100 0000 01',
      isExpense: false,
      dateGroup: 'DÜN, 10 KASIM',
      status: 'Başarılı',
    ),
    TransactionModel(
      txId: 'PP-POS-20261110-749210',
      senderId: 'user_deniz_aksoy',
      receiverId: 'merchant_getir',
      title: 'Getir',
      category: 'Market & Sipariş',
      amount: 48050, // 480,50 TL
      currency: 'TRY',
      timestamp: DateTime(2026, 11, 10, 12, 20),
      type: 'pos_payment',
      isExpense: true,
      dateGroup: 'DÜN, 10 KASIM',
      status: 'Başarılı',
    ),

    // --- GEÇEN HAFTA ---
    TransactionModel(
      txId: 'PP-SAL-20261105-001923',
      senderId: 'comp_techsolutions_01',
      receiverId: 'user_deniz_aksoy',
      title: 'TechSolutions Maaş',
      category: 'Maaş & Hakediş',
      amount: 3215000, // +32.150,00 TL
      currency: 'TRY',
      timestamp: DateTime(2026, 11, 5, 09, 00),
      type: 'salary',
      targetIban: 'TR42 0006 2000 8492 0100 0000 01',
      isExpense: false,
      dateGroup: 'GEÇEN HAFTA',
      status: 'Başarılı',
    ),
    TransactionModel(
      txId: 'PP-BIL-20261104-582910',
      senderId: 'user_deniz_aksoy',
      receiverId: 'merchant_enerjisa',
      title: 'Enerjisa',
      category: 'Elektrik Faturası',
      amount: 62000, // 620,00 TL
      currency: 'TRY',
      timestamp: DateTime(2026, 11, 4, 16, 40),
      type: 'bill',
      isExpense: true,
      dateGroup: 'GEÇEN HAFTA',
      status: 'Başarılı',
    ),
    TransactionModel(
      txId: 'PP-SUB-20261102-182930',
      senderId: 'user_deniz_aksoy',
      receiverId: 'merchant_netflix',
      title: 'Netflix',
      category: 'Dijital Abonelik',
      amount: 19999, // 199,99 TL
      currency: 'TRY',
      timestamp: DateTime(2026, 11, 2, 23, 10),
      type: 'subscription',
      isExpense: true,
      dateGroup: 'GEÇEN HAFTA',
      status: 'Başarılı',
    ),
  ];

  // ================= 3. BÜTÇE KATEGORİLERİ & TASARRUF HEDEFİ =================
  static const List<BudgetCategoryModel> mockBudgetCategories = [
    BudgetCategoryModel(
      categoryId: 'cat_market',
      title: 'Market',
      spentAmount: 3536.40,
      allocatedAmount: 5000.0,
      percentage: 42.0,
      colorHex: '#10B981',
      iconName: 'shopping_bag',
    ),
    BudgetCategoryModel(
      categoryId: 'cat_ulasim',
      title: 'Ulaşım',
      spentAmount: 2020.80,
      allocatedAmount: 3000.0,
      percentage: 24.0,
      colorHex: '#0D9488',
      iconName: 'directions_car',
    ),
    BudgetCategoryModel(
      categoryId: 'cat_faturalar',
      title: 'Faturalar',
      spentAmount: 1515.60,
      allocatedAmount: 2500.0,
      percentage: 18.0,
      colorHex: '#0D1F2D',
      iconName: 'receipt_long',
    ),
    BudgetCategoryModel(
      categoryId: 'cat_yeme_icme',
      title: 'Yeme & İçme',
      spentAmount: 842.00,
      allocatedAmount: 2000.0,
      percentage: 10.0,
      colorHex: '#38BDF8',
      iconName: 'restaurant',
    ),
    BudgetCategoryModel(
      categoryId: 'cat_diger',
      title: 'Diğer',
      spentAmount: 505.20,
      allocatedAmount: 1500.0,
      percentage: 6.0,
      colorHex: '#94A3B8',
      iconName: 'more_horiz',
    ),
  ];

  static const SavingsGoalModel mockSavingsGoal = SavingsGoalModel(
    id: 'goal_m4_pro',
    title: 'Yeni Laptop (M4 Pro)',
    targetAmount: 35000.0,
    currentAmount: 21000.0,
    deadline: '15 Ocak 2027',
    iconName: 'laptop_mac',
  );

  // ================= 4. PERSONEL MASRAF VE FİŞLERİ =================
  static final List<ExpenseModel> mockExpenses = [
    ExpenseModel(
      expenseId: 'exp_ahmet_01',
      employeeId: 'emp_ahmet_yilmaz',
      employeeName: 'Ahmet Yılmaz',
      merchantTitle: 'BiTaksi',
      category: 'Şehir İçi Ulaşım',
      companyId: 'comp_techsolutions_01',
      amount: 45000, // 450,00 TL
      vatAmount: 7500, // %20 KDV: 75,00 TL
      receiptImageUrl:
          'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=500',
      status: 'ONAY_BEKLIYOR',
      date: DateTime(2026, 11, 11, 16, 20),
      accountingCode: '770.01 - Ulaşım',
    ),
    ExpenseModel(
      expenseId: 'exp_elif_02',
      employeeId: 'emp_elif_demir',
      employeeName: 'Elif Demir',
      merchantTitle: 'Midpoint',
      category: 'Müşteri Temsil & Yemek',
      companyId: 'comp_techsolutions_01',
      amount: 198050, // 1.980,50 TL
      vatAmount: 18000, // %10 KDV: 180,00 TL
      receiptImageUrl:
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500',
      status: 'ONAY_BEKLIYOR',
      date: DateTime(2026, 11, 10, 20, 15),
      accountingCode: '770.04 - Temsil Ağırlama',
    ),
    ExpenseModel(
      expenseId: 'exp_caner_03',
      employeeId: 'emp_caner_kilic',
      employeeName: 'Caner Kılıç',
      merchantTitle: 'IKEA',
      category: 'Ofis Donanım & Kırtasiye',
      companyId: 'comp_techsolutions_01',
      amount: 146000, // 1.460,00 TL
      vatAmount: 24333, // %20 KDV: 243,33 TL
      receiptImageUrl:
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=500',
      status: 'ONAY_BEKLIYOR',
      date: DateTime(2026, 11, 09, 14, 00),
      accountingCode: '770.02 - Ofis Giderleri',
    ),
  ];

  // ================= 5. E-FATURA & E-ARŞİV KAYITLARI =================
  // Toplam Hacim: ₺184.650,00 (24 Gelen, 42 Giden)
  static final List<EInvoiceModel> mockInvoices = [
    EInvoiceModel(
      invoiceId: 'inv_aws_01',
      companyId: 'comp_techsolutions_01',
      gibInvoiceNo: 'GIB2026000004812',
      counterpartyName: 'Amazon Web Services (AWS)',
      isIncoming: true,
      documentType: 'e_fatura',
      totalAmount: 3482000, // 34.820,00 TL
      vatAmount: 580333,
      withholdingRate: 0.50,
      badgeText: 'Tevkifat 5/10',
      isPaid: true,
      canPayWithFast: false,
      issueDate: DateTime(2026, 11, 02),
    ),
    EInvoiceModel(
      invoiceId: 'inv_apple_02',
      companyId: 'comp_techsolutions_01',
      gibInvoiceNo: 'GIB2026000009182',
      counterpartyName: 'Apple Teknoloji A.Ş.',
      isIncoming: true,
      documentType: 'e_fatura',
      totalAmount: 7890000, // 78.900,00 TL
      vatAmount: 1315000,
      badgeText: 'Demirbaş',
      isPaid: true,
      canPayWithFast: false,
      issueDate: DateTime(2026, 11, 05),
    ),
    EInvoiceModel(
      invoiceId: 'inv_aydin_03',
      companyId: 'comp_techsolutions_01',
      gibInvoiceNo: 'SMM2026000001092',
      counterpartyName: 'Aydın Hukuk Bürosu',
      isIncoming: true,
      documentType: 'e_smm',
      totalAmount: 1500000, // 15.000,00 TL
      vatAmount: 250000,
      badgeText: 'E-SMM Danışmanlık',
      isPaid: false,
      canPayWithFast: true, // "Anında Öde (FAST)" butonlu
      issueDate: DateTime(2026, 11, 09),
    ),
    EInvoiceModel(
      invoiceId: 'inv_google_04',
      companyId: 'comp_techsolutions_01',
      gibInvoiceNo: 'GIB2026000003310',
      counterpartyName: 'Google Ireland Limited',
      isIncoming: true,
      documentType: 'e_fatura',
      totalAmount: 2640000, // 26.400,00 TL
      vatAmount: 440000,
      badgeText: 'Yurtdışı Yazılım',
      isPaid: true,
      canPayWithFast: false,
      issueDate: DateTime(2026, 11, 08),
    ),
    // Giden (Satış) faturası örneği
    EInvoiceModel(
      invoiceId: 'inv_sale_05',
      companyId: 'comp_techsolutions_01',
      gibInvoiceNo: 'GIB2026000010044',
      counterpartyName: 'E-Ticaret Global A.Ş.',
      isIncoming: false,
      documentType: 'e_fatura',
      totalAmount: 2953000, // 29.530,00 TL
      vatAmount: 492166,
      badgeText: 'Yazılım Hizmet Bedeli',
      isPaid: true,
      canPayWithFast: false,
      issueDate: DateTime(2026, 11, 07),
    ),
  ];

  // ================= 6. SANAL POS HAREKETLERİ =================
  static final List<PosTransactionModel> mockPosTransactions = [
    PosTransactionModel(
      posTxId: 'POS-TX-99401',
      terminalId: 'TRM-8492-01',
      customerName: 'Mehmet Can Özkan',
      grossAmount: 3750.00,
      commissionRate: 1.39,
      commissionAmount: 52.12,
      netAmount: 3697.88,
      timestamp: DateTime(2026, 11, 11, 15, 42),
      cardMasked: '5401 **** **** 8421',
      status: 'Başarılı',
    ),
    PosTransactionModel(
      posTxId: 'POS-TX-99402',
      terminalId: 'TRM-8492-01',
      customerName: 'Selin Yıldız',
      grossAmount: 1850.00,
      commissionRate: 1.39,
      commissionAmount: 25.71,
      netAmount: 1824.29,
      timestamp: DateTime(2026, 11, 11, 13, 20),
      cardMasked: '4543 **** **** 1092',
      status: 'Başarılı',
    ),
  ];

  // ================= FIRESTORE'A CANLI BASMA (BATCH WRITE) =================
  /// Tek tıkla tüm Kasım 2026 verilerini Cloud Firestore'a atomik olarak basar.
  Future<void> seedAll() async {
    final batch = _firestore.batch();

    // 1. Kullanıcı ve Cüzdan
    final userRef = _firestore
        .collection(FirestoreCollections.users)
        .doc(mockUser.uid);
    batch.set(userRef, mockUser.toJson());

    final walletRef = _firestore
        .collection(FirestoreCollections.wallets)
        .doc(mockWallet.walletId);
    batch.set(walletRef, mockWallet.toJson());

    // 2. İşlemler
    for (final tx in mockTransactions) {
      final txRef = _firestore
          .collection(FirestoreCollections.transactions)
          .doc(tx.txId);
      batch.set(txRef, tx.toJson());
    }

    // 3. Bütçe Kategorileri
    for (final cat in mockBudgetCategories) {
      final catRef = _firestore
          .collection(FirestoreCollections.budgetCategories)
          .doc(cat.categoryId);
      batch.set(catRef, cat.toJson());
    }

    // 4. Birikim Hedefi
    final goalRef = _firestore
        .collection(FirestoreCollections.savingsGoals)
        .doc(mockSavingsGoal.id);
    batch.set(goalRef, mockSavingsGoal.toJson());

    // 5. Masraflar
    for (final exp in mockExpenses) {
      final expRef = _firestore
          .collection(FirestoreCollections.expenses)
          .doc(exp.expenseId);
      batch.set(expRef, exp.toJson());
    }

    // 6. E-Faturalar
    for (final inv in mockInvoices) {
      final invRef = _firestore
          .collection(FirestoreCollections.invoices)
          .doc(inv.invoiceId);
      batch.set(invRef, inv.toJson());
    }

    // 7. Sanal POS
    for (final pos in mockPosTransactions) {
      final posRef = _firestore
          .collection(FirestoreCollections.posTransactions)
          .doc(pos.posTxId);
      batch.set(posRef, pos.toJson());
    }

    await batch.commit();
  }
}
