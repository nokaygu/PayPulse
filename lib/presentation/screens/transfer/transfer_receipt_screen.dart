import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/utils/financial_amount.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/repositories/i_transaction_repository.dart';
import '../../widgets/receipt_summary_card_widget.dart';
import '../../widgets/role_switch_app_bar.dart';

/// FAST Para Transferi Adım 4/4: Resmi İşlem Dekontu Ekranı
class TransferReceiptScreen extends StatelessWidget {
  final String txId;
  final ITransactionRepository _transactionRepository = TransactionRepository();

  TransferReceiptScreen({super.key, required this.txId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const RoleSwitchAppBar(
        isBusinessMode: false,
        showBackButton: true,
        customTitle: 'TCMB FAST İşlem Dekontu',
        customSubtitle: 'Adım 4/4 • İşlem Başarıyla Tamamlandı',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<TransactionEntity?>(
          future: _transactionRepository.getTransactionById(txId),
          builder: (context, snapshot) {
            final tx = snapshot.data;
            final String amountFormatted = tx != null
                ? FinancialAmount.format(tx.amount)
                : '₺1.500,00';
            final String senderStr = tx != null && tx.senderId.isNotEmpty
                ? 'Cüzdan (${tx.senderId})'
                : 'Deniz Aksoy (PP-849201)';
            final String recipientStr = tx != null && tx.title.isNotEmpty
                ? tx.title
                : 'Zeynep Kaya';
            final String ibanStr =
                tx?.targetIban ?? 'Garanti BBVA • TR34 •••• 6789 01';
            final String dateStr = tx != null
                ? '${tx.timestamp.day} Kasım ${tx.timestamp.year}, ${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}'
                : '11 Kasım 2026, 15:42';

            return Column(
              children: [
                ReceiptSummaryCardWidget(
                  title: 'FAST Transferi Tamamlandı!',
                  amountText: amountFormatted,
                  badgeLabel:
                      '✓ TCMB FAST • 1.2 Saniyede İletildi (Eğitim Amaçlı FAST Simülasyonu)',
                  details: {
                    'Sorgu / Dekont No': txId,
                    'Gönderen': senderStr,
                    'Alıcı Ad Soyad': recipientStr,
                    'Alıcı Banka / IBAN': ibanStr,
                    'İşlem Tarihi': dateStr,
                    'İşlem Ücreti': '₺0,00 (Ücretsiz)',
                    'Açıklama': tx?.category ?? 'Hafta sonu kahvaltı payı 🥐',
                  },
                  onDownloadPdf: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$txId numaralı PDF dekont indirildi.'),
                      ),
                    );
                  },
                  onShare: () {},
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: const Text('Ana Sayfaya Dön'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
