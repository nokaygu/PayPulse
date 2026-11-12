import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/firebase_configuration/firebase_configure.dart';
<<<<<<< Updated upstream
import 'presentation/screens/home_wallet_and_safe/home.dart';
=======
import 'core/router/app_router.dart';
import 'data/datasources/remote/firebase_notification_datasource.dart';
import 'presentation/screens/auth/bloc/auth_bloc.dart';
import 'presentation/screens/auth/bloc/auth_event.dart';
import 'presentation/screens/budget_analytics/bloc/budget_bloc.dart';
import 'presentation/screens/cards_management/bloc/cards_bloc.dart';
import 'presentation/screens/home_wallet_and_safe/bloc/wallet_bloc.dart';
>>>>>>> Stashed changes



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
await FirebaseConfigure.initialize();
  runApp(const PayPulseApplication());
}

class PayPulseApplication extends StatelessWidget {
  const PayPulseApplication ({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< Updated upstream
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PayPulse',
      theme: ThemeData(

=======
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<WalletBloc>(
          create: (context) => WalletBloc(),
        ),
        BlocProvider<CardsBloc>(
          create: (context) => CardsBloc(),
        ),
        BlocProvider<BudgetBloc>(
          create: (context) => BudgetBloc(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'PayPulse',
        theme: ThemeData(useMaterial3: true),
        routerConfig: _appRouter.router,
>>>>>>> Stashed changes
      ),
      home: const HomeAndWalletEkrani(),
    );
  }
}