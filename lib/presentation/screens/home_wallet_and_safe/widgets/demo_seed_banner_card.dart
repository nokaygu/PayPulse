import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class DemoSeedBannerCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isBusy;
  final String buttonLabel;
  final VoidCallback onSeedPressed;
  final VoidCallback? onConsolePressed;

  const DemoSeedBannerCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isBusy,
    this.buttonLabel = 'Seed Bas',
    required this.onSeedPressed,
    this.onConsolePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_upload_outlined, color: AppColors.primaryTeal),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkNavy,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: isBusy ? null : onSeedPressed,
            child: Text(
              isBusy ? '...' : buttonLabel,
              style: const TextStyle(fontSize: 11.5),
            ),
          ),
          if (onConsolePressed != null) ...[
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Firebase Test Konsolu',
              onPressed: onConsolePressed,
              icon: const Icon(
                Icons.developer_mode_rounded,
                size: 20,
                color: AppColors.darkNavy,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

