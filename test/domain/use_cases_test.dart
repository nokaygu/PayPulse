import 'package:flutter_test/flutter_test.dart';
import 'package:pay_pulse/core/constants/app_limits.dart';
import 'package:pay_pulse/core/constants/app_strings.dart';
import 'package:pay_pulse/domain/entities/expense_entity.dart';
import 'package:pay_pulse/domain/entities/invoice_entity.dart';
import 'package:pay_pulse/domain/entities/payment_request_entity.dart';
import 'package:pay_pulse/domain/entities/pos_transaction_entity.dart';
import 'package:pay_pulse/domain/entities/safe_recipient_entity.dart';
import 'package:pay_pulse/domain/entities/transaction_entity.dart';
import 'package:pay_pulse/domain/entities/user_entity.dart';
import 'package:pay_pulse/domain/entities/wallet_entity.dart';
import 'package:pay_pulse/domain/repositories/i_expense_repository.dart';
import 'package:pay_pulse/domain/repositories/i_payment_request_repository.dart';
import 'package:pay_pulse/domain/repositories/i_transaction_repository.dart';
import 'package:pay_pulse/domain/use_cases/approve_or_reject_expense_use_case.dart';
import 'package:pay_pulse/domain/use_cases/calculate_vat_summary_use_case.dart';
import 'package:pay_pulse/domain/use_cases/execute_fast_transfer_use_case.dart';
import 'package:pay_pulse/domain/use_cases/execute_pos_payment_use_case.dart';
import 'package:pay_pulse/domain/use_cases/pay_payment_request_use_case.dart';
import 'package:pay_pulse/domain/use_cases/submit_expense_use_case.dart';

class _FakeExpenseRepository implements IExpenseRepository {
  final List<ExpenseEntity> createdExpenses = [];
  String? lastApprovedId;
  String? lastApprovedAccountingCode;
  String? lastApprovedBy;
  String? lastRejectedId;
  String? lastRejectedReason;

  @override
  Future<void> approveExpense({
    required String expenseId,
    String? accountingCode,
    String? approvedBy,
  }) async {
    lastApprovedId = expenseId;
    lastApprovedAccountingCode = accountingCode;
    lastApprovedBy = approvedBy;
  }

  @override
  Future<void> createExpense(ExpenseEntity expense) async {
    createdExpenses.add(expense);
  }

  @override
  Future<List<ExpenseEntity>> getAllExpenses() async => createdExpenses;

  @override
  Future<ExpenseEntity?> getExpenseById(String expenseId) async => null;

  @override
  Future<void> rejectExpense({
    required String expenseId,
    required String rejectReason,
    String? rejectedBy,
  }) async {
    lastRejectedId = expenseId;
    lastRejectedReason = rejectReason;
  }

  @override
  Future<String> uploadReceiptImage({
    required String localFilePath,
    required String expenseId,
  }) async => 'https://cdn.paypulse.local/$expenseId.jpg';

  @override
  Stream<List<ExpenseEntity>> watchCompanyExpenses(String companyId) =>
      const Stream.empty();

  @override
  Stream<List<ExpenseEntity>> watchEmployeeExpenses(String employeeId) =>
      const Stream.empty();
}

class _FakeTransactionRepository implements ITransactionRepository {
  int fastCalls = 0;
  int cardPosCalls = 0;
  int qrPosCalls = 0;

  @override
  Future<TransactionEntity> executeCardPosPayment({
    required String companyId,
    required String maskedCardNumber,
    required int amountKurus,
    String currency = 'TRY',
  }) async {
    cardPosCalls++;
    return TransactionEntity(
      txId: 'pos_card_1',
      senderId: 'customer',
      receiverId: companyId,
      amount: amountKurus,
      currency: currency,
      timestamp: DateTime(2026, 11, 11),
      type: 'pos_payment',
    );
  }

  @override
  Future<TransactionEntity> executeFastTransferByIban({
    required String senderUserId,
    required String targetIban,
    required int amountKurus,
    String currency = 'TRY',
    String? title,
    String? category,
  }) async {
    fastCalls++;
    return TransactionEntity(
      txId: 'fast_1',
      senderId: senderUserId,
      receiverId: 'receiver_1',
      amount: amountKurus,
      currency: currency,
      timestamp: DateTime(2026, 11, 11),
      type: 'fast',
      targetIban: targetIban,
      title: title ?? 'FAST',
      category: category ?? 'FAST Transfer',
    );
  }

