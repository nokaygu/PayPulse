import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_mode.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_form_cubit.dart';
import 'bloc/auth_state.dart';
import 'widgets/auth_brand_header.dart';
import 'widgets/register_form_card.dart';

/// Yeni kullanıcı / kurumsal hesap kayıt ekranı (`StatelessWidget` + `RegisterFormCubit`).
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
                      AuthBrandHeader(
                        logoSize: 44,
                        titleStyle: AppTextStyles.headlineSmall,
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
                      RegisterFormCard(
                        formCubit: formCubit,
                        formState: formState,
                        onSubmit: () => _handleRegister(context, formCubit),
                        onNavigateBackToLogin: () => context.pop(),
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
}
