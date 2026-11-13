import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../bloc/profile_settings_cubit.dart';

class ProfileTopBar extends StatelessWidget {
  final bool isDark;
  final VoidCallback onBack;
  final VoidCallback onEditProfile;
  final VoidCallback onMoreOptions;

  const ProfileTopBar({
    super.key,
    required this.isDark,
    required this.onBack,
    required this.onEditProfile,
    required this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context) {
    final primaryTextColor = isDark ? Colors.white : AppColors.darkNavy;
    final secondaryTextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final circleBtnBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final circleBtnBorder =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final backBtnBg =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: onBack,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: backBtnBg, shape: BoxShape.circle),
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
        _CircleIconButton(
          icon: Icons.edit_outlined,
          bg: circleBtnBg,
          border: circleBtnBorder,
          iconColor: primaryTextColor,
          onTap: onEditProfile,
        ),
        const SizedBox(width: 8),
        _CircleIconButton(
          icon: Icons.more_vert_rounded,
          bg: circleBtnBg,
          border: circleBtnBorder,
          iconColor: primaryTextColor,
          onTap: onMoreOptions,
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color border;
  final Color iconColor;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.bg,
    required this.border,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: border),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}

class ProfileHeroCard extends StatelessWidget {
  final ProfileSettingsState settingsState;
  final VoidCallback onAvatarTap;
  final VoidCallback onCopyCustomerNo;

  const ProfileHeroCard({
    super.key,
    required this.settingsState,
    required this.onAvatarTap,
    required this.onCopyCustomerNo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                      onTap: onAvatarTap,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
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
                        color: AppColors.primaryGreen.withValues(alpha: 0.18),
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
          Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
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
                onTap: onCopyCustomerNo,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.25),
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
    );
  }
}

class ProfileIbanLimitCard extends StatelessWidget {
  final ProfileSettingsState settingsState;
  final bool isDark;
  final VoidCallback onShowQr;
  final VoidCallback onCopyIban;
  final VoidCallback onIncreaseLimit;

  const ProfileIbanLimitCard({
    super.key,
    required this.settingsState,
    required this.isDark,
    required this.onShowQr,
    required this.onCopyIban,
    required this.onIncreaseLimit,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final primaryTextColor = isDark ? Colors.white : AppColors.darkNavy;
    final secondaryTextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
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
                  _MiniIconBox(
                    icon: Icons.qr_code_2_rounded,
                    color: primaryTextColor,
                    isDark: isDark,
                    onTap: onShowQr,
                  ),
                  const SizedBox(width: 8),
                  _MiniIconBox(
                    icon: Icons.copy_rounded,
                    color: secondaryTextColor,
                    isDark: isDark,
                    onTap: onCopyIban,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
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
                onTap: onIncreaseLimit,
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
              backgroundColor:
                  isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
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
    );
  }
}

class _MiniIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _MiniIconBox({
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

void copyProfileFieldToClipboard({
  required String value,
  required ProfileSettingsCubit cubit,
  required String feedbackMessage,
}) {
  Clipboard.setData(ClipboardData(text: value));
  cubit.emitFeedback(feedbackMessage);
}