  @override
  Future<TransactionEntity> executeQrWalletPayment({
    required String companyId,
    required String payerUserId,
    required int amountKurus,
    String currency = 'TRY',
  }) async {
    qrPosCalls++;
    return TransactionEntity(
      txId: 'pos_qr_1',
      senderId: payerUserId,
      receiverId: companyId,
      amount: amountKurus,
      currency: currency,
      timestamp: DateTime(2026, 11, 11),
      type: 'pos_payment',
    );
  }

  @override
  Future<SafeRecipientEntity?> findRecipientByIban(String rawIban) async =>
      null;

  @override
  Future<List<TransactionEntity>> getAllTransactions() async => const [];

  @override
  Future<List<PosTransactionEntity>> getPosTransactions(
    String companyId,
  ) async => const [];

  @override
  Future<List<SafeRecipientEntity>> getSavedRecipients() async => const [];

  @override
  Future<List<TransactionEntity>> getSentTransactions(String userId) async =>
      const [];

  @override
  Future<TransactionEntity?> getTransactionById(String txId) async => null;

  @override
  Stream<List<TransactionEntity>> watchReceivedTransactions(String userId) =>
      const Stream.empty();

  @override
  Stream<List<TransactionEntity>> watchSentTransactions(String userId) =>
      const Stream.empty();

  @override
  Stream<List<TransactionEntity>> watchUserTransactions(String userId) =>
      const Stream.empty();
}

class _FakePaymentRequestRepository implements IPaymentRequestRepository {
  PaymentRequestEntity? storedRequest;
  int completeCalls = 0;

  @override
  Future<TransactionEntity> completePaymentRequestWithWallet({
    required String requestId,
    required String payerUserId,
  }) async {
    completeCalls++;
    return TransactionEntity(
      txId: 'pay_tx_1',
      senderId: payerUserId,
      receiverId: storedRequest?.merchantId ?? 'merchant_1',
      amount: storedRequest?.amount ?? 0,
      currency: storedRequest?.currency ?? 'TRY',
      timestamp: DateTime(2026, 11, 11),
      type: 'wallet_payment',
      relatedId: requestId,
    );
  }

  @override
  Future<void> createPaymentRequest(PaymentRequestEntity request) async {
    storedRequest = request;
  }

  @override
  Future<List<PaymentRequestEntity>> getAllPaymentRequests() async =>
      storedRequest == null ? const [] : [storedRequest!];

  @override
  Future<PaymentRequestEntity?> getPaymentRequestById(
    String requestId,
  ) async => storedRequest?.requestId == requestId ? storedRequest : null;
}

