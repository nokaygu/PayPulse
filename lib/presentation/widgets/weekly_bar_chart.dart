import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class BarChartPoint {
  final String label;
  final double value;
  final bool isHighlighted;

  const BarChartPoint({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });
}

class WeeklyBarChart extends StatelessWidget {
  final List<BarChartPoint> points;
  final double maxHeight;
  final ValueChanged<int>? onBarTap;

  const WeeklyBarChart({
    super.key,
    required this.points,
    this.maxHeight = 120,
    this.onBarTap,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final double maxVal = points
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: maxHeight + 36,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < points.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onBarTap == null ? null : () => onBarTap!(i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height:
                          (maxHeight *
                                  (maxVal == 0
                                      ? 0
                                      : (points[i].value / maxVal)))
                              .clamp(10.0, maxHeight),
                      width: 24,
                      decoration: BoxDecoration(
                        color: points[i].isHighlighted
                            ? AppColors.primaryGreen
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: points[i].isHighlighted
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryGreen.withValues(
                                    alpha: 0.35,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      points[i].label,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: points[i].isHighlighted
                            ? AppColors.primaryGreen
                            : colorScheme.onSurfaceVariant,
                        fontWeight: points[i].isHighlighted
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
