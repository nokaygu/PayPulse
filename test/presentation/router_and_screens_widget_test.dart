import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_pulse/core/constants/app_strings.dart';
import 'package:pay_pulse/core/router/app_router.dart';
import 'package:pay_pulse/core/router/app_routes.dart';
import 'package:pay_pulse/core/theme/app_theme.dart';
import 'package:pay_pulse/domain/entities/budget_entity.dart';
import 'package:pay_pulse/domain/entities/company_entity.dart';
import 'package:pay_pulse/domain/entities/expense_entity.dart';
import 'package:pay_pulse/domain/entities/invoice_entity.dart';
import 'package:pay_pulse/domain/entities/notification_entity.dart';
import 'package:pay_pulse/domain/entities/payment_request_entity.dart';
import 'package:pay_pulse/domain/entities/pos_transaction_entity.dart';
import 'package:pay_pulse/domain/entities/safe_recipient_entity.dart';
import 'package:pay_pulse/domain/entities/transaction_entity.dart';
import 'package:pay_pulse/domain/entities/user_entity.dart';
import 'package:pay_pulse/domain/entities/wallet_entity.dart';
import 'package:pay_pulse/domain/repositories/i_budget_repository.dart';
import 'package:pay_pulse/domain/repositories/i_company_repository.dart';
import 'package:pay_pulse/domain/repositories/i_expense_repository.dart';
import 'package:pay_pulse/domain/repositories/i_invoice_repository.dart';
import 'package:pay_pulse/domain/repositories/i_notification_repository.dart';
import 'package:pay_pulse/domain/repositories/i_payment_request_repository.dart';
import 'package:pay_pulse/domain/repositories/i_transaction_repository.dart';
import 'package:pay_pulse/domain/repositories/i_user_repository.dart';
import 'package:pay_pulse/domain/repositories/i_wallet_repository.dart';
import 'package:pay_pulse/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:pay_pulse/presentation/screens/auth/bloc/auth_event.dart';
import 'package:pay_pulse/presentation/screens/b2b_operations/virtual_pos_terminal_screen.dart';
import 'package:pay_pulse/presentation/screens/profile_and_cards/cards_management_screen.dart';
import 'package:pay_pulse/presentation/screens/profile_and_cards/profile_settings_screen.dart';
import 'package:pay_pulse/presentation/screens/qr_and_ocr/qr_payment_center_screen.dart';
import 'package:pay_pulse/presentation/screens/splash_and_onboarding/splash_screen.dart';
import 'package:pay_pulse/presentation/widgets/bloc/notification_cubit.dart';

class _TestUserRepository implements IUserRepository {
  final _authController = StreamController<UserEntity?>.broadcast();

  void emitUser(UserEntity? user) => _authController.add(user);

  @override
  Future<void> createUserProfile(UserEntity user) async {}

  @override
  Future<void> deleteFcmToken(String uid) async {}

  @override
  Future<List<UserEntity>> getAllUsers() async => const [];

  @override
  Future<UserEntity?> getDemoUserByRole(String role) async => null;

  @override
  Future<UserEntity?> getUserById(String uid) async => null;

  @override
  Future<UserEntity?> login({
    required String email,
    required String password,
  }) async => null;

  @override
  Future<void> logout() async => _authController.add(null);

  @override
  Future<UserEntity?> register({
    required String email,
    required String password,
    required String name,
    String role = 'b2c',
    String? companyId,
  }) async => null;

  @override
  Future<void> seedDemoData() async {}

  @override
  Future<void> updateFcmToken(String uid, String token) async {}

  @override
  Future<void> updateUserProfile(UserEntity user) async {}

  @override
  Stream<UserEntity?> watchAuthUser() => _authController.stream;

  Future<void> dispose() => _authController.close();
}

class _TestWalletRepository implements IWalletRepository {
  static const _wallet = WalletEntity(
    walletId: 'w_test',
    ownerId: 'user_test',
    balanceTl: 2500000,
    balanceUsd: 50000,
    balanceEur: 25000,
    iban: 'TR330006100519786457841326',
  );

  @override
  Future<void> createWallet(WalletEntity wallet) async {}

  @override
  Future<List<WalletEntity>> getAllWallets() async => const [_wallet];

