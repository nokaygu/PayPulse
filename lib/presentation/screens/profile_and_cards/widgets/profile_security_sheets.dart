import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../bloc/profile_settings_cubit.dart';
import 'profile_preferences_sheets.dart';

Future<void> showChangePinSheet(
  BuildContext context,
  ProfileSettingsCubit cubit,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomCtx) => _ChangePinSheetBody(
      cubit: cubit,
      isDark: isDark,
      onClose: () => Navigator.of(bottomCtx).pop(),
    ),
  );
}

class _ChangePinSheetBody extends StatelessWidget {
  final ProfileSettingsCubit cubit;
  final bool isDark;
  final VoidCallback onClose;

  const _ChangePinSheetBody({
    required this.cubit,
    required this.isDark,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: cubit.changePinFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cüzdan PIN Kodunu Değiştir',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '6 haneli güvenlik PIN kodunuzu girin.',
              style: TextStyle(
                color:
                    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            _PinField(
              controller: cubit.oldPinController,
              label: 'Mevcut PIN Kodu',
            ),
            const SizedBox(height: 10),
            _PinField(
              controller: cubit.newPinController,
              label: 'Yeni PIN Kodu',
            ),
            const SizedBox(height: 10),
            _PinField(
              controller: cubit.confirmPinController,
              label: 'Yeni PIN Kodu (Tekrar)',
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (cubit.submitPinChange()) onClose();
                },
                child: const Text(
                  'PIN Kodunu Güncelle',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _PinField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 6,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

Future<void> showTwoFactorSheet(
  BuildContext context,
  ProfileSettingsCubit cubit,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomCtx) => _TwoFactorSheetBody(cubit: cubit, isDark: isDark),
  );
}

class _TwoFactorSheetBody extends StatelessWidget {
  final ProfileSettingsCubit cubit;
  final bool isDark;

  const _TwoFactorSheetBody({required this.cubit, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.darkNavy;
    return BlocBuilder<ProfileSettingsCubit, ProfileSettingsState>(
      bloc: cubit,
      builder: (sheetCtx, state) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'İki Adımlı Doğrulama (2FA)',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Hesabınıza her girişte ve yüksek tutarlı transferlerde çift katmanlı koruma.',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(
                  '2FA Korumasını Aç / Kapat',
                  style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
                ),
                subtitle: const Text('SMS ve Authenticator Uygulaması'),
                value: state.twoFactorEnabled,
                activeThumbColor: AppColors.primaryTeal,
                onChanged: cubit.toggleTwoFactor,
              ),
              Divider(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              ),
              ListTile(
                leading: Icon(Icons.sms_outlined, color: textColor),
                title: Text('SMS Doğrulama', style: TextStyle(color: textColor)),
                subtitle: Text('${state.phone} numarasına kod gönderilir'),
                trailing: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> showTrustedDevicesSheet(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomCtx) => _TrustedDevicesSheetBody(
      isDark: isDark,
      onTerminateMac: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('MacBook Pro oturumu sonlandırıldı.')),
        );
      },
      onTerminateAllOthers: () {
        Navigator.of(bottomCtx).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bu cihaz haricindeki tüm oturumlar kapatıldı.'),
          ),
        );
      },
    ),
  );
}

class _TrustedDevicesSheetBody extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTerminateMac;
  final VoidCallback onTerminateAllOthers;

  const _TrustedDevicesSheetBody({
    required this.isDark,
    required this.onTerminateMac,
    required this.onTerminateAllOthers,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.darkNavy;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Güvenilir Cihazlar',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Hesabınıza giriş yapılmış cihazlar ve aktif oturumlar.',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(
              Icons.phone_iphone_rounded,
              color: AppColors.primaryTeal,
            ),
            title: Text(
              'iPhone 15 Pro (Bu Cihaz)',
              style: TextStyle(color: textColor),
            ),
            subtitle: const Text('İstanbul, Türkiye • Aktif Oturum'),
            trailing: const Chip(
              label: Text('Bu Cihaz'),
              backgroundColor: Color(0xFFD1FAE5),
              labelStyle: TextStyle(color: Color(0xFF065F46), fontSize: 11),
            ),
          ),
          Divider(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),
          ListTile(
            leading: Icon(Icons.laptop_mac_rounded, color: textColor),
            title: Text('MacBook Pro 16"', style: TextStyle(color: textColor)),
            subtitle: const Text('Chrome Web • Son giriş: Dün 14:32'),
            trailing: IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFDC2626),
              ),
              onPressed: onTerminateMac,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onTerminateAllOthers,
              child: const Text('Tüm Diğer Oturumları Kapat'),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showSessionTimeoutSheet(
  BuildContext context,
  ProfileSettingsCubit cubit,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  const durations = ['1 Dakika', '5 Dakika', '15 Dakika', '30 Dakika'];
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomCtx) => BlocBuilder<ProfileSettingsCubit, ProfileSettingsState>(
      bloc: cubit,
      builder: (sheetCtx, state) => ProfileOptionPickerSheet(
        title: 'Oturum Zaman Aşımı',
        subtitle: 'Uygulama arka plandayken ne kadar süre sonra PIN istenmeli?',
        options: durations,
        selectedValue: state.sessionTimeout,
        isDark: isDark,
        onSelected: (duration) {
          cubit.setSessionTimeout(duration);
          Navigator.of(bottomCtx).pop();
        },
      ),
    ),
  );
}

Future<void> showLimitIncreaseSheet(
  BuildContext context,
  ProfileSettingsCubit cubit,
  ProfileSettingsState settingsState,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomCtx) => _LimitIncreaseSheetBody(
      settingsState: settingsState,
      isDark: isDark,
      onSubmit: () {
        Navigator.of(bottomCtx).pop();
        cubit.emitFeedback(
          'Seviye 3 limit artırım başvurunuz alındı. 24 saat içinde incelenecektir.',
        );
      },
    ),
  );
}

class _LimitIncreaseSheetBody extends StatelessWidget {
  final ProfileSettingsState settingsState;
  final bool isDark;
  final VoidCallback onSubmit;

  const _LimitIncreaseSheetBody({
    required this.settingsState,
    required this.isDark,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.darkNavy;
    final subColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final formattedCurrentLimit = FinancialAmount.format(
      (settingsState.monthlyLimit * 100).round(),
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transfer Limiti Artırma',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Mevcut Seviye ${settingsState.verificationLevel} limitiniz aylık $formattedCurrentLimit\'dir.',
            style: TextStyle(color: subColor, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mevcut Limit (Seviye ${settingsState.verificationLevel}):',
                      style: TextStyle(color: subColor),
                    ),
                    Text(
                      '$formattedCurrentLimit / Ay',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hedef Limit (Seviye 3 - VIP):',
                      style: TextStyle(color: AppColors.primaryTeal),
                    ),
                    Text(
                      '₺1.000.000,00 / Ay',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onSubmit,
              icon: const Icon(Icons.verified_rounded, size: 18),
              label: const Text('Limit Artırım Talebi Gönder'),
            ),
          ),
        ],
      ),
    );
  }
}

