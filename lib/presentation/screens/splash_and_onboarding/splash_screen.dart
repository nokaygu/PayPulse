import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// PayPulse Açılış ve Karşılama Ekranı (Splash Screen)
/// Uygulama ilk açıldığında kurumsal logoyu animasyonla gösterir
/// ve arka plan hazırlıkları tamamlanınca ana ekrana yönlendirir.
class SplashScreen extends StatefulWidget {
  final VoidCallback? onInitializationComplete;

  const SplashScreen({super.key, this.onInitializationComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Logo büyüme ve belirme animasyonu (900 ms)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();

    // 1.8 saniye sonra ana ekrana geçiş tetiklenir
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted && widget.onInitializationComplete != null) {
        widget.onInitializationComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          // Marka lacivert-koyu yeşil gradyanı
          gradient: AppColors.heroCardGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // PayPulse Kurumsal Logosu (Ölçeklenen & Parlayan Rozet)
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.35),
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
            // Marka Başlığı
            Text(
              'PayPulse',
              style: AppTextStyles.displayLargeMobile.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            // Marka Alt Sloganı
            Text(
              'Yeni Nesil Dijital Cüzdan & B2B/B2C Tahsilat Portalı',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF94A3B8),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 36),
            // Zarif Hazırlanıyor Göstergesi
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
