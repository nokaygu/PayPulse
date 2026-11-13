import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../widgets/status_badge_widget.dart';

/// Bütçe ve Analitik ekranı üst başlığı, dönem sekmesi ve tarih göstergesi.
class BudgetPeriodTabBar extends StatelessWidget {
  final List<String> periodLabels;
  final int selectedPeriodIndex;
  final String dynamicDateLabel;
  final bool isCurrentPeriod;
  final bool canGoPrevious;
  final bool canGoNext;
  final bool hasActiveFilter;
  final ValueChanged<int> onSelectPeriod;
  final VoidCallback onPreviousPeriod;
  final VoidCallback onNextPeriod;
  final VoidCallback onOpenFilter;

  const BudgetPeriodTabBar({
    super.key,
    required this.periodLabels,
    required this.selectedPeriodIndex,
    required this.dynamicDateLabel,
    required this.isCurrentPeriod,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.hasActiveFilter,
    required this.onSelectPeriod,
    required this.onPreviousPeriod,
    required this.onNextPeriod,
    required this.onOpenFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BudgetHeaderRow(
          hasActiveFilter: hasActiveFilter,
          onOpenFilter: onOpenFilter,
        ),
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
        _PeriodIndicatorRow(
          dynamicDateLabel: dynamicDateLabel,
          isCurrentPeriod: isCurrentPeriod,
          canGoPrevious: canGoPrevious,
          canGoNext: canGoNext,
          onPreviousPeriod: onPreviousPeriod,
          onNextPeriod: onNextPeriod,
        ),
      ],
    );
  }
}

class _BudgetHeaderRow extends StatelessWidget {
  final bool hasActiveFilter;
  final VoidCallback onOpenFilter;

  const _BudgetHeaderRow({
    required this.hasActiveFilter,
    required this.onOpenFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.darkNavy,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: onOpenFilter,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: hasActiveFilter
                  ? const Color(0xFFD1FAE5)
                  : const Color(0xFFE2E8F0).withValues(alpha: 0.6),
              shape: BoxShape.circle,
              border: hasActiveFilter
                  ? Border.all(color: AppColors.primaryTeal)
                  : null,
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 20,
              color: hasActiveFilter
                  ? const Color(0xFF0F766E)
                  : AppColors.darkNavy,
            ),
          ),
        ),
      ],
    );
  }
}

class _PeriodIndicatorRow extends StatelessWidget {
  final String dynamicDateLabel;
  final bool isCurrentPeriod;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPreviousPeriod;
  final VoidCallback onNextPeriod;

  const _PeriodIndicatorRow({
    required this.dynamicDateLabel,
    required this.isCurrentPeriod,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPreviousPeriod,
    required this.onNextPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PeriodArrowButton(
          icon: Icons.chevron_left_rounded,
          tooltip: 'Önceki dönem',
          enabled: canGoPrevious,
          onTap: onPreviousPeriod,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: AppColors.darkNavy,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  dynamicDateLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatusBadgeWidget(
                label: isCurrentPeriod ? 'Aktif' : 'Geçmiş',
                type: isCurrentPeriod ? BadgeType.success : BadgeType.info,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        _PeriodArrowButton(
          icon: Icons.chevron_right_rounded,
          tooltip: 'Sonraki dönem',
          enabled: canGoNext,
          onTap: onNextPeriod,
        ),
      ],
    );
  }
}

class _PeriodArrowButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  const _PeriodArrowButton({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: enabled ? Colors.white : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: enabled
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? AppColors.darkNavy : const Color(0xFF94A3B8),
          ),
        ),
      ),
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

