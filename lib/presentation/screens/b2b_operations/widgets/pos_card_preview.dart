import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/virtual_pos_cubit.dart';

/// Sanal POS canlı kredi kartı önizleme kartı.
class PosCardPreview extends StatelessWidget {
  final VirtualPosState state;

  const PosCardPreview({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroCardGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PAYPULSE SANAL POS',
                style: AppTextStyles.labelSmall.copyWith(
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 1.0,
                ),
              ),
              Icon(
                state.isCardLuhnValid
                    ? Icons.verified_rounded
                    : Icons.credit_card_rounded,
                color: state.isCardLuhnValid
                    ? AppColors.primaryGreen
                    : Colors.white54,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            state.cardNumberPreview,
            style: AppTextStyles.headlineSmall.copyWith(
              color: Colors.white,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
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
                      state.cardHolderPreview,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'SKT',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: const Color(0xFF94A3B8),
                      fontSize: 9,
                    ),
                  ),
                  Text(
                    state.expiryPreview,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

