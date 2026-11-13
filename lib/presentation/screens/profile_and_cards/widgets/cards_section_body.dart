import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/cards_management_cubit.dart';
import 'card_preview_tile.dart';

class CardsSectionBody extends StatelessWidget {
  final CardsManagementCubit cubit;
  final CardsManagementState state;
  final bool isDark;
  final Color cardBg;
  final Color cardBorder;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final VoidCallback onAddCardPressed;

  const CardsSectionBody({
    super.key,
    required this.cubit,
    required this.state,
    required this.isDark,
    required this.cardBg,
    required this.cardBorder,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.onAddCardPressed,
  });

  @override
  Widget build(BuildContext context) {
    final currentCard = state.currentCard;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'KARTLARIM (${state.cards.length})',
              style: AppTextStyles.labelSmall.copyWith(
                color: secondaryTextColor,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            TextButton.icon(
              onPressed: onAddCardPressed,
              icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
              label: const Text('Yeni Kart Ekle'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryTeal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 215,
          child: PageView.builder(
            controller: cubit.pageController,
            itemCount: state.cards.length,
            onPageChanged: cubit.onCardPageChanged,
            itemBuilder: (ctx, idx) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: CardPreviewTile(
                  card: state.cards[idx],
                  showCardDetails: state.showCardDetails,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(state.cards.length, (index) {
            final isSelected = index == state.currentCardIndex;
            return GestureDetector(
              onTap: () => cubit.animateToCard(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isSelected ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryTeal
                      : (isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 14),
        _CardQuickActionBar(
          cubit: cubit,
          currentCard: currentCard,
          showCardDetails: state.showCardDetails,
          isDark: isDark,
          cardBg: cardBg,
          cardBorder: cardBorder,
          primaryTextColor: primaryTextColor,
          secondaryTextColor: secondaryTextColor,
        ),
      ],
    );
  }
}

class _CardQuickActionBar extends StatelessWidget {
  final CardsManagementCubit cubit;
  final CardItem currentCard;
  final bool showCardDetails;
  final bool isDark;
  final Color cardBg;
  final Color cardBorder;
  final Color primaryTextColor;
  final Color secondaryTextColor;

  const _CardQuickActionBar({
    required this.cubit,
    required this.currentCard,
    required this.showCardDetails,
    required this.isDark,
    required this.cardBg,
    required this.cardBorder,
    required this.primaryTextColor,
    required this.secondaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: BorderSide(
                  color: currentCard.isDefault
                      ? AppColors.primaryTeal
                      : (isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1)),
                ),
                backgroundColor: currentCard.isDefault
                    ? AppColors.primaryTeal.withValues(alpha: 0.1)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: currentCard.isDefault
                  ? null
                  : () => cubit.switchDefaultCard(currentCard),
              icon: Icon(
                currentCard.isDefault
                    ? Icons.check_circle_rounded
                    : Icons.star_border_rounded,
                size: 16,
                color: currentCard.isDefault
                    ? AppColors.primaryTeal
                    : secondaryTextColor,
              ),
              label: Text(
                currentCard.isDefault ? 'Varsayılan Kart' : 'Varsayılan Yap',
                style: TextStyle(
                  color: currentCard.isDefault
                      ? AppColors.primaryTeal
                      : primaryTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: BorderSide(
                  color: currentCard.isFrozen
                      ? const Color(0xFFDC2626)
                      : (isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1)),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => cubit.toggleFreezeCard(currentCard),
              icon: Icon(
                currentCard.isFrozen
                    ? Icons.lock_open_rounded
                    : Icons.lock_outline_rounded,
                size: 16,
                color: currentCard.isFrozen
                    ? const Color(0xFFDC2626)
                    : secondaryTextColor,
              ),
              label: Text(
                currentCard.isFrozen ? 'Kartı Aç' : 'Dondur',
                style: TextStyle(
                  color: currentCard.isFrozen
                      ? const Color(0xFFDC2626)
                      : primaryTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: cubit.toggleShowCardDetails,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                showCardDetails
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: primaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

