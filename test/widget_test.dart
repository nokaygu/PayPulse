import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PayPulse temel widget duman testi', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('PayPulse FinTech'))),
      ),
    );

    expect(find.text('PayPulse FinTech'), findsOneWidget);
  });
}
