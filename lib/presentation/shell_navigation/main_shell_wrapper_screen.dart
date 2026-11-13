import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../screens/auth/bloc/auth_bloc.dart';
import '../screens/auth/bloc/auth_event.dart';
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
          body: Column(
            children: [
              _RoleAndModeBanner(authState: authState, isBusiness: isBusiness),
              Expanded(child: child),
            ],
          ),
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

class _RoleAndModeBanner extends StatelessWidget {
  final AuthState authState;
  final bool isBusiness;

  const _RoleAndModeBanner({required this.authState, required this.isBusiness});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isBusiness ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: Row(
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isBusiness
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isBusiness
                      ? 'Nova Tasarım'
                      : 'PayPulse Bireysel',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isBusiness ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            PopupMenuButton<String>(
              tooltip: 'Rol Seç (Guard Testi)',
              onSelected: (role) {
                context.read<AuthBloc>().add(AuthRoleChanged(role));
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'b2c', child: Text('Rol: b2c (Bireysel)')),
                PopupMenuItem(
                  value: 'employee',
                  child: Text('Rol: employee (Çalışan)'),
                ),
                PopupMenuItem(
                  value: 'admin',
                  child: Text('Rol: admin (Yönetici)'),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF63E6BE).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${authState.role}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isBusiness
                            ? const Color(0xFF63E6BE)
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color: isBusiness
                          ? const Color(0xFF63E6BE)
                          : const Color(0xFF0F172A),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            if (authState.canAccessBusinessPanel) ...[
              const Spacer(),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: isBusiness
                      ? const Color(0xFF63E6BE)
                      : const Color(0xFF0F172A),
                  foregroundColor: isBusiness
                      ? const Color(0xFF0F172A)
                      : Colors.white,
                ),
                onPressed: () {
                  final nextMode = !isBusiness;
                  context.read<AuthBloc>().add(
                    AuthPanelModeToggled(isBusinessMode: nextMode),
                  );
                  context.go(
                    nextMode ? AppRoutes.businessOverview : AppRoutes.home,
                  );
                },
                icon: Icon(
                  isBusiness
                      ? Icons.account_balance_wallet_outlined
                      : Icons.business_center_outlined,
                  size: 13,
                ),
                label: Text(
                  isBusiness ? 'Bireysel' : 'KOBİ Paneli',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
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
