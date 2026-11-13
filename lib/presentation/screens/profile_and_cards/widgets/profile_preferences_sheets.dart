import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/profile_settings_cubit.dart';

/// SessionTimeout, Currency ve Theme picker bottom sheet'leri için ortak Stateless seçici.
class ProfileOptionPickerSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<String> options;
  final String selectedValue;
  final bool isDark;
  final ValueChanged<String> onSelected;

  const ProfileOptionPickerSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.options,
    required this.selectedValue,
    required this.isDark,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.darkNavy;
    final subColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: TextStyle(color: subColor, fontSize: 12)),
          ],
          const SizedBox(height: 12),
          ...options.map((option) {
            final isSelected = selectedValue == option;
            return ListTile(
              title: Text(
                option,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: textColor,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_rounded, color: AppColors.primaryTeal)
                  : null,
              onTap: () => onSelected(option),
            );
          }),
        ],
      ),
    );
  }
}

Future<void> showNotificationPreferencesSheet(
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
    builder: (bottomCtx) =>
        _NotificationPreferencesSheetBody(cubit: cubit, isDark: isDark),
  );
}

class _NotificationPreferencesSheetBody extends StatelessWidget {
  final ProfileSettingsCubit cubit;
  final bool isDark;

  const _NotificationPreferencesSheetBody({
    required this.cubit,
    required this.isDark,
  });

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
                'Bildirim Tercihleri',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: Text(
                  'FAST & Para Transferi Bildirimleri',
                  style: TextStyle(color: textColor),
                ),
                subtitle: const Text(
                  'Para geldiğinde ve gittiğinde anlık push iletisi',
                ),
                value: state.pushNotifications,
                activeThumbColor: AppColors.primaryTeal,
                onChanged: cubit.togglePushNotifications,
              ),
              SwitchListTile(
                title: Text(
                  'SMS Güvenlik Kodları',
                  style: TextStyle(color: textColor),
                ),
                subtitle: const Text('Oturum ve işlem onay SMS\'leri'),
                value: state.smsNotifications,
                activeThumbColor: AppColors.primaryTeal,
                onChanged: cubit.toggleSmsNotifications,
              ),
              SwitchListTile(
                title: Text(
                  'Kampanya ve Nakit İade Fırsatları',
                  style: TextStyle(color: textColor),
                ),
                subtitle: const Text(
                  'İş ortağı indirimleri ve cashback duyuruları',
                ),
                value: state.campaignNotifications,
                activeThumbColor: AppColors.primaryTeal,
                onChanged: cubit.toggleCampaignNotifications,
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> showCurrencyPickerSheet(
  BuildContext context,
  ProfileSettingsCubit cubit,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  const currencies = [
    '🇹🇷 TRY (₺)',
    '🇺🇸 USD (\$)',
    '🇪🇺 EUR (€)',
    '🇬🇧 GBP (£)',
  ];
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomCtx) => BlocBuilder<ProfileSettingsCubit, ProfileSettingsState>(
      bloc: cubit,
      builder: (sheetCtx, state) => ProfileOptionPickerSheet(
        title: 'Ana Gösterge Para Birimi',
        options: currencies,
        selectedValue: state.currency,
        isDark: isDark,
        onSelected: (curr) {
          cubit.setCurrency(curr);
          Navigator.of(bottomCtx).pop();
        },
      ),
    ),
  );
}

Future<void> showThemePickerSheet(
  BuildContext context,
  ProfileSettingsCubit cubit,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  const themes = ['Açık Tema', 'Koyu Tema', 'Sistem Varsayılanı'];
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomCtx) => BlocBuilder<ProfileSettingsCubit, ProfileSettingsState>(
      bloc: cubit,
      builder: (sheetCtx, state) => ProfileOptionPickerSheet(
        title: 'Görünüm ve Tema',
        subtitle: 'Koyu tema ve açık tema arasında geçiş yapın.',
        options: themes,
        selectedValue: state.themeLabel,
        isDark: isDark,
        onSelected: (theme) {
          cubit.setThemeLabel(theme);
          Navigator.of(bottomCtx).pop();
        },
      ),
    ),
  );
}

Future<void> showLanguagePickerSheet(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomCtx) => _LanguagePickerSheetBody(
      isDark: isDark,
      onClose: () => Navigator.of(bottomCtx).pop(),
    ),
  );
}

class _LanguagePickerSheetBody extends StatelessWidget {
  final bool isDark;
  final VoidCallback onClose;

  const _LanguagePickerSheetBody({required this.isDark, required this.onClose});

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
            'Uygulama Dili / Language',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'PayPulse, BDDK ve TCMB mevzuat lisans koşulları gereği şu anda yalnızca Türkçe (TR) olarak hizmet vermektedir.',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryTeal),
            ),
            child: ListTile(
              leading: const Text('🇹🇷', style: TextStyle(fontSize: 24)),
              title: Text(
                'Türkçe (TR) — Varsayılan',
                style: TextStyle(fontWeight: FontWeight.w800, color: textColor),
              ),
              subtitle: const Text(
                'Aktif Sistem Dili (Resmi Dil)',
                style: TextStyle(color: AppColors.primaryTeal, fontSize: 11),
              ),
              trailing: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryTeal,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onClose,
              child: const Text('Anladım'),
            ),
          ),
        ],
      ),
    );
  }
}

