import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/profile_settings_cubit.dart';

Future<void> showKolasSheet(
  BuildContext context,
  ProfileSettingsCubit cubit,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomCtx) => ProfileKolasSheet(
      cubit: cubit,
      isDark: isDark,
      onClose: () => Navigator.of(bottomCtx).pop(),
    ),
  );
}

class ProfileKolasSheet extends StatelessWidget {
  final ProfileSettingsCubit cubit;
  final bool isDark;
  final VoidCallback onClose;

  const ProfileKolasSheet({
    super.key,
    required this.cubit,
    required this.isDark,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.darkNavy;
    return BlocBuilder<ProfileSettingsCubit, ProfileSettingsState>(
      bloc: cubit,
      builder: (sheetCtx, state) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kolay Adres (KOLAS) Tanımları',
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.white : const Color(0xFF64748B),
                    ),
                    onPressed: onClose,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'IBAN girmeden, telefon veya e-posta ile anında para transferi alın.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.phone_iphone_rounded,
                    color: AppColors.primaryTeal,
                  ),
                ),
                title: Text(
                  'Telefon Numarası',
                  style: TextStyle(color: textColor),
                ),
                subtitle: Text(state.phone),
                trailing: const Chip(
                  label: Text('Varsayılan'),
                  backgroundColor: Color(0xFFD1FAE5),
                  labelStyle: TextStyle(color: Color(0xFF065F46), fontSize: 11),
                ),
              ),
              Divider(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.email_outlined, color: textColor),
                ),
                title: Text(
                  'E-posta Adresi',
                  style: TextStyle(color: textColor),
                ),
                subtitle: Text(state.displayEmail),
                trailing: state.kolasEmailLinked
                    ? const Chip(
                        label: Text('Eşleştirildi'),
                        backgroundColor: Color(0xFFD1FAE5),
                        labelStyle: TextStyle(
                          color: Color(0xFF065F46),
                          fontSize: 11,
                        ),
                      )
                    : TextButton(
                        onPressed: cubit.linkKolasEmail,
                        child: const Text('Eşleştir'),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

