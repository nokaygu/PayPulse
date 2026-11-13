import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../widgets/status_badge_widget.dart';
import '../bloc/qr_payment_cubit.dart';

/// TR Karekod / PayPulse POS kamera tarayıcı, manuel/pano girişi ve demo ödeme simülatörü kartı.
class ScanQrCard extends StatelessWidget {
  final QrPaymentCubit cubit;
  final QrPaymentState state;
  final String payerUserId;

  const ScanQrCard({
    super.key,
    required this.cubit,
    required this.state,
    required this.payerUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'TR Karekod / PayPulse POS Okut',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                  ),
                ),
              ),
              const StatusBadgeWidget(
                label: 'Canlı Kamera & Okuyucu',
                type: BadgeType.info,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _CameraViewportBox(
            isCameraActive: state.isCameraActive,
            onToggleCamera: cubit.toggleCamera,
            onBarcodeDetected: (raw) =>
                cubit.handleCameraDetection(raw, payerUserId: payerUserId),
          ),
          const SizedBox(height: 16),
          _ManualQrPasteBox(
            controller: cubit.scanInputController,
            isBusy: state.isBusy,
            onPasteFromClipboard: () async {
              final data = await Clipboard.getData(Clipboard.kTextPlain);
              if (data?.text != null && data!.text!.isNotEmpty) {
                cubit.setManualQrInputText(data.text!.trim());
              }
            },
            onSubmitRawQr: () => cubit.handleScannedCode(
              cubit.scanInputController.text,
              payerUserId: payerUserId,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Hızlı QR Ödeme Simülatörü (Sunum & Test)',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.darkNavy,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kasa POS terminalindeki 48sn dinamik QR kodu okutarak ödeme işlemini simüle edin:',
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 12),
          _ScanPresetCard(
            merchantName: 'Nova Tasarım Ltd. (Sanal POS)',
            terminalId: 'POS-TR-8492',
            description: 'Web Tasarım Hizmet Bedeli - FTR-2026-08',
            amount: 3750.00,
            isBusy: state.isBusy,
            onPay: () => cubit.simulatePresetPayment(
              merchantName: 'Nova Tasarım Ltd. (Sanal POS)',
              terminalId: 'POS-TR-8492',
              description: 'Web Tasarım Hizmet Bedeli - FTR-2026-08',
              amount: 3750.00,
              payerUserId: payerUserId,
            ),
          ),
          const SizedBox(height: 8),
          _ScanPresetCard(
            merchantName: 'Espresso Lab Kurumsal POS',
            terminalId: 'POS-TR-1904',
            description: 'Kahve & İkram Ödemesi',
            amount: 185.00,
            isBusy: state.isBusy,
            onPay: () => cubit.simulatePresetPayment(
              merchantName: 'Espresso Lab Kurumsal POS',
              terminalId: 'POS-TR-1904',
              description: 'Kahve & İkram Ödemesi',
              amount: 185.00,
              payerUserId: payerUserId,
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraViewportBox extends StatelessWidget {
  final bool isCameraActive;
  final ValueChanged<bool> onToggleCamera;
  final ValueChanged<String> onBarcodeDetected;

  const _CameraViewportBox({
    required this.isCameraActive,
    required this.onToggleCamera,
    required this.onBarcodeDetected,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 230,
        width: double.infinity,
        color: const Color(0xFF0F172A),
        child: isCameraActive
            ? Stack(
                alignment: Alignment.center,
                children: [
                  MobileScanner(
                    onDetect: (capture) {
                      for (final barcode in capture.barcodes) {
                        final raw = barcode.rawValue;
                        if (raw != null && raw.isNotEmpty) {
                          onBarcodeDetected(raw);
                          break;
                        }
                      }
                    },
                  ),
                  Container(
                    width: 155,
                    height: 155,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primaryGreen,
                        width: 2.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                      onPressed: () => onToggleCamera(false),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text(
                        'Kamerayı Kapat',
                        style: TextStyle(fontSize: 11.5),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: AppColors.primaryGreen,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Kamera ile gerçek QR kod okutun veya alttan kod girin',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.darkNavy,
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => onToggleCamera(true),
                    icon: const Icon(Icons.camera_alt_rounded, size: 18),
                    label: const Text(
                      'Kamerayı Aç & QR Okut',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ManualQrPasteBox extends StatelessWidget {
  final TextEditingController controller;
  final bool isBusy;
  final VoidCallback onPasteFromClipboard;
  final VoidCallback onSubmitRawQr;

  const _ManualQrPasteBox({
    required this.controller,
    required this.isBusy,
    required this.onPasteFromClipboard,
    required this.onSubmitRawQr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QR Kodu Yapıştır / Manuel Doğrula',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.darkNavy,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'PAYPULSE://TRKAREKOD/... veya req_001',
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
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
                onPressed: onPasteFromClipboard,
                icon: const Icon(
                  Icons.content_paste_rounded,
                  size: 18,
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(width: 4),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: isBusy ? null : onSubmitRawQr,
                child: const Text(
                  'Çözümle & Öde',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScanPresetCard extends StatelessWidget {
  final String merchantName;
  final String terminalId;
  final String description;
  final double amount;
  final bool isBusy;
  final VoidCallback onPay;

  const _ScanPresetCard({
    required this.merchantName,
    required this.terminalId,
    required this.description,
    required this.amount,
    required this.isBusy,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              color: Color(0xFF065F46),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchantName,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '$terminalId • $description',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkNavy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: isBusy ? null : onPay,
            child: Text(
              'Öde (${FinancialAmount.formatLira(amount)})',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }
}

