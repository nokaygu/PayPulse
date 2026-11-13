import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import '../auth/bloc/auth_state.dart';
import 'bloc/profile_settings_cubit.dart';
import 'widgets/profile_account_dialogs.dart';
import 'widgets/profile_edit_and_info_sheets.dart';
import 'widgets/profile_hero_card.dart';
import 'widgets/profile_kolas_sheet.dart';
import 'widgets/profile_legal_sheets.dart';
import 'widgets/profile_preferences_sheets.dart';
import 'widgets/profile_qr_dialog.dart';
import 'widgets/profile_security_sheets.dart';
import 'widgets/profile_setting_tile.dart';
import 'widgets/profile_settings_section_card.dart';
import 'widgets/profile_support_sheets.dart';

/// Profil ve Ayarlar Ekranı (Stateless + ProfileSettingsCubit + AuthBloc).
class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final initialUser = context.read<AuthBloc>().state.user;
    return BlocProvider<ProfileSettingsCubit>(
      create: (_) => ProfileSettingsCubit(initialUser: initialUser),
      child: const _ProfileSettingsView(),
    );
  }
}

class _ProfileSettingsView extends StatelessWidget {
  const _ProfileSettingsView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final secondaryTextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final authState = context.watch<AuthBloc>().state;

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) =>
              prev.user != curr.user ||
              (prev.errorMessage != curr.errorMessage &&
                  curr.errorMessage != null),
          listener: (ctx, state) {
            ctx.read<ProfileSettingsCubit>().syncUser(state.user);
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: const Color(0xFFDC2626),
                ),
              );
              ctx.read<AuthBloc>().add(const AuthErrorCleared());
            }
          },
        ),
        BlocListener<ProfileSettingsCubit, ProfileSettingsState>(
          listenWhen: (prev, curr) =>
              prev.feedbackMessage != curr.feedbackMessage &&
              curr.feedbackMessage != null,
          listener: (ctx, state) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(state.feedbackMessage!),
                duration: const Duration(seconds: 2),
                backgroundColor:
                    state.isErrorFeedback ? const Color(0xFFDC2626) : null,
              ),
            );
            ctx.read<ProfileSettingsCubit>().clearFeedback();
          },
        ),
      ],
      child: BlocBuilder<ProfileSettingsCubit, ProfileSettingsState>(
        builder: (context, settingsState) {
          final cubit = context.read<ProfileSettingsCubit>();
          final authBloc = context.read<AuthBloc>();

          return Scaffold(
            backgroundColor: scaffoldBg,
            appBar: RoleSwitchAppBar(isBusinessMode: authState.isBusinessMode),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileTopBar(
                    isDark: isDark,
                    onBack: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        context.go(AppRoutes.home);
                      }
                    },
                    onEditProfile: () {
                      cubit.prepareEditProfile();
                      showEditProfileSheet(context, cubit, authBloc);
                    },
                    onMoreOptions: () => showMoreOptionsSheet(
                      context: context,
                      settingsState: settingsState,
                      onShowQr: () => showProfileQrDialog(
                        context,
                        settingsState,
                        settingsState.displayIban,
                      ),
                      onFreezeAccount: () => showFreezeAccountDialog(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ProfileHeroCard(
                    settingsState: settingsState,
                    onAvatarTap: () => showAvatarOptionsSheet(context),
                    onCopyCustomerNo: () => copyProfileFieldToClipboard(
                      value: settingsState.displayCustomerNo,
                      cubit: cubit,
                      feedbackMessage:
                          'Müşteri No (${settingsState.displayCustomerNo}) kopyalandı.',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ProfileIbanLimitCard(
                    settingsState: settingsState,
                    isDark: isDark,
                    onShowQr: () => showProfileQrDialog(
                      context,
                      settingsState,
                      settingsState.displayIban,
                    ),
                    onCopyIban: () => copyProfileFieldToClipboard(
                      value: settingsState.displayIban,
                      cubit: cubit,
                      feedbackMessage: 'FAST IBAN panoya kopyalandı.',
                    ),
                    onIncreaseLimit: () => showLimitIncreaseSheet(
                      context,
                      cubit,
                      settingsState,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ProfileSettingsSectionCard(
                    headerTitle: 'HESAP VE KİŞİSEL BİLGİLER',
                    isDark: isDark,
                    children: [
                      ProfileSettingTile(
                        icon: Icons.badge_outlined,
                        title: 'Kimlik ve İletişim Bilgileri',
                        subtitle: 'TCKN, Adres, Doğum Tarihi',
                        onTap: () => showPersonalInfoSheet(
                          context,
                          cubit,
                          settingsState,
                          authBloc,
                        ),
                        isDark: isDark,
                      ),
                      ProfileSettingTile(
                        icon: Icons.credit_card_rounded,
                        title: 'Kayıtlı Banka ve Kartlarım',
                        subtitle: 'Hesaplar ve Kartlar Arasında Geçiş Yap',
                        trailingBadge: 'Geçiş Yap',
                        badgeIsSuccess: true,
                        onTap: () => context.push(AppRoutes.cards),
                        isDark: isDark,
                      ),
                      ProfileSettingTile(
                        icon: Icons.alternate_email_rounded,
                        title: 'Kolay Adres (KOLAS) Tanımları',
                        subtitle: settingsState.kolasEmailLinked
                            ? 'Telefon ve E-posta Eşli'
                            : 'Telefon Numarası Eşli',
                        showDivider: false,
                        onTap: () => showKolasSheet(context, cubit),
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ProfileSettingsSectionCard(
                    headerTitle: 'GÜVENLİK VE GİZLİLİK',
                    isDark: isDark,
                    children: [
                      ProfileBiometricSwitchTile(
                        value: settingsState.biometricEnabled,
                        isDark: isDark,
                        onChanged: cubit.toggleBiometric,
                      ),
                      ProfileSettingTile(
                        icon: Icons.pin_outlined,
                        title: 'Cüzdan PIN Kodunu Değiştir',
                        subtitle: 'Son değişim: 3 ay önce',
                        onTap: () {
                          cubit.prepareChangePin();
                          showChangePinSheet(context, cubit);
                        },
                        isDark: isDark,
                      ),
                      ProfileSettingTile(
                        icon: Icons.shield_outlined,
                        title: 'İki Adımlı Doğrulama (2FA)',
                        subtitle: 'SMS ve Authenticator koruması',
                        trailingBadge: settingsState.twoFactorEnabled
                            ? 'Etkin'
                            : 'Pasif',
                        badgeIsSuccess: settingsState.twoFactorEnabled,
                        onTap: () => showTwoFactorSheet(context, cubit),
                        isDark: isDark,
                      ),
                      ProfileSettingTile(
                        icon: Icons.devices_rounded,
                        title: 'Güvenilir Cihazlar',
                        subtitle: 'iPhone 15 Pro (Bu Cihaz)',
                        onTap: () => showTrustedDevicesSheet(context),
                        isDark: isDark,
                      ),
                      ProfileSettingTile(
                        icon: Icons.timer_outlined,
                        title: 'Oturum Zaman Aşımı',
                        subtitle: 'Uygulama arka plandayken',
                        trailingText: settingsState.sessionTimeout,
                        showDivider: false,
                        onTap: () => showSessionTimeoutSheet(context, cubit),
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ProfileSettingsSectionCard(
                    headerTitle: 'TERCİHLER VE BİLDİRİMLER',
                    isDark: isDark,
                    children: [
                      ProfileSettingTile(
                        icon: Icons.notifications_active_outlined,
                        title: 'Bildirim Tercihleri',
                        subtitle: 'Anlık FAST, Bütçe ve Kampanyalar',
                        onTap: () =>
                            showNotificationPreferencesSheet(context, cubit),
                        isDark: isDark,
                      ),
                      ProfileSettingTile(
                        icon: Icons.payments_outlined,
                        title: 'Ana Para Birimi',
                        subtitle: 'Gösterge bakiyesi',
                        trailingText: settingsState.currency,
                        onTap: () => showCurrencyPickerSheet(context, cubit),
                        isDark: isDark,
                      ),
                      ProfileSettingTile(
                        icon: Icons.palette_outlined,
                        title: 'Görünüm ve Tema',
                        subtitle: 'Açık / Koyu Tema Geçişi',
                        trailingText: settingsState.themeLabel,
                        trailingBadge: settingsState.themeLabel == 'Koyu Tema'
                            ? 'Koyu'
                            : 'Açık',
                        badgeIsSuccess:
                            settingsState.themeLabel == 'Koyu Tema',
                        onTap: () => showThemePickerSheet(context, cubit),
                        isDark: isDark,
                      ),
                      ProfileSettingTile(
                        icon: Icons.translate_rounded,
                        title: 'Uygulama Dili / Language',
                        subtitle: 'Yalnızca Türkçe (TR) desteklenir',
                        trailingText: settingsState.language,
                        showDivider: false,
                        onTap: () => showLanguagePickerSheet(context),
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ProfileSettingsSectionCard(
                    headerTitle: 'DESTEK VE YASAL BİLGİLER',
                    isDark: isDark,
                    children: [
                      ProfileSettingTile(
                        icon: Icons.support_agent_rounded,
                        title: 'Yardım & Canlı Destek',
                        subtitle: '7/24 Kesintisiz Asistan',
                        subtitleColor: AppColors.primaryTeal,
                        onTap: () => showSupportSheet(context),
                        isDark: isDark,
                      ),
                      ProfileSettingTile(
                        icon: Icons.quiz_outlined,
                        title: 'Sıkça Sorulan Sorular (SSS)',
                        subtitle: 'İşlem limitleri, FAST kuralları',
                        onTap: () => showFaqSheet(context),
                        isDark: isDark,
                      ),
                      ProfileSettingTile(
                        icon: Icons.description_outlined,
                        title: 'Sözleşmeler ve KVKK Metni',
                        subtitle: 'Açık rıza ve gizlilik koşulları',
                        onTap: () => showLegalContractsSheet(context),
                        isDark: isDark,
                      ),
                      ProfileSettingTile(
                        icon: Icons.verified_user_outlined,
                        title: 'Güvenlik ve Lisans Bilgileri',
                        subtitle: 'TCMB & BDDK mevzuat uyumu',
                        showDivider: false,
                        onTap: () => showComplianceSheet(context),
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEE2E2),
                        foregroundColor: const Color(0xFFB91C1C),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => showLogoutConfirmationDialog(context),
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text(
                        'Güvenli Çıkış Yap',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ProfileComplianceFooter(
                    secondaryTextColor: secondaryTextColor,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileComplianceFooter extends StatelessWidget {
  final Color secondaryTextColor;

  const _ProfileComplianceFooter({required this.secondaryTextColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_user_outlined,
                size: 14,
                color: AppColors.primaryTeal,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'TCMB Lisanslı Ödeme ve Elektronik Para Hizmeti',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: secondaryTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'PayPulse v2.4.1 (Build 8420) • Güvenli 256-bit SSL',
            style: AppTextStyles.bodySmall.copyWith(
              color: secondaryTextColor,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}