  @override
  Future<WalletEntity?> getUserWallet(String userId) async => _wallet;

  @override
  Future<WalletEntity?> getWalletById(String walletId) async => _wallet;

  @override
  Future<void> updateWallet(WalletEntity wallet) async {}

  @override
  Stream<WalletEntity?> watchUserWallet(String userId) =>
      Stream.value(_wallet);

  @override
  Stream<WalletEntity?> watchWallet(String walletId) => Stream.value(_wallet);
}

class _TestTransactionRepository implements ITransactionRepository {
  @override
  Future<TransactionEntity> executeCardPosPayment({
    required String companyId,
    required String maskedCardNumber,
    required int amountKurus,
    String currency = 'TRY',
  }) => throw UnimplementedError();

  @override
  Future<TransactionEntity> executeFastTransfer({
    required String senderUserId,
    required String receiverUserId,
    required int amountKurus,
    String currency = 'TRY',
    String? targetIban,
  }) => throw UnimplementedError();

  @override
  Future<TransactionEntity> executeFastTransferByIban({
    required String senderUserId,
    required String targetIban,
    required int amountKurus,
    String currency = 'TRY',
    String? title,
    String? category,
  }) => throw UnimplementedError();

  @override
  Future<TransactionEntity> executeQrWalletPayment({
    required String companyId,
    required String payerUserId,
    required int amountKurus,
    String currency = 'TRY',
  }) => throw UnimplementedError();

  @override
  Future<SafeRecipientEntity?> findRecipientByIban(String rawIban) async =>
      null;

  @override
  Future<List<TransactionEntity>> getAllTransactions() async => const [];

  @override
  Future<List<PosTransactionEntity>> getPosTransactions(
    String companyId,
  ) async => const [];

  @override
  Future<List<SafeRecipientEntity>> getSavedRecipients() async => const [];

  @override
  Future<List<TransactionEntity>> getSentTransactions(String userId) async =>
      const [];

  @override
  Future<TransactionEntity?> getTransactionById(String txId) async => null;

  @override
  Stream<List<TransactionEntity>> watchReceivedTransactions(String userId) =>
      Stream.value(const []);

  @override
  Stream<List<TransactionEntity>> watchSentTransactions(String userId) =>
      Stream.value(const []);

  @override
  Stream<List<TransactionEntity>> watchUserTransactions(String userId) =>
      Stream.value(const []);
}

class _TestExpenseRepository implements IExpenseRepository {
  @override
  Future<void> approveExpense({
    required String expenseId,
    String? accountingCode,
    String? approvedBy,
  }) async {}

  @override
  Future<void> createExpense(ExpenseEntity expense) async {}

  @override
  Future<List<ExpenseEntity>> getAllExpenses() async => const [];

  @override
  Future<ExpenseEntity?> getExpenseById(String expenseId) async => null;

  @override
  Future<void> rejectExpense({
    required String expenseId,
    required String rejectReason,
    String? rejectedBy,
  }) async {}

  @override
  Future<String> uploadReceiptImage({
    required String localFilePath,
    required String expenseId,
  }) async => localFilePath;

  @override
  Stream<List<ExpenseEntity>> watchCompanyExpenses(String companyId) =>
      Stream.value(const []);

  @override
  Stream<List<ExpenseEntity>> watchEmployeeExpenses(String employeeId) =>
      Stream.value(const []);
}

class _TestCompanyRepository implements ICompanyRepository {
  @override
  Future<void> createCompany(CompanyEntity company) async {}

  @override
  Future<List<CompanyEntity>> getAllCompanies() async => const [];

  @override
  Future<CompanyEntity?> getCompanyById(String companyId) async =>
      const CompanyEntity(
        companyId: AppStrings.defaultCompanyId,
        name: 'TechSolutions A.Ş.',
        taxNumber: '1234567890',
        corporateIban: 'TR330006100519786457841326',
        adminIds: ['adm_1'],
      );
}

class _TestNotificationRepository implements INotificationRepository {
  @override
  Stream<int> getUnreadCount(String userId) => Stream.value(0);

  @override
  Stream<List<NotificationEntity>> getUserNotifications(String userId) =>
      Stream.value(const []);

  @override
  Future<void> markAllAsRead(String userId) async {}

