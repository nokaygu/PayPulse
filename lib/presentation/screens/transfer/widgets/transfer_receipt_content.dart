import 'package:flutter/material.dart';

import '../../../../core/utils/financial_amount.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../widgets/receipt_summary_card_widget.dart';

/// FAST işlem dekontu gövdesi ve ana sayfaya dönüş aksiyonu (`StatelessWidget`).
class TransferReceiptContent extends StatelessWidget {
  final String txId;
  final TransactionEntity transaction;
  final VoidCallback onGoHome;

  const TransferReceiptContent({
    super.key,
    required this.txId,
    required this.transaction,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    final amountFormatted = FinancialAmount.format(transaction.amount);
    final senderStr = transaction.senderId.isNotEmpty
        ? 'Cüzdan (${transaction.senderId})'
        : 'PayPulse Cüzdanı';
    final recipientStr = transaction.title.isNotEmpty
        ? transaction.title
        : 'Alıcı';
    final ibanStr = transaction.targetIban ?? 'PayPulse FAST Transferi';
    final dateStr =
        '${transaction.timestamp.day}.${transaction.timestamp.month.toString().padLeft(2, '0')}.${transaction.timestamp.year}, '
        '${transaction.timestamp.hour.toString().padLeft(2, '0')}:${transaction.timestamp.minute.toString().padLeft(2, '0')}';

    return Column(
      children: [
        ReceiptSummaryCardWidget(
          title: 'FAST Transferi Tamamlandı!',
          amountText: amountFormatted,
          badgeLabel: '✓ TCMB FAST • Anında İletildi',
          details: {
            'Sorgu / Dekont No': txId,
            'Gönderen': senderStr,
            'Alıcı Ad Soyad': recipientStr,
            'Alıcı Banka / IBAN': ibanStr,
            'İşlem Tarihi': dateStr,
            'İşlem Ücreti': '₺0,00 (Ücretsiz)',
            'Açıklama': transaction.category,
          },
          onDownloadPdf: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$txId numaralı PDF dekont hazırlandı.')),
            );
          },
          onShare: () {},
        ),
        const SizedBox(height: 16),
        TextButton(onPressed: onGoHome, child: const Text('Ana Sayfaya Dön')),
      ],
    );
  }
}

