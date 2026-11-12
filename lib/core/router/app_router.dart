import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/fast_receipt.dart';
import '../../presentation/screens/auth/bloc/auth_bloc.dart';
import '../../presentation/screens/auth/bloc/auth_event.dart';
import '../../presentation/screens/budget_analytics_screen.dart';
import '../../presentation/screens/expense_approval/batch_approval_receipt_screen.dart';
import '../../presentation/screens/expense_approval/expense_approval_center_screen.dart';
import '../../presentation/screens/home_wallet_and_safe/home.dart';
import '../../presentation/screens/profile_settings_screen.dart';
import '../../presentation/screens/tax_and_vat_report_screen.dart';
import '../../presentation/screens/transfer/fast_receipt_screen.dart';
import '../../presentation/screens/transfer/transfer_screen.dart';
import '../../presentation/screens/virtual_pos/virtual_pos_screen.dart';
import '../../presentation/shell_navigation/main_shell_wrapper_screen.dart';
import 'app_routes.dart';

class AppRouter {
  final AuthBloc authBloc;
  late final GoRouter router;

  AppRouter({required this.authBloc}) {
    router = GoRouter(
      initialLocation: AppRoutes.home,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: _handleRedirect,
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return MainShellWrapperScreen(child: child);
          },
          routes: [
            // ================= BİREYSEL CÜZDAN (B2C) SEKMELERİ =================
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeAndWalletEkrani(),
              routes: [
                GoRoute(
                  path: 'transfer',
                  builder: (context, state) => const TransferScreen(),
                  routes: [
                    GoRoute(
                      path: 'receipt/:txId',
                      builder: (context, state) {
                        final txId = state.pathParameters['txId'] ?? '-';
                        final receipt = state.extra is FastReceipt
                            ? state.extra as FastReceipt
                            : null;
                        return FastReceiptScreen(
                          txId: txId,
                          receipt: receipt,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: AppRoutes.qr,
              builder: (context, state) => const _RoutePlaceholderView(
                title: 'QR Ödeme & Tahsilat',
                subtitle: 'Bireysel Sekme 2 • Deep Link Test Merkezi',
                actions: [
                  _QuickNavButton(
                    label: 'FAST Transfer Akışını Aç (/home/transfer)',
                    path: AppRoutes.fastTransfer,
                  ),
                  _QuickNavButton(
                    label: 'Ödeme Linki Deep Link Testi (/pay/LNK-4402)',
                    path: '/pay/LNK-4402',
                  ),
                ],
              ),
            ),
            GoRoute(
              path: AppRoutes.transactions,
              builder: (context, state) => const _RoutePlaceholderView(
                title: 'İşlem Geçmişi',
                subtitle: 'Tümü • Gelen (+) • Giden (-) • QR Ödemeleri',
                actions: [
                  _QuickNavButton(
                    label: 'Son FAST Dekontunu Aç (:txId)',
                    path: '/home/transfer/receipt/PP-FAST-20261111-849201',
                  ),
                ],
              ),
            ),
            GoRoute(
              path: AppRoutes.budget,
              builder: (context, state) => const BudgetAnalyticsScreen(),
            ),
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileSettingsScreen(),
            ),

            // ================= İŞLETME PANELİ (B2B) SEKMELERİ =================
            GoRoute(
              path: AppRoutes.businessOverview,
              builder: (context, state) => const _RoutePlaceholderView(
                title: 'İşletme Paneli • Genel Bakış',
                subtitle: 'Nova Tasarım Ltd. (Sadece employee ve admin)',
                actions: [
                  _QuickNavButton(
                    label: 'Hızlı İşlem: Fatura & Fiş Tara (AI-OCR)',
                    path: AppRoutes.businessOcrScan,
                  ),
                  _QuickNavButton(
                    label: 'Hızlı İşlem: POS ile Tahsilat',
                    path: AppRoutes.businessPos,
                  ),
                  _QuickNavButton(
                    label: 'Hızlı İşlem: Masraf Onayları',
                    path: AppRoutes.businessExpenses,
                  ),
                ],
              ),
              routes: [
                GoRoute(
                  path: 'ocr-scan',
                  builder: (context, state) => const _RoutePlaceholderView(
                    title: 'Fatura & Fiş Tarama (AI-OCR)',
                    subtitle: 'Alt rota — employee ve admin erişebilir',
                  ),
                ),
              ],
            ),
            GoRoute(
              path: AppRoutes.businessPos,
              builder: (context, state) => const VirtualPosScreen(),
            ),
            GoRoute(
              path: AppRoutes.businessInvoices,
              builder: (context, state) => const _RoutePlaceholderView(
                title: 'E-Fatura & E-Arşiv',
                subtitle: 'GİB Canlı Entegrasyonu • Gelen & Giden Faturalar',
              ),
            ),
            GoRoute(
              path: AppRoutes.businessExpenses,
              builder: (context, state) => const ExpenseApprovalCenterScreen(),
              routes: [
                GoRoute(
                  path: 'batch-approval',
                  builder: (context, state) =>
                      const BatchApprovalReceiptScreen(),
                ),
              ],
            ),
            GoRoute(
              path: AppRoutes.businessReports,
              builder: (context, state) => const TaxAndVatReportScreen(),
            ),

            // ================= DEEP LINK ÖZEL ROTASI =================
            GoRoute(
              path: AppRoutes.paymentRequestDeepLink,
              builder: (context, state) {
                final requestId = state.pathParameters['requestId'] ?? '-';
                return _RoutePlaceholderView(
                  title: 'Ödeme Linki / Tahsilat Talebi',
                  subtitle: 'Deep Link Parametresi requestId: $requestId',
                  actions: const [
                    _QuickNavButton(
                      label: 'Ana Sayfaya Dön',
                      path: AppRoutes.home,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Rol Bazlı Route Guards (Yönlendirme Kalkanı)
  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final authState = authBloc.state;
    final location = state.matchedLocation;

    if (location == '/') {
      return AppRoutes.home;
    }

    final isBusinessRoute = location.startsWith('/business');

    // 1. KALKAN: 'b2c' (Bireysel) kullanıcı İşletme Paneli rotalarına giremez.
    if (isBusinessRoute && !authState.canAccessBusinessPanel) {
      return AppRoutes.home;
    }

    // 2. KALKAN: 'employee' (Çalışan) kullanıcı sadece 'admin' yetkisi isteyen
    // Toplu Masraf Onayı ve KDV/Vergi Raporları rotalarına giremez.
    final isAdminOnlyRoute =
        location.startsWith(AppRoutes.businessBatchApproval) ||
        location.startsWith(AppRoutes.businessReports);

    if (isAdminOnlyRoute && !authState.isAdmin) {
      return AppRoutes.businessOverview;
    }

    // 3. ALT BAR SENKRONİZASYONU: Deep link ile doğrudan '/business/...'
    // rotasına gelindiyse ve kullanıcı yetkiliyse alt barı İşletme moduna al.
    if (isBusinessRoute &&
        authState.canAccessBusinessPanel &&
        !authState.isBusinessMode) {
      authBloc.add(const AuthPanelModeToggled(isBusinessMode: true));
    } else if (!isBusinessRoute &&
        !location.startsWith('/pay') &&
        authState.isBusinessMode) {
      authBloc.add(const AuthPanelModeToggled(isBusinessMode: false));
    }

    return null;
  }
}

/// BLoC Stream'ini GoRouter'ın refreshListenable özelliğine bağlayan adaptör.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Yeni ekran dosyası oluşturmadan rotaları ve kalkanları test etmek için minimal görünüm.
class _RoutePlaceholderView extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> actions;

  const _RoutePlaceholderView({
    required this.title,
    required this.subtitle,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.toString();
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Aktif Rota: $path',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 24),
              ...actions,
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickNavButton extends StatelessWidget {
  final String label;
  final String path;

  const _QuickNavButton({
    required this.label,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FilledButton.tonalIcon(
        onPressed: () => context.go(path),
        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
        label: Text(label),
      ),
    );
  }
}

