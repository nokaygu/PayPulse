import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/fast_receipt.dart';
import '../../presentation/screens/budget_analytics_screen.dart';
import '../../presentation/screens/cards_management/cards_management.dart';
import '../../presentation/screens/home_wallet_and_safe/home.dart';
import '../../presentation/screens/profile_settings_screen.dart';
import '../../presentation/screens/transfer/fast_receipt_screen.dart';
import '../../presentation/screens/transfer/transfer_screen.dart';

/// PayPulse Uygulaması Rota İsimleri ve Yolları
abstract final class AppRoutes {
  AppRoutes._();

  // Splash & Onboarding
  static const String splash = '/splash';
  static const String splashName = 'splash';

  // Auth Rotaları
  static const String login = '/login';
  static const String loginName = 'login';

  static const String register = '/register';
  static const String registerName = 'register';

  // Ana Ekranlar (Cüzdan & Kasa)
  static const String home = '/home';
  static const String homeName = 'home';

  // Kart Yönetimi
  static const String cards = '/cards';
  static const String cardsName = 'cards';

  // Para Transferi & FAST
  static const String transfer = '/transfer';
  static const String transferName = 'transfer';

  static const String receipt = '/receipt/:txId';
  static const String receiptName = 'receipt';

  // QR İşlemleri
  static const String qr = '/qr';
  static const String qrName = 'qr';

  // İşlem Geçmişi
  static const String transactions = '/transactions';
  static const String transactionsName = 'transactions';

  // Bütçe ve Analitik
  static const String budget = '/budget';
  static const String budgetName = 'budget';

  // Profil ve Ayarlar
  static const String profile = '/profile';
  static const String profileName = 'profile';

  // Deep Link Rotaları (Ödeme Linki / Tahsilat)
  static const String paymentLink = '/pay/:requestId';
  static const String paymentLinkName = 'paymentLink';
}

/// Uygulama Router Yapılandırması
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      // Splash Rota
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        builder: (context, state) => const _RoutePlaceholderScreen(
          title: 'PayPulse',
          subtitle: 'Yükleniyor...',
        ),
      ),

      // Auth Rotaları
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (context, state) => const _RoutePlaceholderScreen(
          title: 'Giriş Yap',
          subtitle: 'Hesabınıza giriş yapın',
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: AppRoutes.registerName,
        builder: (context, state) => const _RoutePlaceholderScreen(
          title: 'Kayıt Ol',
          subtitle: 'Yeni bir PayPulse hesabı oluşturun',
        ),
      ),

      // Ana Cüzdan Ekranı
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.homeName,
        builder: (context, state) => const HomeAndWalletEkrani(),
      ),

      // Kart Yönetimi
      GoRoute(
        path: AppRoutes.cards,
        name: AppRoutes.cardsName,
        builder: (context, state) => const CardsManagementScreen(),
      ),

      // Para Transferi & FAST
      GoRoute(
        path: AppRoutes.transfer,
        name: AppRoutes.transferName,
        builder: (context, state) => const TransferScreen(),
      ),

      // İşlem Dekontu (Parametreli Rota)
      GoRoute(
        path: AppRoutes.receipt,
        name: AppRoutes.receiptName,
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

      // QR İşlemleri
      GoRoute(
        path: AppRoutes.qr,
        name: AppRoutes.qrName,
        builder: (context, state) => const _RoutePlaceholderScreen(
          title: 'QR İşlemleri',
          subtitle: 'QR ile öde veya anında ödeme al',
        ),
      ),

      // İşlem Geçmişi
      GoRoute(
        path: AppRoutes.transactions,
        name: AppRoutes.transactionsName,
        builder: (context, state) => const _RoutePlaceholderScreen(
          title: 'Hesap Hareketleri',
          subtitle: 'Gelen ve giden tüm işlemleriniz',
        ),
      ),

      // Bütçe ve Analitik
      GoRoute(
        path: AppRoutes.budget,
        name: AppRoutes.budgetName,
        builder: (context, state) => const BudgetAnalyticsScreen(),
      ),

      // Profil ve Ayarlar
      GoRoute(
        path: AppRoutes.profile,
        name: AppRoutes.profileName,
        builder: (context, state) => const ProfileSettingsScreen(),
      ),

      // Deep Link: /pay/:requestId
      GoRoute(
        path: AppRoutes.paymentLink,
        name: AppRoutes.paymentLinkName,
        builder: (context, state) {
          final requestId = state.pathParameters['requestId'] ?? '-';
          return _RoutePlaceholderScreen(
            title: 'Ödeme Talebi',
            subtitle: 'Talep No: $requestId',
          );
        },
      ),
    ],

    // 404 / Hata Sayfası
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Sayfa Bulunamadı'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                '404 - Sayfa Bulunamadı',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aradığınız rota (${state.uri.toString()}) mevcut değil.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Ana Sayfaya Dön'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Geliştirilmekte olan ekranlar için geçici yer tutucu görünüm
class _RoutePlaceholderScreen extends StatelessWidget {
  final String title;
  final String subtitle;

  const _RoutePlaceholderScreen({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.construction_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Ana Ekrana Dön'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

