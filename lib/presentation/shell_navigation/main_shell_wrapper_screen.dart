import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../screens/auth/bloc/auth_bloc.dart';
import '../screens/auth/bloc/auth_state.dart';

class MainShellWrapperScreen extends StatelessWidget {
  final Widget child;

  const MainShellWrapperScreen({super.key, required this.child});

  static const List<_NavTabItem> _personalTabs = [
    _NavTabItem(
      label: 'Ana Sayfa',
      path: AppRoutes.home,
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    _NavTabItem(
      label: 'QR',
      path: AppRoutes.qr,
      icon: Icons.qr_code_scanner_rounded,
      activeIcon: Icons.qr_code_scanner_rounded,
    ),
    _NavTabItem(
      label: 'İşlemler',
      path: AppRoutes.transactions,
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
    ),
    _NavTabItem(
      label: 'Bütçe',
      path: AppRoutes.budget,
      icon: Icons.pie_chart_outline_rounded,
      activeIcon: Icons.pie_chart_rounded,
    ),
    _NavTabItem(
      label: 'Profil',
      path: AppRoutes.profile,
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  static const List<_NavTabItem> _businessTabs = [
    _NavTabItem(
      label: 'Genel Bakış',
      path: AppRoutes.businessOverview,
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
    ),
    _NavTabItem(
      label: 'Tahsilat',
      path: AppRoutes.businessPos,
      icon: Icons.point_of_sale_outlined,
      activeIcon: Icons.point_of_sale_rounded,
    ),
    _NavTabItem(
      label: 'Faturalar',
      path: AppRoutes.businessInvoices,
      icon: Icons.description_outlined,
      activeIcon: Icons.description_rounded,
    ),
    _NavTabItem(
      label: 'Masraflar',
      path: AppRoutes.businessExpenses,
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
    ),
    _NavTabItem(
      label: 'Raporlar',
      path: AppRoutes.businessReports,
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights_rounded,
    ),
  ];

  int _calculateSelectedIndex(String location, List<_NavTabItem> tabs) {
    for (var i = 0; i < tabs.length; i++) {
      if (location.startsWith(tabs[i].path)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isBusiness =
            authState.isBusinessMode && authState.canAccessBusinessPanel;
        final tabs = isBusiness ? _businessTabs : _personalTabs;
        final selectedIndex = _calculateSelectedIndex(location, tabs);

        return Scaffold(
          body: child,
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: Colors.white,
                indicatorColor: const Color(0xFF63E6BE),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final isSelected = states.contains(WidgetState.selected);
                  return TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF64748B),
                  );
                }),
              ),
              child: NavigationBar(
                height: 68,
                elevation: 0,
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  final targetPath = tabs[index].path;
                  if (location != targetPath) {
                    context.go(targetPath);
                  }
                },
                destinations: tabs
                    .map(
                      (tab) => NavigationDestination(
                        icon: Icon(tab.icon, color: const Color(0xFF64748B)),
                        selectedIcon: Icon(
                          tab.activeIcon,
                          color: const Color(0xFF0F172A),
                        ),
                        label: tab.label,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavTabItem {
  final String label;
  final String path;
  final IconData icon;
  final IconData activeIcon;

  const _NavTabItem({
    required this.label,
    required this.path,
    required this.icon,
    required this.activeIcon,
  });
}