void main() {
  const validIban = 'TR33 0006 1005 1978 6457 8413 26';

  const b2cUser = UserEntity(
    uid: 'b2c_1',
    name: 'Deniz Aksoy',
    email: 'deniz@paypulse.app',
    role: AppStrings.roleB2C,
  );

  const employeeUser = UserEntity(
    uid: 'emp_1',
    name: 'Mert Can',
    email: 'mert@paypulse.app',
    role: AppStrings.roleEmployee,
    companyId: AppStrings.defaultCompanyId,
    hasB2BAccess: true,
  );

  const adminUser = UserEntity(
    uid: 'adm_1',
    name: 'Ayşe Demir',
    email: 'ayse@paypulse.app',
    role: AppStrings.roleAdmin,
    companyId: AppStrings.defaultCompanyId,
    hasB2BAccess: true,
  );

  group('CalculateVatSummaryUseCase', () {
    const useCase = CalculateVatSummaryUseCase();

    test(
      'Satış KDVsi, gelen fatura KDVsi ve yalnız onaylı masraf KDVlerini netleştirir',
      () {
        final summary = useCase.call(
          invoices: [
            InvoiceEntity(
              invoiceId: 'inv_out',
              companyId: 'comp_1',
              gibInvoiceNo: 'GIB001',
              counterpartyName: 'Müşteri A.Ş.',
              isIncoming: false,
              documentType: 'e_fatura',
              totalAmount: 120000,
              vatAmount: 20000,
              issueDate: DateTime(2026, 11, 5),
            ),
            InvoiceEntity(
              invoiceId: 'inv_in',
              companyId: 'comp_1',
              gibInvoiceNo: 'GIB002',
              counterpartyName: 'AWS Cloud',
              isIncoming: true,
              documentType: 'e_fatura',
              totalAmount: 60000,
              vatAmount: 10000,
              issueDate: DateTime(2026, 11, 6),
            ),
          ],
          expenses: [
            ExpenseEntity(
              expenseId: 'exp_approved',
              employeeId: 'emp_1',
              companyId: 'comp_1',
              amount: 12000,
              vatAmount: 2000,
              receiptImageUrl: '',
              status: 'approved',
              date: DateTime(2026, 11, 7),
            ),
            ExpenseEntity(
              expenseId: 'exp_pending',
              employeeId: 'emp_1',
              companyId: 'comp_1',
              amount: 24000,
              vatAmount: 4000,
              receiptImageUrl: '',
              status: 'pending',
              date: DateTime(2026, 11, 8),
            ),
            ExpenseEntity(
              expenseId: 'exp_rejected',
              employeeId: 'emp_1',
              companyId: 'comp_1',
              amount: 36000,
              vatAmount: 6000,
              receiptImageUrl: '',
              status: 'rejected',
              date: DateTime(2026, 11, 9),
            ),
          ],
        );

        expect(summary.calculatedOutputVatKurus, 20000);
        expect(summary.deductibleInvoiceVatKurus, 10000);
        expect(summary.deductibleExpenseVatKurus, 2000);
        expect(summary.totalDeductibleVatKurus, 12000);
        expect(summary.netVatKurus, 8000);
        expect(summary.hasDeferredVat, isFalse);
        expect(summary.salesBaseKurus, 100000);
        expect(summary.purchaseBaseKurus, 60000);
        expect(summary.approvedExpenseCount, 1);
      },
    );

    test('İndirilecek KDV yüksek olduğunda devreden KDV (negatif net) üretir', () {
      final summary = useCase.call(
        invoices: [
          InvoiceEntity(
            invoiceId: 'inv_in',
            companyId: 'comp_1',
            gibInvoiceNo: 'GIB003',
            counterpartyName: 'Apple TR',
            isIncoming: true,
            documentType: 'e_arsiv',
            totalAmount: 120000,
            vatAmount: 20000,
          ),
        ],
        expenses: const [],
      );

      expect(summary.netVatKurus, -20000);
      expect(summary.hasDeferredVat, isTrue);
    });
  });

  group('SubmitExpenseUseCase', () {
    test('B2C kullanıcı masraf gönderemez', () async {
      final repo = _FakeExpenseRepository();
      final useCase = SubmitExpenseUseCase(repo);

      await expectLater(
        () => useCase.call(
          actor: b2cUser,
          expense: ExpenseEntity(
            expenseId: 'e1',
            employeeId: b2cUser.uid,
            companyId: 'comp_1',
            merchantTitle: 'Ofis Kırtasiye',
            amount: 10000,
            vatAmount: 2000,
            receiptImageUrl: '',
            status: 'pending',
          ),
        ),
        throwsStateError,
      );
      expect(repo.createdExpenses, isEmpty);
    });

    test('Boş tedarikçi adı ve hatalı KDV tutarı reddedilir', () async {
      final repo = _FakeExpenseRepository();
      final useCase = SubmitExpenseUseCase(repo);

      await expectLater(
        () => useCase.call(
          actor: employeeUser,
          expense: ExpenseEntity(
            expenseId: 'e2',
            employeeId: employeeUser.uid,
            companyId: 'comp_1',
            merchantTitle: '   ',
            amount: 10000,
            vatAmount: 2000,
            receiptImageUrl: '',
            status: 'pending',
          ),
        ),
        throwsArgumentError,
      );

      await expectLater(
        () => useCase.call(
          actor: employeeUser,
          expense: ExpenseEntity(
            expenseId: 'e3',
            employeeId: employeeUser.uid,
            companyId: 'comp_1',
            merchantTitle: 'Kahve Dünyası',
            amount: 10000,
            vatAmount: 15000,
            receiptImageUrl: '',
            status: 'pending',
          ),
        ),
        throwsArgumentError,
      );
    });

    test('Yetkili çalışan geçerli masrafı depoya kaydeder', () async {
      final repo = _FakeExpenseRepository();
      final useCase = SubmitExpenseUseCase(repo);
      final expense = ExpenseEntity(
        expenseId: 'e4',
        employeeId: employeeUser.uid,
        companyId: 'comp_1',
        merchantTitle: 'Türk Hava Yolları',
        amount: 240000,
        vatAmount: 40000,
        receiptImageUrl: 'https://cdn.paypulse.local/e4.jpg',
        status: 'pending',
      );

      await useCase.call(actor: employeeUser, expense: expense);
      expect(repo.createdExpenses, [expense]);
    });
  });

  group('ApproveOrRejectExpenseUseCase', () {
    test('Admin dışındaki roller onay ve ret işlemi yapamaz', () async {
      final repo = _FakeExpenseRepository();
      final useCase = ApproveOrRejectExpenseUseCase(repo);
      final pending = ExpenseEntity(
        expenseId: 'exp_1',
        employeeId: 'emp_1',
        companyId: 'comp_1',
        merchantTitle: 'Bulut Sunucu',
        amount: 50000,
        vatAmount: 10000,
        receiptImageUrl: '',
        status: 'pending',
      );

      await expectLater(
        () => useCase.approve(expense: pending, actorRole: AppStrings.roleEmployee),
        throwsStateError,
      );
      await expectLater(
        () => useCase.reject(
          expense: pending,
          actorRole: AppStrings.roleB2C,
          rejectReason: 'Yetkisiz',
        ),
        throwsStateError,
      );
    });

    test('Çift onay ve boş ret gerekçesi engellenir, admin akışı çalışır', () async {
      final repo = _FakeExpenseRepository();
      final useCase = ApproveOrRejectExpenseUseCase(repo);
      final alreadyApproved = ExpenseEntity(
        expenseId: 'exp_done',
        employeeId: 'emp_1',
        companyId: 'comp_1',
        amount: 50000,
        vatAmount: 10000,
        receiptImageUrl: '',
        status: 'approved',
      );
      final awaiting = ExpenseEntity(
        expenseId: 'exp_wait',
        employeeId: 'emp_1',
        companyId: 'comp_1',
        amount: 50000,
        vatAmount: 10000,
        receiptImageUrl: '',
        status: 'ONAY_BEKLIYOR',
      );

      await expectLater(
        () => useCase.approve(expense: alreadyApproved, actorRole: AppStrings.roleAdmin),
        throwsStateError,
      );
      await expectLater(
        () => useCase.reject(
          expense: awaiting,
          actorRole: AppStrings.roleAdmin,
          rejectReason: '  ',
        ),
        throwsArgumentError,
      );

      await useCase.approve(
        expense: awaiting,
        actorRole: AppStrings.roleAdmin,
        actorId: adminUser.uid,
        accountingCode: '770.02',
      );
      expect(repo.lastApprovedId, 'exp_wait');
      expect(repo.lastApprovedAccountingCode, '770.02');
      expect(repo.lastApprovedBy, adminUser.uid);

      await useCase.reject(
        expense: awaiting,
        actorRole: AppStrings.roleAdmin,
        actorId: adminUser.uid,
        rejectReason: 'Fatura okunaksız',
      );
      expect(repo.lastRejectedId, 'exp_wait');
      expect(repo.lastRejectedReason, 'Fatura okunaksız');
    });
  });

  group('ExecuteFastTransferUseCase', () {
    test(
      'Geçersiz IBAN, sıfır tutar, yetersiz bakiye ve onaysız fraud eşiği reddedilir',
      () async {
        final repo = _FakeTransactionRepository();
        final useCase = ExecuteFastTransferUseCase(repo);
        const wallet = WalletEntity(
          walletId: 'w_1',
          ownerId: 'b2c_1',
          balanceTl: 6000000,
          balanceUsd: 0,
          balanceEur: 0,
        );

        await expectLater(
          () => useCase.call(
            senderUserId: 'b2c_1',
            targetIban: 'TR00',
            amountKurus: 10000,
          ),
          throwsArgumentError,
        );

        await expectLater(
          () => useCase.call(
            senderUserId: 'b2c_1',
            targetIban: validIban,
            amountKurus: 0,
          ),
          throwsArgumentError,
        );

        await expectLater(
          () => useCase.call(
            senderUserId: 'b2c_1',
            targetIban: validIban,
            amountKurus: 7000000,
            senderWallet: wallet,
          ),
          throwsStateError,
        );

        await expectLater(
          () => useCase.call(
            senderUserId: 'b2c_1',
            targetIban: validIban,
            amountKurus: AppLimits.fraudLimitInKurus,
            senderWallet: wallet,
            fraudConfirmed: false,
          ),
          throwsStateError,
        );

        final tx = await useCase.call(
          senderUserId: 'b2c_1',
          targetIban: validIban,
          amountKurus: AppLimits.fraudLimitInKurus,
          senderWallet: wallet,
          fraudConfirmed: true,
        );
        expect(tx.amount, AppLimits.fraudLimitInKurus);
        expect(repo.fastCalls, 1);
      },
    );
  });

  group('ExecutePosPaymentUseCase', () {
    test('B2C kart POS tahsilatı açamaz, B2B kart ve QR tahsilatı çalışır', () async {
      final repo = _FakeTransactionRepository();
      final useCase = ExecutePosPaymentUseCase(repo);

      await expectLater(
        () => useCase.executeCard(
          actor: b2cUser,
          companyId: 'comp_1',
          maskedCardNumber: '4242 **** **** 4242',
          amountKurus: 150000,
        ),
        throwsStateError,
      );

      final cardTx = await useCase.executeCard(
        actor: adminUser,
        companyId: 'comp_1',
        maskedCardNumber: '4242 **** **** 4242',
        amountKurus: 150000,
      );
      expect(cardTx.txId, 'pos_card_1');

      final qrTx = await useCase.executeQrWallet(
        companyId: 'comp_1',
        payerUserId: 'b2c_1',
        amountKurus: 85000,
      );
      expect(qrTx.txId, 'pos_qr_1');
      expect(repo.cardPosCalls, 1);
      expect(repo.qrPosCalls, 1);
    });
  });

  group('PayPaymentRequestUseCase', () {
    test('Bulunamayan, tamamlanmış veya yetersiz bakiyeli talepler reddedilir', () async {
      final repo = _FakePaymentRequestRepository();
      final useCase = PayPaymentRequestUseCase(repo);
      const lowWallet = WalletEntity(
        walletId: 'w_1',
        ownerId: 'b2c_1',
        balanceTl: 10000,
        balanceUsd: 0,
        balanceEur: 0,
      );

      await expectLater(
        () => useCase.call(requestId: 'missing', payerUserId: 'b2c_1'),
        throwsException,
      );

      repo.storedRequest = const PaymentRequestEntity(
        requestId: 'req_done',
        merchantId: 'comp_1',
        amount: 5000,
        currency: 'TRY',
        status: 'completed',
        description: 'Kahve',
      );
      await expectLater(
        () => useCase.call(requestId: 'req_done', payerUserId: 'b2c_1'),
        throwsStateError,
      );

      repo.storedRequest = const PaymentRequestEntity(
        requestId: 'req_pending',
        merchantId: 'comp_1',
        amount: 50000,
        currency: 'TRY',
        status: 'pending',
        description: 'Fatura Tahsilatı',
      );
      await expectLater(
        () => useCase.call(
          requestId: 'req_pending',
          payerUserId: 'b2c_1',
          payerWallet: lowWallet,
        ),
        throwsStateError,
      );

      final tx = await useCase.call(
        requestId: 'req_pending',
        payerUserId: 'b2c_1',
        payerWallet: lowWallet.copyWith(balanceTl: 100000),
      );
      expect(tx.relatedId, 'req_pending');
      expect(repo.completeCalls, 1);
    });
  });
}
