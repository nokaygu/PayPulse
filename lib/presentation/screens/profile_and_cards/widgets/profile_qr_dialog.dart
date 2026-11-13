import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/profile_settings_cubit.dart';

Future<void> showProfileQrDialog(
  BuildContext context,
  ProfileSettingsState settingsState,
  String iban,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showDialog<void>(
    context: context,
    builder: (dialogCtx) => ProfileQrDialog(
      settingsState: settingsState,
      iban: iban,
      isDark: isDark,
      onClose: () => Navigator.of(dialogCtx).pop(),
      onCopyIban: () {
        Clipboard.setData(ClipboardData(text: iban));
        Navigator.of(dialogCtx).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('FAST IBAN panoya kopyalandı.'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      onShareQr: () {
        Navigator.of(dialogCtx).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Kod paylaşım bağlantısı hazırlandı.'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    ),
  );
}

class ProfileQrDialog extends StatelessWidget {
  final ProfileSettingsState settingsState;
  final String iban;
  final bool isDark;
  final VoidCallback onClose;
  final VoidCallback onCopyIban;
  final VoidCallback onShareQr;

  const ProfileQrDialog({
    super.key,
    required this.settingsState,
    required this.iban,
    required this.isDark,
    required this.onClose,
    required this.onCopyIban,
    required this.onShareQr,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.darkNavy;
    final subColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        color: AppColors.primaryTeal,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FAST QR ile Ödeme Al',
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'PayPulse TRY FAST',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: subColor,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
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
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: 'iban:$iban;name:${settingsState.displayName};service:FAST',
                version: QrVersions.auto,
                size: 200.0,
                gapless: true,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              settingsState.displayName,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      iban,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isDark
                            ? const Color(0xFF475569)
                            : const Color(0xFFCBD5E1),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onCopyIban,
                    icon: Icon(Icons.copy_rounded, size: 16, color: textColor),
                    label: Text(
                      'IBAN Kopyala',
                      style: TextStyle(color: textColor),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onShareQr,
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: const Text('Paylaş'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

