import 'package:flutter_test/flutter_test.dart';
import 'package:pay_pulse/core/utils/financial_amount.dart';
import 'package:pay_pulse/core/validators/financial_validators.dart';

void main() {
  group('Luhn', () {
    test('Geçerli 16 haneli kart kabul edilir', () {
      expect(
        FinancialValidators.cardNumber('4242 4242 4242 4242'),
        isNull,
      );
    });

    test('Yanlış kontrol rakamı reddedilir', () {
      expect(
        FinancialValidators.cardNumber('4242 4242 4242 4241'),
        isNotNull,
      );
    });

    test('Görselde belirtilen numara Luhn geçerli değildir', () {
      expect(
        FinancialValidators.isLuhnValid('5400 8291 3847 8912'),
        isFalse,
      );
    });

    test('Eksik kart ve sıfırlardan oluşan kart reddedilir', () {
      expect(
        FinancialValidators.cardNumber('4242'),
        isNotNull,
      );

      expect(
        FinancialValidators.cardNumber('0000 0000 0000 0000'),
        isNotNull,
      );
    });
  });

  group('TR IBAN', () {
    test('Geçerli IBAN kabul edilir', () {
      expect(
        FinancialValidators.iban(
          'TR33 0006 1005 1978 6457 8413 26',
        ),
        isNull,
      );
    });

    test('Yanlış uzunluk reddedilir', () {
      expect(
        FinancialValidators.iban('TR330006'),
        isNotNull,
      );
    });

    test('26 karakter olsa da yanlış kontrol rakamı reddedilir', () {
      expect(
        FinancialValidators.iban(
          'TR330006100519786457841327',
        ),
        isNotNull,
      );
    });
  });

  group('Tutar ve bakiye', () {
    test('Türkçe tutar kuruşa doğru çevrilir', () {
      expect(FinancialAmount.parse('1.500,25'), 150025);
      expect(FinancialAmount.parse('1500,25'), 150025);
      expect(FinancialAmount.parse('0,01'), 1);
      expect(FinancialAmount.parse('1.50'), isNull);
      expect(FinancialAmount.parse('1500,001'), isNull);
    });

    test('Bakiye üstü transfer reddedilir', () {
      expect(
        FinancialValidators.amount(
          '24850,01',
          balanceKurus: 2485000,
        ),
        isNotNull,
      );
    });

    test('Bakiyenin tamamı gönderilebilir', () {
      expect(
        FinancialAmount.balanceAfter(
          balanceKurus: 2485000,
          amountKurus: 2485000,
        ),
        0,
      );
    });

    test('Bakiye negatife düşürülemez', () {
      expect(
        () => FinancialAmount.balanceAfter(
          balanceKurus: 2485000,
          amountKurus: 2485001,
        ),
        throwsStateError,
      );
    });

    test('1500 TL transfer sonrası 23350 TL kalır', () {
      expect(
        FinancialAmount.balanceAfter(
          balanceKurus: 2485000,
          amountKurus: 150000,
        ),
        2335000,
      );
    });

    test('Sıfır ve negatif transfer reddedilir', () {
      for (final amount in [0, -1]) {
        expect(
          () => FinancialAmount.balanceAfter(
            balanceKurus: 100,
            amountKurus: amount,
          ),
          throwsArgumentError,
        );
      }
    });

    test('Para biçimi ve yazıyla tutar', () {
      expect(FinancialAmount.format(2335000), '₺23.350,00');

      expect(
        FinancialAmount.inWords(150000),
        'Bin Beş Yüz Türk Lirası',
      );
    });
  });

  group('POS komisyonu', () {
    test('3750 TL için yüzde 1,39 komisyon 52,13 TL', () {
      expect(
        FinancialAmount.posCommission(375000),
        5213,
      );
    });

    test('100 TL komisyonu 1,39 TL', () {
      expect(FinancialAmount.posCommission(10000), 139);
    });

    test('Negatif tutar reddedilir', () {
      expect(
        () => FinancialAmount.posCommission(-1),
        throwsArgumentError,
      );
    });
  });

  group('Son kullanma tarihi', () {
    final now = DateTime(2026, 11, 12);

    test('İçinde bulunulan ay geçerlidir', () {
      expect(
        FinancialValidators.expiry('11 / 26', now: now),
        isNull,
      );
    });

    test('Önceki ay ve geçersiz ay reddedilir', () {
      expect(
        FinancialValidators.expiry('10 / 26', now: now),
        isNotNull,
      );

      expect(
        FinancialValidators.expiry('13 / 28', now: now),
        isNotNull,
      );
    });
  });
}