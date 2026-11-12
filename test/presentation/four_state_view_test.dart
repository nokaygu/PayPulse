import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_pulse/presentation/widgets/four_state_view.dart';

void main() {
  Future<void> showState(
    WidgetTester tester,
    ViewStatus status, {
    VoidCallback? onRetry,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FourStateView(
            status: status,
            errorMessage: 'Test hata mesajı',
            emptyMessage: 'Test boş durum mesajı',
            onRetry: onRetry,
            child: const Text('İçerik hazır'),
          ),
        ),
      ),
    );
  }

  testWidgets('Loading durumunda yüklenme göstergesi görünür', (tester) async {
    await showState(tester, ViewStatus.loading);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('İçerik hazır'), findsNothing);
    expect(find.text('Test hata mesajı'), findsNothing);
  });

  testWidgets('Error durumunda hata mesajı görünür', (tester) async {
    await showState(tester, ViewStatus.error);

    expect(find.text('Test hata mesajı'), findsOneWidget);
    expect(find.text('İçerik hazır'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Empty durumunda boş veri mesajı görünür', (tester) async {
    await showState(tester, ViewStatus.empty);

    expect(find.text('Test boş durum mesajı'), findsOneWidget);
    expect(find.text('İçerik hazır'), findsNothing);
  });

  testWidgets('Success durumunda verilen içerik görünür', (tester) async {
    await showState(tester, ViewStatus.success);

    expect(find.text('İçerik hazır'), findsOneWidget);
    expect(find.text('Test hata mesajı'), findsNothing);
    expect(find.text('Test boş durum mesajı'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Tekrar dene butonu callback çağırır', (tester) async {
    var retryCount = 0;

    await showState(
      tester,
      ViewStatus.error,
      onRetry: () {
        retryCount++;
      },
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Tekrar dene'));
    await tester.pump();

    expect(retryCount, 1);
  });

  testWidgets('Callback verilmezse tekrar dene butonu görünmez', (
    tester,
  ) async {
    await showState(tester, ViewStatus.error);

    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets('Loading sonrasında başarı içeriğine geçilir', (tester) async {
    await showState(tester, ViewStatus.loading);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await showState(tester, ViewStatus.success);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('İçerik hazır'), findsOneWidget);
  });
}
