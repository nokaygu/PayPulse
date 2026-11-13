import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/formatters/auth_input_formatters.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/validators/auth_validator.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_form_cubit.dart';
import '../bloc/auth_state.dart';
import 'auth_brand_header.dart';

/// Kayıt ekranının B2C/B2B seçim, firma/kişi alanları, KVKK onayı ve gönderim formu.
class RegisterFormCard extends StatelessWidget {
  final RegisterFormCubit formCubit;
  final RegisterFormState formState;
  final VoidCallback onSubmit;
  final VoidCallback onNavigateBackToLogin;

  const RegisterFormCard({
    super.key,
    required this.formCubit,
    required this.formState,
    required this.onSubmit,
    required this.onNavigateBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthRoleSwitch(
          isB2BSelected: formState.isB2BAccount,
          onSelectB2B: formCubit.setB2BAccount,
        ),
        const SizedBox(height: 20),
        _PersonalIdentityFields(formCubit: formCubit, formState: formState),
        if (formState.isB2BAccount) ...[
          const SizedBox(height: 16),
          _B2BCompanyFields(formCubit: formCubit),
        ],
        const SizedBox(height: 16),
        _ContactAndPasswordFields(formCubit: formCubit, formState: formState),
        const SizedBox(height: 16),
        _KvkkConsentBox(formCubit: formCubit, accepted: formState.kvkkAccepted),
        const SizedBox(height: 24),
        _RegisterSubmitButton(
          isB2BAccount: formState.isB2BAccount,
          onSubmit: onSubmit,
        ),
        const SizedBox(height: 20),
        _LoginLinkRow(onTap: onNavigateBackToLogin),
      ],
    );
  }
}

InputDecoration _registerInputDecoration({
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
      borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
    ),
  );
}

class _PersonalIdentityFields extends StatelessWidget {
  final RegisterFormCubit formCubit;
  final RegisterFormState formState;

  const _PersonalIdentityFields({
    required this.formCubit,
    required this.formState,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ad Soyad', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: formCubit.fullNameController,
          style: AppTextStyles.bodyMedium,
          decoration: _registerInputDecoration(
            hintText: 'Deniz Aksoy',
            prefixIcon: Icons.person_outline_rounded,
          ),
          validator: (val) => (val == null || val.trim().length < 3)
              ? 'Ad ve soyadınızı eksiksiz girin'
              : null,
        ),
      ],
    );
  }
}

class _B2BCompanyFields extends StatelessWidget {
  final RegisterFormCubit formCubit;

  const _B2BCompanyFields({required this.formCubit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Şirket / İşletme Ünvanı', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: formCubit.companyNameController,
          style: AppTextStyles.bodyMedium,
          decoration: _registerInputDecoration(
            hintText: 'PayPulse Teknoloji A.Ş.',
            prefixIcon: Icons.business_rounded,
          ),
          validator: (val) => (val == null || val.trim().isEmpty)
              ? 'Şirket ünvanı zorunludur'
              : null,
        ),
        const SizedBox(height: 16),
        Text('Vergi Kimlik Numarası (VKN)', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: formCubit.taxNumberController,
          style: AppTextStyles.bodyMedium,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: _registerInputDecoration(
            hintText: '10 haneli VKN',
            prefixIcon: Icons.receipt_long_rounded,
          ),
          validator: (val) => (val == null || val.length != 10)
              ? 'Vergi numarası 10 haneli olmalıdır'
              : null,
        ),
      ],
    );
  }
}

class _ContactAndPasswordFields extends StatelessWidget {
  final RegisterFormCubit formCubit;
  final RegisterFormState formState;

  const _ContactAndPasswordFields({
    required this.formCubit,
    required this.formState,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('E-Posta Adresi', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: formCubit.emailController,
          style: AppTextStyles.bodyMedium,
          keyboardType: TextInputType.emailAddress,
          inputFormatters: [EmailInputFormatter()],
          decoration: _registerInputDecoration(
            hintText: 'deniz@paypulse.com',
            prefixIcon: Icons.mail_outline_rounded,
          ),
          validator: AuthValidator.validateEmail,
        ),
        const SizedBox(height: 16),
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
          decoration: _registerInputDecoration(
            hintText: '5XX XXX XX XX',
            prefixIcon: Icons.phone_iphone_rounded,
          ),
          validator: (val) => (val == null || val.length != 10)
              ? 'Başında 0 olmadan 10 haneli numaranızı girin'
              : null,
        ),
        const SizedBox(height: 16),
        Text('Şifre Belirleyin', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: formCubit.passwordController,
          style: AppTextStyles.bodyMedium,
          obscureText: formState.obscurePassword,
          decoration: _registerInputDecoration(
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
      ],
    );
  }
}

class _KvkkConsentBox extends StatelessWidget {
  final RegisterFormCubit formCubit;
  final bool accepted;

  const _KvkkConsentBox({required this.formCubit, required this.accepted});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              value: accepted,
              onChanged: (val) => formCubit.setKvkkAccepted(val ?? false),
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
    );
  }
}

class _RegisterSubmitButton extends StatelessWidget {
  final bool isB2BAccount;
  final VoidCallback onSubmit;

  const _RegisterSubmitButton({
    required this.isB2BAccount,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (prev, curr) => prev.isSubmitting != curr.isSubmitting,
      builder: (_, authState) {
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
            onPressed: authState.isSubmitting ? null : onSubmit,
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
                    isB2BAccount
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
    );
  }
}

class _LoginLinkRow extends StatelessWidget {
  final VoidCallback onTap;

  const _LoginLinkRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Zaten bir hesabınız var mı?', style: AppTextStyles.bodyMedium),
          const SizedBox(width: 4),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: onTap,
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
    );
  }
}

