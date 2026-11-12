import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Firebase Analytics ve Crashlytics merkezi servis sınıfı.
/// Kişisel veya hassas finansal verileri (IBAN, kart no, CVV, parola) ASLA event'lere eklemez.
/// macOS, Android, iOS ve Web platformlarında güvenle çalışır, hata fırlatarak uygulamayı çökertmez.
class AppAnalyticsService {
  AppAnalyticsService._();

  static FirebaseAnalytics? _analytics;
  static FirebaseCrashlytics? _crashlytics;

  static Future<void> initialize() async {
    try {
      _analytics = FirebaseAnalytics.instance;
    } catch (e) {
      debugPrint('FirebaseAnalytics başlatma atlandı: $e');
    }

    try {
      if (!kIsWeb) {
        _crashlytics = FirebaseCrashlytics.instance;
        // Flutter framework hatalarını Crashlytics'e yönlendir
        FlutterError.onError = _crashlytics!.recordFlutterFatalError;
        PlatformDispatcher.instance.onError = (error, stack) {
          _crashlytics?.recordError(error, stack, fatal: true);
          return true;
        };
      }
    } catch (e) {
      debugPrint('FirebaseCrashlytics başlatma atlandı: $e');
    }
  }

  /// 1. Kullanıcı Giriş Olayı
  static Future<void> logLogin({required String method}) async {
    try {
      await _analytics?.logLogin(loginMethod: method);
    } catch (_) {}
  }

  /// 2. Cüzdan / FAST Transfer Olayı (Hassas alıcı ve IBAN bilgisi içermez)
  static Future<void> logWalletTransfer({
    required String currency,
    required int amountKurus,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'wallet_transfer',
        parameters: {
          'currency': currency,
          'amount_major': (amountKurus / 100).toStringAsFixed(2),
        },
      );
    } catch (_) {}
  }

  /// 3. Masraf Oluşturma Olayı
  static Future<void> logExpenseCreated({required int amountKurus}) async {
    try {
      await _analytics?.logEvent(
        name: 'expense_created',
        parameters: {'amount_major': (amountKurus / 100).toStringAsFixed(2)},
      );
    } catch (_) {}
  }

  /// 4. Masraf Onaylama Olayı
  static Future<void> logExpenseApproved({required String status}) async {
    try {
      await _analytics?.logEvent(
        name: 'expense_approved',
        parameters: {'status': status},
      );
    } catch (_) {}
  }

  /// 5. Masraf Reddetme Olayı
  static Future<void> logExpenseRejected() async {
    try {
      await _analytics?.logEvent(name: 'expense_rejected');
    } catch (_) {}
  }

  /// 6. POS Ödeme Olayı
  static Future<void> logPosPayment({
    required String type,
    required String currency,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'pos_payment',
        parameters: {'payment_type': type, 'currency': currency},
      );
    } catch (_) {}
  }

  /// Beklenmeyen hataları Crashlytics'e raporlar
  static void recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
  }) {
    try {
      _crashlytics?.recordError(exception, stack, reason: reason);
    } catch (_) {}
  }
}
