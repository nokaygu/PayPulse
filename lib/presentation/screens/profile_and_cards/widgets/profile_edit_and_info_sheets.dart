import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../bloc/profile_settings_cubit.dart';

Future<void> showEditProfileSheet(
  BuildContext context,
  ProfileSettingsCubit cubit,
  AuthBloc authBloc,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomCtx) => EditProfileSheet(
      cubit: cubit,
      authBloc: authBloc,
      isDark: isDark,
      onClose: () => Navigator.of(bottomCtx).pop(),
    ),
  );
}

class EditProfileSheet extends StatelessWidget {
  final ProfileSettingsCubit cubit;
  final AuthBloc authBloc;
  final bool isDark;
  final VoidCallback onClose;

  const EditProfileSheet({
    super.key,
    required this.cubit,
    required this.authBloc,
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
        key: cubit.editProfileFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profili Düzenle',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.darkNavy,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white : const Color(0xFF64748B),
                  ),
                  onPressed: onClose,
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: cubit.nameController,
              validator: (v) => (v == null || v.trim().length < 2)
                  ? 'Ad soyad en az 2 karakter olmalıdır.'
                  : null,
              decoration: InputDecoration(
                labelText: 'Ad Soyad',
                prefixIcon: const Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: cubit.phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Cep Telefonu',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: cubit.emailController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'E-posta Adresi',
                helperText: 'Hesap e-postası güvenlik nedeniyle sabittir.',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                  final isValid =
                      cubit.editProfileFormKey.currentState?.validate() ?? true;
                  if (!isValid) return;
                  authBloc.add(
                    AuthProfileUpdated(name: cubit.nameController.text.trim()),
                  );
                  cubit.savePhoneAndNotify(phone: cubit.phoneController.text);
                  onClose();
                },
                child: const Text(
                  'Değişiklikleri Kaydet',
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

Future<void> showMoreOptionsSheet({
  required BuildContext context,
  required ProfileSettingsState settingsState,
  required VoidCallback onShowQr,
  required VoidCallback onFreezeAccount,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomCtx) => _MoreOptionsSheetBody(
      settingsState: settingsState,
      isDark: isDark,
      onShareInfo: () {
        Navigator.of(bottomCtx).pop();
        Clipboard.setData(
          ClipboardData(
            text:
                'PayPulse Hesabı: ${settingsState.displayName}\n'
                'IBAN: ${settingsState.displayIban}\n'
                'Müşteri No: ${settingsState.displayCustomerNo}',
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hesap bilgileri panoya kopyalandı ve paylaşıma hazır.'),
          ),
        );
      },
      onDownloadStatement: () {
        Navigator.of(bottomCtx).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hesap ekstresi PDF olarak indirildi.')),
        );
      },
      onShowQr: () {
        Navigator.of(bottomCtx).pop();
        onShowQr();
      },
      onFreezeAccount: () {
        Navigator.of(bottomCtx).pop();
        onFreezeAccount();
      },
    ),
  );
}

class _MoreOptionsSheetBody extends StatelessWidget {
  final ProfileSettingsState settingsState;
  final bool isDark;
  final VoidCallback onShareInfo;
  final VoidCallback onDownloadStatement;
  final VoidCallback onShowQr;
  final VoidCallback onFreezeAccount;

