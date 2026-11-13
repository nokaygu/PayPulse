import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';

Future<void> showFreezeAccountDialog(BuildContext context) {
  return _showProfileConfirmActionDialog(
    context: context,
    title: 'Hesabı Dondur',
    message:
        'Hesabınızı geçici olarak dondurduğunuzda tüm kartlarınız ve para transferleriniz durdurulacaktır. Tekrar giriş yaptığınızda hesabınız yeniden aktifleşecektir.',
    confirmLabel: 'Hesabı Dondur',
    confirmColor: const Color(0xFFDC2626),
    snackbarMessage: 'Hesabınız güvenle donduruldu.',
  );
}

Future<void> showLogoutConfirmationDialog(BuildContext context) {
  return _showProfileConfirmActionDialog(
    context: context,
    title: 'Güvenli Çıkış',
    message: 'PayPulse oturumunuzu sonlandırmak istediğinize emin misiniz?',
    confirmLabel: 'Çıkış Yap',
    confirmColor: const Color(0xFFB91C1C),
    snackbarMessage: 'Oturum güvenle sonlandırıldı.',
  );
}

Future<void> _showProfileConfirmActionDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  required Color confirmColor,
  required String snackbarMessage,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final authBloc = context.read<AuthBloc>();
  final router = GoRouter.of(context);
  final messenger = ScaffoldMessenger.of(context);

  return showDialog<void>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy),
      ),
      content: Text(
        message,
        style: TextStyle(
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogCtx).pop(),
          child: const Text('Vazgeç'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 44),
          ),
          onPressed: () {
            Navigator.of(dialogCtx).pop();
            authBloc.add(const AuthLogoutRequested());
            router.go(AppRoutes.login);
            messenger.showSnackBar(SnackBar(content: Text(snackbarMessage)));
          },
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}

