import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/role_switch_app_bar.dart';

/// Görsel 10: Toplu Onay Protokolü (3 Masraf Başarıyla Onaylandı! & ERP Dekontu) Ekranı
class BulkExpenseErpReceiptScreen extends StatelessWidget {
  const BulkExpenseErpReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const RoleSwitchAppBar(isBusinessMode: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Satır: Toplu Onay Protokolü + Kapat (X)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      size: 18,
                      color: AppColors.primaryTeal,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Toplu Onay Protokolü',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.darkNavy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => context.go(AppRoutes.businessExpenses),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE2E8F0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.darkNavy,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 1. Ana Onay Başarı Kartı (₺3.890,50)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.darkNavy,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Color(0xFF5EEAD4),
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '3 Masraf Başarıyla\nOnaylandı!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.darkNavy,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Gider fişleri kurum içi politikalarla denetlendi\nve muhasebe defterine aktarıldı.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'ONAYLANAN TOPLAM TUTAR',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₺3.890,50',
                          style: AppTextStyles.numericBalance.copyWith(
                            color: AppColors.darkNavy,
                            fontSize: 32,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '🐷 +₺648,40 KDV İndirimi Şirket Hesabına Yansıtıldı',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF065F46),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('🕒 Onay Zamanı', '11 Kasım 2026, 14:48'),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    '🛡️ Onay Yetkilisi',
                    'Mehmet Can Özkan (Genel Müdür)',
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    '# Toplu İşlem No',
                    'BATCH-EXP-2026-9941 ⧉',
                    isBadgeValue: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. ERP & Muhasebe Entegrasyonu Kartı
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.darkNavy,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.computer_rounded,
                          color: Color(0xFF5EEAD4),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ERP & Muhasebe\nEntegrasyonu',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkNavy,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '● Canlı Senkronizasyon Başarılı',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primaryTeal,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '✓ Logo &\nParaşüt',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFF065F46),
                            fontSize: 9.5,
                            height: 1.15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Muhasebe Fiş No:', '#MSF-88410'),
                        const SizedBox(height: 6),
                        _buildDetailRow(
                          'Yevmiye Kaydı:',
                          '770.01 - Genel Yönetim Giderleri',
                        ),
                        const SizedBox(height: 6),
                        _buildDetailRow(
                          'KDV Mahsubu:',
                          '191 İndirilecek KDV (%20, %10)',
                        ),
                        const SizedBox(height: 6),
                        _buildDetailRow(
                          'GİB E-Arşiv / Portal Durumu:',
                          '☁️ İletildi & Arşivlendi',
                          valueColor: AppColors.primaryTeal,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Onaylanan Kalemler (3)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Onaylanan Kalemler (3)',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                  ),
                ),
                Text(
                  'Şirket Kartı Ekstreleri',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildApprovedLineItem(
              icon: Icons.local_taxi_outlined,
              name: 'Ahmet Yılmaz',
              role: 'Frontend Lead',
              sub: 'BiTaksi E-Fiş • Ulaşım • Kart •••• 4120',
              amount: '₺450,00',
              vat: 'KDV: ₺75,00',
            ),
            const SizedBox(height: 8),
            _buildApprovedLineItem(
              icon: Icons.restaurant_rounded,
              name: 'Elif Demir',
              role: 'Ürün Tasarımcısı',
              sub: 'Midpoint • Müşteri Ağırlama • Kart •••• 8831',
              amount: '₺1.980,50',
              vat: 'KDV: ₺180,05',
            ),
            const SizedBox(height: 8),
            _buildApprovedLineItem(
              icon: Icons.laptop_mac_rounded,
              name: 'Caner Kılıç',
              role: 'DevOps',
              sub: 'IKEA Donanım • Ön Onaylı • Kart •••• 9921',
              amount: '₺1.460,00',
              vat: 'KDV: ₺243,33',
            ),
            const SizedBox(height: 16),

            // 4. Aksiyon Butonları
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ERP Muhasebe Dekontu (PDF) indirildi.'),
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text(
                  'ERP Muhasebe Dekontunu İndir (PDF)',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.darkNavy,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.mail_outline_rounded, size: 18),
                label: const Text(
                  'Mali Müşavire / Muhasebeye İlet',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => context.go(AppRoutes.businessExpenses),
                child: Text(
                  'Masraf Onay Merkezine Dön',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 5. Denetim İzi & Blokzincir Zaman Damgası
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        size: 16,
                        color: AppColors.primaryTeal,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Denetim İzi & Blokzincir Zaman Damgası',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.darkNavy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'SHA-256: 89f4b381c29e67a00f12ad8813bc38a91176e1082c448bb',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Bu işlem kurumsal harcama limitleri yönetmeliğine ve Vergi Usul Kanunu (VUK) 509 No'lu E-Defter tebliğine tam uyumlu olarak mühürlenmiştir.",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBadgeValue = false,
    Color? valueColor,
  }) {
    return Row(
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
          child: Container(
            padding: isBadgeValue
                ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
                : EdgeInsets.zero,
            decoration: isBadgeValue
                ? BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  )
                : null,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.labelSmall.copyWith(
                color: valueColor ?? AppColors.darkNavy,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApprovedLineItem({
    required IconData icon,
    required String name,
    required String role,
    required String sub,
    required String amount,
    required String vat,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.darkNavy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        role,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: const Color(0xFF475569),
                          fontSize: 9.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
              ),
              Text(
                vat,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primaryTeal,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

