# Qurb · قُرب

Anonymous, location-based community app for Arabic-speaking users. Built with Flutter + Supabase.

## Stack
- **Flutter** 3.32 · Riverpod · go_router · official gen-l10n (AR/EN)
- **Supabase** Postgres 16 + PostGIS 3.3 · Realtime · SECURITY DEFINER RPCs · RLS

## Privacy by design
- Anonymous sign-in only — no name, email, or phone collected
- GPS snapped to a **100m grid cell** before leaving the device
- Posts visible to nearby users via PostGIS `posts_near` RPC (radius keyed by feed filter)
- Whispers are private 1:1 chats with TLS in transit + disk encryption at rest
- Server-side moderation (stopwords + spam regex + rate limits + ban enforcement)

## Project layout
```
lib/
  core/         theme, auth, location, prefs, router, widgets
  features/
    feed/       posts, comments (threaded), composer, post owner ops
    whispers/   1:1 chats with realtime delivery
    explore/    discovery + trending tags
    profile/    settings, blocks, my content, account deletion
    legal/      Privacy Policy, Terms of Use, Community Guidelines
supabase/
  migrations/   001..013 — schema, RPCs, RLS, geo, moderation
docs/
  privacy.html  Public bilingual privacy policy (enable GitHub Pages)
ios/Runner/
  PrivacyInfo.xcprivacy
  {ar,en}.lproj/InfoPlist.strings
```

## Running
```bash
flutter pub get
flutter run -d chrome        # or any device
flutter analyze
flutter test
```

## License
Proprietary — all rights reserved.
