import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';
import '../analytics_and_crashlytics/app_analytics_service.dart';

class FirebaseConfigure {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Platform bağımsız güvenli Analytics ve Crashlytics başlatımı
    await AppAnalyticsService.initialize();
  }
}
