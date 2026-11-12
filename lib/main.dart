import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/firebase_configuration/firebase_configure.dart';
import 'core/router/app_router.dart';
import 'data/datasources/remote/firebase_notification_datasource.dart';
import 'presentation/screens/auth/bloc/auth_bloc.dart';
import 'presentation/screens/auth/bloc/auth_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseConfigure.initialize();

  runApp(const PayPulseApplication());

  final notificationService = FirebaseNotificationDatasource();
  await notificationService.initialize();
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
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'PayPulse',
        theme: ThemeData(useMaterial3: true),
        routerConfig: _appRouter.router,
      ),
    );
  }
}
