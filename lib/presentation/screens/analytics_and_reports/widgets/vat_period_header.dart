import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../widgets/status_badge_widget.dart';
import '../bloc/tax_report_cubit.dart';

/// Vergi & KDV Raporu başlık satırı ve dönem seçici çubuğu (`StatelessWidget`).
class VatPeriodHeader extends StatelessWidget {
  final TaxPeriodFilter selectedPeriod;
  final ValueChanged<TaxPeriodFilter> onSelectPeriod;

  const VatPeriodHeader({
    super.key,
    required this.selectedPeriod,
    required this.onSelectPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KURUMSAL FİNANS',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Vergi & KDV Raporu',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const StatusBadgeWidget(
              label: 'GİB Canlı Veri',
              type: BadgeType.success,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: TaxPeriodFilter.values.map((period) {
              final selected = selectedPeriod == period;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelectPeriod(period),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      period.label,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: selected
                            ? AppColors.darkNavy
                            : const Color(0xFF64748B),
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

