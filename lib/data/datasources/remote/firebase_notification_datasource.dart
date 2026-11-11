
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseNotificationDatasource {
  // Firebase Cloud Messaging servisine erişim sağlar.
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

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

  // Uygulama açıkken gelen bildirimleri dinler.
  void listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Bildirim geldi!');

      print('Başlık: ${message.notification?.title}');
      print('İçerik: ${message.notification?.body}');
    });
  }

  // Bildirim altyapısını başlatır.
  Future<void> initialize() async {
    // FCM yalnızca Android'de çalıştırılacak.
    if (!Platform.isAndroid) {
      print('FCM sadece Android üzerinde aktif.');
      return;
    }

    try {
      // Kullanıcıdan bildirim izni iste.
      await requestNotificationPermission();

      // Android cihazın FCM token değerini al.
      await getFcmToken();

      // Uygulama açıkken gelen bildirimleri dinle.
      listenForegroundMessages();

      print('Firebase bildirim servisi başlatıldı.');
    } catch (e) {
      print('FCM başlatma hatası: $e');
    }
  }
}
