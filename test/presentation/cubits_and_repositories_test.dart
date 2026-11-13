import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_pulse/core/constants/app_strings.dart';
import 'package:pay_pulse/core/theme/app_theme.dart';
import 'package:pay_pulse/core/validators/financial_validators.dart';
import 'package:pay_pulse/data/datasources/remote/firebase_firestore_datasource.dart';
import 'package:pay_pulse/data/models/expense_model.dart';
import 'package:pay_pulse/data/repositories/expense_repository.dart';
import 'package:pay_pulse/domain/entities/company_entity.dart';
import 'package:pay_pulse/domain/entities/expense_entity.dart';
import 'package:pay_pulse/domain/entities/invoice_entity.dart';
import 'package:pay_pulse/domain/entities/notification_entity.dart';
import 'package:pay_pulse/domain/entities/pos_transaction_entity.dart';
import 'package:pay_pulse/domain/entities/safe_recipient_entity.dart';
import 'package:pay_pulse/domain/entities/transaction_entity.dart';
import 'package:pay_pulse/domain/entities/user_entity.dart';
import 'package:pay_pulse/domain/entities/wallet_entity.dart';
import 'package:pay_pulse/domain/repositories/i_company_repository.dart';
import 'package:pay_pulse/domain/repositories/i_expense_repository.dart';
import 'package:pay_pulse/domain/repositories/i_invoice_repository.dart';
import 'package:pay_pulse/domain/repositories/i_notification_repository.dart';
import 'package:pay_pulse/domain/repositories/i_transaction_repository.dart';
import 'package:pay_pulse/domain/repositories/i_user_repository.dart';
import 'package:pay_pulse/domain/repositories/i_wallet_repository.dart';
import 'package:pay_pulse/presentation/screens/analytics_and_reports/bloc/tax_report_cubit.dart';
import 'package:pay_pulse/presentation/screens/b2b_operations/bloc/expense_approval_cubit.dart';
import 'package:pay_pulse/presentation/screens/home_wallet_and_safe/bloc/business_overview_cubit.dart';
import 'package:pay_pulse/presentation/screens/home_wallet_and_safe/bloc/home_wallet_cubit.dart';
import 'package:pay_pulse/presentation/screens/profile_and_cards/bloc/cards_management_cubit.dart';
import 'package:pay_pulse/presentation/screens/profile_and_cards/bloc/profile_settings_cubit.dart';
import 'package:pay_pulse/presentation/screens/splash_and_onboarding/bloc/splash_cubit.dart';
import 'package:pay_pulse/presentation/widgets/bloc/notification_cubit.dart';
import 'package:pay_pulse/presentation/widgets/four_state_view.dart';

class _FakeExpenseFirestoreDatasource extends FirebaseFirestoreDatasource {
  final List<ExpenseModel> stored = [];
  final StreamController<List<ExpenseModel>> companyController =
      StreamController<List<ExpenseModel>>.broadcast();
  String? lastUploadedPath;

  @override
  Future<List<ExpenseModel>> getAllExpenses() async => List.of(stored);

  @override
  Future<ExpenseModel?> getExpense(String expenseId) async {
    for (final e in stored) {
      if (e.expenseId == expenseId) return e;
    }
    return null;
  }

  @override
  Future<void> createExpense(ExpenseModel expense) async {
    stored.add(expense);
    companyController.add(List.of(stored));
  }

  @override
  Future<void> approveExpense({
    required String expenseId,
    String? accountingCode,
  }) async {
    for (var i = 0; i < stored.length; i++) {
      if (stored[i].expenseId == expenseId) {
        stored[i] = stored[i].copyWith(
          status: 'approved',
          accountingCode: accountingCode ?? stored[i].accountingCode,
        );
      }
    }
    companyController.add(List.of(stored));
  }

