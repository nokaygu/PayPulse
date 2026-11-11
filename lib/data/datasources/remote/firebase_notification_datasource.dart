import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_firestore_datasource.dart';

class FirebaseNotificationDatasource {
  // Firebase Cloud Messaging servisine erişim sağlar.
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Yerel bildirimleri göstermek için kullanılır.
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Android bildirim kanalı.
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'paypulse_notifications',
    'PayPulse Bildirimleri',
    description: 'PayPulse uygulama bildirimleri',
    importance: Importance.high,
  );

  // Kullanıcıdan bildirim izni ister.
  Future<void> requestNotificationPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Bildirim izni: ${settings.authorizationStatus}');
  }

  // Cihazın FCM token değerini getirir.
  Future<String?> getFcmToken() async {
    final token = await _messaging.getToken();

    print('FCM Token: $token');

    return token;
  }

  // Android yerel bildirimlerini hazırlar.
  Future<void> initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(settings: initializationSettings);

    // Android bildirim kanalını oluşturur.
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  // Uygulama açıkken gelen bildirimleri dinler.
  void listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Bildirim geldi!');
      print('Başlık: ${message.notification?.title}');
      print('İçerik: ${message.notification?.body}');

      final notification = message.notification;

      if (notification != null) {
        // Bildirimi Android bildirim çubuğunda gösterir.
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

  // Bildirim altyapısını başlatır.
  Future<void> initialize() async {
    // FCM yalnızca Android üzerinde aktif.
    if (!Platform.isAndroid) {
      print('FCM sadece Android üzerinde aktif.');
      return;
    }

    try {
      // Kullanıcıdan bildirim izni iste.
      await requestNotificationPermission();

      // Yerel bildirimleri hazırla.
      await initializeLocalNotifications();

      // Cihazın FCM token değerini al.
      await getFcmToken();

      // Uygulama açıkken bildirimleri dinle.
      listenForegroundMessages();

      // Token değişikliklerini dinle.
      listenTokenRefresh();

      // Kullanıcı oturumu açıksa token'ı Firestore'a kaydet.
      await saveTokenToFirestore();

      print('Firebase bildirim servisi başlatıldı.');
    } catch (e) {
      print('FCM başlatma hatası: $e');
    }
  }

  // Giriş yapan kullanıcının FCM token'ını kaydeder.
  Future<void> saveTokenToFirestore() async {
    if (!Platform.isAndroid) return;

    final user = FirebaseAuth.instance.currentUser;

    // Kullanıcı giriş yapmamışsa kayıt yapma.
    if (user == null) return;

    try {
      final token = await _messaging.getToken();

      if (token == null) return;

      final firestoreService = FirebaseFirestoreDatasource();

      await firestoreService.updateFcmToken(user.uid, token);

      print('FCM token Firestore’a kaydedildi.');
    } catch (e) {
      print('FCM token kaydetme hatası: $e');
    }
  }

  // Firebase tarafından yenilenen FCM token'ını kaydeder.
  void listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) async {
      final user = FirebaseAuth.instance.currentUser;

      // Giriş yapan kullanıcı yoksa işlem yapma.
      if (user == null) return;

      try {
        final firestoreService = FirebaseFirestoreDatasource();

        await firestoreService.updateFcmToken(user.uid, newToken);

        print('Yeni FCM token Firestore’a kaydedildi.');
      } catch (e) {
        print('FCM token güncelleme hatası: $e');
      }
    });
  }
}
