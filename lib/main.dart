import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/app_mode.dart';
import 'core/firebase_configuration/firebase_configure.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/remote/firebase_notification_datasource.dart';
import 'data/repositories/budget_repository.dart';
import 'data/repositories/company_repository.dart';
import 'data/repositories/expense_repository.dart';
import 'data/repositories/invoice_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/payment_request_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/wallet_repository.dart';
import 'domain/repositories/i_budget_repository.dart';
import 'domain/repositories/i_company_repository.dart';
import 'domain/repositories/i_expense_repository.dart';
import 'domain/repositories/i_invoice_repository.dart';
import 'domain/repositories/i_notification_repository.dart';
import 'domain/repositories/i_payment_request_repository.dart';
import 'domain/repositories/i_transaction_repository.dart';
import 'domain/repositories/i_user_repository.dart';
import 'domain/repositories/i_wallet_repository.dart';
import 'presentation/screens/auth/bloc/auth_bloc.dart';
import 'presentation/screens/auth/bloc/auth_event.dart';
import 'presentation/screens/auth/bloc/auth_state.dart';
import 'presentation/widgets/bloc/notification_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Canlı Firebase ve FCM yalnızca Android (Live) üzerinde başlatılır.
  // Demo modunda (macOS/Web) Firebase başlatma adımı atlanır.
  if (AppMode.isLiveFirebase) {
    try {
      await FirebaseConfigure.initialize();
      final notificationService = FirebaseNotificationDatasource();
      await notificationService.initialize();
    } catch (e) {
      debugPrint('Firebase başlatma hatası: $e');
    }
  }

  runApp(const PayPulseApplication());
}

class PayPulseApplication extends StatelessWidget {
  const PayPulseApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IUserRepository>(create: (_) => UserRepository()),
        RepositoryProvider<IWalletRepository>(
          create: (_) => WalletRepository(),
        ),
        RepositoryProvider<ITransactionRepository>(
          create: (_) => TransactionRepository(),
        ),
        RepositoryProvider<IExpenseRepository>(
          create: (_) => ExpenseRepository(),
        ),
        RepositoryProvider<ICompanyRepository>(
          create: (_) => CompanyRepository(),
        ),
        RepositoryProvider<INotificationRepository>(
          create: (_) => NotificationRepository(),
        ),
        RepositoryProvider<IPaymentRequestRepository>(
          create: (_) => PaymentRequestRepository(),
        ),
        RepositoryProvider<IBudgetRepository>(
          create: (_) => BudgetRepository(),
        ),
        RepositoryProvider<IInvoiceRepository>(
          create: (_) => InvoiceRepository(),
        ),
      ],
      child: const _PayPulseRouterHost(),
    );
  }
}

class _PayPulseRouterHost extends StatefulWidget {
  const _PayPulseRouterHost();

  @override
  State<_PayPulseRouterHost> createState() => _PayPulseRouterHostState();
}

class _PayPulseRouterHostState extends State<_PayPulseRouterHost> {
  late final AuthBloc _authBloc;
  late final NotificationCubit _notificationCubit;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(userRepository: context.read<IUserRepository>())
      ..add(const AuthSubscriptionRequested());
    _notificationCubit = NotificationCubit(
      repository: context.read<INotificationRepository>(),
    );
    _appRouter = AppRouter(authBloc: _authBloc);
  }

  @override
  void dispose() {
    _notificationCubit.close();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<NotificationCubit>.value(value: _notificationCubit),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => prev.user?.uid != curr.user?.uid,
        listener: (context, authState) {
          context.read<NotificationCubit>().watchForUser(authState.user?.uid);
        },
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: AppTheme.themeModeNotifier,
          builder: (context, currentMode, _) {
            return MaterialApp.router(
              title: 'PayPulse',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: currentMode,
              routerConfig: _appRouter.router,
            );
          },
        ),
      ),
    );
  }
}
