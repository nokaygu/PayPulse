import 'dart:math';

/// PayPulse B2C & B2B TR Karekod / QR Veri Modeli ve Ayrıştırıcısı (Parser)
/// - 48 saniyelik dinamik güvenlik ömrü (TTL) kontrolü
/// - B2B Sanal POS (`PAYPULSE://TRKAREKOD/B2B_POS?...`) ve B2C Cüzdan (`PAYPULSE://TRKAREKOD/B2C?...`)
///   ile genel TR Karekod / IBAN / JSON verilerini okuma ve doğrulama
class PayPulseQrPayload {
  static const int defaultTtlSeconds = 48;

  final String mode; // 'B2B_POS', 'B2C', 'EXTERNAL'
  final String version;
  final String? merchantName;
  final String? companyId;
  final String? terminalId;
  final String? userId;
  final String? userName;
  final String? customerNo;
  final String? iban;
  final double amount;
  final String currency;
  final int installment;
  final String? description;
  final String token;
  final int expiresAtEpochMs;
  final String rawPayload;

  const PayPulseQrPayload({
    required this.mode,
    this.version = '1',
    this.merchantName,
    this.companyId,
    this.terminalId,
    this.userId,
    this.userName,
    this.customerNo,
    this.iban,
    required this.amount,
    this.currency = 'TRY',
    this.installment = 1,
    this.description,
    required this.token,
    required this.expiresAtEpochMs,
    required this.rawPayload,
  });

  /// QR kodun 48 saniyelik geçerlilik süresinin dolup dolmadığını kontrol eder.
  bool isExpired({DateTime? now}) {
    if (expiresAtEpochMs <= 0) return false;
    final currentMs = (now ?? DateTime.now()).millisecondsSinceEpoch;
    return currentMs > expiresAtEpochMs;
  }

  /// Kalan geçerlilik süresini saniye cinsinden döndürür (0..48).
  int remainingSeconds({DateTime? now}) {
    if (expiresAtEpochMs <= 0) return defaultTtlSeconds;
    final currentMs = (now ?? DateTime.now()).millisecondsSinceEpoch;
    final diffSec = ((expiresAtEpochMs - currentMs) / 1000).ceil();
    return diffSec.clamp(0, defaultTtlSeconds);
  }

  /// Kısa referans kodu (Son 8 karakter)
  String get shortToken {
    if (token.length <= 8) return token;
    return token.substring(token.length - 8);
  }

  /// 48 saniyelik benzersiz güvenlik token'ı üretir.
  static String generateDynamicToken({required String prefix}) {
    final random = Random();
    final randomHex = List.generate(
      8,
      (_) => random.nextInt(16).toRadixString(16).toUpperCase(),
    ).join();
    final epochSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return '$prefix-$epochSec-$randomHex';
  }

  /// B2C Bireysel Cüzdan için 48sn ömürlü gerçek QR veri metni oluşturur.
  static String buildB2cPayload({
    required String userId,
    required String userName,
    required String customerNo,
    required String iban,
    required String token,
    required DateTime generatedAt,
    double? amount,
    String currency = 'TRY',
    int ttlSeconds = defaultTtlSeconds,
  }) {
    final expiresAt = generatedAt.add(Duration(seconds: ttlSeconds));
    final amountStr = amount != null ? amount.toStringAsFixed(2) : '0.00';

    return 'PAYPULSE://TRKAREKOD/B2C'
        '?v=1'
        '&uid=${Uri.encodeComponent(userId)}'
        '&name=${Uri.encodeComponent(userName)}'
        '&cust=${Uri.encodeComponent(customerNo)}'
        '&iban=${Uri.encodeComponent(iban.replaceAll(' ', ''))}'
        '&amt=$amountStr'
        '&curr=$currency'
        '&token=$token'
        '&exp=${expiresAt.millisecondsSinceEpoch}';
  }