  @override
  Future<void> rejectExpense({
    required String expenseId,
    required String reason,
  }) async {
    for (var i = 0; i < stored.length; i++) {
      if (stored[i].expenseId == expenseId) {
        stored[i] = stored[i].copyWith(
          status: 'rejected',
          rejectReason: reason,
        );
      }
    }
    companyController.add(List.of(stored));
  }

  @override
  Future<String> uploadReceiptImage({
    required String localFilePath,
    required String expenseId,
  }) async {
    lastUploadedPath = localFilePath;
    return 'https://storage.paypulse.test/$expenseId.jpg';
  }

  @override
  Stream<List<ExpenseModel>> watchCompanyExpenses(String companyId) =>
      companyController.stream;

  @override
  Stream<List<ExpenseModel>> watchEmployeeExpenses(String employeeId) =>
      companyController.stream;

  Future<void> dispose() => companyController.close();
}

class _FakeNotificationRepository implements INotificationRepository {
  final controller = StreamController<List<NotificationEntity>>.broadcast();
  final countController = StreamController<int>.broadcast();
  String? lastMarkedId;
  String? lastMarkedAllUserId;

  @override
  Stream<int> getUnreadCount(String userId) => countController.stream;

  @override
  Stream<List<NotificationEntity>> getUserNotifications(String userId) =>
      controller.stream;

  @override
  Future<void> markAllAsRead(String userId) async {
    lastMarkedAllUserId = userId;
    countController.add(0);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    lastMarkedId = notificationId;
  }

  @override
  Future<void> sendNotification(NotificationEntity notification) async {}

  Future<void> dispose() async {
    await controller.close();
    await countController.close();
  }
}

class _FakeWalletRepository implements IWalletRepository {
  final controller = StreamController<WalletEntity?>.broadcast();
  WalletEntity? currentWallet;
  WalletEntity? lastUpdatedWallet;

  @override
  Future<void> createWallet(WalletEntity wallet) async {
    currentWallet = wallet;
  }

  @override
  Future<List<WalletEntity>> getAllWallets() async =>
      currentWallet == null ? const [] : [currentWallet!];

  @override
  Future<WalletEntity?> getUserWallet(String userId) async => currentWallet;

  @override
  Future<WalletEntity?> getWalletById(String walletId) async => currentWallet;

  @override
  Future<void> updateWallet(WalletEntity wallet) async {
    currentWallet = wallet;
    lastUpdatedWallet = wallet;
    controller.add(wallet);
  }

  @override
  Stream<WalletEntity?> watchUserWallet(String userId) => controller.stream;

  @override
  Stream<WalletEntity?> watchWallet(String walletId) => controller.stream;

  Future<void> dispose() => controller.close();
}

class _FakeTxRepo implements ITransactionRepository {
  final controller = StreamController<List<TransactionEntity>>.broadcast();
  List<PosTransactionEntity> posItems = const [];

  @override
  Future<TransactionEntity> executeCardPosPayment({
    required String companyId,
    required String maskedCardNumber,
    required int amountKurus,
    String currency = 'TRY',
  }) => throw UnimplementedError();

  @override
  Future<TransactionEntity> executeFastTransferByIban({
    required String senderUserId,
    required String targetIban,
    required int amountKurus,
    String currency = 'TRY',
    String? title,
    String? category,
  }) => throw UnimplementedError();

  @override
  Future<TransactionEntity> executeQrWalletPayment({
    required String companyId,
    required String payerUserId,
    required int amountKurus,
    String currency = 'TRY',
  }) => throw UnimplementedError();

  @override
  Future<SafeRecipientEntity?> findRecipientByIban(String rawIban) async =>
      null;

  @override
  Future<List<TransactionEntity>> getAllTransactions() async => const [];

  @override
  Future<List<PosTransactionEntity>> getPosTransactions(
    String companyId,
  ) async => posItems;

  @override
  Future<List<SafeRecipientEntity>> getSavedRecipients() async => const [];

  @override
  Future<List<TransactionEntity>> getSentTransactions(String userId) async =>
      const [];

  @override
  Future<TransactionEntity?> getTransactionById(String txId) async => null;

