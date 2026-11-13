import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class ProfileSectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const ProfileSectionHeader({
    super.key,
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.labelSmall.copyWith(
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        letterSpacing: 0.7,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class ProfileSettingsSectionCard extends StatelessWidget {
  final String headerTitle;
  final List<Widget> children;
  final bool isDark;

  const ProfileSettingsSectionCard({
    super.key,
    required this.headerTitle,
    required this.children,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeader(title: headerTitle, isDark: isDark),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

