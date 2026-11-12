import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'auth/widgets/dark_gradient_hero_card.dart';
import 'auth/widgets/status_badge_widget.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool _biometricEnabled = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const String fastIban = 'TR42 0006 2000 8492 0100 0000 01';

    return Scaffold(
      appBar: AppBar(
        title: Text('Profil ve Ayarlar', style: AppTextStyles.headlineSmall),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. Deniz Aksoy Profil Kartı (PP-849201) + FAST IBAN + %57 Limit Barı
            DarkGradientHeroCard(
              title: 'Müşteri No: PP-849201',
              mainAmount: 'Deniz Aksoy',
              subtitle: 'PayPulse Doğrulanmış Hesap',
              topRightBadge: const StatusBadgeWidget(
                label: 'FAST',
                type: BadgeType.darkGlass,
                icon: Icons.bolt_rounded,
              ),
              bottomChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          fastIban,
                          style: AppTextStyles.labelLarge.copyWith(color: AppDarkColors.onSurface),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(const ClipboardData(text: fastIban));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('FAST IBAN kopyalandı')),
                          );
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.copy_rounded, size: 15, color: AppDarkColors.primary),
                            const SizedBox(width: 4),
                            Text('Kopyala', style: AppTextStyles.labelMedium.copyWith(color: AppDarkColors.primary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Günlük Transfer Limiti', style: AppTextStyles.bodySmall.copyWith(color: AppDarkColors.onSurfaceVariant)),
                      Text('%57 kullanıldı', style: AppTextStyles.labelMedium.copyWith(color: AppDarkColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const LinearProgressIndicator(
                      value: 0.57,
                      minHeight: 7,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(AppDarkColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Biyometrik Giriş, 2FA ve Tema Ayarları
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: Icon(Icons.fingerprint_rounded, color: colorScheme.primary),
                    title: Text('Biyometrik Giriş', style: AppTextStyles.bodyLarge),
                    subtitle: Text('Parmak izi / Yüz tanıma ile giriş', style: AppTextStyles.bodySmall),
                    value: _biometricEnabled,
                    onChanged: (val) => setState(() => _biometricEnabled = val),
                  ),
                  const Divider(height: 1, color: AppLightColors.outlineVariant),
                  ListTile(
                    leading: Icon(Icons.verified_user_outlined, color: colorScheme.primary),
                    title: Text('İki Faktörlü Doğrulama (2FA)', style: AppTextStyles.bodyLarge),
                    subtitle: Text('SMS ve E-posta doğrulaması', style: AppTextStyles.bodySmall),
                    trailing: const StatusBadgeWidget(label: 'Başarılı', type: BadgeType.success),
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppLightColors.outlineVariant),
                  ListTile(
                    leading: Icon(Icons.palette_outlined, color: colorScheme.primary),
                    title: Text('Görünüm ve Tema', style: AppTextStyles.bodyLarge),
                    subtitle: Text('Açık Tema', style: AppTextStyles.bodySmall),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Güvenli Çıkış Butonu
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {},
                icon: const Icon(Icons.logout_rounded),
                label: Text('Güvenli Çıkış', style: AppTextStyles.labelLarge.copyWith(color: colorScheme.error)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}