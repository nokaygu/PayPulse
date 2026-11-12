import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/financial_amount.dart';
import '../../../domain/entities/fast_receipt.dart';

class FastReceiptScreen extends StatelessWidget {
  final String txId;
  final FastReceipt? receipt;

  const FastReceiptScreen({
    super.key,
    required this.txId,
    this.receipt,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveReceipt = receipt ??
        FastReceipt(
          transactionId: txId,
          recipientName: 'Ahmet Yılmaz',
          recipientIban: 'TR33 0006 1005 1234 5678 9012 34',
          amountKurus: 150000,
          remainingBalanceKurus: 2300000,
          completedAt: DateTime.now(),
          description: 'FAST Para Transferi',
        );

    final amountTl = FinancialAmount.format(effectiveReceipt.amountKurus);
    final remainingTl =
        FinancialAmount.format(effectiveReceipt.remainingBalanceKurus);

    return Scaffold(
      appBar: AppBar(
        title: Text('Transfer Dekontu', style: AppTextStyles.headlineSmall),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Onay İkonu
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 40,
                color: Color(0xFF16A34A),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'FAST Transferi Başarılı!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppLightColors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'İşlem referansınız banka ağına iletildi.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Tutar Gösterimi
            Text(
              '₺$amountTl',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppLightColors.onSurface,
              ),
            ),
            const SizedBox(height: 24),

            // Dekont Detay Kartı
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppLightColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppLightColors.outlineVariant),
              ),
              child: Column(
                children: [
                  _ReceiptRow(
                    label: 'Alıcı Adı Soyadı',
                    value: effectiveReceipt.recipientName,
                  ),
                  const Divider(height: 24),
                  _ReceiptRow(
                    label: 'Alıcı IBAN',
                    value: effectiveReceipt.recipientIban,
                  ),
                  const Divider(height: 24),
                  _ReceiptRow(
                    label: 'Referans No',
                    value: effectiveReceipt.transactionId,
                  ),
                  const Divider(height: 24),
                  _ReceiptRow(
                    label: 'Tarih & Saat',
                    value:
                        '${effectiveReceipt.completedAt.day.toString().padLeft(2, '0')}.${effectiveReceipt.completedAt.month.toString().padLeft(2, '0')}.${effectiveReceipt.completedAt.year} ${effectiveReceipt.completedAt.hour.toString().padLeft(2, '0')}:${effectiveReceipt.completedAt.minute.toString().padLeft(2, '0')}',
                  ),
                  const Divider(height: 24),
                  _ReceiptRow(
                    label: 'Açıklama',
                    value: effectiveReceipt.description,
                  ),
                  const Divider(height: 24),
                  _ReceiptRow(
                    label: 'Kalan Bakiye',
                    value: '₺$remainingTl',
                    isHighlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Paylaş Butonları
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dekont PDF olarak indirildi.')),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('PDF İndir'),
                ),
                const SizedBox(width: 12),
                FilledButton.tonalIcon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dekont paylaşıldı.')),
                    );
                  },
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Paylaş'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Ana Sayfaya Dön Butonu
            FilledButton(
              onPressed: () => context.go(AppRoutes.home),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              color: isHighlight
                  ? AppLightColors.primary
                  : AppLightColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

