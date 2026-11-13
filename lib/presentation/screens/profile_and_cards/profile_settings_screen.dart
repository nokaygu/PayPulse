import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';

/// Görsel 5 (Görsel 1): Profil ve Ayarlar Ekranı
class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool _biometricEnabled = true;

  @override
  Widget build(BuildContext context) {
    const String fastIban = 'TR34 0006 2000 0001 2345 6789 01';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const RoleSwitchAppBar(isBusinessMode: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Başlık Satırı
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: AppColors.darkNavy,
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
                          color: AppColors.darkNavy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Bireysel Cüzdan Yönetimi',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 17,
                    color: AppColors.darkNavy,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.more_vert_rounded,
                    size: 18,
                    color: AppColors.darkNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 1. Deniz Aksoy Profil Kartı (PP-849201)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.heroCardGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkNavy.withOpacity(0.3),
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
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: 12,
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
                              'Deniz Aksoy',
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
                                color: AppColors.primaryGreen.withOpacity(0.18),
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
                                    'Onaylı Hesap (Seviye 2)',
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
                              '+90 532 ••• •• 45',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF94A3B8),
                                fontSize: 11.5,
                              ),
                            ),
                            Text(
                              'deniz.aksoy@paypulse.me',
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
                  Divider(color: Colors.white.withOpacity(0.12), height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF94A3B8),
                          ),
                          children: const [
                            TextSpan(text: 'Müşteri No:  '),
                            TextSpan(
                              text: 'PP-849201',
                              style: TextStyle(
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
                            const ClipboardData(text: 'PP-849201'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Müşteri No (PP-849201) kopyalandı.',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTeal.withOpacity(0.25),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
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
                              color: AppColors.darkNavy,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.qr_code_2_rounded,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                const ClipboardData(text: fastIban),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('FAST IBAN panoya kopyalandı.'),
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.copy_rounded,
                              size: 16,
                              color: Color(0xFF64748B),
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
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            fastIban,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.darkNavy,
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
                          child: Text(
                            'FAST',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF065F46),
                              fontSize: 10,
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
                      Text(
                        'Kalan Aylık Transfer Limiti',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        'Limit Artır',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: const LinearProgressIndicator(
                      value: 0.57,
                      minHeight: 7,
                      backgroundColor: Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryTeal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₺142.500 / ₺250.000',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '%57 kullanıldı',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF64748B),
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
            _buildSectionHeader('HESAP VE KİŞİSEL BİLGİLER'),
            const SizedBox(height: 8),
            _buildMenuCard([
              _buildSettingTile(
                icon: Icons.badge_outlined,
                title: 'Kimlik ve İletişim Bilgileri',
                subtitle: 'TCKN, Adres, Doğum Tarihi',
              ),
              _buildSettingTile(
                icon: Icons.credit_card_rounded,
                title: 'Kayıtlı Banka ve Kartlarım',
                subtitle: 'Garanti BBVA, İş Bankası (2 Kart)',
                trailingBadge: '2 Banka',
              ),
              _buildSettingTile(
                icon: Icons.alternate_email_rounded,
                title: 'Kolay Adres (KOLAS) Tanımları',
                subtitle: 'Telefon Numarası Eşli',
                showDivider: false,
              ),
            ]),
            const SizedBox(height: 18),

            // GRUP 2: GÜVENLİK VE GİZLİLİK
            _buildSectionHeader('GÜVENLİK VE GİZLİLİK'),
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
                              color: AppColors.darkNavy,
                            ),
                          ),
                          Text(
                            'Face ID / Parmak İzi ile aç',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: const Color(0xFF64748B),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _biometricEnabled,
                      activeColor: Colors.white,
                      activeTrackColor: AppColors.primaryTeal,
                      onChanged: (v) => setState(() => _biometricEnabled = v),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildSettingTile(
                icon: Icons.pin_outlined,
                title: 'Cüzdan PIN Kodunu Değiştir',
                subtitle: 'Son değişim: 3 ay önce',
              ),
              _buildSettingTile(
                icon: Icons.shield_outlined,
                title: 'İki Adımlı Doğrulama (2FA)',
                subtitle: 'SMS ve Authenticator koruması',
                trailingBadge: 'Etkin',
                badgeIsSuccess: true,
              ),
              _buildSettingTile(
                icon: Icons.devices_rounded,
                title: 'Güvenilir Cihazlar',
                subtitle: 'iPhone 15 Pro (Bu Cihaz)',
              ),
              _buildSettingTile(
                icon: Icons.timer_outlined,
                title: 'Oturum Zaman Aşımı',
                subtitle: 'Uygulama arka plandayken',
                trailingText: '5 Dakika',
                showDivider: false,
              ),
            ]),
            const SizedBox(height: 18),

            // GRUP 3: TERCİHLER VE BİLDİRİMLER
            _buildSectionHeader('TERCİHLER VE BİLDİRİMLER'),
            const SizedBox(height: 8),
            _buildMenuCard([
              _buildSettingTile(
                icon: Icons.notifications_active_outlined,
                title: 'Bildirim Tercihleri',
                subtitle: 'Anlık FAST, Bütçe ve Kampanyalar',
              ),
              _buildSettingTile(
                icon: Icons.payments_outlined,
                title: 'Ana Para Birimi',
                subtitle: 'Gösterge bakiyesi',
                trailingText: '🇹🇷 TRY (₺)',
              ),
              _buildSettingTile(
                icon: Icons.palette_outlined,
                title: 'Görünüm ve Tema',
                subtitle: 'Sistem Varsayılanı',
                trailingText: 'Açık Tema',
              ),
              _buildSettingTile(
                icon: Icons.translate_rounded,
                title: 'Uygulama Dili / Language',
                subtitle: 'Dil seçimi',
                trailingText: 'Türkçe (TR)',
                showDivider: false,
              ),
            ]),
            const SizedBox(height: 18),

            // GRUP 4: DESTEK VE YASAL BİLGİLER
            _buildSectionHeader('DESTEK VE YASAL BİLGİLER'),
            const SizedBox(height: 8),
            _buildMenuCard([
              _buildSettingTile(
                icon: Icons.support_agent_rounded,
                title: 'Yardım & Canlı Destek',
                subtitle: '7/24 Kesintisiz Asistan',
                subtitleColor: AppColors.primaryTeal,
              ),
              _buildSettingTile(
                icon: Icons.quiz_outlined,
                title: 'Sıkça Sorulan Sorular (SSS)',
                subtitle: 'İşlem limitleri, FAST kuralları',
              ),
              _buildSettingTile(
                icon: Icons.description_outlined,
                title: 'Sözleşmeler ve KVKK Metni',
                subtitle: 'Açık rıza ve gizlilik koşulları',
              ),
              _buildSettingTile(
                icon: Icons.verified_user_outlined,
                title: 'Güvenlik ve Lisans Bilgileri',
                subtitle: 'TCMB & BDDK mevzuat uyumu',
                showDivider: false,
              ),
            ]),
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
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                  context.go(AppRoutes.login);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Oturum güvenle sonlandırıldı.'),
                    ),
                  );
                },
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
                      Text(
                        'TCMB Lisanslı Ödeme ve Elektronik Para Hizmeti',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PayPulse v2.4.1 (Build 8420) • Güvenli 256-bit SSL',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF94A3B8),
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
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.labelSmall.copyWith(
        color: const Color(0xFF64748B),
        letterSpacing: 0.7,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.darkNavy, size: 19),
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
                        color: AppColors.darkNavy,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: subtitleColor ?? const Color(0xFF64748B),
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
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    trailingBadge,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: badgeIsSuccess
                          ? const Color(0xFF065F46)
                          : AppColors.darkNavy,
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
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: Color(0xFFF1F5F9)),
      ],
    );
  }
}
