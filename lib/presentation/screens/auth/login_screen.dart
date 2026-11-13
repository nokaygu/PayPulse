import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_mode.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_text_styles.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_form_cubit.dart';
import 'bloc/auth_state.dart';
import 'widgets/auth_brand_header.dart';
import 'widgets/demo_quick_login_section.dart';
import 'widgets/login_form_card.dart';

/// Kullanıcı giriş ekranı (`StatelessWidget` + `LoginFormCubit`).
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: formCubit.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AuthBrandHeader(showDemoBadge: true),
                  const SizedBox(height: 28),
                  Text('Tekrar Hoş Geldiniz', style: AppTextStyles.displaySmallMobile),
                  const SizedBox(height: 6),
                  Text(
                    'Hesabınıza giriş yaparak işlemlerinizi yönetin.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  LoginFormCard(
                    formCubit: formCubit,
                    onSubmit: () => _handleLogin(context, formCubit),
                  ),
                  const SizedBox(height: 20),
                  DemoQuickLoginSection(
                    onLoginWithRole: (role) =>
                        context.read<AuthBloc>().add(AuthDemoLoginRequested(role)),
                    onNavigateToRegister: () => context.push(AppRoutes.register),
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
