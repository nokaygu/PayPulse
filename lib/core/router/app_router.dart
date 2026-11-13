import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/analytics_and_reports/budget_analytics_screen.dart';
import '../../presentation/screens/analytics_and_reports/tax_and_vat_report_screen.dart';
import '../../presentation/screens/analytics_and_reports/transaction_history_screen.dart';
import '../../presentation/screens/auth/bloc/auth_bloc.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/b2b_operations/b2b_expense_approval_center_screen.dart';
import '../../presentation/screens/b2b_operations/bulk_expense_erp_receipt_screen.dart';
import '../../presentation/screens/b2b_operations/virtual_pos_terminal_screen.dart';
import '../../presentation/screens/home_wallet_and_safe/home_screen.dart';
import '../../presentation/screens/profile_and_cards/profile_settings_screen.dart';
import '../../presentation/screens/splash_and_onboarding/splash_screen.dart';
import '../../presentation/screens/qr_and_ocr/e_invoice_gib_list_screen.dart';
import '../../presentation/screens/qr_and_ocr/ocr_camera_scanner_screen.dart';
import '../../presentation/screens/qr_and_ocr/qr_payment_center_screen.dart';
import '../../presentation/screens/transfer/transfer_receipt_screen.dart';
import '../../presentation/screens/transfer/transfer_summary_screen.dart';
import '../../presentation/shell_navigation/main_shell_wrapper_screen.dart';
import 'app_routes.dart';

class AppRouter {
  final AuthBloc authBloc;
  late final GoRouter router;

  AppRouter({required this.authBloc}) {
    router = GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: _handleRedirect,
      routes: [
        // ================= AÇILIŞ / KARŞILAMA EKRANI (TAM EKRAN) =================
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => SplashScreen(
            onInitializationComplete: () {
              final authState = authBloc.state;
              if (authState.isAuthenticated) {
                if (authState.role == 'admin') {
                  router.go(AppRoutes.businessOverview);
                } else {
                  router.go(AppRoutes.home);
                }
              } else {
                router.go(AppRoutes.login);
              }
            },
          ),
        ),
        // ================= KİMLİK DOĞRULAMA (SHELL DIŞINDA) =================
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return MainShellWrapperScreen(child: child);
          },
          routes: [
            // ================= BİREYSEL CÜZDAN (B2C) SEKMELERİ =================
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'transfer',
                  builder: (context, state) => const TransferSummaryScreen(),
                  routes: [
                    GoRoute(
                      path: 'receipt/:txId',
                      builder: (context, state) {
                        final txId =
                            state.pathParameters['txId'] ??
                            'PP-FAST-20261111-849201';
                        return TransferReceiptScreen(txId: txId);
                      },
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: AppRoutes.qr,
              builder: (context, state) => const QrPaymentCenterScreen(),
            ),
            GoRoute(
              path: AppRoutes.transactions,
              builder: (context, state) => const TransactionHistoryScreen(),
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
              builder: (context, state) => const BusinessSafeOverviewScreen(),
              routes: [
                GoRoute(
                  path: 'ocr-scan',
                  builder: (context, state) => const OcrCameraScannerScreen(),
                ),
              ],
            ),
            GoRoute(
              path: AppRoutes.businessPos,
              builder: (context, state) => const VirtualPosTerminalScreen(),
            ),
            GoRoute(
              path: AppRoutes.businessInvoices,
              builder: (context, state) => const EInvoiceGibListScreen(),
            ),
            GoRoute(
              path: AppRoutes.businessExpenses,
              builder: (context, state) =>
                  const B2bExpenseApprovalCenterScreen(),
              routes: [
                GoRoute(
                  path: 'batch-approval',
                  builder: (context, state) =>
                      const BulkExpenseErpReceiptScreen(),
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
              builder: (context, state) => const TransferSummaryScreen(),
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
      return AppRoutes.splash;
    }

    // Splash ekranındayken yönlendirmeyi kesme
    if (location == AppRoutes.splash) {
      return null;
    }

    final isAuthRoute =
        location == AppRoutes.login || location == AppRoutes.register;

    // 1. GİRİŞ KONTROLÜ: Oturumu kapalı kullanıcılar auth rotaları harici yerlerden login'e yönlendirilir
    if (!authState.isAuthenticated) {
      return isAuthRoute ? null : AppRoutes.login;
    }

    // 2. OTURUM AÇIK: Giriş yapmış kullanıcı login/register ekranına giderse ana ekrana yönlendirilir
    if (isAuthRoute) {
      return authState.role == 'admin'
          ? AppRoutes.businessOverview
          : AppRoutes.home;
    }

    final isBusinessRoute = location.startsWith('/business');

    // 3. KALKAN: 'b2c' (Bireysel) kullanıcı İşletme Paneli rotalarına giremez.
    if (isBusinessRoute && !authState.canAccessBusinessPanel) {
      return AppRoutes.home;
    }

    // 4. KALKAN: Sadece 'admin' rolüne açık olan toplu masraf onay rotası:
    final isAdminOnlyRoute = location == AppRoutes.businessBatchApproval;

    if (isAdminOnlyRoute && !authState.canApproveExpenses) {
      return AppRoutes.businessOverview;
    }

    return null;
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
