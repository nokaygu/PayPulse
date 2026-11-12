import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/role_switch_app_bar.dart';

/// Görsel 10 (Görsel 7): E-Fatura & E-Arşiv (GİB Canlı Entegrasyonu) Ekranı
class EInvoiceGibListScreen extends StatefulWidget {
  const EInvoiceGibListScreen({super.key});

  @override
  State<EInvoiceGibListScreen> createState() => _EInvoiceGibListScreenState();
}

class _EInvoiceGibListScreenState extends State<EInvoiceGibListScreen> {
  bool _isIncomingTab = true;
  String _selectedStatusFilter = 'Tümü (24)';

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
            // Başlık Satırı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'E-Fatura & E-Arşiv',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.darkNavy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'GİB Canlı',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF065F46),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.sync_rounded,
                      size: 16,
                      color: AppColors.primaryTeal,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '14:15',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Gelir İdaresi Başkanlığı resmi e-Fatura entegrasyonu',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 14),

            // 1. Kasım 2026 E-Fatura Hacmi Hero Kartı (₺184.650,00)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.heroCardGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkNavy.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.account_balance_rounded,
                              color: Color(0xFF5EEAD4),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Kasım 2026 E-Fatura\nHacmi',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF94A3B8),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '%100 GİB\nUyumlu',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFF5EEAD4),
                            fontSize: 10,
                            height: 1.15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Toplam Gelen Fatura Tutarı',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₺184.650,00',
                        style: AppTextStyles.numericBalance.copyWith(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+₺30.775 KDV',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: const Color(0xFF5EEAD4),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gelen Faturalar',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  '24 Adet',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF94A3B8),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Giden Faturalar',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  '42 Adet',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F766E),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Yeni E-Fatura oluşturma ekranı açıldı.'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline, size: 16),
                          label: const Text(
                            'Yeni E-Fatura Kes',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 4,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white.withOpacity(0.08),
                            side: BorderSide(color: Colors.white.withOpacity(0.15)),
                            minimumSize: const Size(0, 42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.download_for_offline_outlined, size: 16),
                          label: const Text(
                            'Toplu XML',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. Gelen (Alış) 24 | Giden (Satış) 42 Sekmeleri
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0).withOpacity(0.6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isIncomingTab = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isIncomingTab ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.arrow_downward_rounded,
                              size: 14,
                              color: AppColors.primaryTeal,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Gelen (Alış)  24',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: _isIncomingTab
                                    ? AppColors.darkNavy
                                    : const Color(0xFF64748B),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isIncomingTab = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isIncomingTab ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.arrow_upward_rounded,
                              size: 14,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Giden (Satış)  42',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: !_isIncomingTab
                                    ? AppColors.darkNavy
                                    : const Color(0xFF64748B),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 3. Arama Kutusu + Filtre
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Fatura No, Tedarikçi veya VKN ara...',
                        hintStyle: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: Color(0xFF64748B),
                        ),
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: AppColors.darkNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 4. Durum Filtre Çipleri
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusPill('Tümü (24)'),
                  const SizedBox(width: 8),
                  _buildStatusPill('Ödendi / Kapandı'),
                  const SizedBox(width: 8),
                  _buildStatusPill('● Onay Bekleyenler (3)', isWarning: true),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. Fatura Kayıtları Başlığı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkNavy,
                    ),
                    children: const [
                      TextSpan(text: 'Fatura Kayıtları  '),
                      TextSpan(
                        text: 'GİB Posta Kutusu',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Tarihe Göre ⌄',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ================= 4 FATURA KARTI =================
            // Kart 1: Amazon Web Services
            _buildDetailedInvoiceCard(
              icon: Icons.cloud_outlined,
              iconBg: const Color(0xFFFFF7ED),
              iconColor: const Color(0xFFD97706),
              title: 'Amazon Web Services',
              gibNo: 'GIB2026000004812',
              docType: 'E-Fatura',
              amount: '₺34.820,00',
              subAmount: 'KDV %20: ₺5.803,33',
              tag1: "✓ Onaylandı & ERP'de",
              tag1Bg: const Color(0xFFD1FAE5),
              tag1Fg: const Color(0xFF065F46),
              tag2: 'Tevkifat (5/10)',
              tag2Bg: const Color(0xFFE0F2FE),
              tag2Fg: const Color(0xFF0369A1),
              dateText: '10 Kas 2026',
              btn1Label: 'PDF',
              btn2Label: '<> UBL-XML',
              rightLabel: 'Detay İncele >',
            ),
            const SizedBox(height: 12),

            // Kart 2: Apple Teknoloji A.Ş.
            _buildDetailedInvoiceCard(
              icon: Icons.devices_rounded,
              iconBg: const Color(0xFFF1F5F9),
              iconColor: AppColors.darkNavy,
              title: 'Apple Teknoloji A.Ş.',
              gibNo: 'APL2026000019402',
              docType: 'E-Fatura',
              amount: '₺78.900,00',
              subAmount: 'KDV %20: ₺13.150,00',
              tag1: '🗓️ Demirbaş / Varlık',
              tag1Bg: const Color(0xFFE0F2FE),
              tag1Fg: const Color(0xFF1E40AF),
              tag2: 'KDV İndirimi Sağlandı',
              tag2Bg: const Color(0xFFD1FAE5),
              tag2Fg: const Color(0xFF065F46),
              dateText: '08 Kas 2026',
              btn1Label: 'PDF İndir',
              btn2Label: '✓ GİB Doğrula',
              rightLabel: 'Detay >',
            ),
            const SizedBox(height: 12),

            // Kart 3: Aydın Hukuk & Danışmanlık (Sarı Şeritli + Anında Öde FAST)
            _buildDetailedInvoiceCard(
              icon: Icons.gavel_rounded,
              iconBg: const Color(0xFFFEF3C7),
              iconColor: const Color(0xFFB45309),
              title: 'Aydın Hukuk & Danışmanlık',
              gibNo: 'AYD202600000319',
              docType: 'E-SMM',
              amount: '₺15.000,00',
              subAmount: 'Net: ₺12.300,00',
              tag1: '🕒 Ödeme Bekliyor (Vade: 2 Gün)',
              tag1Bg: const Color(0xFFFEF3C7),
              tag1Fg: const Color(0xFFB45309),
              tag2: 'Stopaj %20',
              tag2Bg: const Color(0xFFF1F5F9),
              tag2Fg: const Color(0xFF475569),
              dateText: '05 Kas 2026',
              btn1Label: 'Makbuz',
              hasLeftAmberAccent: true,
              fastActionCallback: () => _showFastPaymentDialog(context),
            ),
            const SizedBox(height: 12),

            // Kart 4: Google Ireland Limited
            _buildDetailedInvoiceCard(
              icon: Icons.ads_click_rounded,
              iconBg: const Color(0xFFE0F2FE),
              iconColor: const Color(0xFF0284C7),
              title: 'Google Ireland Limited',
              gibNo: 'GOOG-TR-2026-99',
              docType: 'E-Arşiv',
              amount: '₺26.400,00',
              subAmount: 'KDV %20: ₺5.280,00',
              tag1: '👁️ İncelendi',
              tag1Bg: const Color(0xFFF1F5F9),
              tag1Fg: AppColors.darkNavy,
              tag2: 'KDV-2 Sorumlu Sıfatıyla',
              tag2Bg: const Color(0xFFFEF3C7),
              tag2Fg: const Color(0xFFB45309),
              dateText: '03 Kas 2026',
              btn1Label: 'PDF',
              btn2Label: '🔗 Müşavire Gönder',
              rightLabel: 'Detay >',
            ),
            const SizedBox(height: 16),

            // 6. Mali Müşavir Portalı Paylaşım Kartı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.business_center_outlined,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mali Müşavir Portalı',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkNavy,
                          ),
                        ),
                        Text(
                          'Otomatik Luca & Zirve Entegrasyonu',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF64748B),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkNavy,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Kasım 2026 E-Fatura paketi Luca & Zirve Mali Müşavir Portalına aktarıldı.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_rounded, size: 14),
                    label: const Text(
                      'Paylaş',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 7. GİB Portal ile Şimdi Senkronize Et
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('GİB Portal senkronizasyonu başarıyla tamamlandı.'),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.sync_rounded,
                  size: 18,
                  color: AppColors.primaryTeal,
                ),
                label: const Text(
                  'GİB Portal ile Şimdi Senkronize Et',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(String label, {bool isWarning = false}) {
    final bool isSelected = _selectedStatusFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatusFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.darkNavy
              : (isWarning ? const Color(0xFFFFFBEB) : Colors.white),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.darkNavy : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected
                ? Colors.white
                : (isWarning ? const Color(0xFFB45309) : const Color(0xFF475569)),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedInvoiceCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String gibNo,
    required String docType,
    required String amount,
    required String subAmount,
    required String tag1,
    required Color tag1Bg,
    required Color tag1Fg,
    required String tag2,
    required Color tag2Bg,
    required Color tag2Fg,
    required String dateText,
    required String btn1Label,
    String? btn2Label,
    String? rightLabel,
    bool hasLeftAmberAccent = false,
    VoidCallback? fastActionCallback,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(
          left: BorderSide(
            color: hasLeftAmberAccent
                ? const Color(0xFFF59E0B)
                : const Color(0xFFE2E8F0),
            width: hasLeftAmberAccent ? 4 : 1,
          ),
          top: const BorderSide(color: Color(0xFFE2E8F0)),
          right: const BorderSide(color: Color(0xFFE2E8F0)),
          bottom: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkNavy,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$gibNo ⧉',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        docType,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: const Color(0xFF1D4ED8),
                          fontSize: 9.5,
                        ),
                      ),
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
                  const SizedBox(height: 2),
                  Text(
                    subAmount,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: tag1Bg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag1,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: tag1Fg,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: tag2Bg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag2,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: tag2Fg,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                dateText,
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.picture_as_pdf_outlined,
                          size: 14,
                          color: Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          btn1Label,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.darkNavy,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (btn2Label != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        btn2Label,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.darkNavy,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (fastActionCallback != null)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: fastActionCallback,
                  icon: const Icon(Icons.bolt_rounded, size: 15),
                  label: const Text(
                    'Anında Öde (FAST)',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                  ),
                )
              else if (rightLabel != null)
                Text(
                  rightLabel,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFastPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('TCMB FAST ile E-SMM Ödemesi'),
        content: const Text(
          'Aydın Hukuk & Danışmanlık adına kayıtlı AYD202600000319 numaralı '
          '₺15.000,00 (Stopaj sonrası Net: ₺12.300,00) tutarındaki makbuz '
          'Nova Tasarım Ltd. ticari hesabınızdan 7/24 FAST ile ödenecektir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.primaryGreen,
                  content: Text(
                    'Aydın Hukuk E-SMM ödemesi FAST ile tamamlandı ve ERP defterine işlendi!',
                  ),
                ),
              );
            },
            child: const Text('Onayla ve Öde'),
          ),
        ],
      ),
    );
  }
}

typedef EInvoiceArchiveScreen = EInvoiceGibListScreen;

