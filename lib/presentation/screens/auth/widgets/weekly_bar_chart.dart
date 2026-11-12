import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

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

  const WeeklyBarChart({
    super.key,
    required this.points,
    this.maxHeight = 115,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double maxVal =
        points.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: maxHeight + 34,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: points.map((point) {
          final double heightFactor = maxVal == 0 ? 0 : (point.value / maxVal);
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: (maxHeight * heightFactor).clamp(8.0, maxHeight),
                  width: 24,
                  decoration: BoxDecoration(
                    color: point.isHighlighted
                        ? colorScheme.primary
                        : AppLightColors.primaryFixed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  point.label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: point.isHighlighted
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}