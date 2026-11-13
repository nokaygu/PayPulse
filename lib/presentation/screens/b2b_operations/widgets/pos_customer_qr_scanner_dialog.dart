import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../widgets/status_badge_widget.dart';

/// B2B Kasadan Müşterinin B2C QR Kodunu Okutarak / Yapıştırarak Tahsil Etme Modalı.
class PosCustomerQrScannerSheet extends StatelessWidget {
  final TextEditingController pasteController;
  final ValueChanged<String> onQrCaptured;

  const PosCustomerQrScannerSheet({
    super.key,
    required this.pasteController,
    required this.onQrCaptured,
  });

  @override
  Widget build(BuildContext context) {
    bool hasScanned = false;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Müşteri B2C QR Okut & Tahsil Et',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                  ),
                ),
              ),
              const StatusBadgeWidget(
                label: 'TR Karekod Okuyucu',
                type: BadgeType.info,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Müşterinin PayPulse B2C ekranındaki 48sn dinamik QR kodunu kamerayla okutun veya kod metnini yapıştırın:',
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 190,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  MobileScanner(
                    onDetect: (capture) {
                      if (hasScanned || capture.barcodes.isEmpty) return;
                      final raw = capture.barcodes.first.rawValue;
                      if (raw != null && raw.isNotEmpty) {
                        hasScanned = true;
                        Navigator.of(context).pop();
                        onQrCaptured(raw);
                      }
                    },
                  ),
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primaryTeal,
                        width: 2.5,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: pasteController,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.darkNavy,
                    fontSize: 11.5,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'PAYPULSE://TRKAREKOD/B2C?... yapıştırın',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Panodan Yapıştır',
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFE2E8F0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final clip = await Clipboard.getData(Clipboard.kTextPlain);
                  if (clip?.text != null) {
                    pasteController.text = clip!.text!.trim();
                  }
                },
                icon: const Icon(
                  Icons.content_paste_rounded,
                  size: 18,
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkNavy,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 42),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  final raw = pasteController.text.trim();
                  if (raw.isEmpty) return;
                  Navigator.of(context).pop();
                  onQrCaptured(raw);
                },
                child: const Text(
                  'Tahsil Et',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

