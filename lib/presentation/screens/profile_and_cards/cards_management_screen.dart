import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../../widgets/status_badge_widget.dart';

/// Kayıtlı Banka ve Sanal Kartlar Yönetim Ekranı
class CardsManagementScreen extends StatelessWidget {
  const CardsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const RoleSwitchAppBar(
        isBusinessMode: false,
        showBackButton: true,
        customTitle: 'Kayıtlı Banka ve Kartlarım',
        customSubtitle: 'Fiziksel & Sanal Kart Yönetimi',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PayPulse Sanal Kart Önizlemesi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.heroCardGradient,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PAYPULSE VIRTUAL PREPAID',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const StatusBadgeWidget(
                        label: 'Aktif Kart',
                        type: BadgeType.darkGlass,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    '5400 •••• •••• 4829',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KART SAHİBİ',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF94A3B8),
                              fontSize: 9,
                            ),
                          ),
                          Text(
                            'DENİZ AKSOY',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'AYLIK LİMİT',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF94A3B8),
                              fontSize: 9,
                            ),
                          ),
                          Text(
                            '₺15.000,00',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'KAYITLI BANKA HESAPLARI (FAST)',
              style: AppTextStyles.labelSmall.copyWith(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.account_balance_rounded,
                      color: AppColors.primaryTeal,
                    ),
                    title: Text('Garanti BBVA Vadesiz TRY'),
                    subtitle: Text('TR56 0006 2000 •••• 5500 01'),
                    trailing: StatusBadgeWidget(
                      label: 'Varsayılan',
                      type: BadgeType.success,
                    ),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.account_balance_rounded,
                      color: AppColors.darkNavy,
                    ),
                    title: Text('Türkiye İş Bankası TRY'),
                    subtitle: Text('TR12 0006 4000 •••• 8821 02'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

