import 'package:flutter_test/flutter_test.dart';
import 'package:pay_pulse/core/utils/qr_payload_parser.dart';

void main() {
  group('PayPulseQrPayload (B2C & B2B 48sn Dinamik QR Testleri)', () {
    test('B2C QR verisi doğru üretilmeli ve ayrıştırılabilmeli (48sn TTL)', () {
      final now = DateTime.now();
      final token = PayPulseQrPayload.generateDynamicToken(prefix: 'PPB2C');
      final raw = PayPulseQrPayload.buildB2cPayload(
        userId: 'user_deniz_aksoy',
        userName: 'Deniz Aksoy',
        customerNo: 'PP-849201',
        iban: 'TR42 0006 2000 8492 0100 0000 01',
        token: token,
        generatedAt: now,
        amount: 250.0,
      );

      final parsed = PayPulseQrPayload.tryParse(raw);
      expect(parsed, isNotNull);
      expect(parsed!.mode, equals('B2C'));
      expect(parsed.userId, equals('user_deniz_aksoy'));
      expect(parsed.userName, equals('Deniz Aksoy'));
      expect(parsed.customerNo, equals('PP-849201'));
      expect(parsed.amount, equals(250.0));
      expect(parsed.token, equals(token));
      expect(parsed.isExpired(now: now), isFalse);
      expect(
        parsed.isExpired(now: now.add(const Duration(seconds: 49))),
        isTrue,
      );
    });

    test('B2B POS QR verisi doğru üretilmeli ve ayrıştırılabilmeli (48sn TTL)', () {
      final now = DateTime.now();
      final token = PayPulseQrPayload.generateDynamicToken(prefix: 'PPPOS');
      final raw = PayPulseQrPayload.buildB2bPosPayload(
        merchantName: 'Nova Tasarım Ltd.',
        companyId: 'comp_techsolutions_01',
        terminalId: 'POS-TR-8492',
        amount: 3750.00,
        installment: 3,
        description: 'Web Tasarım Hizmet Bedeli - FTR-2026-08',
        token: token,
        generatedAt: now,
      );

      final parsed = PayPulseQrPayload.tryParse(raw);
      expect(parsed, isNotNull);
      expect(parsed!.mode, equals('B2B_POS'));
      expect(parsed.merchantName, equals('Nova Tasarım Ltd.'));
      expect(parsed.companyId, equals('comp_techsolutions_01'));
      expect(parsed.terminalId, equals('POS-TR-8492'));
      expect(parsed.amount, equals(3750.00));
      expect(parsed.installment, equals(3));
      expect(parsed.token, equals(token));
      expect(parsed.isExpired(now: now), isFalse);
      expect(
        parsed.isExpired(now: now.add(const Duration(seconds: 49))),
        isTrue,
      );
    });
  });
}

