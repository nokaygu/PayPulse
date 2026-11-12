import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/budget_donut_chart.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../../widgets/status_badge_widget.dart';

/// Görsel 4: Bütçe ve Analitik Ekranı
class BudgetAnalyticsScreen extends StatefulWidget {
  const BudgetAnalyticsScreen({super.key});

  @override
  State<BudgetAnalyticsScreen> createState() => _BudgetAnalyticsScreenState();
}

class _BudgetAnalyticsScreenState extends State<BudgetAnalyticsScreen> {
  int _selectedPeriodIndex = 1; // 0: Haftalık, 1: Aylık, 2: Yıllık

  @override
  Widget build(BuildContext context) {
    const categories = [
      DonutChartItem(
        label: 'Market (%42)',
        percentage: 42,
        color: AppColors.darkNavy,
      ),
      DonutChartItem(
        label: 'Ulaşım (%24)',
        percentage: 24,
        color: Color(0xFF0D9488),
      ),
      DonutChartItem(
        label: 'Faturalar (%18)',
        percentage: 18,
        color: Color(0xFF1D4ED8),
      ),
      DonutChartItem(
        label: 'Yeme & İçme (%10)',
        percentage: 10,
        color: Color(0xFFF59E0B),
      ),
      DonutChartItem(
        label: 'Diğer (%6)',
        percentage: 6,
        color: Color(0xFF94A3B8),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const RoleSwitchAppBar(isBusinessMode: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık Satırı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FİNANSAL SAĞLIK',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bütçe ve Analitik',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.darkNavy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0).withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: AppColors.darkNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Haftalık | Aylık | Yıllık Segmented Bar
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0).withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildPeriodTab('Haftalık', 0),
                  _buildPeriodTab('Aylık', 1),
                  _buildPeriodTab('Yıllık', 2),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Tarih Seçici (< Kasım 2026 [Aktif] >)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.chevron_left_rounded,
                  color: Color(0xFF64748B),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 15,
                      color: AppColors.darkNavy,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Kasım 2026',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.darkNavy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const StatusBadgeWidget(
                      label: 'Aktif',
                      type: BadgeType.success,
                    ),
                  ],
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 1. Ana Cüzdan Kotası Hero Kartı (₺6.580,00)
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
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: AppColors.primaryGreen,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ANA CÜZDAN KOTASI',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF94A3B8),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const StatusBadgeWidget(
                        label: '%44 Bütçe Kaldı',
                        type: BadgeType.darkGlass,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Kalan Harcama Hakkı',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₺ 6.580,00',
                    style: AppTextStyles.numericBalance.copyWith(
                      color: Colors.white,
                      fontSize: 34,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Harcanan: ₺8.420,00',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Hedef: ₺15.000,00',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: const LinearProgressIndicator(
                      value: 0.56,
                      minHeight: 8,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: AppColors.primaryGreen,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontSize: 11.5,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'Harika gidiyorsunuz! Harcama hızınız planlanan bütçenin ',
                                ),
                                TextSpan(
                                  text: '%12 altında',
                                  style: TextStyle(
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(text: ' seyrediyor. 🎯'),
                              ],
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

            // 2. Haftalık Harcama Trendi (4 Haftalık Bar)
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.bar_chart_rounded,
                              size: 18,
                              color: AppColors.darkNavy,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Haftalık Harcama\nTrendi',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkNavy,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const StatusBadgeWidget(
                        label: 'Düşüş Trendinde',
                        type: BadgeType.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 135,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildWeekBar('1. Hafta', 0.72, false),
                        const SizedBox(width: 10),
                        _buildWeekBar('2. Hafta', 0.75, false),
                        const SizedBox(width: 10),
                        _buildWeekBar('3. Hafta', 0.78, false),
                        const SizedBox(width: 10),
                        _buildWeekBar('4. Hafta', 0.74, true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Haftalık Ortalama: ₺2.105,00',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                          children: const [
                            TextSpan(text: 'Bu hafta: '),
                            TextSpan(
                              text: '₺1.820,00',
                              style: TextStyle(
                                color: AppColors.primaryTeal,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Harcama Kategorileri (Donut Chart + 5 Kategori Listesi)
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.pie_chart_outline_rounded,
                              size: 18,
                              color: AppColors.darkNavy,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Harcama Kategorileri',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkNavy,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '5 Kategori',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const BudgetDonutChart(
                        items: categories,
                        centerTitle: '₺8.4k',
                        centerSubtitle: 'Dengeli Dağılım',
                        size: 135,
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: categories.map((c) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: c.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      c.label,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.darkNavy,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 5 Kategori Detay Kutuları
                  _buildCategoryBox(
                    icon: Icons.shopping_cart_outlined,
                    iconBg: AppColors.darkNavy,
                    title: 'Market & Alışveriş',
                    quota: 'Kota: ₺4.500,00',
                    amount: '₺3.536,40',
                    statusText: '%78 kullanıldı',
                    statusColor: AppColors.primaryTeal,
                    progress: 0.78,
                    barColor: AppColors.darkNavy,
                  ),
                  const SizedBox(height: 10),
                  _buildCategoryBox(
                    icon: Icons.local_gas_station_outlined,
                    iconBg: const Color(0xFF0D9488),
                    title: 'Ulaşım & Yakıt',
                    quota: 'Kota: ₺2.500,00',
                    amount: '₺2.020,80',
                    statusText: '%80 kullanıldı',
                    statusColor: AppColors.primaryTeal,
                    progress: 0.80,
                    barColor: const Color(0xFF0D9488),
                  ),
                  const SizedBox(height: 10),
                  _buildCategoryBox(
                    icon: Icons.receipt_long_outlined,
                    iconBg: const Color(0xFF1D4ED8),
                    title: 'Faturalar & Abonelikler',
                    quota: 'Kota: ₺1.600,00',
                    amount: '₺1.515,60',
                    statusText: 'Limit uyarısı (%94)',
                    statusColor: AppColors.expenseRed,
                    progress: 0.94,
                    barColor: const Color(0xFF1D4ED8),
                  ),
                  const SizedBox(height: 10),
                  _buildCategoryBox(
                    icon: Icons.restaurant_outlined,
                    iconBg: const Color(0xFFF59E0B),
                    title: 'Yeme & İçme',
                    quota: 'Kota: ₺2.000,00',
                    amount: '₺842,00',
                    statusText: '%42 kullanıldı',
                    statusColor: AppColors.primaryTeal,
                    progress: 0.42,
                    barColor: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 10),
                  _buildCategoryBox(
                    icon: Icons.sports_esports_outlined,
                    iconBg: const Color(0xFF64748B),
                    title: 'Eğlence & Diğer',
                    quota: 'Kota: ₺1.000,00',
                    amount: '₺505,20',
                    statusText: '%50 kullanıldı',
                    statusColor: AppColors.primaryTeal,
                    progress: 0.50,
                    barColor: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Akıllı Hedef ve Tasarruf (Yeni Laptop M4 Pro)
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.savings_outlined,
                              size: 18,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Akıllı Hedef ve\nTasarruf',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkNavy,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const StatusBadgeWidget(
                        label: '%60 Tamamlandı',
                        type: BadgeType.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.darkNavy,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.laptop_mac_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Yeni Laptop (M4 Pro)',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkNavy,
                                ),
                              ),
                              Text(
                                'Hedef: ₺35.000,00',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '↗ Bu ay +₺4.200,00 eklendi',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primaryTeal,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Biriken Fon',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '₺21.000,00 / ₺35.000,00',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.darkNavy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: const LinearProgressIndicator(
                      value: 0.60,
                      minHeight: 8,
                      backgroundColor: Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tahmini Bitiş: Ocak 2027',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        'Hedefe ₺14.000 kaldı',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkNavy,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Hedef düzenleme ekranı açıldı.'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Bütçe Hedefini Düzenle'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.darkNavy,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. PayPulse Bütçe Tavsiyesi Kartı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD1FAE5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.primaryTeal,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PayPulse Bütçe Tavsiyesi',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.darkNavy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Abonelik faturalarınız bu ay normalin üzerinde görünüyor. Kullanmadığınız 2 streaming servisini durdurarak ayda ₺240,00 tasarruf sağlayabilirsiniz.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
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

  Widget _buildPeriodTab(String title, int index) {
    final bool isSelected = _selectedPeriodIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriodIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? AppColors.darkNavy : const Color(0xFF64748B),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekBar(String label, double heightFactor, bool isActive) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isActive)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF065F46),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'AKTİF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: heightFactor,
                widthFactor: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF34D399), Color(0xFF0D9488)],
                          )
                        : null,
                    color: isActive ? null : const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isActive ? AppColors.darkNavy : const Color(0xFF64748B),
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBox({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String quota,
    required String amount,
    required String statusText,
    required Color statusColor,
    required double progress,
    required Color barColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
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
                    ),
                    Text(
                      quota,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 11,
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
                  Text(
                    statusText,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
