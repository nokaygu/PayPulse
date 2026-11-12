import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'budget_analytics_screen.dart';
import 'profile_settings_screen.dart';
import 'tax_and_vat_report_screen.dart';

class MainNavigationShell extends StatefulWidget {
  /// Başlangıçta B2B kullanıcısı mı? (true ise B2B'den başlar ve B2C'ye tek yönlü geçebilir)
  final bool initialIsB2B;

  const MainNavigationShell({
    super.key,
    this.initialIsB2B = true,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late bool _isB2BMode;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _isB2BMode = widget.initialIsB2B;
  }

  // Tek yönlü geçiş kuralı: B2B -> B2C yapılabilir ama B2C -> B2B yapılamaz
  void _onRoleSwitchChanged(bool newValue) {
    if (_isB2BMode && !newValue) {
      setState(() {
        _isB2BMode = false;
        _currentIndex = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('B2C Bireysel Cüzdan moduna geçiş yapıldı.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // B2C Sekme Ekranları (Soldan Sağa)
    final List<Widget> b2cScreens = [
      _buildPlaceholderPage('B2C Ana Sayfa (Çoklu Cüzdan)', Icons.account_balance_wallet_rounded),
      _buildPlaceholderPage('7/24 FAST Para Transferi', Icons.swap_horiz_rounded),
      _buildPlaceholderPage('QR Kod ile Ödeme', Icons.qr_code_scanner_rounded),
      const BudgetAnalyticsScreen(), // 4. Sekme: Durumum (Senin ekranın)
      const ProfileSettingsScreen(), // 5. Sekme: Menü (Senin ekranın)
    ];

    // B2B Sekme Ekranları (Soldan Sağa)
    final List<Widget> b2bScreens = [
      _buildPlaceholderPage('B2B İşletme Kasası & Ciro', Icons.storefront_rounded),
      _buildPlaceholderPage('Sanal POS & Tahsilat', Icons.point_of_sale_rounded),
      _buildPlaceholderPage('OCR ile Fatura Tarama', Icons.document_scanner_rounded),
      const TaxAndVatReportScreen(), // 4. Sekme: B2B KDV Raporu (Senin ekranın)
      const ProfileSettingsScreen(), // 5. Sekme: Menü (Senin ekranın)
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              _isB2BMode ? Icons.business_center_rounded : Icons.person_rounded,
              color: colorScheme.primary,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              _isB2BMode ? 'PayPulse B2B Kurumsal' : 'PayPulse B2C Bireysel',
              style: AppTextStyles.labelLarge,
            ),
          ],
        ),
        actions: [
          // Sadece B2B modundayken B2C'ye geçiş Switch'i aktif olur (Tersi olamaz)
          if (_isB2BMode)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                children: [
                  Text('B2C\'ye Geç', style: AppTextStyles.labelSmall),
                  const SizedBox(width: 4),
                  Switch(
                    value: _isB2BMode,
                    activeColor: AppLightColors.primary,
                    onChanged: _onRoleSwitchChanged,
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppLightColors.primaryFixed,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'B2C Modu (Kilitli)',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppLightColors.onPrimaryFixedVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _isB2BMode ? b2bScreens : b2cScreens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppLightColors.surfaceContainerLow,
        indicatorColor: AppLightColors.primaryFixed,
        destinations: _isB2BMode
            ? const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded, color: AppLightColors.primary),
                  label: 'Ana Sayfa',
                ),
                NavigationDestination(
                  icon: Icon(Icons.point_of_sale_outlined),
                  selectedIcon: Icon(Icons.point_of_sale_rounded, color: AppLightColors.primary),
                  label: 'Tahsilat',
                ),
                NavigationDestination(
                  icon: Icon(Icons.document_scanner_outlined),
                  selectedIcon: Icon(Icons.document_scanner_rounded, color: AppLightColors.primary),
                  label: 'Fatura Tara',
                ),
                NavigationDestination(
                  icon: Icon(Icons.analytics_outlined),
                  selectedIcon: Icon(Icons.analytics_rounded, color: AppLightColors.primary),
                  label: 'KDV & Rapor',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_rounded),
                  selectedIcon: Icon(Icons.menu_open_rounded, color: AppLightColors.primary),
                  label: 'Menü',
                ),
              ]
            : const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded, color: AppLightColors.primary),
                  label: 'Ana Sayfa',
                ),
                NavigationDestination(
                  icon: Icon(Icons.swap_horiz_outlined),
                  selectedIcon: Icon(Icons.swap_horiz_rounded, color: AppLightColors.primary),
                  label: 'Transfer',
                ),
                NavigationDestination(
                  icon: Icon(Icons.qr_code_scanner_rounded),
                  selectedIcon: Icon(Icons.qr_code_2_rounded, color: AppLightColors.primary),
                  label: 'QR Öde',
                ),
                NavigationDestination(
                  icon: Icon(Icons.pie_chart_outline_rounded),
                  selectedIcon: Icon(Icons.pie_chart_rounded, color: AppLightColors.primary),
                  label: 'Durumum',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_rounded),
                  selectedIcon: Icon(Icons.menu_open_rounded, color: AppLightColors.primary),
                  label: 'Menü',
                ),
              ],
      ),
    );
  }

  Widget _buildPlaceholderPage(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: AppLightColors.primary),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Ekip arkadaşlarının bağlayacağı modül ekranı',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}