import 'package:flutter_test/flutter_test.dart';
import 'package:pay_pulse/data/datasources/remote/firebase_firestore_datasource.dart';
import 'package:pay_pulse/data/models/expense_model.dart';
import 'package:pay_pulse/data/models/safe_recipient_model.dart';

void main() {
  group('1. Güvenli IBAN Arama ve Veri İfşasını Engelleme', () {
    test('İsim maskeleme algoritması doğru çalışır', () {
      expect(
        FirebaseFirestoreDatasource.maskName('Deniz Aksoy'),
        'D**** A****',
      );
      expect(
        FirebaseFirestoreDatasource.maskName('Ali Can Veli'),
        'A** C** V***',
      );
      expect(FirebaseFirestoreDatasource.maskName('A'), 'A');
      expect(FirebaseFirestoreDatasource.maskName('   '), 'Kullanıcı');
    });

    test('SafeRecipientModel asla bakiye, e-posta veya FCM token taşımaz', () {
      const recipient = SafeRecipientModel(
        userId: 'user_bob',
        maskedName: 'B** D****',
        iban: 'TR330006100519786457841326',
      );

      final json = recipient.toJson();
      expect(json.keys, containsAll(['userId', 'maskedName', 'iban']));
      expect(json.keys.length, 3);
      expect(json.containsKey('balance'), isFalse);
      expect(json.containsKey('email'), isFalse);
      expect(json.containsKey('fcmToken'), isFalse);
    });
  });

  group('2. Masraf Modeli Doğrulama', () {
    test('Masraf modeli KDV ve tutar ilişkisi kuruş bazında korunur', () {
      final expense = ExpenseModel(
        expenseId: 'exp_1',
        employeeId: 'emp_1',
        companyId: 'comp_1',
        amount: 25000, // 250.00 TL
        vatAmount: 5000, // 50.00 TL (%20)
        receiptImageUrl: '/data/user/0/com.paypulse/cache/receipt_1.jpg',
        status: 'pending',
      );

      final json = expense.toJson();
      expect(json['amount'], 25000);
      expect(json['vatAmount'], 5000);
      expect(json['status'], 'pending');
      expect(json['receiptImageUrl'], contains('receipt_1.jpg'));
    });
  });

  group('3. POS Para Birimi ve Bakiye Eşlemesi', () {
    test('Para birimleri doğru bakiye alanlarına eşlenir', () {
      expect(FirebaseFirestoreDatasource.getBalanceField('TRY'), 'balanceTl');
      expect(FirebaseFirestoreDatasource.getBalanceField('tl'), 'balanceTl');
      expect(FirebaseFirestoreDatasource.getBalanceField('USD'), 'balanceUsd');
      expect(FirebaseFirestoreDatasource.getBalanceField('usd'), 'balanceUsd');
      expect(FirebaseFirestoreDatasource.getBalanceField('EUR'), 'balanceEur');
      expect(FirebaseFirestoreDatasource.getBalanceField('eur'), 'balanceEur');
    });
  });
}
