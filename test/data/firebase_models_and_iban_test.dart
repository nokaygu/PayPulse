import 'package:flutter_test/flutter_test.dart';
import 'package:pay_pulse/core/utils/iban_generator.dart';
import 'package:pay_pulse/core/validators/financial_validators.dart';
import 'package:pay_pulse/data/models/notification_model.dart';
import 'package:pay_pulse/data/models/safe_recipient_model.dart';
import 'package:pay_pulse/data/models/transaction_model.dart';
import 'package:pay_pulse/data/models/wallet_model.dart';

void main() {
  group('IbanGenerator ve TR Standartları', () {
    test(
      'Kullanıcı ID için üretilen IBAN tam 26 karakter ve TR ile başlar',
      () {
        final iban = IbanGenerator.generateForUser('user_test_123');

        expect(iban.length, 26);
        expect(iban.startsWith('TR'), isTrue);
      },
    );

    test('Üretilen IBAN FinancialValidators.iban mod-97 kuralından başarıyla geçer', () {
      final iban1 = IbanGenerator.generateForUser('uid_eren_1');
      final iban2 = IbanGenerator.generateForUser('uid_abdullah_2');
      final iban3 = IbanGenerator.generateForUser('uid_betul_3');

      expect(
        FinancialValidators.iban(iban1),
        isNull,
        reason: '$iban1 geçerli olmalı',
      );
      expect(
        FinancialValidators.iban(iban2),
        isNull,
        reason: '$iban2 geçerli olmalı',
      );
      expect(
        FinancialValidators.iban(iban3),
        isNull,
        reason: '$iban3 geçerli olmalı',
      );
    });

    test('Farklı kullanıcılar için benzersiz hesap numaraları türetilir', () {
      final ibanA = IbanGenerator.generateForUser('alice_123');
      final ibanB = IbanGenerator.generateForUser('bob_456');

      expect(ibanA, isNot(equals(ibanB)));
    });
  });

  group('SafeRecipientModel', () {
    test('JSON serileştirme ve veri minimizasyonu', () {
      const model = SafeRecipientModel(
        userId: 'user_99',
        maskedName: 'A*** B****',
        iban: 'TR330006100519786457841326',
      );

      final json = model.toJson();
      expect(json['userId'], 'user_99');
      expect(json['maskedName'], 'A*** B****');
      expect(json['iban'], 'TR330006100519786457841326');
      // Hassas veri alanlarının modelde bulunmadığı doğrulanır
      expect(json.containsKey('balance'), isFalse);
      expect(json.containsKey('email'), isFalse);
    });
  });

  group('WalletModel Finansal Hassasiyet', () {
    test('Bakiyeler en küçük para birimi (kuruş) cinsinden tam sayı olarak korunur', () {
      final wallet = WalletModel(
        walletId: 'wallet_1',
        ownerId: 'user_1',
        balanceTl: 15050, // 150.50 TL
        balanceUsd: 1000, // 10.00 USD
        balanceEur: 0,
      );

      final json = wallet.toJson();
      expect(json['balanceTl'], 15050);
      expect(json['balanceUsd'], 1000);
      expect(json['balanceEur'], 0);

      final fromJson = WalletModel.fromJson(json);
      expect(fromJson.balanceTl, 15050);
    });
  });

  group('NotificationModel Serileştirme ve Deterministik Yapı', () {
    test('NotificationModel alanları ve Timestamp uyumu', () {
      final notif = NotificationModel(
        notificationId: 'notif_tx_12345',
        userId: 'user_receiver_1',
        title: 'Para Transferi Alındı',
        body: '150,00 TL hesabınıza ulaştı.',
        type: 'transfer_received',
        createdAt: DateTime(2026, 11, 13, 15, 00),
        relatedId: 'tx_12345',
      );

      final json = notif.toJson();
      expect(json['notificationId'], 'notif_tx_12345');
      expect(json['userId'], 'user_receiver_1');
      expect(json['isRead'], isFalse);
      expect(json['relatedId'], 'tx_12345');

      final parsed = NotificationModel.fromJson({
        'notificationId': 'notif_tx_12345',
        'userId': 'user_receiver_1',
        'title': 'Para Transferi Alındı',
        'body': '150,00 TL hesabınıza ulaştı.',
        'type': 'transfer_received',
        'isRead': false,
        'createdAt': '2026-11-13T15:00:00.000',
        'relatedId': 'tx_12345',
      });

      expect(parsed.notificationId, 'notif_tx_12345');
      expect(parsed.isRead, isFalse);
      expect(parsed.type, 'transfer_received');
    });

    test('Okundu işaretleme copyWith ile doğrulanır', () {
      final notif = NotificationModel(
        notificationId: 'notif_1',
        userId: 'user_1',
        title: 'Masraf Onaylandı',
        body: 'Onaylandı',
        type: 'expense_approved',
        createdAt: DateTime.now(),
      );

      final updated = notif.copyWith(isRead: true);
      expect(updated.isRead, isTrue);
      expect(updated.notificationId, 'notif_1');
    });
  });

  group('TransactionModel Zaman ve Tip Desteği', () {
    test('Hem String hem DateTime hem de timestamp formatlarını destekler', () {
      final tx = TransactionModel(
        txId: 'tx_001',
        senderId: 'user_a',
        receiverId: 'user_b',
        amount: 25000,
        currency: 'TRY',
        timestamp: DateTime(2026, 11, 13, 14, 30),
        type: 'fast',
      );

      final json = tx.toJson();
      final parsed = TransactionModel.fromJson(json);
      expect(parsed.txId, 'tx_001');
      expect(parsed.amount, 25000);
      expect(parsed.type, 'fast');
      expect(parsed.timestamp.year, 2026);
    });
  });
}
