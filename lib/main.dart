import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/firebase_configuration/firebase_configure.dart';
import 'presentation/screens/home_wallet_and_safe/home.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
await FirebaseConfigure.initialize();
  runApp(const PayPulseApplication());
}

class PayPulseApplication extends StatelessWidget {
  const PayPulseApplication ({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PayPulse',
      theme: ThemeData(

      ),
      home: const HomeAndWalletEkrani(),
    );
  }
}