import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class BatchApprovalReceiptScreen extends StatelessWidget {
  const BatchApprovalReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const batchId = 'BATCH-EXP-2026-9941';
    const erpIntegration = 'Logo & Paraşüt - #MSF-88410';
    const hash =
        '0x8f7a93c4e12d45b76810cba483910fbc28d3617e9204c3821049581726a4bc2e';

    return Scaffold(
      appBar: AppBar(
        title: Text('Toplu Onay Protokolü', style: AppTextStyles.headlineSmall),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go(AppRoutes.businessExpenses),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Onay Rozeti
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 44,
                color: Color(0xFF16A34A),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '3 Masraf Başarıyla Onaylandı!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppLightColors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'İşlem No: $batchId',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),

            // 1. ERP & Muhasebe Entegrasyonu Kartı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.sync_alt_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ERP & Muhasebe Entegrasyonu',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF14532D),
                          ),
                        ),
                        Text(
                          erpIntegration,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF166534),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF16A34A),
                    size: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Onaylanan 3 Kalemin Özeti
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppLightColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppLightColors.outlineVariant),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Onaylanan Kalemler',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 16),
                  _ApprovedItemRow(
                    name: 'Ahmet Yılmaz',
                    category: 'Temsil & Ağırlama',
                    amount: '₺1.250,50',
                  ),
                  Divider(height: 20),
                  _ApprovedItemRow(
                    name: 'Elif Demir',
                    category: 'Ulaşım & Seyahat',
                    amount: '₺1.980,00',
                  ),
                  Divider(height: 20),
                  _ApprovedItemRow(
                    name: 'Caner Kılıç',
                    category: 'Yazılım & Bulut Lisansı',
                    amount: '₺660,00',
                  ),
                  Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Toplam Onaylanan Tutar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '₺3.890,50',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppLightColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. SHA-256 Blokzincir Zaman Damgası Kutusu
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.security_rounded,
                        color: Color(0xFF38BDF8),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'SHA-256 Blokzincir Zaman Damgası',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    hash,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: hash));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Zaman damgası kopyalandı.'),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.copy_rounded,
                          color: Color(0xFF38BDF8),
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Hash Kodunu Kopyala',
                          style: TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Masraf Merkezine Dön
            FilledButton(
              onPressed: () => context.go(AppRoutes.businessExpenses),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Masraf Onay Merkezine Dön'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApprovedItemRow extends StatelessWidget {
  final String name;
  final String category;
  final String amount;

  const _ApprovedItemRow({
    required this.name,
    required this.category,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            Text(
              category,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}

