import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/formatters/auth_input_formatters.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/validators/auth_validator.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_form_cubit.dart';
import '../bloc/auth_state.dart';
import 'auth_brand_header.dart';

/// E-posta, şifre, rol anahtarı ve giriş butonu formu (`StatelessWidget`).
class LoginFormCard extends StatelessWidget {
  final LoginFormCubit formCubit;
  final VoidCallback onSubmit;

  const LoginFormCard({
    super.key,
    required this.formCubit,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<LoginFormCubit, LoginFormState>(
          buildWhen: (prev, curr) => prev.isB2BSelected != curr.isB2BSelected,
          builder: (_, formState) => AuthRoleSwitch(
            isB2BSelected: formState.isB2BSelected,
            onSelectB2B: formCubit.setB2BSelected,
          ),
        ),
        const SizedBox(height: 24),
        _EmailAndPasswordFields(formCubit: formCubit),
        const SizedBox(height: 24),
        _LoginSubmitButton(onSubmit: onSubmit),
      ],
    );
  }
}

class _EmailAndPasswordFields extends StatelessWidget {
  final LoginFormCubit formCubit;

  const _EmailAndPasswordFields({required this.formCubit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          builder: (_, formState) {
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
      ],
    );
  }
}

class _LoginSubmitButton extends StatelessWidget {
  final VoidCallback onSubmit;

  const _LoginSubmitButton({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (prev, curr) => prev.isSubmitting != curr.isSubmitting,
      builder: (_, authState) {
        return BlocBuilder<LoginFormCubit, LoginFormState>(
          buildWhen: (prev, curr) => prev.isB2BSelected != curr.isB2BSelected,
          builder: (_, formState) {
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
    );
  }
}

