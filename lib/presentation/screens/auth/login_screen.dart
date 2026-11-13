import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_mode.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/formatters/auth_input_formatters.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/validators/auth_validator.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_form_cubit.dart';
import 'bloc/auth_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginFormCubit>(
      create: (_) => LoginFormCubit(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  void _handleLogin(BuildContext context, LoginFormCubit formCubit) {
    if (!(formCubit.formKey.currentState?.validate() ?? false)) return;

    if (AppMode.isDemoMode) {
      final targetRole = formCubit.state.isB2BSelected
          ? AppStrings.roleAdmin
          : AppStrings.roleB2C;
      context.read<AuthBloc>().add(AuthDemoLoginRequested(targetRole));
      return;
    }

    context.read<AuthBloc>().add(
      AuthLoginRequested(
        email: formCubit.emailController.text.trim(),
        password: formCubit.passwordController.text,
      ),
    );
  }

  void _loginAsDemoRole(BuildContext context, String role) {
    context.read<AuthBloc>().add(AuthDemoLoginRequested(role));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formCubit = context.read<LoginFormCubit>();

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.errorMessage!),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<AuthBloc>().add(const AuthErrorCleared());
        } else if (authState.isAuthenticated) {
          context.go(
            authState.isBusinessMode
                ? AppRoutes.businessOverview
                : AppRoutes.home,
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Form(
              key: formCubit.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Üst Marka Logosı & Başlık (Taşma Korumalı)
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(
                                alpha: 0.25,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PayPulse',
                              style: AppTextStyles.headlineMedium,
                            ),
                            Text(
                              'Yeni Nesil Dijital Cüzdan & POS',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (AppMode.isDemoMode)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFBAE6FD),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.bolt_rounded,
                                      size: 13,
                                      color: AppColors.primaryTeal,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Demo Modu',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.primaryTeal,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
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
                  BlocBuilder<LoginFormCubit, LoginFormState>(
                    buildWhen: (prev, curr) =>
                        prev.isB2BSelected != curr.isB2BSelected,
                    builder: (context, formState) {
                      return Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => formCubit.setB2BSelected(false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !formState.isB2BSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: !formState.isB2BSelected
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
                                        color: !formState.isB2BSelected
                                            ? AppColors.darkNavy
                                            : colorScheme.onSurfaceVariant,
                                        fontWeight: !formState.isB2BSelected
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
                                onTap: () => formCubit.setB2BSelected(true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: formState.isB2BSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: formState.isB2BSelected
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
                                        color: formState.isB2BSelected
                                            ? AppColors.darkNavy
                                            : colorScheme.onSurfaceVariant,
                                        fontWeight: formState.isB2BSelected
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
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // 4. Form Alanları
                  Text('E-Posta Adresi', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: formCubit.emailController,
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: [EmailInputFormatter()],
                    decoration: const InputDecoration(
                      hintText: 'ornek@paypulse.com',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                    validator: AuthValidator.validateEmail,
                  ),
                  const SizedBox(height: 16),

                  Text('Şifre', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 8),
                  BlocBuilder<LoginFormCubit, LoginFormState>(
                    buildWhen: (prev, curr) =>
                        prev.obscurePassword != curr.obscurePassword,
                    builder: (context, formState) {
                      return TextFormField(
                        controller: formCubit.passwordController,
                        obscureText: formState.obscurePassword,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              formState.obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: formCubit.togglePasswordVisibility,
                          ),
                        ),
                        validator: AuthValidator.validateLoginPassword,
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // 5. Giriş Yap Butonu
                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (prev, curr) =>
                        prev.isSubmitting != curr.isSubmitting,
                    builder: (context, authState) {
                      return BlocBuilder<LoginFormCubit, LoginFormState>(
                        buildWhen: (prev, curr) =>
                            prev.isB2BSelected != curr.isB2BSelected,
                        builder: (context, formState) {
                          return SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              onPressed: authState.isSubmitting
                                  ? null
                                  : () => _handleLogin(context, formCubit),
                              child: authState.isSubmitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      formState.isB2BSelected
                                          ? 'Kurumsal Panele Giriş Yap'
                                          : 'Cüzdana Giriş Yap',
                                      style: AppTextStyles.labelLarge.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // 6. Doğrudan Demo Rol Seçimi Bölümü (Yalnızca Demo Modunda)
                  if (AppMode.isDemoMode) ...[
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: Color(0xFFE2E8F0)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'VEYA DOĞRUDAN DEMO ROLÜ İLE GİRİN',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: Color(0xFFE2E8F0)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _DemoRoleCard(
                      title: 'Deniz Aksoy',
                      roleBadge: 'Bireysel (B2C)',
                      subtitle: 'Bakiye: ₺12.500,00 • FAST Transfer & Cüzdan',
                      icon: Icons.account_balance_wallet_rounded,
                      iconBg: const Color(0xFFD1FAE5),
                      iconColor: AppColors.primaryGreen,
                      badgeBg: const Color(0xFFD1FAE5),
                      badgeColor: const Color(0xFF065F46),
                      onTap: () => _loginAsDemoRole(context, AppStrings.roleB2C),
                    ),
                    const SizedBox(height: 8),

                    _DemoRoleCard(
                      title: 'Ahmet Yılmaz',
                      roleBadge: 'Çalışan (Employee)',
                      subtitle:
                          'PayPulse Teknoloji • Bakiye: ₺5.000,00 • Masraf',
                      icon: Icons.badge_outlined,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFD97706),
                      badgeBg: const Color(0xFFFEF3C7),
                      badgeColor: const Color(0xFF92400E),
                      onTap: () =>
                          _loginAsDemoRole(context, AppStrings.roleEmployee),
                    ),
                    const SizedBox(height: 8),

                    _DemoRoleCard(
                      title: 'Ali Yılmaz',
                      roleBadge: 'Yönetici (Admin)',
                      subtitle:
                          'PayPulse Teknoloji • Kasa: ₺50.000,00 • POS & Onay',
                      icon: Icons.business_center_rounded,
                      iconBg: const Color(0xFFE0F2FE),
                      iconColor: AppColors.darkNavy,
                      badgeBg: const Color(0xFFE0F2FE),
                      badgeColor: const Color(0xFF0369A1),
                      onTap: () =>
                          _loginAsDemoRole(context, AppStrings.roleAdmin),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 7. Kayıt Ekranına Yönlendirme
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Henüz hesabınız yok mu?',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(width: 4),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoRoleCard extends StatelessWidget {
  final String title;
  final String roleBadge;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color badgeBg;
  final Color badgeColor;
  final VoidCallback onTap;

  const _DemoRoleCard({
    required this.title,
    required this.roleBadge,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.badgeBg,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.darkNavy,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            roleBadge,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
