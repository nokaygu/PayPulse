import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../domain/entities/transaction_entity.dart';

/// Sanal POS başarılı kart veya QR tahsilat slip diyalogu.
class PosPaymentSlipDialog extends StatelessWidget {
  final TransactionEntity tx;
  final String? qrShortToken;

  const PosPaymentSlipDialog({
    super.key,
    required this.tx,
    this.qrShortToken,
  });

  @override
  Widget build(BuildContext context) {
    final isQr = qrShortToken != null && qrShortToken!.isNotEmpty;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isQr ? 'PayPulse QR Tahsilat Slipi' : 'POS Tahsilatı Başarılı',
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
          PosSlipRow(label: 'İşlem Referans:', value: tx.txId),
          PosSlipRow(
            label: 'Tahsil Edilen Tutar:',
            value: FinancialAmount.format(tx.amount),
          ),
          PosSlipRow(label: 'Kategori:', value: tx.category),
          if (isQr) ...[
            const PosSlipRow(
              label: 'Ödeme Yöntemi:',
              value: 'PayPulse Dinamik QR (TR Karekod)',
            ),
            PosSlipRow(
              label: 'QR Güvenlik Kodu:',
              value: '#$qrShortToken (48sn Dinamik)',
            ),
          ],
          PosSlipRow(label: 'Durum:', value: tx.status),
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Tamam'),
        ),
      ],
    );
  }
}

/// Slip ve özet kartlarında kullanılan ortak anahtar/değer satırı.
class PosSlipRow extends StatelessWidget {
  final String label;
  final String value;

  const PosSlipRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.darkNavy,
            ),
          ),
        ],
      ),
    );
  }
}
