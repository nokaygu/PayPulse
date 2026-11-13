import 'package:flutter_test/flutter_test.dart';
import 'package:pay_pulse/data/datasources/remote/local_demo_data_service.dart';
import 'package:pay_pulse/data/models/expense_model.dart';

void main() {
  group('LocalDemoDataService Finansal Simülasyon Testleri', () {
    late LocalDemoDataService service;

    setUp(() {
      service = LocalDemoDataService.instance;
    });

    test('1. Başlangıç Kullanıcı ve Cüzdan Bakiyeleri Doğrulama', () {
      final b2cUser = service.getUserProfile('user_deniz_aksoy');
      expect(b2cUser, isNotNull);
      expect(b2cUser?.name, 'Deniz Aksoy');

      final b2cWallet = service.getUserWallet('user_deniz_aksoy');
      expect(b2cWallet, isNotNull);
      expect(b2cWallet?.balanceTl, 1250000); // ₺12.500,00
      expect(b2cWallet?.balanceUsd, 50000); // $500,00
      expect(b2cWallet?.balanceEur, 30000); // €300,00

      final empWallet = service.getUserWallet('user_employee_ahmet');
      expect(empWallet, isNotNull);
      expect(empWallet?.balanceTl, 500000); // ₺5.000,00

      final adminWallet = service.getUserWallet('user_admin_ali');
      expect(adminWallet, isNotNull);
      expect(adminWallet?.balanceTl, 1000000); // ₺10.000,00

      final compWallet = service.getWallet('wallet_comp_paypulse_tech');
      expect(compWallet, isNotNull);
      expect(compWallet?.balanceTl, 5000000); // ₺50.000,00 Şirket Kasası
    });

    test('2. FAST Para Transferi ve Bakiye Güncellemesi', () async {
      final initialSender = service.getUserWallet('user_deniz_aksoy')!.balanceTl;
      final initialReceiver = service.getUserWallet('user_employee_ahmet')!.balanceTl;

      const transferAmount = 100000; // ₺1.000,00

      final tx = await service.executeFastTransferByIban(
        senderUserId: 'user_deniz_aksoy',
        targetIban: 'TR18 0006 2000 8492 0100 0000 02',
        amountKurus: transferAmount,
      );

      expect(tx.status, 'Başarılı');
      expect(tx.amount, transferAmount);

      final updatedSender = service.getUserWallet('user_deniz_aksoy')!.balanceTl;
      final updatedReceiver = service.getUserWallet('user_employee_ahmet')!.balanceTl;

      expect(updatedSender, initialSender - transferAmount);
      expect(updatedReceiver, initialReceiver + transferAmount);
    });

    test('3. Geçersiz IBAN ile FAST Transfer Hata Vermelidir', () async {
      expect(
        () => service.executeFastTransferByIban(
          senderUserId: 'user_deniz_aksoy',
          targetIban: 'TR99 9999 9999 9999 9999 9999 99',
          amountKurus: 50000,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('4. Masraf Oluşturma, Onaylama ve Çift Onay Engeli (İdempotency)', () async {
      final compSafeBefore = service.getWallet('wallet_comp_paypulse_tech')!.balanceTl;
      final empBalanceBefore = service.getUserWallet('user_employee_ahmet')!.balanceTl;

      const expenseAmount = 40000; // ₺400,00
      final expense = ExpenseModel(
        expenseId: 'exp_test_unit_1',
        employeeId: 'user_employee_ahmet',
        employeeName: 'Ahmet Yılmaz',
        merchantTitle: 'Ofis Kırtasiye',
        category: 'Ofis',
        companyId: 'comp_paypulse_tech',
        amount: expenseAmount,
        vatAmount: 8000,
        receiptImageUrl: '',
        status: 'pending',
      );

      await service.createExpense(expense);
      expect(service.getExpense('exp_test_unit_1')?.status, 'pending');

      // Onayla
      await service.approveExpense(expenseId: 'exp_test_unit_1');
      expect(service.getExpense('exp_test_unit_1')?.status, 'approved');

      // Şirket kasasından düşmeli, çalışan cüzdanına eklenmeli
      final compSafeAfter = service.getWallet('wallet_comp_paypulse_tech')!.balanceTl;
      final empBalanceAfter = service.getUserWallet('user_employee_ahmet')!.balanceTl;

      expect(compSafeAfter, compSafeBefore - expenseAmount);
      expect(empBalanceAfter, empBalanceBefore + expenseAmount);

      // İkinci kez onaylanamaz (İdempotency)
      expect(
        () => service.approveExpense(expenseId: 'exp_test_unit_1'),
        throwsA(isA<StateError>()),
      );
    });

    test('5. Masraf Reddetme Gerekçeli Olmalıdır', () async {
      final expense = ExpenseModel(
        expenseId: 'exp_test_unit_reject',
        employeeId: 'user_employee_ahmet',
        employeeName: 'Ahmet Yılmaz',
        merchantTitle: 'Lüks Otel',
        category: 'Konaklama',
        companyId: 'comp_paypulse_tech',
        amount: 50000,
        vatAmount: 10000,
        receiptImageUrl: '',
        status: 'pending',
      );

      await service.createExpense(expense);
      await service.rejectExpense(
        expenseId: 'exp_test_unit_reject',
        rejectReason: 'Şirket seyahat limitini aşıyor.',
      );

      final rejected = service.getExpense('exp_test_unit_reject');
      expect(rejected?.status, 'rejected');
      expect(rejected?.rejectReason, 'Şirket seyahat limitini aşıyor.');
    });

    test('6. Sanal POS Tahsilatı Komisyon ve Kasa Güncellemesi', () async {
      final compSafeBefore = service.getWallet('wallet_comp_paypulse_tech')!.balanceTl;
      const amount = 100000; // ₺1.000,00
      const commission = (100000 * 139) ~/ 10000; // ₺13,90 (1390 kuruş)
      const expectedNet = amount - commission; // 98610 kuruş

      final tx = await service.executeCardPosPayment(
        companyId: 'comp_paypulse_tech',
        maskedCardNumber: '•••• •••• •••• 1234',
        amountKurus: amount,
      );

      expect(tx.status, 'Başarılı');
      expect(tx.amount, amount);

      final compSafeAfter = service.getWallet('wallet_comp_paypulse_tech')!.balanceTl;
      expect(compSafeAfter, compSafeBefore + expectedNet);
    });
  });
}

