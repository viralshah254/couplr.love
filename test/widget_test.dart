// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can use WidgetTester
// to find child widgets in the widget tree, send tap and scroll gestures, and
// verify that widget properties are correct.

import 'package:couplr/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Couplr app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CouplrApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
