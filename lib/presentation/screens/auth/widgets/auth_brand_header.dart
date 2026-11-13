import 'package:flutter/material.dart';

import '../../../../core/config/app_mode.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Giriş ve kayıt ekranları için ortak PayPulse marka başlığı.
class AuthBrandHeader extends StatelessWidget {
  final double logoSize;
  final bool showDemoBadge;
  final TextStyle? titleStyle;

  const AuthBrandHeader({
    super.key,
    this.logoSize = 48,
    this.showDemoBadge = false,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(logoSize >= 48 ? 14 : 12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(logoSize >= 48 ? 14 : 12),
            child: Image.asset(
              'assets/images/paypulse_logo.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PayPulse',
                style: titleStyle ?? AppTextStyles.headlineMedium,
              ),
              Text(
                'Yeni Nesil Dijital Cüzdan & POS',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (showDemoBadge && AppMode.isDemoMode) const _AuthDemoBadge(),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuthDemoBadge extends StatelessWidget {
  const _AuthDemoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bolt_rounded,
            size: 13,
            color: AppColors.primaryTeal,
          ),
          const SizedBox(width: 4),
          Text(
            'Demo Modu',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primaryTeal,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// Giriş ve kayıt ekranları için ortak B2C / B2B rol geçiş anahtarı.
class AuthRoleSwitch extends StatelessWidget {
  final bool isB2BSelected;
  final ValueChanged<bool> onSelectB2B;

  const AuthRoleSwitch({
    super.key,
    required this.isB2BSelected,
    required this.onSelectB2B,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RoleSegmentTile(
              label: 'Bireysel (B2C)',
              selected: !isB2BSelected,
              onTap: () => onSelectB2B(false),
            ),
          ),
          Expanded(
            child: _RoleSegmentTile(
              label: 'Kurumsal (B2B)',
              selected: isB2BSelected,
              onTap: () => onSelectB2B(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleSegmentTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleSegmentTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: selected ? AppColors.darkNavy : colorScheme.onSurfaceVariant,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

