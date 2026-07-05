import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ascento_abacus/app.dart';
import 'package:ascento_abacus/core/services/storage_service.dart';

void main() {
  testWidgets('Splash view renders and prepares boots sequence', (WidgetTester tester) async {
    // Mock the SharedPreferences for clean isolated tests
    SharedPreferences.setMockInitialValues({
      'theme_mode': 'light',
      'onboarding_done': false,
      'levels_completed': 0,
      'total_stars': 0,
    });

    final sharedPrefs = await SharedPreferences.getInstance();

    // Pump the app with simulated Riverpod overrides
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        ],
        child: const MyApp(),
      ),
    );

    // Re-render layout frames and let GoRouter async initialization settle
    await tester.pump();
    await tester.pump();
    await tester.pump();

    // Verify splash sequence elements are present
    expect(find.text('Ascento Abacus'), findsOneWidget);
    expect(find.text('MIND OVER MATH'), findsOneWidget);

    // Verify Bootloader progress bar is rendered
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    // Let the asynchronous splash delays and timers finish cleanly
    await tester.pump(const Duration(seconds: 5));
  });
}
