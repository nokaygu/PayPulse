import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../widgets/status_badge_widget.dart';
import '../bloc/cards_management_cubit.dart';

class CardPreviewTile extends StatelessWidget {
  final CardItem card;
  final bool showCardDetails;

  const CardPreviewTile({
    super.key,
    required this.card,
    required this.showCardDetails,
  });

  @override
  Widget build(BuildContext context) {
    final maskedNumber = card.cardNumber.length >= 8
        ? '${card.cardNumber.substring(0, 4)} •••• •••• ${card.cardNumber.substring(card.cardNumber.length - 4)}'
        : card.cardNumber;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: card.isFrozen
            ? const LinearGradient(
                colors: [Color(0xFF334155), Color(0xFF475569)],
              )
            : card.gradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CardTopRow(card: card),
          _CardNumberRow(
            card: card,
            maskedNumber: maskedNumber,
            showCardDetails: showCardDetails,
          ),
          _CardBottomRow(card: card),
        ],
      ),
    );
  }
}

class _CardTopRow extends StatelessWidget {
  final CardItem card;

  const _CardTopRow({required this.card});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  card.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.8,
                    fontSize: 10.5,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  card.cardType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        StatusBadgeWidget(
          label: card.isFrozen
              ? 'Donduruldu'
              : (card.isDefault ? 'Varsayılan' : 'Aktif'),
          type: card.isFrozen ? BadgeType.error : BadgeType.darkGlass,
        ),
      ],
    );
  }
}

class _CardNumberRow extends StatelessWidget {
  final CardItem card;
  final String maskedNumber;
  final bool showCardDetails;

  const _CardNumberRow({
    required this.card,
    required this.maskedNumber,
    required this.showCardDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              showCardDetails ? card.cardNumber : maskedNumber,
              style: AppTextStyles.headlineMedium.copyWith(
                color: Colors.white,
                letterSpacing: 1.8,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
        ),
        if (showCardDetails) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'CVV: ${card.cvv}',
              style: const TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CardBottomRow extends StatelessWidget {
  final CardItem card;

  const _CardBottomRow({required this.card});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KART SAHİBİ',
                style: AppTextStyles.labelSmall.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontSize: 8.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                card.holder,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'S.K.T',
              style: AppTextStyles.labelSmall.copyWith(
                color: const Color(0xFF94A3B8),
                fontSize: 8.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              card.expiry,
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'AYLIK LİMİT',
                style: AppTextStyles.labelSmall.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontSize: 8.5,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  card.limit,
                  maxLines: 1,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

