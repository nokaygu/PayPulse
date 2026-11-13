import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/cards_management_cubit.dart';

class BankAccountsSection extends StatelessWidget {
  final CardsManagementCubit cubit;
  final List<BankAccountItem> bankAccounts;
  final bool isDark;
  final Color cardBg;
  final Color cardBorder;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final VoidCallback onAddBankPressed;

  const BankAccountsSection({
    super.key,
    required this.cubit,
    required this.bankAccounts,
    required this.isDark,
    required this.cardBg,
    required this.cardBorder,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.onAddBankPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'KAYITLI BANKA HESAPLARI (FAST)',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: onAddBankPressed,
              icon: const Icon(Icons.account_balance_outlined, size: 16),
              label: const Text('Yeni Hesap Ekle'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryTeal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Aktif transfer hesabı olarak kullanmak istediğiniz bankaya dokunun.',
          style: AppTextStyles.bodySmall.copyWith(
            color: secondaryTextColor,
            fontSize: 11.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            children: List.generate(bankAccounts.length, (index) {
              final account = bankAccounts[index];
              final isLast = index == bankAccounts.length - 1;
              return Column(
                children: [
                  _BankAccountRow(
                    account: account,
                    isDark: isDark,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    onTap: () => cubit.switchDefaultAccount(account),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFF1F5F9),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _BankAccountRow extends StatelessWidget {
  final BankAccountItem account;
  final bool isDark;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final VoidCallback onTap;

  const _BankAccountRow({
    required this.account,
    required this.isDark,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: account.isDefault
              ? AppColors.primaryTeal.withValues(alpha: isDark ? 0.15 : 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: account.iconColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(account.icon, color: account.iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          account.bankName,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: primaryTextColor,
                          ),
                        ),
                      ),
                      if (account.isDefault) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Varsayılan',
                            style: TextStyle(
                              color: Color(0xFF065F46),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    account.iban,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: secondaryTextColor,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bakiye: ${account.balance}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: account.isDefault
                    ? AppColors.primaryTeal
                    : Colors.transparent,
                border: Border.all(
                  color: account.isDefault
                      ? AppColors.primaryTeal
                      : (isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1)),
                  width: 2,
                ),
              ),
              child: account.isDefault
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

