import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterFormCubit>(
      create: (_) => RegisterFormCubit(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  void _handleRegister(BuildContext context, RegisterFormCubit formCubit) {
    if (!(formCubit.formKey.currentState?.validate() ?? false)) return;

    if (!formCubit.state.kvkkAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Devam etmek için KVKK ve Kullanım Koşullarını onaylayın.'),
          backgroundColor: Color(0xFFD97706),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final role = formCubit.state.isB2BAccount
        ? AppStrings.roleAdmin
        : AppStrings.roleB2C;

    if (AppMode.isDemoMode) {
      context.read<AuthBloc>().add(AuthDemoLoginRequested(role));
      return;
    }

    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        email: formCubit.emailController.text.trim(),
        password: formCubit.passwordController.text,
        name: formCubit.fullNameController.text.trim(),
        role: role,
        companyId: formCubit.state.isB2BAccount
            ? AppStrings.defaultCompanyId
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formCubit = context.read<RegisterFormCubit>();

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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.darkNavy,
              size: 20,
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.login);
              }
            },
          ),
          title: Text(
            'Yeni Hesap Oluştur',
            style: AppTextStyles.headlineSmall.copyWith(fontSize: 16),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Form(
              key: formCubit.formKey,
              child: BlocBuilder<RegisterFormCubit, RegisterFormState>(
                builder: (context, formState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Üst Logo & Başlık
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGreen.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
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
                                  style: AppTextStyles.headlineSmall,
                                ),
                                Text(
                                  'Yeni Nesil Dijital Cüzdan & POS',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: const Color(0xFF64748B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'PayPulse Ekosistemine Katılın',
                        style: AppTextStyles.displaySmallMobile.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Hesap tipinizi seçerek saniyeler içinde dijital cüzdanınızı açın.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2. B2C / B2B Segmented Switch
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
                                onTap: () => formCubit.setB2BAccount(false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !formState.isB2BAccount
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: !formState.isB2BAccount
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
                                        color: !formState.isB2BAccount
                                            ? AppColors.darkNavy
                                            : const Color(0xFF64748B),
                                        fontWeight: !formState.isB2BAccount
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
                                onTap: () => formCubit.setB2BAccount(true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: formState.isB2BAccount
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: formState.isB2BAccount
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
                                        color: formState.isB2BAccount
                                            ? AppColors.darkNavy
                                            : const Color(0xFF64748B),
                                        fontWeight: formState.isB2BAccount
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
                      const SizedBox(height: 20),

                      // 3. Ad Soyad
                      Text('Ad Soyad', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: formCubit.fullNameController,
                        style: AppTextStyles.bodyMedium,
                        decoration: _buildInputDecoration(
                          hintText: 'Deniz Aksoy',
                          prefixIcon: Icons.person_outline_rounded,
                        ),
                        validator: (val) =>
                            (val == null || val.trim().length < 3)
                            ? 'Ad ve soyadınızı eksiksiz girin'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // 4. B2B Şirket Bilgileri
                      if (formState.isB2BAccount) ...[
                        Text(
                          'Şirket / İşletme Ünvanı',
                          style: AppTextStyles.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: formCubit.companyNameController,
                          style: AppTextStyles.bodyMedium,
                          decoration: _buildInputDecoration(
                            hintText: 'PayPulse Teknoloji A.Ş.',
                            prefixIcon: Icons.business_rounded,
                          ),
                          validator: (val) => (val == null || val.trim().isEmpty)
                              ? 'Şirket ünvanı zorunludur'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Vergi Kimlik Numarası (VKN)',
                          style: AppTextStyles.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: formCubit.taxNumberController,
                          style: AppTextStyles.bodyMedium,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: _buildInputDecoration(
                            hintText: '10 haneli VKN',
                            prefixIcon: Icons.receipt_long_rounded,
                          ),
                          validator: (val) => (val == null || val.length != 10)
                              ? 'Vergi numarası 10 haneli olmalıdır'
                              : null,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 5. E-Posta
                      Text('E-Posta Adresi', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: formCubit.emailController,
                        style: AppTextStyles.bodyMedium,
                        keyboardType: TextInputType.emailAddress,
                        inputFormatters: [EmailInputFormatter()],
                        decoration: _buildInputDecoration(
                          hintText: 'deniz@paypulse.com',
                          prefixIcon: Icons.mail_outline_rounded,
                        ),
                        validator: AuthValidator.validateEmail,
                      ),
                      const SizedBox(height: 16),

                      // 6. Telefon Numarası
                      Text(
                        'Telefon Numarası (FAST Kolay Adres)',
                        style: AppTextStyles.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: formCubit.phoneController,
                        style: AppTextStyles.bodyMedium,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: _buildInputDecoration(
                          hintText: '5XX XXX XX XX',
                          prefixIcon: Icons.phone_iphone_rounded,
                        ),
                        validator: (val) => (val == null || val.length != 10)
                            ? 'Başında 0 olmadan 10 haneli numaranızı girin'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // 7. Şifre
                      Text('Şifre Belirleyin', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: formCubit.passwordController,
                        style: AppTextStyles.bodyMedium,
                        obscureText: formState.obscurePassword,
                        decoration: _buildInputDecoration(
                          hintText: 'En az 6 karakter (büyük/küçük harf & rakam)',
                          prefixIcon: Icons.lock_outline_rounded,
                          suffixIcon: IconButton(
                            onPressed: formCubit.togglePasswordVisibility,
                            icon: Icon(
                              formState.obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        validator: AuthValidator.validatePassword,
                      ),
                      const SizedBox(height: 16),

                      // 8. KVKK Onayı
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                activeColor: AppColors.primaryGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                value: formState.kvkkAccepted,
                                onChanged: (val) =>
                                    formCubit.setKvkkAccepted(val ?? false),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: formCubit.toggleKvkkAccepted,
                                child: Text(
                                  'KVKK Aydınlatma Metni ve PayPulse Çift Yönlü Cüzdan Sözleşmesini okudum, onaylıyorum.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: const Color(0xFF475569),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 9. Kayıt Ol Butonu
                      BlocBuilder<AuthBloc, AuthState>(
                        buildWhen: (prev, curr) =>
                            prev.isSubmitting != curr.isSubmitting,
                        builder: (context, authState) {
                          return SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: authState.isSubmitting
                                  ? null
                                  : () => _handleRegister(context, formCubit),
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
                                      formState.isB2BAccount
                                          ? 'Kurumsal Hesabı Oluştur'
                                          : 'Bireysel Cüzdanı Oluştur',
                                      style: AppTextStyles.labelLarge.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // 10. Giriş Yap Ekranına Yönlendirme
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Zaten bir hesabınız var mı?',
                              style: AppTextStyles.bodyMedium,
                            ),
                            const SizedBox(width: 4),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => context.pop(),
                              child: Text(
                                'Giriş Yapın',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF64748B)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primaryGreen,
          width: 1.5,
        ),
      ),
    );
  }
}
