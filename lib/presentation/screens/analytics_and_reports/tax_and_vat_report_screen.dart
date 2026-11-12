import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../../widgets/status_badge_widget.dart';

/// Görsel 1 (Görsel 12): B2B Raporlar / KDV Analizi Ekranı
class TaxAndVatReportScreen extends StatefulWidget {
  const TaxAndVatReportScreen({super.key});

  @override
  State<TaxAndVatReportScreen> createState() => _TaxAndVatReportScreenState();
}

class _TaxAndVatReportScreenState extends State<TaxAndVatReportScreen> {
  int _selectedPeriod = 0; // 0: Kasım 2026, 1: Q3 (3. Çeyrek), 2: 2026 Yıllık

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
            // Üst Dönem Seçici (Kasım 2026 | Q3 | 2026 Yıllık + Takvim İkonu)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildPeriodTab('Kasım 2026', 0),
                        _buildPeriodTab('Q3 (3. Çeyrek)', 1),
                        _buildPeriodTab('2026 Yıllık', 2),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: AppColors.darkNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 1. Net Ödenecek KDV Hero Kartı (₺28.450,00)
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
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'NET ÖDENECEK KDV',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF94A3B8),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const StatusBadgeWidget(
                        label: 'GİB E-Fatura Uyumlu',
                        type: BadgeType.darkGlass,
                        icon: Icons.verified_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₺28.450,00',
                        style: AppTextStyles.numericBalance.copyWith(
                          color: Colors.white,
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'KDV-1 Tahmini',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Matrah mahsubu sonrası devlete ödenecek net vergi bakiyesi',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF94A3B8),
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2 Yan Yana Kutu: Hesaplanan KDV vs İndirilecek KDV
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hesaplanan KDV\n(Satış)',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 11,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '₺64.820,00',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'POS & Ticari Satışlar',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xFF64748B),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTeal.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primaryGreen.withOpacity(0.25),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'İndirilecek KDV\n(Gider)',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xFF5EEAD4),
                                  fontSize: 11,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '-₺36.370,00',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: const Color(0xFF5EEAD4),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '%56 Mahsup Oranı',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primaryGreen,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.savings_outlined,
                          color: Color(0xFF5EEAD4),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '₺36.370 gider belgeleriyle vergiden düşüldü.',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Yaklaşan Beyanname: KDV-1 Kartı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
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
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.event_note_rounded,
                          color: Color(0xFFDC2626),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Yaklaşan Beyanname: KDV-1',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkNavy,
                              ),
                            ),
                            Text(
                              'Ekim 2026 Dönemi Yasal Bildirimi',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF64748B),
                                fontSize: 11.5,
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
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '15 Gün\nKaldı',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFFB91C1C),
                            fontSize: 10,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.laptop_chromebook_rounded,
                          color: AppColors.primaryTeal,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ön Taslak Hazır',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.darkNavy,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'ERP & Banka Senkronize (GİB)',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xFF64748B),
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkNavy,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'KDV-1 Beyanname Ön Taslağı GİB İnternet Vergi Dairesine iletildi.',
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'GİB Bildir →',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. KDV Oran Dağılımı & Son 4 Ay KDV Seyri Kartı
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KDV Oran Dağılımı',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkNavy,
                            ),
                          ),
                          Text(
                            'Kasım ayı gider matrah kırılımı',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.donut_large_rounded,
                        color: AppColors.darkNavy,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Çok Bölmeli Yatay Progress Bar (%66, %23, %11)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: SizedBox(
                      height: 10,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 66,
                            child: Container(color: AppColors.darkNavy),
                          ),
                          Expanded(
                            flex: 23,
                            child: Container(color: const Color(0xFF0F766E)),
                          ),
                          Expanded(
                            flex: 11,
                            child: Container(color: const Color(0xFF2DD4BF)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3 Sütunlu KDV Oran Özeti
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildVatRateColumn(
                        dotColor: AppColors.darkNavy,
                        label: '%20 Genel',
                        amount: '₺24.120',
                        share: '%66 pay',
                      ),
                      _buildVatRateColumn(
                        dotColor: const Color(0xFF0F766E),
                        label: '%10 Hizmet',
                        amount: '₺8.450',
                        share: '%23 pay',
                      ),
                      _buildVatRateColumn(
                        dotColor: const Color(0xFF2DD4BF),
                        label: '%1 Temel',
                        amount: '₺3.800',
                        share: '%11 pay',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Son 4 Ay KDV Seyri Başlığı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Son 4 Ay KDV Seyri',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.darkNavy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            color: AppColors.darkNavy,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tahsilat',
                            style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 8,
                            height: 8,
                            color: const Color(0xFF0F766E),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'İndirim',
                            style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // İkili Sütun Grafiği (Ağu, Eyl, Eki, Kas)
                  Container(
                    height: 120,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildDualMonthBar('Ağu', 0.65, 0.45, false),
                        _buildDualMonthBar('Eyl', 0.72, 0.52, false),
                        _buildDualMonthBar('Eki', 0.76, 0.56, false),
                        _buildDualMonthBar('Kas', 0.88, 0.72, true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Gider & Matrah Analizi (4 Kategori)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gider & Matrah Analizi',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkNavy,
                            ),
                          ),
                          Text(
                            'Kurumlar Vergisi ve KDV Uygunluğu',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '4 Kategori',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.darkNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildExpenseMatrahItem(
                    icon: Icons.local_gas_station_outlined,
                    title: 'Ulaşım & Akaryakıt',
                    vatText: 'KDV:\n₺3.650',
                    tagText: '%100\nİndirilebilir',
                    tagColor: AppColors.primaryTeal,
                    totalAmount: '₺18.250',
                  ),
                  const SizedBox(height: 10),
                  _buildExpenseMatrahItem(
                    icon: Icons.restaurant_rounded,
                    title: 'Temsil, Ağırlama & Yemek',
                    vatText: 'KDV:\n₺1.480',
                    tagText: 'KKEG Sınırı\n%82',
                    tagColor: AppColors.primaryTeal,
                    totalAmount: '₺14.800',
                    hasHighlightTag: true,
                  ),
                  const SizedBox(height: 10),
                  _buildExpenseMatrahItem(
                    icon: Icons.cloud_outlined,
                    title: 'Yazılım & SaaS Abonelik...',
                    vatText: 'Tevkifat / Stopaj Uygulandı',
                    tagText: '',
                    tagColor: const Color(0xFF64748B),
                    totalAmount: '₺26.400',
                  ),
                  const SizedBox(height: 10),
                  _buildExpenseMatrahItem(
                    icon: Icons.laptop_mac_rounded,
                    title: 'Ofis & Donanım Demirbaş',
                    vatText: 'KDV:\n₺2.420',
                    tagText: 'Amortisman\nDahil',
                    tagColor: AppColors.primaryTeal,
                    totalAmount: '₺12.100',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. Mali Müşavir ve Muhasebe Entegrasyonu
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.folder_open_rounded,
                        color: AppColors.darkNavy,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mali Müşavir ve Muhasebe Entegrasyonu',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkNavy,
                              ),
                            ),
                            Text(
                              'Resmi defter ve beyan formatlarında anında dışa aktarım',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF64748B),
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
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
                            content: Text(
                              'E-Defter & KDV-1 Ön Beyannamesi (XML / PDF) indirildi.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.description_outlined, size: 18),
                      label: const Text(
                        'E-Defter & KDV-1 Ön Beyannamesi (XML / PDF)',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Aylık veri paketi Mali Müşavir e-posta adresine gönderildi.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.mail_outline_rounded,
                        size: 16,
                        color: AppColors.primaryTeal,
                      ),
                      label: Text(
                        'Mali Müşavire Aylık Veri Paketini Gönder',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.darkNavy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.balance_rounded,
                        size: 14,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Tüm hesaplamalar 213 sayılı VUK ve 3065 sayılı KDV Kanunu mevzuatına uygun olarak doğrulanmış banka & e-arşiv hareketleri üzerinden üretilmektedir.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF64748B),
                            fontSize: 10.5,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildPeriodTab(String label, int index) {
    final bool isSelected = _selectedPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? AppColors.darkNavy : const Color(0xFF64748B),
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildVatRateColumn({
    required Color dotColor,
    required String label,
    required String amount,
    required String share,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.darkNavy,
          ),
        ),
        Text(
          share,
          style: AppTextStyles.bodySmall.copyWith(
            color: const Color(0xFF64748B),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildDualMonthBar(
    String month,
    double firstRatio,
    double secondRatio,
    bool isCurrent,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 12,
                height: 68 * firstRatio,
                decoration: BoxDecoration(
                  color: AppColors.darkNavy,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 12,
                height: 68 * secondRatio,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          month,
          style: AppTextStyles.labelSmall.copyWith(
            color: isCurrent ? AppColors.darkNavy : const Color(0xFF64748B),
            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseMatrahItem({
    required IconData icon,
    required String title,
    required String vatText,
    required String tagText,
    required Color tagColor,
    required String totalAmount,
    bool hasHighlightTag = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Icon(icon, size: 18, color: AppColors.darkNavy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkNavy,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        vatText,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 11,
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (tagText.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: hasHighlightTag
                            ? const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              )
                            : EdgeInsets.zero,
                        decoration: hasHighlightTag
                            ? BoxDecoration(
                                color: const Color(0xFFD1FAE5),
                                borderRadius: BorderRadius.circular(6),
                              )
                            : null,
                        child: Text(
                          tagText,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: tagColor,
                            fontSize: 10,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                totalAmount,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
              ),
              Text(
                'Toplam Harcama',
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
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

