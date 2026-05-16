// Smoke test for the design system. The full app boots through Supabase
// which we don't want to initialize from a unit test, so we mount the
// design showcase directly inside a minimal Material wrapper.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:minto/core/theme/app_theme.dart';
import 'package:minto/features/showcase/design_showcase_screen.dart';

void main() {
  testWidgets('Design showcase renders brand wordmark', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark(),
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
          home: const DesignShowcaseScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('قُرب'), findsWidgets);
  });
}
