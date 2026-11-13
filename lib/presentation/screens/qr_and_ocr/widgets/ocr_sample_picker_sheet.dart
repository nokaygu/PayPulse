import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/ocr_scanner_cubit.dart';
import '../bloc/ocr_verification_cubit.dart';

/// Galeri veya demo örnek fiş seçimi sunan alt sayfa widget'ı (`StatelessWidget`).
class OcrSamplePickerSheet extends StatelessWidget {
  final OcrScannerCubit cubit;

  const OcrSamplePickerSheet({super.key, required this.cubit});

  static const _samples = [
    OcrExtractedData(
      merchantTitle: 'Petrol Ofisi A.Ş.',
      amountKurus: 142050,
      vatAmountKurus: 23675,
      category: 'Ulaşım',
      confidence: 0.99,
    ),
    OcrExtractedData(
      merchantTitle: 'Midpoint Restoran',
      amountKurus: 198050,
      vatAmountKurus: 18005,
      category: 'Yemek & Temsil',
      confidence: 0.97,
    ),
    OcrExtractedData(
      merchantTitle: 'Apple Store Türkiye',
      amountKurus: 485000,
      vatAmountKurus: 80833,
      category: 'Donanım & Ofis',
      confidence: 0.98,
    ),
  ];

  static Future<void> show(BuildContext context, OcrScannerCubit cubit) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => OcrSamplePickerSheet(cubit: cubit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fiş Görseli Seç',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  cubit.pickFromGallery();
                },
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Cihaz Galerisinden Seç'),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Hızlı Test / Demo Örnek Fişler',
              style: AppTextStyles.labelSmall.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            ..._samples.map(
              (s) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primaryTeal,
                ),
                title: Text(s.merchantTitle),
                subtitle: Text(s.category),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.pop(context);
                  cubit.openWithSample(s);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

