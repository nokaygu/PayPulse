import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../widgets/dark_gradient_hero_card.dart';
import '../bloc/home_wallet_cubit.dart';
import 'home_transaction_tile_item.dart';
import 'personal_quick_actions_row.dart';

class PersonalContextBanner extends StatelessWidget {
  final String leftLabel;
  final Widget trailing;

  const PersonalContextBanner({
    super.key,
    required this.leftLabel,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryTeal,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    leftLabel,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.darkNavy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}

class PersonalWalletHeroCard extends StatelessWidget {
  final HomeWalletState state;
  final String ibanStr;
  final ValueChanged<String> onSelectCurrency;
  final VoidCallback onToggleHideBalance;

  const PersonalWalletHeroCard({
    super.key,
    required this.state,
    required this.ibanStr,
    required this.onSelectCurrency,
    required this.onToggleHideBalance,
  });

  @override
  Widget build(BuildContext context) {
    return DarkGradientHeroCard(
      title: 'KULLANILABİLİR CÜZDAN BAKİYESİ',
      mainAmount: state.formattedActiveBalance,
      subtitle: '7/24 Anında FAST & Karekod Hazır',
      topRightBadge: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final curr in const ['TRY', 'USD', 'EUR']) ...[
            WalletCurrencyChip(
              currency: curr,
              isSelected: state.selectedCurrency == curr,
              onTap: () => onSelectCurrency(curr),
            ),
            const SizedBox(width: 4),
          ],
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: onToggleHideBalance,
            icon: Icon(
              state.hideBalance
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF5EEAD4),
              size: 19,
            ),
          ),
        ],
      ),
      bottomChild: Column(
        children: [
          _IbanCopyStrip(iban: ibanStr),
          const SizedBox(height: 14),
          const PersonalQuickActionsRow(),
        ],
      ),
    );
  }
}

class _IbanCopyStrip extends StatelessWidget {
  final String iban;

  const _IbanCopyStrip({required this.iban});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              iban,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 10.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: iban));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('FAST IBAN kopyalandı.')),
              );
            },
            child: const Icon(
              Icons.copy_rounded,
              size: 15,
              color: Color(0xFF5EEAD4),
            ),
          ),
        ],
      ),
    );
  }
}

