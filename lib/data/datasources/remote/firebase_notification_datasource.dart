import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_firestore_datasource.dart';

/// Push bildirim servisi.
/// Android üzerinde FCM ve flutter_local_notifications ile tam teşekküllü çalışır.
/// macOS ve iOS üzerinde (Apple Developer hesabı/APNs gerekmediği için) sessizce atlanır,
/// uygulamanın açılışını veya oturum akışlarını kesinlikle engellemez.
class FirebaseNotificationDatasource {
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin get _localNotifications =>
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'paypulse_notifications',
    'PayPulse Bildirimleri',
    description: 'PayPulse uygulama bildirimleri',
    importance: Importance.high,
  );

  /// Kullanıcıdan bildirim izni ister (Yalnızca Android).
  Future<void> requestNotificationPermission() async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('Bildirim izni: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('Bildirim izni isteme atlandı: $e');
    }
  }

  /// Cihazın FCM token değerini getirir (Yalnızca Android).
  Future<String?> getFcmToken() async {
    if (kIsWeb || !Platform.isAndroid) return null;

    try {
      // FCM cihaz token backend uyumluluğu için korunuyor (firebase_messaging 17 FID API'ye geçiş öncesi).
      // ignore: deprecated_member_use
      final token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('FCM token alma hatası: $e');
      return null;
    }
  }

  /// Android yerel bildirimlerini hazırlar.
  Future<void> initializeLocalNotifications() async {
    if (kIsWeb || !Platform.isAndroid) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(settings: initializationSettings);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  /// Uygulama açıkken gelen bildirimleri dinler (Yalnızca Android).
  void listenForegroundMessages() {
    if (kIsWeb || !Platform.isAndroid) return;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;

      if (notification != null) {
        await _localNotifications.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  /// Bildirim altyapısını başlatır.
  /// macOS ve iOS üzerinde Apple Developer/APNs bağımlılığı olmaksızın güvenle atlanır.
  Future<void> initialize() async {
    if (kIsWeb || !Platform.isAndroid) {
      debugPrint(
        'FCM ve Local Notifications yalnızca Android üzerinde aktiftir (macOS/iOS/Web atlandı).',
      );
      return;
    }

    try {
      await requestNotificationPermission();
      await initializeLocalNotifications();
      await getFcmToken();
      listenForegroundMessages();
      listenTokenRefresh();
      await saveTokenToFirestore();
      debugPrint('Firebase bildirim servisi başlatıldı (Android).');
    } catch (e) {
      debugPrint('FCM başlatma hatası: $e');
    }
  }

  /// Giriş yapan kullanıcının FCM token'ını kaydeder (Yalnızca Android).
  Future<void> saveTokenToFirestore() async {
    if (kIsWeb || !Platform.isAndroid) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // FCM cihaz token backend uyumluluğu için korunuyor (firebase_messaging 17 FID API'ye geçiş öncesi).
      // ignore: deprecated_member_use
      final token = await _messaging.getToken();
      if (token == null) return;

      final firestoreService = FirebaseFirestoreDatasource();
      await firestoreService.updateFcmToken(user.uid, token);
      debugPrint('FCM token Firestore’a kaydedildi.');
    } catch (e) {
      debugPrint('FCM token kaydetme hatası: $e');
    }
  }

  /// Çıkış anında FCM token'ını siler (Yalnızca Android).
  /// macOS veya iOS'tan çıkış yapıldığında kullanıcının Android cihazındaki token'ı silinmez!
  Future<void> deleteTokenOnLogout(String uid) async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      final firestoreService = FirebaseFirestoreDatasource();
      await firestoreService.deleteFcmToken(uid);
      debugPrint('Android FCM token oturum çıkışıyla silindi.');
    } catch (e) {
      debugPrint('Token silme hatası: $e');
    }
  }

  /// Firebase tarafından yenilenen FCM token'ını kaydeder (Yalnızca Android).
  void listenTokenRefresh() {
    if (kIsWeb || !Platform.isAndroid) return;

    // FCM cihaz token yenileme akışı backend uyumluluğu için korunuyor.
    // ignore: deprecated_member_use
    _messaging.onTokenRefresh.listen((newToken) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      try {
        final firestoreService = FirebaseFirestoreDatasource();
        await firestoreService.updateFcmToken(user.uid, newToken);
        debugPrint('Yeni FCM token Firestore’a kaydedildi.');
      } catch (e) {
        debugPrint('FCM token güncelleme hatası: $e');
      }
    });
  }
}
