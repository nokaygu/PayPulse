import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// AI-OCR tarayıcı deklanşör, galeri, manuel giriş çubuğu ve bilgi ipucu kartı.
class OcrScannerActionsBar extends StatelessWidget {
  final bool isBusy;
  final VoidCallback onOpenGalleryOrSamples;
  final VoidCallback onCaptureCamera;
  final VoidCallback onManualEntry;

  const OcrScannerActionsBar({
    super.key,
    required this.isBusy,
    required this.onOpenGalleryOrSamples,
    required this.onCaptureCamera,
    required this.onManualEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ActionOption(
              icon: Icons.photo_library_outlined,
              label: 'Galeriden Seç',
              onTap: isBusy ? null : onOpenGalleryOrSamples,
            ),
            _CameraShutterButton(
              isBusy: isBusy,
              onTap: isBusy ? null : onCaptureCamera,
            ),
            _ActionOption(
              icon: Icons.edit_note_rounded,
              label: 'Manuel Giriş',
              onTap: isBusy ? null : onManualEntry,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _OcrSmartTipCard(),
      ],
    );
  }
}

class _CameraShutterButton extends StatelessWidget {
  final bool isBusy;
  final VoidCallback? onTap;

  const _CameraShutterButton({required this.isBusy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 74,
        height: 74,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF99F6E4), width: 4),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF0D9488)],
            ),
            shape: BoxShape.circle,
          ),
          child: isBusy
              ? const Padding(
                  padding: EdgeInsets.all(18),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Icon(
                  Icons.document_scanner_outlined,
                  color: Colors.white,
                  size: 30,
                ),
        ),
      ),
    );
  }
}

class _ActionOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.darkNavy),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OcrSmartTipCard extends StatelessWidget {
  const _OcrSmartTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFD1FAE5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primaryTeal,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Doğrudan Doğrulama ve Muhasebeleştirme',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Seçilen veya çekilen fiş görseli bir sonraki adımda doğrulanıp Firebase Storage üzerinden güvenle arşivlenir.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

