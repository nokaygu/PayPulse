import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// PayPulse Uygulama Çalışma Modu (Environment Mode)
/// macOS üzerinde Apple hesabı ve Keychain erişim hatası olmadan,
/// yerel mock finansal verilerle eğitim ve sunum yapabilmeyi sağlar.
/// Android tarafında ise mevcut Cloud Firestore, Firebase Auth ve FCM altyapısı aynen çalışır.
enum EnvironmentMode {
  localDemo,
  liveFirebase,
}

class AppMode {
  AppMode._();

  static EnvironmentMode get current {
    if (kIsWeb) return EnvironmentMode.localDemo;
    if (Platform.isMacOS) return EnvironmentMode.localDemo;
    return EnvironmentMode.liveFirebase;
  }

  static bool get isDemoMode => current == EnvironmentMode.localDemo;
  static bool get isLiveFirebase => current == EnvironmentMode.liveFirebase;
}

