// Smoke test for the design system. The full app boots through Supabase
// which we don't want to initialize from a unit test, so we mount the
// design showcase directly inside a minimal Material wrapper.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:minto/core/prefs/prefs_providers.dart';
import 'package:minto/core/theme/app_theme.dart';
import 'package:minto/features/showcase/design_showcase_screen.dart';
import 'package:minto/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('Design showcase renders brand wordmark', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const DesignShowcaseScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('قُرب'), findsWidgets);
  });
}
