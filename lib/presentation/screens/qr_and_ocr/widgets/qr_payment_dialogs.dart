import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../core/utils/qr_payload_parser.dart';
import '../bloc/qr_payment_cubit.dart';

/// Okutulan 0 TL (serbest tutarlı) PayPulse QR kodu için tutar giriş diyalogu.
class QrZeroAmountDialog extends StatelessWidget {
  final PayPulseQrPayload parsedPayload;
  final TextEditingController controller;
  final ValueChanged<double> onConfirmAmount;
  final VoidCallback onCancel;

  const QrZeroAmountDialog({
    super.key,
    required this.parsedPayload,
    required this.controller,
    required this.onConfirmAmount,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final receiverName =
        parsedPayload.userName ??
        parsedPayload.merchantName ??
        'PayPulse Hesabı';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        'QR Ödeme Tutarı Girin',
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.darkNavy,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alıcı: $receiverName',
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: '₺ ',
              labelText: 'Gönderilecek / Ödenecek Tutar',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('İptal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkNavy,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 42),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onPressed: () {
            final cleaned = controller.text
                .trim()
                .replaceAll('.', '')
                .replaceAll(',', '.');
            final val = double.tryParse(cleaned);
            if (val != null && val > 0) {
              onConfirmAmount(val);
            }
          },
          child: const Text('Devam Et'),
        ),
      ],
    );
  }
}

/// Başarılı QR kod ödemesi / B2C transferi sonrasında gösterilen işlem fişi diyalogu.
class QrPaymentSuccessDialog extends StatelessWidget {
  final QrPaymentReceipt receipt;
  final VoidCallback onClose;

  const QrPaymentSuccessDialog({
    super.key,
    required this.receipt,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final ts = receipt.timestamp;
    final formattedDate =
        '${ts.day.toString().padLeft(2, '0')}.${ts.month.toString().padLeft(2, '0')}.${ts.year} '
        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.primaryGreen,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'QR Ödeme Başarılı',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavy,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Text(
                  'ÖDENEN TUTAR',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  FinancialAmount.formatLira(receipt.amount),
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SlipInfoRow('Alıcı / İşyeri:', receipt.merchantName),
          _SlipInfoRow('Terminal / IBAN:', receipt.terminalId),
          if (receipt.description != null && receipt.description!.isNotEmpty)
            _SlipInfoRow('Açıklama:', receipt.description!),
          _SlipInfoRow('QR Referans (48sn):', '#${receipt.qrRef}'),
          _SlipInfoRow('İşlem No:', receipt.txId),
          const _SlipInfoRow('Ödeme Yöntemi:', 'PayPulse TR Karekod'),
          _SlipInfoRow('Tarih & Saat:', formattedDate),
        ],
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkNavy,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 42),
            padding: const EdgeInsets.symmetric(horizontal: 18),
          ),
          onPressed: onClose,
          child: const Text('Tamam'),
        ),
      ],
    );
  }
}

class _SlipInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _SlipInfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 11.5,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.darkNavy,
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

