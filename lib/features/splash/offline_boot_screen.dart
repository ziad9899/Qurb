import 'package:flutter/material.dart';

/// Last-resort UI when Supabase.initialize fails at boot (no network,
/// DNS failure, server outage). Without this the app would render a
/// black screen forever because runApp is never reached from main().
///
/// Intentionally self-contained — no Riverpod, no l10n delegates, no
/// theme — because any of those could be the thing that failed.
class OfflineBootScreen extends StatelessWidget {
  const OfflineBootScreen({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0C0D10),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD84D),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.wifi_off_rounded,
                      size: 30, color: Color(0xFF1A1300)),
                ),
                const SizedBox(height: 22),
                // Bilingual on purpose — we don't know which locale
                // the user expects since AppLocalizations isn't loaded.
                const Text(
                  'تعذّر الاتصال بالخوادم',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFF1F3F5),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Couldn't connect to Qurb servers",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFAAB2BD),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 48,
                  width: 220,
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD84D),
                      foregroundColor: const Color(0xFF1A1300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'إعادة المحاولة · Retry',
                      style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
