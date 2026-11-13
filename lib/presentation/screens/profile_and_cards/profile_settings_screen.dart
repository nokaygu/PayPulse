import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/financial_amount.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import '../auth/bloc/auth_state.dart';
import 'bloc/profile_settings_cubit.dart';

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
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final primaryTextColor = isDark ? Colors.white : AppColors.darkNavy;
    final secondaryTextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final circleBtnBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final circleBtnBorder =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final backBtnBg =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

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
            final msg = state.feedbackMessage!;
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(msg),
                duration: const Duration(seconds: 2),
                backgroundColor: state.isErrorFeedback
                    ? const Color(0xFFDC2626)
                    : null,
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
            appBar: RoleSwitchAppBar(
              isBusinessMode: authState.isBusinessMode,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      context.go(AppRoutes.home);
                    }
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: backBtnBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 18,
                      color: primaryTextColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profil ve Ayarlar',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: primaryTextColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Bireysel Cüzdan Yönetimi',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Profil Düzenle (Kalem İkonu)
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {
                    cubit.prepareEditProfile();
                    _showEditProfileSheet(context, cubit, authBloc);
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: circleBtnBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: circleBtnBorder),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: primaryTextColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Daha Fazla Seçenek (Üç Nokta İkonu)
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () => _showMoreOptionsSheet(context, settingsState),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: circleBtnBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: circleBtnBorder),
                    ),
                    child: Icon(
                      Icons.more_vert_rounded,
                      size: 18,
                      color: primaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 1. Dinamik Kullanıcı Profil Kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.heroCardGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryGreen,
                                width: 2,
                              ),
                              color: const Color(0xFF1E293B),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () => _showAvatarOptionsSheet(context),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  size: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              settingsState.displayName,
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withValues(
                                  alpha: 0.18,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.verified_outlined,
                                    color: AppColors.primaryGreen,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Onaylı Hesap (Seviye ${settingsState.verificationLevel})',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.primaryGreen,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              settingsState.phone,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF94A3B8),
                                fontSize: 11.5,
                              ),
                            ),
                            Text(
                              settingsState.displayEmail,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF94A3B8),
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(
                    color: Colors.white.withValues(alpha: 0.12),
                    height: 1,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF94A3B8),
                          ),
                          children: [
                            const TextSpan(text: 'Müşteri No:  '),
                            TextSpan(
                              text: settingsState.displayCustomerNo,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: settingsState.displayCustomerNo,
                            ),
                          );
                          cubit.emitFeedback(
                            'Müşteri No (${settingsState.displayCustomerNo}) kopyalandı.',
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTeal.withValues(
                              alpha: 0.25,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Kopyala',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. PayPulse TRY FAST IBAN & Transfer Limiti Kartı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.account_balance_outlined,
                            size: 16,
                            color: AppColors.primaryTeal,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'PayPulse TRY FAST IBAN',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: primaryTextColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => _showQrCodeDialog(
                              context,
                              settingsState,
                              settingsState.displayIban,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.qr_code_2_rounded,
                                size: 18,
                                color: primaryTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: settingsState.displayIban),
                              );
                              cubit.emitFeedback(
                                'FAST IBAN panoya kopyalandı.',
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.copy_rounded,
                                size: 18,
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            settingsState.displayIban,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: primaryTextColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'FAST',
                            style: TextStyle(
                              color: Color(0xFF065F46),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Kalan Aylık Transfer Limiti',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _showLimitIncreaseSheet(
                          context,
                          cubit,
                          settingsState,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Text(
                            'Limit Artır',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primaryTeal,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: settingsState.limitUsageRatio,
                      minHeight: 7,
                      backgroundColor: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryTeal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${FinancialAmount.format((settingsState.spentThisMonth * 100).round())} / '
                          '${FinancialAmount.format((settingsState.monthlyLimit * 100).round())}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: secondaryTextColor,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '%${(settingsState.limitUsageRatio * 100).round()} kullanıldı',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: secondaryTextColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // GRUP 1: HESAP VE KİŞİSEL BİLGİLER
            _buildSectionHeader('HESAP VE KİŞİSEL BİLGİLER', isDark),
            const SizedBox(height: 8),
            _buildMenuCard([
              _buildSettingTile(
                icon: Icons.badge_outlined,
                title: 'Kimlik ve İletişim Bilgileri',
                subtitle: 'TCKN, Adres, Doğum Tarihi',
                onTap: () => _showPersonalInfoSheet(
                  context,
                  cubit,
                  settingsState,
                  authBloc,
                ),
                isDark: isDark,
              ),
              _buildSettingTile(
                icon: Icons.credit_card_rounded,
                title: 'Kayıtlı Banka ve Kartlarım',
                subtitle: 'Hesaplar ve Kartlar Arasında Geçiş Yap',
                trailingBadge: 'Geçiş Yap',
                badgeIsSuccess: true,
                onTap: () => context.push(AppRoutes.cards),
                isDark: isDark,
              ),
              _buildSettingTile(
                icon: Icons.alternate_email_rounded,
                title: 'Kolay Adres (KOLAS) Tanımları',
                subtitle: settingsState.kolasEmailLinked
                    ? 'Telefon ve E-posta Eşli'
                    : 'Telefon Numarası Eşli',
                showDivider: false,
                onTap: () => _showKolasSheet(context, cubit, settingsState),
                isDark: isDark,
              ),
            ], isDark: isDark),
            const SizedBox(height: 18),

            // GRUP 2: GÜVENLİK VE GİZLİLİK
            _buildSectionHeader('GÜVENLİK VE GİZLİLİK', isDark),
            const SizedBox(height: 8),
            _buildMenuCard([
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.fingerprint_rounded,
                        color: AppColors.primaryTeal,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Biyometrik Giriş',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: primaryTextColor,
                            ),
                          ),
                          Text(
                            'Face ID / Parmak İzi ile aç',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: secondaryTextColor,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: settingsState.biometricEnabled,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.primaryTeal,
                      onChanged: cubit.toggleBiometric,
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFF1F5F9),
              ),
              _buildSettingTile(
                icon: Icons.pin_outlined,
                title: 'Cüzdan PIN Kodunu Değiştir',
                subtitle: 'Son değişim: 3 ay önce',
                onTap: () {
                  cubit.prepareChangePin();
                  _showChangePinSheet(context, cubit);
                },
                isDark: isDark,
              ),
              _buildSettingTile(
                icon: Icons.shield_outlined,
                title: 'İki Adımlı Doğrulama (2FA)',
                subtitle: 'SMS ve Authenticator koruması',
                trailingBadge: settingsState.twoFactorEnabled
                    ? 'Etkin'
                    : 'Pasif',
                badgeIsSuccess: settingsState.twoFactorEnabled,
                onTap: () => _showTwoFactorSheet(context, cubit),
                isDark: isDark,
              ),
              _buildSettingTile(
                icon: Icons.devices_rounded,
                title: 'Güvenilir Cihazlar',
                subtitle: 'iPhone 15 Pro (Bu Cihaz)',
                onTap: () => _showTrustedDevicesSheet(context),
                isDark: isDark,
              ),
              _buildSettingTile(
                icon: Icons.timer_outlined,
                title: 'Oturum Zaman Aşımı',
                subtitle: 'Uygulama arka plandayken',
                trailingText: settingsState.sessionTimeout,
                showDivider: false,
                onTap: () => _showSessionTimeoutSheet(context, cubit),
                isDark: isDark,
              ),
            ], isDark: isDark),
            const SizedBox(height: 18),

            // GRUP 3: TERCİHLER VE BİLDİRİMLER
            _buildSectionHeader('TERCİHLER VE BİLDİRİMLER', isDark),
            const SizedBox(height: 8),
            _buildMenuCard([
              _buildSettingTile(
                icon: Icons.notifications_active_outlined,
                title: 'Bildirim Tercihleri',
                subtitle: 'Anlık FAST, Bütçe ve Kampanyalar',
                onTap: () =>
                    _showNotificationPreferencesSheet(context, cubit),
                isDark: isDark,
              ),
              _buildSettingTile(
                icon: Icons.payments_outlined,
                title: 'Ana Para Birimi',
                subtitle: 'Gösterge bakiyesi',
                trailingText: settingsState.currency,
                onTap: () => _showCurrencyPickerSheet(context, cubit),
                isDark: isDark,
              ),
              _buildSettingTile(
                icon: Icons.palette_outlined,
                title: 'Görünüm ve Tema',
                subtitle: 'Açık / Koyu Tema Geçişi',
                trailingText: settingsState.themeLabel,
                trailingBadge:
                    settingsState.themeLabel == 'Koyu Tema' ? 'Koyu' : 'Açık',
                badgeIsSuccess: settingsState.themeLabel == 'Koyu Tema',
                onTap: () => _showThemePickerSheet(context, cubit),
                isDark: isDark,
              ),
              _buildSettingTile(
                icon: Icons.translate_rounded,
                title: 'Uygulama Dili / Language',
                subtitle: 'Yalnızca Türkçe (TR) desteklenir',
                trailingText: settingsState.language,
                showDivider: false,
                onTap: () => _showLanguagePickerSheet(context),
                isDark: isDark,
              ),
            ], isDark: isDark),
            const SizedBox(height: 18),

            // GRUP 4: DESTEK VE YASAL BİLGİLER
            _buildSectionHeader('DESTEK VE YASAL BİLGİLER', isDark),
            const SizedBox(height: 8),
            _buildMenuCard([
              _buildSettingTile(
                icon: Icons.support_agent_rounded,
                title: 'Yardım & Canlı Destek',
                subtitle: '7/24 Kesintisiz Asistan',
                subtitleColor: AppColors.primaryTeal,
                onTap: () => _showSupportSheet(context),
                isDark: isDark,
              ),
              _buildSettingTile(
                icon: Icons.quiz_outlined,
                title: 'Sıkça Sorulan Sorular (SSS)',
                subtitle: 'İşlem limitleri, FAST kuralları',
                onTap: () => _showFaqSheet(context),
                isDark: isDark,
              ),
              _buildSettingTile(
                icon: Icons.description_outlined,
                title: 'Sözleşmeler ve KVKK Metni',
                subtitle: 'Açık rıza ve gizlilik koşulları',
                onTap: () => _showLegalContractsSheet(context),
                isDark: isDark,
              ),
              _buildSettingTile(
                icon: Icons.verified_user_outlined,
                title: 'Güvenlik ve Lisans Bilgileri',
                subtitle: 'TCMB & BDDK mevzuat uyumu',
                showDivider: false,
                onTap: () => _showComplianceSheet(context),
                isDark: isDark,
              ),
            ], isDark: isDark),
            const SizedBox(height: 18),

            // Güvenli Çıkış Yap Butonu
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
                onPressed: () => _showLogoutConfirmationDialog(context),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(
                  'Güvenli Çıkış Yap',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Alt Lisans Bilgisi
            Center(
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

  // ==================== BÜYÜYEN QR KOD DİYALOĞU ====================
  void _showQrCodeDialog(
    BuildContext context,
    ProfileSettingsState settingsState,
    String iban,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.qr_code_2_rounded,
                            color: AppColors.primaryTeal,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FAST QR ile Ödeme Al',
                              style: AppTextStyles.headlineSmall.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.darkNavy,
                              ),
                            ),
                            Text(
                              'PayPulse TRY FAST',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data:
                        'iban:$iban;name:${settingsState.displayName};service:FAST',
                    version: QrVersions.auto,
                    size: 200.0,
                    gapless: true,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  settingsState.displayName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          iban,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark ? Colors.white : AppColors.darkNavy,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: isDark
                                ? const Color(0xFF475569)
                                : const Color(0xFFCBD5E1),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: iban));
                          Navigator.of(dialogCtx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('FAST IBAN panoya kopyalandı.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: isDark ? Colors.white : AppColors.darkNavy,
                        ),
                        label: Text(
                          'IBAN Kopyala',
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.darkNavy,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogCtx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'QR Kod paylaşım bağlantısı hazırlandı.',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.share_rounded, size: 16),
                        label: const Text('Paylaş'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== PROFİLİ DÜZENLE (KALEM İKONU) ====================
  void _showEditProfileSheet(
    BuildContext context,
    ProfileSettingsCubit cubit,
    AuthBloc authBloc,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomCtx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(bottomCtx).viewInsets.bottom + 20,
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
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                      onPressed: () => Navigator.of(bottomCtx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: cubit.nameController,
                  validator: (v) =>
                      (v == null || v.trim().length < 2)
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
                          cubit.editProfileFormKey.currentState?.validate() ??
                              true;
                      if (!isValid) return;

                      final newName = cubit.nameController.text.trim();
                      authBloc.add(AuthProfileUpdated(name: newName));
                      cubit.savePhoneAndNotify(
                        phone: cubit.phoneController.text,
                      );
                      Navigator.of(bottomCtx).pop();
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
      },
    );
  }

  // ==================== DAHA FAZLA SEÇENEK (ÜST ÜSTE NOKTA) ====================
  void _showMoreOptionsSheet(
    BuildContext context,
    ProfileSettingsState settingsState,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomCtx) {
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
                    color: isDark ? Colors.white : AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(
                    Icons.share_rounded,
                    color: AppColors.primaryTeal,
                  ),
                  title: Text(
                    'Profili & FAST IBAN Paylaş',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.darkNavy,
                    ),
                  ),
                  subtitle: const Text(
                    'Hesap bilgilerini mesaj veya PDF ile ilet',
                  ),
                  onTap: () {
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
                        content: Text(
                          'Hesap bilgileri panoya kopyalandı ve paylaşıma hazır.',
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.receipt_long_rounded,
                    color: isDark ? Colors.white : AppColors.darkNavy,
                  ),
                  title: Text(
                    'Aylık Hesap Özeti İndir (PDF)',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.darkNavy,
                    ),
                  ),
                  subtitle: const Text(
                    'Son aya ait resmi mühürlü hesap ekstresi',
                  ),
                  onTap: () {
                    Navigator.of(bottomCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hesap ekstresi PDF olarak indirildi.'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: AppColors.primaryTeal,
                  ),
                  title: Text(
                    'FAST QR Kodunu Göster',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.darkNavy,
                    ),
                  ),
                  subtitle: const Text('Tahsilat için büyütülmüş QR kod'),
                  onTap: () {
                    Navigator.of(bottomCtx).pop();
                    _showQrCodeDialog(
                      context,
                      settingsState,
                      settingsState.displayIban,
                    );
                  },
                ),
                Divider(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
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
                  onTap: () {
                    Navigator.of(bottomCtx).pop();
                    _showFreezeAccountDialog(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== PROFİL FOTOĞRAFI SEÇENEKLERİ ====================
  void _showAvatarOptionsSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomCtx) {
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
                    color: isDark ? Colors.white : AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.primaryTeal,
                  ),
                  title: Text(
                    'Kamerayı Aç',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.darkNavy,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(bottomCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kamera erişimi başlatılıyor...'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color: isDark ? Colors.white : AppColors.darkNavy,
                  ),
                  title: Text(
                    'Galeriden Fotoğraf Seç',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.darkNavy,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(bottomCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fotoğraf galerisi açılıyor...'),
                      ),
                    );
                  },
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
                  onTap: () {
                    Navigator.of(bottomCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Profil fotoğrafı varsayılana sıfırlandı.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== KİMLİK VE İLETİŞİM BİLGİLERİ ====================
  void _showPersonalInfoSheet(
    BuildContext context,
    ProfileSettingsCubit cubit,
    ProfileSettingsState settingsState,
    AuthBloc authBloc,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomCtx) {
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
                    onPressed: () => Navigator.of(bottomCtx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Ad Soyad', settingsState.displayName, isDark),
              _buildInfoRow(
                'T.C. Kimlik No',
                '284******** (Doğrulandı)',
                isDark,
              ),
              _buildInfoRow('Doğum Tarihi', '14.06.1994', isDark),
              _buildInfoRow('Cep Telefonu', settingsState.phone, isDark),
              _buildInfoRow('E-posta', settingsState.displayEmail, isDark),
              _buildInfoRow(
                'Kayıtlı İkametgah',
                'Levent Mah. Cömert Sk. No: 1 Beşiktaş / İstanbul',
                isDark,
              ),
              _buildInfoRow(
                'Müşteri Statüsü',
                'Onaylı Seviye ${settingsState.verificationLevel}',
                isDark,
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
                  onPressed: () {
                    Navigator.of(bottomCtx).pop();
                    cubit.prepareEditProfile();
                    _showEditProfileSheet(context, cubit, authBloc);
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Bilgileri Düzenle / Güncelle'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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

  // ==================== KOLAY ADRES (KOLAS) TANIMLARI ====================
  void _showKolasSheet(
    BuildContext context,
    ProfileSettingsCubit cubit,
    ProfileSettingsState settingsState,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomCtx) {
        return BlocProvider<ProfileSettingsCubit>.value(
          value: cubit,
          child: BlocBuilder<ProfileSettingsCubit, ProfileSettingsState>(
            builder: (sheetCtx, state) {
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
                          'Kolay Adres (KOLAS) Tanımları',
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.darkNavy,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF64748B),
                          ),
                          onPressed: () => Navigator.of(bottomCtx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'IBAN girmeden, telefon veya e-posta ile anında para transferi alın.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.phone_iphone_rounded,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                      title: Text(
                        'Telefon Numarası',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.darkNavy,
                        ),
                      ),
                      subtitle: Text(state.phone),
                      trailing: const Chip(
                        label: Text('Varsayılan'),
                        backgroundColor: Color(0xFFD1FAE5),
                        labelStyle: TextStyle(
                          color: Color(0xFF065F46),
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Divider(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFF1F5F9),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.email_outlined,
                          color: isDark ? Colors.white : AppColors.darkNavy,
                        ),
                      ),
                      title: Text(
                        'E-posta Adresi',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.darkNavy,
                        ),
                      ),
                      subtitle: Text(state.displayEmail),
                      trailing: state.kolasEmailLinked
                          ? const Chip(
                              label: Text('Eşleştirildi'),
                              backgroundColor: Color(0xFFD1FAE5),
                              labelStyle: TextStyle(
                                color: Color(0xFF065F46),
                                fontSize: 11,
                              ),
                            )
                          : TextButton(
                              onPressed: cubit.linkKolasEmail,
                              child: const Text('Eşleştir'),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ==================== CÜZDAN PIN KODUNU DEĞİŞTİR ====================
  void _showChangePinSheet(BuildContext context, ProfileSettingsCubit cubit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomCtx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(bottomCtx).viewInsets.bottom + 20,
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
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: cubit.oldPinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Mevcut PIN Kodu',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: cubit.newPinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Yeni PIN Kodu',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: cubit.confirmPinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Yeni PIN Kodu (Tekrar)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
                      if (cubit.submitPinChange()) {
                        Navigator.of(bottomCtx).pop();
                      }
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
      },
    );
  }

  // ==================== İKİ ADIMLI DOĞRULAMA (2FA) ====================
  void _showTwoFactorSheet(BuildContext context, ProfileSettingsCubit cubit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomCtx) {
        return BlocProvider<ProfileSettingsCubit>.value(
          value: cubit,
          child: BlocBuilder<ProfileSettingsCubit, ProfileSettingsState>(
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
                        color: isDark ? Colors.white : AppColors.darkNavy,
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
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.darkNavy,
                        ),
                      ),
                      subtitle: const Text('SMS ve Authenticator Uygulaması'),
                      value: state.twoFactorEnabled,
                      activeThumbColor: AppColors.primaryTeal,
                      onChanged: cubit.toggleTwoFactor,
                    ),
                    Divider(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFF1F5F9),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.sms_outlined,
                        color: isDark ? Colors.white : AppColors.darkNavy,
                      ),
                      title: Text(
                        'SMS Doğrulama',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.darkNavy,
                        ),
                      ),
                      subtitle: Text(
                        '${state.phone} numarasına kod gönderilir',
                      ),
                      trailing: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ==================== GÜVENİLİR CİHAZLAR ====================
  void _showTrustedDevicesSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomCtx) {
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
                  color: isDark ? Colors.white : AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Hesabınıza giriş yapılmış cihazlar ve aktif oturumlar.',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
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
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.darkNavy,
                  ),
                ),
                subtitle: const Text('İstanbul, Türkiye • Aktif Oturum'),
                trailing: const Chip(
                  label: Text('Bu Cihaz'),
                  backgroundColor: Color(0xFFD1FAE5),
                  labelStyle: TextStyle(color: Color(0xFF065F46), fontSize: 11),
                ),
              ),
              Divider(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFF1F5F9),
              ),
              ListTile(
                leading: Icon(
                  Icons.laptop_mac_rounded,
                  color: isDark ? Colors.white : AppColors.darkNavy,
                ),
                title: Text(
                  'MacBook Pro 16"',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.darkNavy,
                  ),
                ),
                subtitle: const Text('Chrome Web • Son giriş: Dün 14:32'),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFDC2626),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('MacBook Pro oturumu sonlandırıldı.'),
                      ),
                    );
                  },
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
                  onPressed: () {
                    Navigator.of(bottomCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Bu cihaz haricindeki tüm oturumlar kapatıldı.',
                        ),
                      ),
                    );
                  },
                  child: const Text('Tüm Diğer Oturumları Kapat'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== OTURUM ZAMAN AŞIMI ====================
  void _showSessionTimeoutSheet(
    BuildContext context,
    ProfileSettingsCubit cubit,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const durations = ['1 Dakika', '5 Dakika', '15 Dakika', '30 Dakika'];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomCtx) {
        return BlocProvider<ProfileSettingsCubit>.value(
          value: cubit,
          child: BlocBuilder<ProfileSettingsCubit, ProfileSettingsState>(
            builder: (sheetCtx, state) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Oturum Zaman Aşımı',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.darkNavy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Uygulama arka plandayken ne kadar süre sonra PIN istenmeli?',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...durations.map((duration) {
                      final isSelected = state.sessionTimeout == duration;
                      return ListTile(
                        title: Text(
                          duration,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: isDark ? Colors.white : AppColors.darkNavy,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                color: AppColors.primaryTeal,
                              )
                            : null,
                        onTap: () {
                          cubit.setSessionTimeout(duration);
                          Navigator.of(bottomCtx).pop();
                        },
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ==================== TRANSFER LİMİTİ ARTIR ====================
  void _showLimitIncreaseSheet(
    BuildContext context,
    ProfileSettingsCubit cubit,
    ProfileSettingsState settingsState,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedCurrentLimit = FinancialAmount.format(
      (settingsState.monthlyLimit * 100).round(),
    );

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomCtx) {
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
                  color: isDark ? Colors.white : AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Mevcut Seviye ${settingsState.verificationLevel} limitiniz aylık $formattedCurrentLimit\'dir.',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
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
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          '$formattedCurrentLimit / Ay',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.darkNavy,
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
                  onPressed: () {
                    Navigator.of(bottomCtx).pop();
                    cubit.emitFeedback(
                      'Seviye 3 limit artırım başvurunuz alındı. 24 saat içinde incelenecektir.',
                    );
                  },
                  icon: const Icon(Icons.verified_rounded, size: 18),
                  label: const Text('Limit Artırım Talebi Gönder'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== BİLDİRİM TERCİHLERİ ====================
  void _showNotificationPreferencesSheet(
    BuildContext context,
    ProfileSettingsCubit cubit,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomCtx) {
        return BlocProvider<ProfileSettingsCubit>.value(
          value: cubit,
          child: BlocBuilder<ProfileSettingsCubit, ProfileSettingsState>(
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
                        color: isDark ? Colors.white : AppColors.darkNavy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: Text(
                        'FAST & Para Transferi Bildirimleri',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.darkNavy,
                        ),
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
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.darkNavy,
                        ),
                      ),
                      subtitle: const Text('Oturum ve işlem onay SMS\'leri'),
                      value: state.smsNotifications,
                      activeThumbColor: AppColors.primaryTeal,
                      onChanged: cubit.toggleSmsNotifications,
                    ),
                    SwitchListTile(
                      title: Text(
                        'Kampanya ve Nakit İade Fırsatları',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.darkNavy,
                        ),
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
          ),
        );
      },
    );
  }

  // ==================== PARA BİRİMİ SEÇİCİ ====================
  void _showCurrencyPickerSheet(
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
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomCtx) {
        return BlocProvider<ProfileSettingsCubit>.value(
          value: cubit,
          child: BlocBuilder<ProfileSettingsCubit, ProfileSettingsState>(
            builder: (sheetCtx, state) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ana Gösterge Para Birimi',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.darkNavy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...currencies.map((curr) {
                      final isSelected = state.currency == curr;
                      return ListTile(
                        title: Text(
                          curr,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: isDark ? Colors.white : AppColors.darkNavy,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                color: AppColors.primaryTeal,
                              )
                            : null,
                        onTap: () {
                          cubit.setCurrency(curr);
                          Navigator.of(bottomCtx).pop();
                        },
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ==================== TEMA SEÇİCİ (KOYU / AÇIK TEMA) ====================
  void _showThemePickerSheet(
    BuildContext context,
    ProfileSettingsCubit cubit,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const themes = ['Açık Tema', 'Koyu Tema', 'Sistem Varsayılanı'];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomCtx) {
        return BlocProvider<ProfileSettingsCubit>.value(
          value: cubit,
          child: BlocBuilder<ProfileSettingsCubit, ProfileSettingsState>(
            builder: (sheetCtx, state) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Görünüm ve Tema',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.darkNavy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Koyu tema ve açık tema arasında geçiş yapın.',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...themes.map((t) {
                      final isSelected = state.themeLabel == t;
                      return ListTile(
                        title: Text(
                          t,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: isDark ? Colors.white : AppColors.darkNavy,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                color: AppColors.primaryTeal,
                              )
                            : null,
                        onTap: () {
                          cubit.setThemeLabel(t);
                          Navigator.of(bottomCtx).pop();
                        },
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ==================== DİL SEÇİCİ (SADECE TÜRKÇE) ====================
  void _showLanguagePickerSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomCtx) {
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
                  color: isDark ? Colors.white : AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'PayPulse, BDDK ve TCMB mevzuat lisans koşulları gereği şu anda yalnızca Türkçe (TR) olarak hizmet vermektedir.',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
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
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.darkNavy,
                    ),
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
                  onPressed: () => Navigator.of(bottomCtx).pop(),
                  child: const Text('Anladım'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== YARDIM & CANLI DESTEK ====================
  void _showSupportSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomCtx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Yardım ve Canlı Destek',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'PayPulse uzman destek ekibi 7/24 yanınızda.',
                style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.support_agent_rounded, color: AppColors.primaryTeal),
                ),
                title: Text('Canlı Desteğe Bağlan', style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy)),
                subtitle: const Text('Ortalama yanıt süresi: < 1 dakika'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.of(bottomCtx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Canlı destek oturumu başlatılıyor...')),
                  );
                },
              ),
              Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.phone_outlined, color: isDark ? Colors.white : AppColors.darkNavy),
                ),
                title: Text('Müşteri Hizmetleri Çağrı Merkezi', style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy)),
                subtitle: const Text('0850 555 00 00 (Ücretsiz)'),
                onTap: () {
                  Navigator.of(bottomCtx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Çağrı merkezi numarası panoya kopyalandı.')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== SSS (SIKÇA SORULAN SORULAR) ====================
  void _showFaqSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomCtx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Sıkça Sorulan Sorular (SSS)',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: 12),
                ExpansionTile(
                  title: Text(
                    'FAST para transferi ne kadar sürer?',
                    style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy, fontWeight: FontWeight.w700),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'TCMB FAST sistemi sayesinde PayPulse ile yapılan tüm transferler 7/24 saniyeler içerisinde alıcının hesabına geçer.',
                        style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
                ExpansionTile(
                  title: Text(
                    'Transfer ve işlem limitleri nelerdir?',
                    style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy, fontWeight: FontWeight.w700),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Seviye 2 onaylı bireysel hesaplar için aylık FAST transfer limiti ₺250.000 TL\'dir. Limit artırımı için Kimlik ve Adres belgesi yükleyebilirsiniz.',
                        style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
                ExpansionTile(
                  title: Text(
                    'Kolay Adres (KOLAS) nedir, nasıl çalışır?',
                    style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy, fontWeight: FontWeight.w700),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'IBAN yerine telefon numarası veya e-posta bilginizi eşleştirerek doğrudan para transferi alabilmenizi sağlayan TCMB altyapısıdır.',
                        style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==================== SÖZLEŞMELER VE KVKK METNİ ====================
  void _showLegalContractsSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Sözleşmeler ve Yasal Metinler',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Detaylarını incelemek istediğiniz yasal sözleşmeye dokunun.',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.description_outlined,
                        color: AppColors.primaryTeal),
                  ),
                  title: Text(
                    'Kullanıcı Çerçeve Sözleşmesi',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.darkNavy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text('Elektronik para ve ödeme hizmetleri koşulları'),
                  trailing:
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    _showDocumentDetailSheet(
                      context,
                      title: 'Kullanıcı Çerçeve Sözleşmesi',
                      lastUpdated: '01.01.2025 (v2.4)',
                      sections: [
                        {
                          'title': '1. Taraflar ve Kapsam',
                          'body':
                              'İşbu Çerçeve Sözleşme, 6493 sayılı Kanun kapsamında faaliyet gösteren PayPulse Ödeme ve Elektronik Para Hizmetleri A.Ş. ile PayPulse mobil uygulamasını kullanan hesap sahibi ("Kullanıcı") arasında akdedilmiştir. Sözleşme, cüzdan oluşturma, FAST transferleri, ön ödemeli kart ihracı ve tahsilat hizmetlerinin yasal sınırlarını düzenler.',
                        },
                        {
                          'title': '2. Hesap Güvenliği ve Doğrulama',
                          'body':
                              'Kullanıcı, hesap açılışında beyan ettiği T.C. Kimlik Numarası, telefon numarası ve yerleşim yeri bilgilerinin güncel ve doğru olduğunu taahhüt eder. Şifre, cüzdan PIN kodu ve tek kullanımlık SMS onay kodlarının gizliliği tamamen Kullanıcı sorumluluğundadır. Yetkisiz bir işlem şüphesinde derhal 7/24 Çağrı Merkezine bildirim yapılmalıdır.',
                        },
                        {
                          'title': '3. FAST ve Fon Aktarımı Kuralları',
                          'body':
                              'TCMB FAST kuralları gereğince yapılan transferler geri dönülemez nitelikte olup alıcı hesabına saniyeler içinde ulaşır. Yanlış IBAN veya KOLAS adresine yapılan transferlerde iade talepleri alıcı bankanın onayına tabidir. Seviye 2 onaylı bireysel hesaplar için aylık FAST transfer tavanı ₺250.000 TL\'dir.',
                        },
                        {
                          'title': '4. Ücretler ve Masraflar',
                          'body':
                              'PayPulse bireysel kullanıcılarından standart FAST transferleri, hesap işletim ücreti veya bakiye sorgulama için hiçbir masraf alınmaz. Sanal kart oluşturma ilk 3 kart için tamamen ücretsizdir. Kurumsal POS komisyonları ise B2B sözleşmesinde ayrıca belirlenir.',
                        },
                        {
                          'title': '5. Fesih ve Hesap Kapatma',
                          'body':
                              'Kullanıcı, dilediği an hiçbir gerekçe göstermeksizin ve cezai şart ödemeksizin hesabını kapatma hakkına sahiptir. Hesapta kalan bakiye, kullanıcının adına kayıtlı teyitli IBAN adresine 1 iş günü içinde eksiksiz aktarılır.',
                        },
                      ],
                    );
                  },
                ),
                Divider(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFF1F5F9),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.privacy_tip_outlined,
                        color: Color(0xFF3B82F6)),
                  ),
                  title: Text(
                    'KVKK Aydınlatma ve Açık Rıza Metni',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.darkNavy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text('Kişisel verilerin işlenmesine ilişkin esaslar'),
                  trailing:
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    _showDocumentDetailSheet(
                      context,
                      title: 'KVKK Aydınlatma ve Açık Rıza Metni',
                      lastUpdated: '15.01.2025 (v1.8)',
                      sections: [
                        {
                          'title': '1. Veri Sorumlusu',
                          'body':
                              '6698 sayılı Kişisel Verilerin Korunması Kanunu ("KVKK") uyarınca PayPulse A.Ş., veri sorumlusu sıfatıyla kişisel verilerinizi mevzuata uygun şekilde toplamakta, saklamakta ve işlemektedir.',
                        },
                        {
                          'title': '2. İşlenen Kişisel Veri Kategorileri',
                          'body':
                              'Kimlik Bilgileri (Ad, Soyad, TCKN, Doğum Tarihi), İletişim Bilgileri (Telefon, E-posta, İkametgah Adresi), Finansal Veriler (FAST IBAN, kart numaraları, hesap hareketleri, işlem tutarları) ve Cihaz Güvenlik Bilgileri (IP adresi, cihaz UUID, işletim sistemi versiyonu).',
                        },
                        {
                          'title': '3. Veri İşleme Amaçları ve Hukuki Sebepler',
                          'body':
                              'Kişisel verileriniz; finansal işlemlerin güvenle ifa edilmesi, MASAK ve TCMB yasal yükümlülüklerinin yerine getirilmesi, kimlik teyidi (KYC) yapılması, dolandırıcılığın önlenmesi ve 7/24 müşteri desteği sağlanması amacıyla işlenir.',
                        },
                        {
                          'title': '4. Verilerin Aktarıldığı Taraflar',
                          'body':
                              'Toplanan veriler yalnızca yasal zorunluluklar çerçevesinde Türkiye Cumhuriyet Merkez Bankası (TCMB), MASAK, Bankalararası Kart Merkezi (BKM) ve yetkili yargı mercileri ile paylaşılır. Verileriniz hiçbir koşulda ticari amaçla üçüncü kişilere satılmaz.',
                        },
                        {
                          'title': '5. KVKK Kapsamındaki Haklarınız',
                          'body':
                              'KVKK\'nın 11. maddesi uyarınca; kişisel verilerinizin işlenip işlenmediğini öğrenme, yanlış işlenen verilerin düzeltilmesini talep etme ve verilerinizin silinmesini isteme hakkına sahipsiniz. Başvurularınızı kvkk@paypulse.me adresine iletebilirsiniz.',
                        },
                      ],
                    );
                  },
                ),
                Divider(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFF1F5F9),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shield_outlined,
                        color: AppColors.primaryGreen),
                  ),
                  title: Text(
                    'Çerez ve Gizlilik Politikası',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.darkNavy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text('Mobil uygulama veri güvenliği ve SSL standartları'),
                  trailing:
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    _showDocumentDetailSheet(
                      context,
                      title: 'Çerez ve Gizlilik Politikası',
                      lastUpdated: '10.02.2025 (v3.1)',
                      sections: [
                        {
                          'title': '1. Güvenlik Standartları',
                          'body':
                              'PayPulse mobil uygulaması üzerinden iletilen tüm hassas finansal veriler 256-bit SSL şifreleme ve PCI-DSS Seviye 1 sertifikalı sunucularda korunmaktadır.',
                        },
                        {
                          'title': '2. Biyometrik Verilerin Korunması',
                          'body':
                              'Face ID ve Parmak İzi ile giriş özelliği kullanılırken biyometrik verileriniz hiçbir zaman sunucularımıza gönderilmez. Doğrulama tamamen cihazınızın kendi güvenli donanım çipinde (Secure Enclave) yerel olarak gerçekleştirilir.',
                        },
                        {
                          'title': '3. Mobil Oturum ve Çerezler',
                          'body':
                              'Uygulamada oturum güvenliğini sağlamak amacıyla güvenli token teknolojisi kullanılır. Arka planda 5 dakika boyunca hareketsiz kalan oturumlar otomatik olarak kilitlenir.',
                        },
                        {
                          'title': '4. Gizlilik İletişim Hattı',
                          'body':
                              'Veri güvenliği ve gizlilik politikamıza ilişkin tüm soru ve önerileriniz için gizlilik@paypulse.me üzerinden Veri Koruma Görevlimizle irtibata geçebilirsiniz.',
                        },
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== YASAL METİN DETAY GÖRÜNTÜLEYİCİ ====================
  void _showDocumentDetailSheet(
    BuildContext context, {
    required String title,
    required String lastUpdated,
    required List<Map<String, String>> sections,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (docCtx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTextStyles.headlineSmall.copyWith(
                                fontWeight: FontWeight.w800,
                                color:
                                    isDark ? Colors.white : AppColors.darkNavy,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Son Güncelleme: $lastUpdated',
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF64748B)),
                        onPressed: () => Navigator.of(docCtx).pop(),
                      ),
                    ],
                  ),
                ),
                Divider(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFF1F5F9)),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    itemCount: sections.length,
                    itemBuilder: (ctx, idx) {
                      final sec = sections[idx];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sec['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryTeal,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              sec['body'] ?? '',
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.5,
                                color: isDark
                                    ? const Color(0xFFCBD5E1)
                                    : const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF8FAFC),
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  child: SizedBox(
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
                      onPressed: () => Navigator.of(docCtx).pop(),
                      child: const Text(
                        'Okudum ve Anladım',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==================== GÜVENLİK VE LİSANS BİLGİLERİ ====================
  void _showComplianceSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomCtx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Güvenlik ve Lisans Bilgileri',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 12),
              _buildComplianceItem(
                icon: Icons.verified_rounded,
                title: 'TCMB Elektronik Para Lisansı',
                desc: '6493 sayılı Kanun kapsamında Türkiye Cumhuriyet Merkez Bankası tarafından yetkilendirilmiştir.',
                isDark: isDark,
              ),
              _buildComplianceItem(
                icon: Icons.shield_rounded,
                title: 'BDDK Mevzuat Uyumu',
                desc: 'Banka ve finansal kuruluşlar bilgi güvenliği standartları ile tam uyumludur.',
                isDark: isDark,
              ),
              _buildComplianceItem(
                icon: Icons.lock_outline_rounded,
                title: 'PCI-DSS Seviye 1 & 256-bit SSL',
                desc: 'Uluslararası ödeme sistemleri en yüksek güvenlik sertifikasyonuna sahiptir.',
                isDark: isDark,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComplianceItem({
    required IconData icon,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryTeal, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.darkNavy)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 11.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HESAP DONDURMA DİYALOĞU ====================
  void _showFreezeAccountDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authBloc = context.read<AuthBloc>();
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Hesabı Dondur',
            style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy),
          ),
          content: Text(
            'Hesabınızı geçici olarak dondurduğunuzda tüm kartlarınız ve para transferleriniz durdurulacaktır. Tekrar giriş yaptığınızda hesabınız yeniden aktifleşecektir.',
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
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                authBloc.add(const AuthLogoutRequested());
                router.go(AppRoutes.login);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Hesabınız güvenle donduruldu.')),
                );
              },
              child: const Text('Hesabı Dondur'),
            ),
          ],
        );
      },
    );
  }

  // ==================== GÜVENLİ ÇIKIŞ ONAY DİYALOĞU ====================
  void _showLogoutConfirmationDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authBloc = context.read<AuthBloc>();
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Güvenli Çıkış',
            style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy),
          ),
          content: Text(
            'PayPulse oturumunuzu sonlandırmak istediğinize emin misiniz?',
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
                backgroundColor: const Color(0xFFB91C1C),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                authBloc.add(const AuthLogoutRequested());
                router.go(AppRoutes.login);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Oturum güvenle sonlandırıldı.'),
                  ),
                );
              },
              child: const Text('Çıkış Yap'),
            ),
          ],
        );
      },
    );
  }

  // ==================== YARDIMCI WIDGET'LAR ====================
  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: AppTextStyles.labelSmall.copyWith(
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        letterSpacing: 0.7,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children, {bool isDark = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? subtitleColor,
    String? trailingBadge,
    bool badgeIsSuccess = false,
    String? trailingText,
    bool showDivider = true,
    VoidCallback? onTap,
    bool isDark = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: isDark ? Colors.white : AppColors.darkNavy, size: 19),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.darkNavy,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: subtitleColor ?? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailingBadge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: badgeIsSuccess
                          ? const Color(0xFFD1FAE5)
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      trailingBadge,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: badgeIsSuccess
                            ? const Color(0xFF065F46)
                            : (isDark ? Colors.white : AppColors.darkNavy),
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (trailingText != null) ...[
                  Text(
                    trailingText,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark ? Colors.white : AppColors.darkNavy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),
      ],
    );
  }
}
