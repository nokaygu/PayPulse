import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/auth_error_messages.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/datasources/remote/firebase_auth_datasource.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';

/// PayPulse Kullanıcı Giriş Ekranı (Login Screen)
/// Bireysel (B2C) ve Kurumsal (B2B) kullanıcıların sisteme giriş yapmasını sağlar.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isB2BSelected = false; // false: B2C Bireysel, true: B2B Kurumsal
  bool _isLoading = false;

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Firebase Authentication ile gerçek kullanıcı girişi yapar.
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Firebase Authentication ile giriş
      await FirebaseAuthDatasource().login(email, password);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isB2BSelected
                ? 'B2B Kurumsal Yönetici Paneline giriş başarılı!'
                : 'B2C Bireysel Cüzdana giriş başarılı!',
          ),
          backgroundColor: AppColors.incomeGreen,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = AuthErrorMessages.fromCode(e.code);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.expenseRed,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Giriş başarısız: $e'),
          backgroundColor: AppColors.expenseRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Jüri sunumu ve hızlı demo için tek tıkla test girişi sağlar.
  void _handleDemoLogin() {
    final targetRole = _isB2BSelected ? 'admin' : 'b2c';
    context.read<AuthBloc>().add(AuthRoleChanged(targetRole));
    context.go(
      targetRole == 'admin' ? AppRoutes.businessOverview : AppRoutes.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // 1. Üst Logo & Marka Başlığı
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.primaryGreen.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          'assets/images/paypulse_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PayPulse', style: AppTextStyles.headlineMedium),
                        Text(
                          'Yeni Nesil Dijital Cüzdan & POS',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // 2. Karşılama Başlığı
                Text(
                  'Tekrar Hoş Geldiniz',
                  style: AppTextStyles.displaySmallMobile,
                ),
                const SizedBox(height: 6),
                Text(
                  'Hesabınıza giriş yaparak işlemlerinizi yönetin.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Segmented Role Switch (B2C vs B2B)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isB2BSelected = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isB2BSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: !_isB2BSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                'Bireysel (B2C)',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: !_isB2BSelected
                                      ? AppColors.darkNavy
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: !_isB2BSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isB2BSelected = true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isB2BSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _isB2BSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                'Kurumsal (B2B)',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: _isB2BSelected
                                      ? AppColors.darkNavy
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: _isB2BSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Form Alanları
                Text('E-Posta Adresi', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'ornek@paypulse.com',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen e-posta adresinizi girin.';
                    }
                    if (!_emailRegex.hasMatch(value.trim())) {
                      return 'Geçerli bir e-posta adresi girin.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Text('Şifre', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen şifrenizi girin.';
                    }
                    if (value.length < 6) {
                      return 'Şifre en az 6 karakter olmalıdır.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // 5. Giriş Yap Butonu
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isB2BSelected
                                ? 'Kurumsal Panele Giriş Yap'
                                : 'Cüzdana Giriş Yap',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // 6. Hızlı Jüri / Demo Girişi Butonu
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _handleDemoLogin,
                    icon: const Icon(
                      Icons.play_circle_outline_rounded,
                      color: AppColors.primaryTeal,
                      size: 20,
                    ),
                    label: Text(
                      _isB2BSelected
                          ? 'Hızlı Demo: Yönetici Olarak Gir (Admin)'
                          : 'Hızlı Demo: Deniz Aksoy Olarak Gir (B2C)',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.darkNavy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 7. Kayıt Ekranına Yönlendirme
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Henüz hesabınız yok mu?',
                      style: AppTextStyles.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        context.push(AppRoutes.register);
                      },
                      child: Text(
                        'Hemen Kayıt Olun',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
