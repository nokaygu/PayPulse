import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/app_mode.dart';
import 'core/firebase_configuration/firebase_configure.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/remote/firebase_notification_datasource.dart';
import 'presentation/screens/auth/bloc/auth_bloc.dart';
import 'presentation/screens/auth/bloc/auth_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Canlı Firebase ve FCM yalnızca Android üzerinde başlatılır.
  // macOS üzerinde ise Apple Developer hesabı ve Keychain erişim hatalarını önlemek için
  // yerel eğitim/sunum demo modu devrededir.
  if (AppMode.isLiveFirebase) {
    try {
      await FirebaseConfigure.initialize();
      final notificationService = FirebaseNotificationDatasource();
      await notificationService.initialize();
    } catch (e) {
      debugPrint('Firebase başlatma hatası: $e');
    }
  } else {
    // macOS Demo Modu: Firebase konfigürasyonunu güvenle dener; hata olursa sessizce atlar
    try {
      await FirebaseConfigure.initialize();
    } catch (e) {
      debugPrint('Demo Modu: Firebase başlatımı atlandı: $e');
    }
  }

  runApp(const PayPulseApplication());
}

class PayPulseApplication extends StatefulWidget {
  const PayPulseApplication({super.key});

  @override
  State<PayPulseApplication> createState() => _PayPulseApplicationState();
}

class _PayPulseApplicationState extends State<PayPulseApplication> {
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc()..add(const AuthSubscriptionRequested());
    _appRouter = AppRouter(authBloc: _authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: _authBloc,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: AppTheme.themeModeNotifier,
        builder: (context, themeMode, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'PayPulse',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: _appRouter.router,
          );
        },
      ),
    );
  }
}
