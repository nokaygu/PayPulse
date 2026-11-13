import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'bloc/splash_cubit.dart';

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
        listener: (context, state) {
          onInitializationComplete?.call();
        },
        child: const _SplashView(),
      ),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SplashCubit, SplashState>(
      builder: (context, state) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.heroCardGradient,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: state.animateIn ? 1.0 : 0.72,
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutBack,
                  child: AnimatedOpacity(
                    opacity: state.animateIn ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeIn,
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.35,
                            ),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Image.asset(
                          'assets/images/paypulse_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'PayPulse',
                  style: AppTextStyles.displayLargeMobile.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Yeni Nesil Dijital Cüzdan & B2B/B2C Tahsilat Portalı',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 36),
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
