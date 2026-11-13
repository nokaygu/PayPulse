import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/splash_cubit.dart';
import 'widgets/splash_brand_content.dart';

/// PayPulse Açılış ve Karşılama Ekranı (Stateless + SplashCubit).
class SplashScreen extends StatelessWidget {
  final VoidCallback? onInitializationComplete;

  const SplashScreen({super.key, this.onInitializationComplete});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashCubit>(
      create: (_) => SplashCubit(),
      child: BlocListener<SplashCubit, SplashState>(
        listenWhen: (prev, curr) => !prev.isCompleted && curr.isCompleted,
        listener: (context, state) => onInitializationComplete?.call(),
        child: BlocBuilder<SplashCubit, SplashState>(
          builder: (context, state) {
            return Scaffold(
              body: SplashBrandContent(animateIn: state.animateIn),
            );
          },
        ),
      ),
    );
  }
}