  @override
  Future<void> markAsRead(String notificationId) async {}

  @override
  Future<void> sendNotification(NotificationEntity notification) async {}
}

class _TestPaymentRequestRepository implements IPaymentRequestRepository {
  @override
  Future<TransactionEntity> completePaymentRequestWithWallet({
    required String requestId,
    required String payerUserId,
  }) => throw UnimplementedError();

  @override
  Future<void> createPaymentRequest(PaymentRequestEntity request) async {}

  @override
  Future<List<PaymentRequestEntity>> getAllPaymentRequests() async => const [];

  @override
  Future<PaymentRequestEntity?> getPaymentRequestById(
    String requestId,
  ) async => PaymentRequestEntity(
    requestId: requestId,
    merchantId: 'comp_1',
    amount: 45000,
    currency: 'TRY',
    status: 'pending',
    description: 'PayPulse Tahsilat Linki',
  );
}

class _TestBudgetRepository implements IBudgetRepository {
  @override
  Future<List<BudgetCategoryEntity>> getBudgetCategories({
    required String userId,
    required String period,
  }) async => const [];

  @override
  Future<SavingsGoalEntity?> getSavingsGoal({required String userId}) async =>
      null;
}

class _TestInvoiceRepository implements IInvoiceRepository {
  @override
  Future<List<InvoiceEntity>> getInvoices({required String companyId}) async =>
      const [];

  @override
  Future<void> payInvoiceWithFast({
    required String companyId,
    required String invoiceId,
    required String payerUserId,
    required String targetIban,
  }) async {}
}

Widget _wrapWithProviders({
  required AuthBloc authBloc,
  required Widget child,
}) {
  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<IUserRepository>(create: (_) => _TestUserRepository()),
      RepositoryProvider<IWalletRepository>(
        create: (_) => _TestWalletRepository(),
      ),
      RepositoryProvider<ITransactionRepository>(
        create: (_) => _TestTransactionRepository(),
      ),
      RepositoryProvider<IExpenseRepository>(
        create: (_) => _TestExpenseRepository(),
      ),
      RepositoryProvider<ICompanyRepository>(
        create: (_) => _TestCompanyRepository(),
      ),
      RepositoryProvider<INotificationRepository>(
        create: (_) => _TestNotificationRepository(),
      ),
      RepositoryProvider<IPaymentRequestRepository>(
        create: (_) => _TestPaymentRequestRepository(),
      ),
      RepositoryProvider<IBudgetRepository>(
        create: (_) => _TestBudgetRepository(),
      ),
      RepositoryProvider<IInvoiceRepository>(
        create: (_) => _TestInvoiceRepository(),
      ),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<NotificationCubit>(
          create: (context) => NotificationCubit(
            repository: context.read<INotificationRepository>(),
          ),
        ),
      ],
      child: child,
    ),
  );
}