  const _MoreOptionsSheetBody({
    required this.settingsState,
    required this.isDark,
    required this.onShareInfo,
    required this.onDownloadStatement,
    required this.onShowQr,
    required this.onFreezeAccount,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.darkNavy;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hesap ve Cüzdan Seçenekleri',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.share_rounded, color: AppColors.primaryTeal),
              title: Text(
                'Profili & FAST IBAN Paylaş',
                style: TextStyle(color: textColor),
              ),
              subtitle: const Text('Hesap bilgilerini mesaj veya PDF ile ilet'),
              onTap: onShareInfo,
            ),
            ListTile(
              leading: Icon(Icons.receipt_long_rounded, color: textColor),
              title: Text(
                'Aylık Hesap Özeti İndir (PDF)',
                style: TextStyle(color: textColor),
              ),
              subtitle: const Text('Son aya ait resmi mühürlü hesap ekstresi'),
              onTap: onDownloadStatement,
            ),
            ListTile(
              leading: const Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.primaryTeal,
              ),
              title: Text(
                'FAST QR Kodunu Göster',
                style: TextStyle(color: textColor),
              ),
              subtitle: const Text('Tahsilat için büyütülmüş QR kod'),
              onTap: onShowQr,
            ),
            Divider(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            ListTile(
              leading: const Icon(
                Icons.lock_clock_rounded,
                color: Color(0xFFDC2626),
              ),
              title: const Text(
                'Hesabı Geçici Olarak Dondur',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: const Text(
                'Tüm kart ve transfer işlemlerini anında askıya al',
              ),
              onTap: onFreezeAccount,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showAvatarOptionsSheet(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomCtx) => _AvatarOptionsSheetBody(
      isDark: isDark,
      onNotify: (msg) {
        Navigator.of(bottomCtx).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      },
    ),
  );
}

class _AvatarOptionsSheetBody extends StatelessWidget {
  final bool isDark;
  final ValueChanged<String> onNotify;

  const _AvatarOptionsSheetBody({required this.isDark, required this.onNotify});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.darkNavy;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profil Fotoğrafını Değiştir',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primaryTeal,
              ),
              title: Text('Kamerayı Aç', style: TextStyle(color: textColor)),
              onTap: () => onNotify('Kamera erişimi başlatılıyor...'),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: textColor),
              title: Text(
                'Galeriden Fotoğraf Seç',
                style: TextStyle(color: textColor),
              ),
              onTap: () => onNotify('Fotoğraf galerisi açılıyor...'),
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFDC2626),
              ),
              title: const Text(
                'Mevcut Fotoğrafı Kaldır',
                style: TextStyle(color: Color(0xFFDC2626)),
              ),
              onTap: () => onNotify('Profil fotoğrafı varsayılana sıfırlandı.'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showPersonalInfoSheet(
  BuildContext context,
  ProfileSettingsCubit cubit,
  ProfileSettingsState settingsState,
  AuthBloc authBloc,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomCtx) => _PersonalInfoSheetBody(
      settingsState: settingsState,
      isDark: isDark,
      onClose: () => Navigator.of(bottomCtx).pop(),
      onEdit: () {
        Navigator.of(bottomCtx).pop();
        cubit.prepareEditProfile();
        showEditProfileSheet(context, cubit, authBloc);
      },
    ),
  );
}

class _PersonalInfoSheetBody extends StatelessWidget {
  final ProfileSettingsState settingsState;
  final bool isDark;
  final VoidCallback onClose;
  final VoidCallback onEdit;

  const _PersonalInfoSheetBody({
    required this.settingsState,
    required this.isDark,
    required this.onClose,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Ad Soyad', settingsState.displayName),
      ('T.C. Kimlik No', '284******** (Doğrulandı)'),
      ('Doğum Tarihi', '14.06.1994'),
      ('Cep Telefonu', settingsState.phone),
      ('E-posta', settingsState.displayEmail),
      (
        'Kayıtlı İkametgah',
        'Levent Mah. Cömert Sk. No: 1 Beşiktaş / İstanbul',
      ),
      ('Müşteri Statüsü', 'Onaylı Seviye ${settingsState.verificationLevel}'),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kimlik ve İletişim Bilgileri',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.darkNavy,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: isDark ? Colors.white : const Color(0xFF64748B),
                ),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final entry in rows)
            _PersonalInfoRow(
              label: entry.$1,
              value: entry.$2,
              isDark: isDark,
            ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Bilgileri Düzenle / Güncelle'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _PersonalInfoRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color:
                  isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? Colors.white : AppColors.darkNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
          Divider(
            height: 12,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),
        ],
      ),
    );
  }
}

