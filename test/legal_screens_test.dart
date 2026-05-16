// Smoke tests for the three legal screens. They don't talk to Supabase so we
// can mount them directly under a Material+l10n harness without overriding
// any data providers.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:minto/core/prefs/prefs_providers.dart';
import 'package:minto/core/theme/app_theme.dart';
import 'package:minto/features/legal/community_guidelines_screen.dart';
import 'package:minto/features/legal/privacy_policy_screen.dart';
import 'package:minto/features/legal/terms_screen.dart';
import 'package:minto/l10n/generated/app_localizations.dart';

Future<void> _mount(WidgetTester tester, Widget child,
    {Locale locale = const Locale('ar')}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MaterialApp(
        theme: AppTheme.dark(),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: child,
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('TermsScreen renders title + first section above the fold',
      (tester) async {
    await _mount(tester, const TermsScreen());
    expect(find.text('شروط الاستخدام'), findsOneWidget);
    expect(find.textContaining('١. القبول'), findsOneWidget);
    expect(find.textContaining('٢. الهوية المجهولة'), findsOneWidget);
  });

  testWidgets('TermsScreen renders in English when locale is en',
      (tester) async {
    await _mount(tester, const TermsScreen(), locale: const Locale('en'));
    expect(find.text('Terms of Use'), findsOneWidget);
    expect(find.textContaining('1. Acceptance'), findsOneWidget);
  });

  testWidgets('PrivacyPolicyScreen renders intro + identity section',
      (tester) async {
    await _mount(tester, const PrivacyPolicyScreen());
    expect(find.text('سياسة الخصوصية'), findsOneWidget);
    expect(find.textContaining('هويتك'), findsWidgets);
  });

  testWidgets('CommunityGuidelinesScreen renders do/dont blocks',
      (tester) async {
    await _mount(tester, const CommunityGuidelinesScreen());
    expect(find.text('معايير المجتمع'), findsOneWidget);
    // Headings are present somewhere even though scrolled lists may
    // collapse off-screen rows on small test surfaces.
    expect(find.textContaining('مُشجَّع'), findsOneWidget);
  });
}
