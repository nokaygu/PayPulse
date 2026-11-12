import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

class DonutChartItem {
  final String label;
  final double percentage;
  final Color color;

  const DonutChartItem({
    required this.label,
    required this.percentage,
    required this.color,
  });
}

class BudgetDonutChart extends StatelessWidget {
  final List<DonutChartItem> items;
  final String centerTitle;
  final String centerSubtitle;
  final double size;

  const BudgetDonutChart({
    super.key,
    required this.items,
    required this.centerTitle,
    required this.centerSubtitle,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutChartPainter(items: items),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                centerSubtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<DonutChartItem> items;

  _DonutChartPainter({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 22.0;
    final Rect insetRect = (Offset.zero & size).deflate(strokeWidth / 2);

    double startAngle = -math.pi / 2;
    const double gapAngle = 0.045;

    for (final item in items) {
      final double sweepAngle =
          (item.percentage / 100) * (2 * math.pi) - gapAngle;
      final Paint paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      if (sweepAngle > 0) {
        canvas.drawArc(insetRect, startAngle, sweepAngle, false, paint);
      }
      startAngle += sweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) =>
      oldDelegate.items != items;
}

