// Verifies the welcome-screen age gate: the "create my ID" button stays
// disabled until the 13+ checkbox is ticked. We don't exercise the actual
// sign-in (that touches Supabase) — only the UI state machine.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:minto/core/prefs/prefs_providers.dart';
import 'package:minto/core/theme/app_theme.dart';
import 'package:minto/features/welcome/welcome_screen.dart';
import 'package:minto/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('CTA is disabled until the age checkbox is ticked',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          theme: AppTheme.dark(),
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const WelcomeScreen(),
        ),
      ),
    );
    await tester.pump();

    // The CTA exists.
    final cta = find.byType(ElevatedButton);
    expect(cta, findsOneWidget);

    // Initially the button is disabled (onPressed: null) because the age
    // gate hasn't been confirmed.
    final initial = tester.widget<ElevatedButton>(cta);
    expect(initial.onPressed, isNull);

    // The age-confirm sentence is visible.
    expect(
      find.textContaining('أؤكد أن عمري ١٣ سنة فأكثر'),
      findsOneWidget,
    );

    // Tap the checkbox row (the row is wrapped in a GestureDetector that
    // toggles state on tap).
    await tester.tap(find.textContaining('أؤكد أن عمري'));
    await tester.pump();

    // After ticking, the CTA is enabled.
    final enabled = tester.widget<ElevatedButton>(cta);
    expect(enabled.onPressed, isNotNull);
  });
}
