import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/repositories/i_expense_repository.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../auth/bloc/auth_bloc.dart';
import 'bloc/ocr_verification_cubit.dart';
import 'widgets/ocr_verification_form_card.dart';

/// AI-OCR Fiş Veri Doğrulama ve Muhasebeleştirme Ekranı (Stateless + OcrVerificationCubit).
class OcrDataVerificationScreen extends StatelessWidget {
  final OcrExtractedData? initialData;

  const OcrDataVerificationScreen({super.key, this.initialData});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OcrVerificationCubit>(
      create: (ctx) => OcrVerificationCubit(
        expenseRepository: ctx.read<IExpenseRepository>(),
        initialData: initialData,
      ),
      child: const _OcrDataVerificationBody(),
    );
  }
}

class _OcrDataVerificationBody extends StatelessWidget {
  const _OcrDataVerificationBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OcrVerificationCubit>();

    return MultiBlocListener(
      listeners: [
        BlocListener<OcrVerificationCubit, OcrVerificationState>(
          listenWhen: (prev, curr) => !prev.isSubmitted && curr.isSubmitted,
          listener: (ctx, _) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(
                content: Text(
                  'Masraf kaydı ve fiş görseli başarıyla onaya gönderildi.',
                ),
                backgroundColor: AppColors.primaryTeal,
              ),
            );
            ctx.pop();
          },
        ),
        BlocListener<OcrVerificationCubit, OcrVerificationState>(
          listenWhen: (prev, curr) =>
              curr.errorMessage != null &&
              prev.errorMessage != curr.errorMessage,
          listener: (ctx, state) {
            final msg = state.errorMessage;
            if (msg == null) return;
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: AppColors.expenseRed),
            );
            ctx.read<OcrVerificationCubit>().clearError();
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const RoleSwitchAppBar(
          isBusinessMode: true,
          showBackButton: true,
          customTitle: 'OCR Veri Doğrulama',
          customSubtitle: 'Fiş Matrah & KDV Kontrolü',
        ),
        body: BlocBuilder<OcrVerificationCubit, OcrVerificationState>(
          builder: (context, state) {
            final actor = context.watch<AuthBloc>().state.user;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: cubit.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OcrVerificationFormCard(cubit: cubit, state: state),
                    const SizedBox(height: 20),
                    _SubmitButton(
                      isSubmitting: state.isSubmitting,
                      onPressed: () => cubit.submitExpense(actor: actor),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onPressed;

  const _SubmitButton({required this.isSubmitting, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: isSubmitting ? null : onPressed,
        icon: isSubmitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.check_circle_rounded),
        label: Text(
          isSubmitting
              ? 'Fiş Yükleniyor ve Kaydediliyor...'
              : 'Doğrula ve Masrafı Onaya Gönder',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
