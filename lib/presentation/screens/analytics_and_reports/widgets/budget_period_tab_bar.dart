import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../widgets/status_badge_widget.dart';

/// Bütçe ve Analitik ekranı üst başlığı, dönem sekmesi ve tarih göstergesi.
class BudgetPeriodTabBar extends StatelessWidget {
  final List<String> periodLabels;
  final int selectedPeriodIndex;
  final String selectedPeriodLabel;
  final ValueChanged<int> onSelectPeriod;
  final VoidCallback onRefresh;

  const BudgetPeriodTabBar({
    super.key,
    required this.periodLabels,
    required this.selectedPeriodIndex,
    required this.selectedPeriodLabel,
    required this.onSelectPeriod,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BudgetHeaderRow(onRefresh: onRefresh),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: List.generate(
              periodLabels.length,
              (index) => Expanded(
                child: _PeriodTab(
                  title: periodLabels[index],
                  isSelected: selectedPeriodIndex == index,
                  onTap: () => onSelectPeriod(index),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _PeriodIndicatorRow(selectedPeriodLabel: selectedPeriodLabel),
      ],
    );
  }
}

class _BudgetHeaderRow extends StatelessWidget {
  final VoidCallback onRefresh;

  const _BudgetHeaderRow({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FİNANSAL SAĞLIK',
              style: AppTextStyles.labelSmall.copyWith(
                color: const Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Bütçe ve Analitik',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.darkNavy,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        InkWell(
          onTap: onRefresh,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.tune_rounded,
              size: 20,
              color: AppColors.darkNavy,
            ),
          ),
        ),
      ],
    );
  }
}

class _PeriodIndicatorRow extends StatelessWidget {
  final String selectedPeriodLabel;

  const _PeriodIndicatorRow({required this.selectedPeriodLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.chevron_left_rounded, color: Color(0xFF64748B)),
        Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 15,
              color: AppColors.darkNavy,
            ),
            const SizedBox(width: 6),
            Text(
              'Kasım 2026 ($selectedPeriodLabel)',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.darkNavy,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            const StatusBadgeWidget(label: 'Aktif', type: BadgeType.success),
          ],
        ),
        const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
      ],
    );
  }
}

class _PeriodTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodTab({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.darkNavy : const Color(0xFF64748B),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