  /// B2B Sanal POS Terminali için 48sn ömürlü gerçek QR veri metni oluşturur.
  static String buildB2bPosPayload({
    required String merchantName,
    required String companyId,
    required String terminalId,
    required double amount,
    required int installment,
    required String description,
    required String token,
    required DateTime generatedAt,
    String currency = 'TRY',
    int ttlSeconds = defaultTtlSeconds,
  }) {
    final expiresAt = generatedAt.add(Duration(seconds: ttlSeconds));
    return 'PAYPULSE://TRKAREKOD/B2B_POS'
        '?v=1'
        '&merchant=${Uri.encodeComponent(merchantName)}'
        '&companyId=${Uri.encodeComponent(companyId)}'
        '&terminal=${Uri.encodeComponent(terminalId)}'
        '&amt=${amount.toStringAsFixed(2)}'
        '&curr=$currency'
        '&inst=$installment'
        '&desc=${Uri.encodeComponent(description.trim())}'
        '&token=$token'
        '&exp=${expiresAt.millisecondsSinceEpoch}';
  }

  /// Okutulan veya yapıştırılan ham QR metnini ayrıştırır (parse eder).
  static PayPulseQrPayload? tryParse(String rawInput) {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) return null;

    // 1. PayPulse URI Formatı: PAYPULSE://TRKAREKOD/B2B_POS?... veya PAYPULSE://TRKAREKOD/B2C?...
    final uri = Uri.tryParse(trimmed);
    if (uri != null &&
        (uri.scheme.toUpperCase() == 'PAYPULSE' ||
            trimmed.toUpperCase().startsWith('PAYPULSE://'))) {
      final qp = uri.queryParameters;
      final pathUpper = '${uri.host}/${uri.path}'.toUpperCase();
      final isB2b = pathUpper.contains('B2B');

      final parsedAmount =
          double.tryParse((qp['amt'] ?? '0').replaceAll(',', '.')) ?? 0.0;
      final parsedInst = int.tryParse(qp['inst'] ?? '1') ?? 1;
      final parsedExp = int.tryParse(qp['exp'] ?? '0') ?? 0;
      final token = qp['token'] ??
          generateDynamicToken(prefix: isB2b ? 'PPPOS' : 'PPB2C');

      return PayPulseQrPayload(
        mode: isB2b ? 'B2B_POS' : 'B2C',
        version: qp['v'] ?? '1',
        merchantName: qp['merchant'],
        companyId: qp['companyId'] ?? 'comp_techsolutions_01',
        terminalId: qp['terminal'] ?? 'POS-TR-8492',
        userId: qp['uid'],
        userName: qp['name'],
        customerNo: qp['cust'],
        iban: qp['iban'],
        amount: parsedAmount,
        currency: qp['curr'] ?? 'TRY',
        installment: parsedInst,
        description: qp['desc'],
        token: token,
        expiresAtEpochMs: parsedExp,
        rawPayload: trimmed,
      );
    }

    // 2. Doğrudan TR IBAN içeriyorsa
    final ibanMatch = RegExp(
      r'TR\d{2}\s?\d{4}\s?\d{4}\s?\d{4}\s?\d{4}\s?\d{4}\s?\d{2}',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (ibanMatch != null) {
      final extractedIban = ibanMatch.group(0)!.replaceAll(' ', '').toUpperCase();
      return PayPulseQrPayload(
        mode: 'B2C',
        userName: 'TR Karekod IBAN Alıcısı',
        customerNo: 'FAST-IBAN',
        iban: extractedIban,
        amount: 0.0,
        token: 'TRQR-${extractedIban.substring(extractedIban.length - 6)}',
        expiresAtEpochMs:
            DateTime.now().millisecondsSinceEpoch + (defaultTtlSeconds * 1000),
        rawPayload: trimmed,
      );
    }

    // 3. Genel / Harici Karekod Metni
    final fallbackToken = trimmed.length > 10
        ? trimmed.substring(trimmed.length - 8).toUpperCase()
        : trimmed.toUpperCase();
    return PayPulseQrPayload(
      mode: 'EXTERNAL',
      merchantName: 'TR Karekod Üye İşyeri',
      companyId: 'comp_techsolutions_01',
      terminalId: 'POS-TR-8492',
      amount: 3750.00,
      description: trimmed.length > 48 ? '${trimmed.substring(0, 48)}...' : trimmed,
      token: 'EXT-$fallbackToken',
      expiresAtEpochMs:
          DateTime.now().millisecondsSinceEpoch + (defaultTtlSeconds * 1000),
      rawPayload: trimmed,
    );
  }
}

