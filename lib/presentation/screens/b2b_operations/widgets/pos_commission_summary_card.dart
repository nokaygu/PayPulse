import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/virtual_pos_cubit.dart';
import 'pos_payment_slip_dialog.dart';

/// Sanal POS hizmet komisyonu ve net hesaba geçecek tutar özet kartı.
class PosCommissionSummaryCard extends StatelessWidget {
  final VirtualPosState state;

  const PosCommissionSummaryCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          PosSlipRow(
            label:
                'POS Hizmet Komisyonu (%${state.commissionRatePercent.toStringAsFixed(2)})',
            value: '-${state.formattedCommission}',
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Net Kasaya Geçecek Tutar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                state.formattedNetAmount,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