  @override
  Stream<List<TransactionEntity>> watchReceivedTransactions(String userId) =>
      controller.stream;

  @override
  Stream<List<TransactionEntity>> watchSentTransactions(String userId) =>
      controller.stream;

  @override
  Stream<List<TransactionEntity>> watchUserTransactions(String userId) =>
      controller.stream;

  Future<void> dispose() => controller.close();
}

class _FakeUserRepo implements IUserRepository {
  int seedCalls = 0;

  @override
  Future<void> createUserProfile(UserEntity user) async {}

  @override
  Future<void> deleteFcmToken(String uid) async {}

  @override
  Future<List<UserEntity>> getAllUsers() async => const [];

  @override
  Future<UserEntity?> getDemoUserByRole(String role) async => null;

  @override
  Future<UserEntity?> getUserById(String uid) async => null;

  @override
  Future<UserEntity?> login({
    required String email,
    required String password,
  }) async => null;

  @override
  Future<void> logout() async {}

  @override
  Future<UserEntity?> register({
    required String email,
    required String password,
    required String name,
    String role = 'b2c',
    String? companyId,
  }) async => null;

  @override
  Future<void> seedDemoData() async {
    seedCalls++;
  }

  @override
  Future<void> updateFcmToken(String uid, String token) async {}

  @override
  Future<void> updateUserProfile(UserEntity user) async {}

  @override
  Stream<UserEntity?> watchAuthUser() => const Stream.empty();
}

class _FakeCompanyRepo implements ICompanyRepository {
  CompanyEntity? company;

  @override
  Future<void> createCompany(CompanyEntity company) async {
    this.company = company;
  }

  @override
  Future<List<CompanyEntity>> getAllCompanies() async =>
      company == null ? const [] : [company!];

  @override
  Future<CompanyEntity?> getCompanyById(String companyId) async => company;
}

class _FakeExpenseRepo implements IExpenseRepository {
  final controller = StreamController<List<ExpenseEntity>>.broadcast();
  final List<ExpenseEntity> items = [];

  @override
  Future<void> approveExpense({
    required String expenseId,
    String? accountingCode,
    String? approvedBy,
  }) async {
    for (var i = 0; i < items.length; i++) {
      if (items[i].expenseId == expenseId) {
        items[i] = items[i].copyWith(
          status: 'approved',
          accountingCode: accountingCode ?? items[i].accountingCode,
        );
      }
    }
    controller.add(List.of(items));
  }

  @override
  Future<void> createExpense(ExpenseEntity expense) async {
    items.add(expense);
  }

  @override
  Future<List<ExpenseEntity>> getAllExpenses() async => List.of(items);

  @override
  Future<ExpenseEntity?> getExpenseById(String expenseId) async => null;

  @override
  Future<void> rejectExpense({
    required String expenseId,
    required String rejectReason,
    String? rejectedBy,
  }) async {
    for (var i = 0; i < items.length; i++) {
      if (items[i].expenseId == expenseId) {
        items[i] = items[i].copyWith(
          status: 'rejected',
          rejectReason: rejectReason,
        );
      }
    }
    controller.add(List.of(items));
  }

  @override
  Future<String> uploadReceiptImage({
    required String localFilePath,
    required String expenseId,
  }) async => localFilePath;

  @override
  Stream<List<ExpenseEntity>> watchCompanyExpenses(String companyId) =>
      controller.stream;

  @override
  Stream<List<ExpenseEntity>> watchEmployeeExpenses(String employeeId) =>
      controller.stream;

  Future<void> dispose() => controller.close();
}

class _FakeInvoiceRepo implements IInvoiceRepository {
  List<InvoiceEntity> invoices = const [];

  @override
  Future<List<InvoiceEntity>> getInvoices({required String companyId}) async =>
      invoices;

