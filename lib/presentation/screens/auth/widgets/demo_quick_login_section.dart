import 'package:flutter/material.dart';

import '../../../../core/config/app_mode.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'demo_role_card.dart';

/// Hızlı demo rolü seçim listesi ve kayıt ekranı yönlendirme bölümü.
class DemoQuickLoginSection extends StatelessWidget {
  final ValueChanged<String> onLoginWithRole;
  final VoidCallback onNavigateToRegister;

  const DemoQuickLoginSection({
    super.key,
    required this.onLoginWithRole,
    required this.onNavigateToRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (AppMode.isDemoMode) ...[
          const _SectionDivider(),
          const SizedBox(height: 12),
          DemoRoleCard(
            title: 'Deniz Aksoy',
            roleBadge: 'Bireysel (B2C)',
            subtitle: 'Bakiye: ₺12.500,00 • FAST Transfer & Cüzdan',
            icon: Icons.account_balance_wallet_rounded,
            iconBg: const Color(0xFFD1FAE5),
            iconColor: AppColors.primaryGreen,
            badgeBg: const Color(0xFFD1FAE5),
            badgeColor: const Color(0xFF065F46),
            onTap: () => onLoginWithRole(AppStrings.roleB2C),
          ),
          const SizedBox(height: 8),
          DemoRoleCard(
            title: 'Ahmet Yılmaz',
            roleBadge: 'Çalışan (Employee)',
            subtitle: 'PayPulse Teknoloji • Bakiye: ₺5.000,00 • Masraf',
            icon: Icons.badge_outlined,
            iconBg: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
            badgeBg: const Color(0xFFFEF3C7),
            badgeColor: const Color(0xFF92400E),
            onTap: () => onLoginWithRole(AppStrings.roleEmployee),
          ),
          const SizedBox(height: 8),
          DemoRoleCard(
            title: 'Ali Yılmaz',
            roleBadge: 'Yönetici (Admin)',
            subtitle: 'PayPulse Teknoloji • Kasa: ₺50.000,00 • POS & Onay',
            icon: Icons.business_center_rounded,
            iconBg: const Color(0xFFE0F2FE),
            iconColor: AppColors.darkNavy,
            badgeBg: const Color(0xFFE0F2FE),
            badgeColor: const Color(0xFF0369A1),
            onTap: () => onLoginWithRole(AppStrings.roleAdmin),
          ),
          const SizedBox(height: 20),
        ],
        _RegisterLinkRow(onNavigateToRegister: onNavigateToRegister),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'VEYA DOĞRUDAN DEMO ROLÜ İLE GİRİN',
            style: AppTextStyles.labelSmall.copyWith(
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
      ],
    );
  }
}

class _RegisterLinkRow extends StatelessWidget {
  final VoidCallback onNavigateToRegister;

  const _RegisterLinkRow({required this.onNavigateToRegister});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Henüz hesabınız yok mu?', style: AppTextStyles.bodyMedium),
          const SizedBox(width: 4),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: onNavigateToRegister,
            child: Text(
              'Hemen Kayıt Olun',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

