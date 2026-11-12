import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../widgets/receipt_summary_card_widget.dart';
import '../../widgets/role_switch_app_bar.dart';

/// FAST Para Transferi Adım 4/4: Resmi İşlem Dekontu Ekranı
class TransferReceiptScreen extends StatelessWidget {
  final String txId;

  const TransferReceiptScreen({
    super.key,
    required this.txId,
  });

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
        child: Column(
          children: [
            ReceiptSummaryCardWidget(
              title: 'FAST Transferi Tamamlandı!',
              amountText: '₺1.500,00',
              badgeLabel: '✓ TCMB FAST • 1.2 Saniyede İletildi',
              details: {
                'Sorgu / Dekont No': txId,
                'Gönderen': 'Deniz Aksoy (PP-849201)',
                'Alıcı Ad Soyad': 'Zeynep Kaya',
                'Alıcı Banka / IBAN': 'Garanti BBVA • TR34 •••• 6789 01',
                'İşlem Tarihi': '11 Kasım 2026, 15:42',
                'İşlem Ücreti': '₺0,00 (Ücretsiz)',
                'Açıklama': 'Hafta sonu kahvaltı payı 🥐',
              },
              onDownloadPdf: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$txId numaralı PDF dekont indirildi.')),
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
        ),
      ),
    );
  }
}