  @override
  Future<void> payInvoiceWithFast({
    required String companyId,
    required String invoiceId,
    required String payerUserId,
    required String targetIban,
  }) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExpenseRepository Data-Domain Eşlemesi', () {
    test(
      'Entity oluşturma, onaylama, reddetme ve fiş yükleme datasource üzerinden işlenir',
      () async {
        final fakeDs = _FakeExpenseFirestoreDatasource();
        final repo = ExpenseRepository(firestoreDatasource: fakeDs);

        final uploadedUrl = await repo.uploadReceiptImage(
          localFilePath: '/tmp/receipt_1.jpg',
          expenseId: 'exp_101',
        );
        expect(fakeDs.lastUploadedPath, '/tmp/receipt_1.jpg');
        expect(uploadedUrl, 'https://storage.paypulse.test/exp_101.jpg');

        final expense = ExpenseEntity(
          expenseId: 'exp_101',
          employeeId: 'emp_1',
          employeeName: 'Mert Can',
          merchantTitle: 'Migros Jet',
          category: 'Yemek & Temsil',
          companyId: AppStrings.defaultCompanyId,
          amount: 12000,
          vatAmount: 2000,
          receiptImageUrl: uploadedUrl,
          status: 'pending',
          date: DateTime(2026, 11, 10),
        );

        await repo.createExpense(expense);
        final list = await repo.getAllExpenses();
        expect(list, [expense]);

        await repo.approveExpense(
          expenseId: 'exp_101',
          accountingCode: '770.05',
          approvedBy: 'adm_1',
        );
        final approved = await repo.getExpenseById('exp_101');
        expect(approved?.isApproved, isTrue);
        expect(approved?.accountingCode, '770.05');

        await repo.rejectExpense(
          expenseId: 'exp_101',
          rejectReason: 'Hatalı fiş',
          rejectedBy: 'adm_1',
        );
        final rejected = await repo.getExpenseById('exp_101');
        expect(rejected?.isRejected, isTrue);
        expect(rejected?.rejectReason, 'Hatalı fiş');

        await fakeDs.dispose();
      },
    );
  });

  group('NotificationCubit', () {
    test('Bildirim akışını ve okundu sayacını yönetir', () async {
      final repo = _FakeNotificationRepository();
      final cubit = NotificationCubit(repository: repo);

      await cubit.watchForUser('user_1');
      repo.controller.add([
        NotificationEntity(
          notificationId: 'n1',
          userId: 'user_1',
          title: 'FAST Alındı',
          body: '1.500 TL hesabınıza geçti',
          type: 'transfer',
          isRead: false,
          createdAt: DateTime(2026, 11, 11),
        ),
        NotificationEntity(
          notificationId: 'n2',
          userId: 'user_1',
          title: 'Hoş Geldiniz',
          body: 'PayPulse aktif',
          type: 'system',
          isRead: true,
          createdAt: DateTime(2026, 11, 10),
        ),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.notifications, hasLength(2));
      expect(cubit.state.unreadCount, 1);

      await cubit.markAsRead('n1');
      expect(repo.lastMarkedId, 'n1');

      await cubit.markAllAsRead();
      expect(repo.lastMarkedAllUserId, 'user_1');

      await cubit.watchForUser(null);
      expect(cubit.state, const NotificationState());

      await cubit.close();
      await repo.dispose();
    });
  });

  group('HomeWalletCubit & BusinessOverviewCubit', () {
    test(
      'HomeWalletCubit para birimi seçimi, bakiye gizleme ve seed aksiyonunu yönetir',
      () async {
        final walletRepo = _FakeWalletRepository();
        final txRepo = _FakeTxRepo();
        final userRepo = _FakeUserRepo();
        final cubit = HomeWalletCubit(
          walletRepository: walletRepo,
          transactionRepository: txRepo,
          userRepository: userRepo,
        );

        await cubit.watchUser('b2c_1');
        walletRepo.controller.add(
          const WalletEntity(
            walletId: 'w_1',
            ownerId: 'b2c_1',
            balanceTl: 2485000,
            balanceUsd: 120000,
            balanceEur: 50000,
          ),
        );
        txRepo.controller.add(const []);
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state.status, ViewStatus.success);
        expect(cubit.state.formattedActiveBalance, '₺24.850,00');

        cubit.selectCurrency('USD');
        expect(cubit.state.formattedActiveBalance, r'$1.200,00');

        cubit.toggleHideBalance();
        expect(cubit.state.formattedActiveBalance, r'$ ••••••');

        await cubit.seedDemoData();
        expect(userRepo.seedCalls, 1);
        expect(cubit.state.isErrorAction, isFalse);

        await cubit.close();
        await walletRepo.dispose();
        await txRepo.dispose();
      },
    );

    test(
      'BusinessOverviewCubit kasa bakiyesini yükler, aşımı engeller ve bakiye ekler',
      () async {
        final walletRepo = _FakeWalletRepository()
          ..currentWallet = const WalletEntity(
            walletId: 'cw_1',
            ownerId: AppStrings.defaultCompanyId,
            balanceTl: 1000000,
            balanceUsd: 0,
            balanceEur: 0,
          );
        final companyRepo = _FakeCompanyRepo()
          ..company = const CompanyEntity(
            companyId: AppStrings.defaultCompanyId,
            name: 'TechSolutions A.Ş.',
            taxNumber: '1234567890',
            corporateIban: 'TR330006100519786457841326',
            adminIds: ['adm_1'],
          );
        final expenseRepo = _FakeExpenseRepo();
        final txRepo = _FakeTxRepo()
          ..posItems = [
            PosTransactionEntity(
              posTxId: 'pos_1',
              terminalId: 'TERM_1',
              customerName: 'Müşteri',
              grossAmount: 3750.0,
            ),
          ];
        final userRepo = _FakeUserRepo();

        final cubit = BusinessOverviewCubit(
          walletRepository: walletRepo,
          companyRepository: companyRepo,
          expenseRepository: expenseRepo,
          transactionRepository: txRepo,
          userRepository: userRepo,
        );

        await cubit.loadCompany(AppStrings.defaultCompanyId);
        expect(cubit.state.status, ViewStatus.success);
        expect(cubit.state.balanceKurus, 1000000);
        expect(cubit.state.posTotalKurus, 375000);

        cubit.transferAmountController.text = '50000,00';
        final overdraftOk = await cubit.transferToBankAccount();
        expect(overdraftOk, isFalse);
        expect(cubit.state.isErrorAction, isTrue);

        cubit.setTransferPresetKurus(250000);
        final transferOk = await cubit.transferToBankAccount();
        expect(transferOk, isTrue);
        expect(cubit.state.balanceKurus, 750000);

        cubit.setTopUpAmountKurus(500000);
        final topUpOk = await cubit.topUpBalance();
        expect(topUpOk, isTrue);
        expect(cubit.state.balanceKurus, 1250000);

        await cubit.close();
        await walletRepo.dispose();
        await expenseRepo.dispose();
        await txRepo.dispose();
      },
    );
  });

  group('ExpenseApprovalCubit & TaxReportCubit', () {
    test(
      'ExpenseApprovalCubit filtreler ve admin toplu onayını çalıştırır',
      () async {
        final expenseRepo = _FakeExpenseRepo()
          ..items.addAll([
            ExpenseEntity(
              expenseId: 'e1',
              employeeId: 'emp_1',
              employeeName: 'Mert Can',
              merchantTitle: 'THY Uçuş',
              category: 'Ulaşım',
              companyId: AppStrings.defaultCompanyId,
              amount: 240000,
              vatAmount: 40000,
              receiptImageUrl: '',
              status: 'pending',
              date: DateTime(2026, 11, 10),
            ),
            ExpenseEntity(
              expenseId: 'e2',
              employeeId: 'emp_2',
              employeeName: 'Selin Ak',
              merchantTitle: 'Kahve Lab',
              category: 'Yemek & Temsil',
              companyId: AppStrings.defaultCompanyId,
              amount: 18000,
              vatAmount: 3000,
              receiptImageUrl: '',
              status: 'approved',
              date: DateTime(2026, 11, 9),
            ),
          ]);

        final cubit = ExpenseApprovalCubit(expenseRepository: expenseRepo);
        await cubit.watchCompany(AppStrings.defaultCompanyId);
        expenseRepo.controller.add(List.of(expenseRepo.items));
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state.status, ViewStatus.success);
        expect(cubit.state.pendingExpenses, hasLength(1));
        expect(cubit.state.approvedExpenses, hasLength(1));

        cubit.setCategory('Ulaşım');
        expect(cubit.state.filteredExpenses, hasLength(1));
        cubit.resetFilters();

        final approvedBatch = await cubit.approveAllPending(
          actorRole: AppStrings.roleAdmin,
          actorId: 'adm_1',
        );
        expect(approvedBatch, hasLength(1));
        await Future<void>.delayed(Duration.zero);
        expect(cubit.state.pendingExpenses, isEmpty);
        expect(cubit.state.approvedExpenses, hasLength(2));

        await cubit.close();
        await expenseRepo.dispose();
      },
    );

    test('TaxReportCubit döneme göre KDV özetini dinamik günceller', () async {
      final invoiceRepo = _FakeInvoiceRepo()
        ..invoices = [
          InvoiceEntity(
            invoiceId: 'i1',
            companyId: AppStrings.defaultCompanyId,
            gibInvoiceNo: 'GIB100',
            counterpartyName: 'Satış A',
            isIncoming: false,
            documentType: 'e_fatura',
            totalAmount: 120000,
            vatAmount: 20000,
            issueDate: DateTime(2026, 11, 4),
          ),
          InvoiceEntity(
            invoiceId: 'i2',
            companyId: AppStrings.defaultCompanyId,
            gibInvoiceNo: 'GIB101',
            counterpartyName: 'Q3 Satış',
            isIncoming: false,
            documentType: 'e_fatura',
            totalAmount: 240000,
            vatAmount: 40000,
            issueDate: DateTime(2026, 8, 12),
          ),
        ];
      final expenseRepo = _FakeExpenseRepo();
      final cubit = TaxReportCubit(
        invoiceRepository: invoiceRepo,
        expenseRepository: expenseRepo,
      );

      await cubit.watchCompany(AppStrings.defaultCompanyId);
      expenseRepo.controller.add([
        ExpenseEntity(
          expenseId: 'e_nov',
          employeeId: 'emp_1',
          companyId: AppStrings.defaultCompanyId,
          amount: 12000,
          vatAmount: 2000,
          receiptImageUrl: '',
          status: 'approved',
          date: DateTime(2026, 11, 5),
        ),
        ExpenseEntity(
          expenseId: 'e_pending_ignored',
          employeeId: 'emp_1',
          companyId: AppStrings.defaultCompanyId,
          amount: 60000,
          vatAmount: 10000,
          receiptImageUrl: '',
          status: 'pending',
          date: DateTime(2026, 11, 6),
        ),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.selectedPeriod, TaxPeriodFilter.november2026);
      expect(cubit.state.summary.calculatedOutputVatKurus, 20000);
      expect(cubit.state.summary.deductibleExpenseVatKurus, 2000);
      expect(cubit.state.summary.netVatKurus, 18000);

      cubit.selectPeriod(TaxPeriodFilter.q3_2026);
      expect(cubit.state.summary.calculatedOutputVatKurus, 40000);
      expect(cubit.state.summary.approvedExpenseCount, 0);

      cubit.selectPeriod(TaxPeriodFilter.year2026);
      expect(cubit.state.summary.calculatedOutputVatKurus, 60000);

      await cubit.close();
      await expenseRepo.dispose();
    });
  });

  group('CardsManagementCubit, ProfileSettingsCubit & SplashCubit', () {
    test(
      'CardsManagementCubit Luhn kart üretimi, doğrulama, dondurma ve IBAN eklemeyi yönetir',
      () async {
        final cubit = CardsManagementCubit(initialHolderName: 'Deniz Aksoy');

        cubit.prepareAddCardDraft();
        expect(
          FinancialValidators.cardNumber(cubit.cardNumberController.text),
          isNull,
        );
        expect(
          FinancialValidators.expiry(cubit.cardExpiryController.text),
          isNull,
        );
        expect(cubit.cardNumberController.text.startsWith('5400 '), isTrue);

        cubit.setDraftCardType('Metal Kart');
        expect(cubit.cardNumberController.text.startsWith('5124 '), isTrue);

        // Geçersiz kart numarası reddedilir
        final validGenerated = cubit.cardNumberController.text;
        cubit.cardNumberController.text = '4242 4242 4242 4241';
        expect(cubit.createCardFromDraft(), isFalse);
        expect(cubit.state.isSuccessFeedback, isFalse);

        // Geçerli taslak yeni kart oluşturur
        cubit.cardNumberController.text = validGenerated;
        cubit.cardTitleController.text = 'Yurt Dışı Harcama';
        final beforeCount = cubit.state.cards.length;
        expect(cubit.createCardFromDraft(), isTrue);
        expect(cubit.state.cards.length, beforeCount + 1);
        expect(cubit.state.cards.last.cardNumber, validGenerated);

        final targetCard = cubit.state.cards.last;
        cubit.toggleFreezeCard(targetCard);
        expect(cubit.state.cards.last.isFrozen, isTrue);

        cubit.switchDefaultCard(targetCard);
        expect(cubit.state.cards.last.isDefault, isTrue);

        cubit.prepareAddBankDraft();
        cubit.bankNameController.text = 'Ziraat Bankası';
        cubit.ibanController.text = 'TR330006100519786457841326';
        expect(cubit.linkBankAccountFromDraft(), isTrue);
        expect(
          cubit.state.bankAccounts.last.iban,
          'TR33 0006 1005 1978 6457 8413 26',
        );

        await cubit.close();
      },
    );

    test(
      'ProfileSettingsCubit güvenlik tercihleri, tema bildirimi ve PIN doğrulamasını yönetir',
      () async {
        final previousMode = AppTheme.themeModeNotifier.value;
        addTearDown(() => AppTheme.setThemeMode(previousMode));

        final cubit = ProfileSettingsCubit(
          initialUser: const UserEntity(
            uid: 'b2c_1',
            name: 'Deniz Aksoy',
            email: 'deniz@paypulse.app',
            role: AppStrings.roleB2C,
          ),
        );

        cubit.toggleBiometric(true);
        expect(cubit.state.biometricEnabled, isTrue);

        cubit.toggleTwoFactor(false);
        expect(cubit.state.twoFactorEnabled, isFalse);

        cubit.setThemeLabel('Koyu Tema');
        expect(AppTheme.themeModeNotifier.value, ThemeMode.dark);

        cubit.prepareChangePin();
        cubit.oldPinController.text = '1234';
        cubit.newPinController.text = '5678';
        cubit.confirmPinController.text = '9999';
        expect(cubit.submitPinChange(), isFalse);
        expect(cubit.state.isErrorFeedback, isTrue);

        cubit.confirmPinController.text = '5678';
        expect(cubit.submitPinChange(), isTrue);
        expect(cubit.state.isErrorFeedback, isFalse);

        await cubit.close();
      },
    );

    test(
      'SplashCubit gecikme sonunda tamamlanır ve erken kapanmada timer iptal edilir',
      () async {
        final quickCubit = SplashCubit(
          completionDelay: const Duration(milliseconds: 25),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(quickCubit.state.isCompleted, isTrue);
        await quickCubit.close();

        final canceledCubit = SplashCubit(
          completionDelay: const Duration(seconds: 5),
        );
        await canceledCubit.close();
        expect(canceledCubit.state.isCompleted, isFalse);
      },
    );
  });
}