void main() {
  group('AppRouter RBAC ve Deep Link Yönlendirmeleri', () {
    testWidgets(
      'Oturumsuz, B2C, Employee ve Admin rolleri kalkan kurallarına göre yönlendirilir',
      (tester) async {
        tester.view.physicalSize = const Size(900, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final userRepo = _TestUserRepository();
        final authBloc = AuthBloc(
          userRepository: userRepo,
          allowDemoPersonaSwitch: true,
        )..add(const AuthSubscriptionRequested());
        final appRouter = AppRouter(authBloc: authBloc);
        addTearDown(() async {
          appRouter.router.dispose();
          await authBloc.close();
          await userRepo.dispose();
        });

        await tester.pumpWidget(
          _wrapWithProviders(
            authBloc: authBloc,
            child: MaterialApp.router(
              theme: AppTheme.lightTheme,
              routerConfig: appRouter.router,
            ),
          ),
        );

        // Splash tamamlanıp oturumsuz kullanıcı /login ekranına düşer
        await tester.pump(const Duration(milliseconds: 1900));
        await tester.pump();
        expect(
          appRouter.router.routeInformationProvider.value.uri.path,
          AppRoutes.login,
        );

        // Kalkan 1: Oturumsuz kullanıcı korunan rotalara ve /pay/:id rotasına giremez
        appRouter.router.go(AppRoutes.home);
        await tester.pump();
        expect(
          appRouter.router.routeInformationProvider.value.uri.path,
          AppRoutes.login,
        );

        appRouter.router.go('/pay/req_99');
        await tester.pump();
        expect(
          appRouter.router.routeInformationProvider.value.uri.path,
          AppRoutes.login,
        );

        // B2C oturumu açılır -> /home'a yönlenir, /business/* Kalkan 3 ile engellenir
        authBloc.add(
          const AuthUserProfileLoaded(
            UserEntity(
              uid: 'b2c_1',
              name: 'Deniz Aksoy',
              email: 'deniz@paypulse.app',
              role: AppStrings.roleB2C,
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(
          appRouter.router.routeInformationProvider.value.uri.path,
          AppRoutes.home,
        );

        appRouter.router.go(AppRoutes.businessOverview);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(
          appRouter.router.routeInformationProvider.value.uri.path,
          AppRoutes.home,
        );

        // Deep link: Oturumlu kullanıcı /pay/req_42 rotasına gidebilir
        appRouter.router.go('/pay/req_42');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(
          appRouter.router.routeInformationProvider.value.uri.path,
          '/pay/req_42',
        );

        // Employee oturumu: /business/expenses açık, ancak Kalkan 4 /business/reports & toplu onayı engeller
        authBloc.add(
          const AuthUserProfileLoaded(
            UserEntity(
              uid: 'emp_1',
              name: 'Mert Can',
              email: 'mert@paypulse.app',
              role: AppStrings.roleEmployee,
              companyId: AppStrings.defaultCompanyId,
              hasB2BAccess: true,
            ),
          ),
        );
        await tester.pump();

        appRouter.router.go(AppRoutes.businessExpenses);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(
          appRouter.router.routeInformationProvider.value.uri.path,
          AppRoutes.businessExpenses,
        );

        appRouter.router.go(AppRoutes.businessReports);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(
          appRouter.router.routeInformationProvider.value.uri.path,
          AppRoutes.businessOverview,
        );

        appRouter.router.go(AppRoutes.businessBatchApproval);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(
          appRouter.router.routeInformationProvider.value.uri.path,
          AppRoutes.businessOverview,
        );

        // Admin oturumu: Kalkan 4 rotalarına erişebilir
        authBloc.add(
          const AuthUserProfileLoaded(
            UserEntity(
              uid: 'adm_1',
              name: 'Ayşe Demir',
              email: 'ayse@paypulse.app',
              role: AppStrings.roleAdmin,
              companyId: AppStrings.defaultCompanyId,
              hasB2BAccess: true,
            ),
          ),
        );
        await tester.pump();

        appRouter.router.go(AppRoutes.businessReports);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(
          appRouter.router.routeInformationProvider.value.uri.path,
          AppRoutes.businessReports,
        );
      },
    );
  });

  group('Stateless Ekran Widget Testleri', () {
    testWidgets('SplashScreen zamanlayıcı tamamlandığında callback tetikler', (
      tester,
    ) async {
      var completed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onInitializationComplete: () => completed = true,
          ),
        ),
      );

      expect(find.text('PayPulse'), findsOneWidget);
      expect(completed, isFalse);

      await tester.pump(const Duration(milliseconds: 1850));
      await tester.pump();
      expect(completed, isTrue);
    });

    testWidgets(
      'ProfileSettingsScreen AuthBloc üzerinden dinamik kullanıcı verilerini gösterir',
      (tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final userRepo = _TestUserRepository();
        final authBloc = AuthBloc(userRepository: userRepo)
          ..add(
            const AuthUserProfileLoaded(
              UserEntity(
                uid: 'u_dyn',
                name: 'Zeynep Yıldız',
                email: 'zeynep@kurum.tr',
                role: AppStrings.roleB2C,
                customerNo: '99112233',
                iban: 'TR330006100519786457841326',
              ),
            ),
          );
        addTearDown(() async {
          await authBloc.close();
          await userRepo.dispose();
        });

        await tester.pumpWidget(
          _wrapWithProviders(
            authBloc: authBloc,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const ProfileSettingsScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Zeynep Yıldız'), findsOneWidget);
        expect(find.text('zeynep@kurum.tr'), findsOneWidget);
        expect(
          find.textContaining('99112233', findRichText: true),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'CardsManagementScreen form üzerinden Luhn ve SKT doğrulamalı yeni kart oluşturur',
      (tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final userRepo = _TestUserRepository();
        final authBloc = AuthBloc(userRepository: userRepo)
          ..add(
            const AuthUserProfileLoaded(
              UserEntity(
                uid: 'u_cards',
                name: 'Zeynep Yıldız',
                email: 'zeynep@kurum.tr',
                role: AppStrings.roleB2C,
              ),
            ),
          );
        addTearDown(() async {
          await authBloc.close();
          await userRepo.dispose();
        });

        await tester.pumpWidget(
          _wrapWithProviders(
            authBloc: authBloc,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const CardsManagementScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('ZEYNEP YILDIZ'), findsWidgets);

        await tester.tap(find.text('Yeni Kart Ekle'));
        await tester.pumpAndSettle();

        expect(find.text('Kart Numarası'), findsOneWidget);
        expect(find.text('SKT (AA/YY)'), findsOneWidget);

        final submitFinder = find.text('Sanal Kart Oluştur');
        await tester.ensureVisible(submitFinder);
        await tester.tap(submitFinder);
        await tester.pumpAndSettle();

        expect(find.textContaining('başarıyla oluşturuldu'), findsOneWidget);
      },
    );
  });

  group('QR Ödeme ve Sanal POS Layout & Render Testleri', () {
    for (final entry in <String, ThemeData>{
      'lightTheme': AppTheme.lightTheme,
      'darkTheme': AppTheme.darkTheme,
    }.entries) {
      testWidgets(
        'QrPaymentCenterScreen (${entry.key}) iki sekme, tutar chipleri ve 48sn sayaçla 0 hatayla render edilir',
        (tester) async {
          tester.view.physicalSize = const Size(430, 932);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          final userRepo = _TestUserRepository();
          final authBloc = AuthBloc(userRepository: userRepo)
            ..add(
              const AuthUserProfileLoaded(
                UserEntity(
                  uid: 'u_qr_test',
                  name: 'Deniz Aksoy',
                  email: 'deniz@paypulse.app',
                  role: AppStrings.roleB2C,
                ),
              ),
            );
          addTearDown(() async {
            await authBloc.close();
            await userRepo.dispose();
          });

          await tester.pumpWidget(
            _wrapWithProviders(
              authBloc: authBloc,
              child: MaterialApp(
                theme: entry.value,
                home: const QrPaymentCenterScreen(),
              ),
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
          expect(find.text('QR Kodumu Göster'), findsOneWidget);
          expect(find.text('QR Okut ve Öde'), findsOneWidget);
          expect(find.textContaining('00:48'), findsOneWidget);

          // Tutar chip seçimi + 2 saniyelik geri sayım tiklemesi
          await tester.ensureVisible(find.text('₺250'));
          await tester.tap(find.text('₺250'));
          await tester.pump(const Duration(seconds: 2));
          expect(tester.takeException(), isNull);
          expect(find.textContaining('00:46'), findsOneWidget);

          // QR Okut ve Öde sekmesine geçiş
          await tester.tap(find.text('QR Okut ve Öde'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.text('TR Karekod / PayPulse POS Okut'), findsOneWidget);
          expect(find.text('Çözümle & Öde'), findsOneWidget);
        },
      );
    }

    testWidgets(
      'VirtualPosTerminalScreen QR Tahsilat sekmesi 48sn dinamik QR ile hatasız render edilir',
      (tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final userRepo = _TestUserRepository();
        final authBloc = AuthBloc(userRepository: userRepo)
          ..add(
            const AuthUserProfileLoaded(
              UserEntity(
                uid: 'u_pos_admin',
                name: 'Ayşe Demir',
                email: 'ayse@paypulse.app',
                role: AppStrings.roleAdmin,
                companyId: AppStrings.defaultCompanyId,
                hasB2BAccess: true,
              ),
            ),
          );
        addTearDown(() async {
          await authBloc.close();
          await userRepo.dispose();
        });

        await tester.pumpWidget(
          _wrapWithProviders(
            authBloc: authBloc,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const VirtualPosTerminalScreen(),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('PayPulse QR Tahsilat'));
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull);
        expect(find.textContaining('00:47'), findsOneWidget);
      },
    );
  });
}
