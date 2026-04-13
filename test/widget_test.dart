import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jmixviewer/main.dart';
import 'package:jmixviewer/pages/splash_page.dart';

void main() {
  testWidgets('Splash shows loader then navigates to login', (WidgetTester tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);

    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    expect(find.text('JMIX Viewer'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(SplashPage.displayDuration);
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Connect to Foodie'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
