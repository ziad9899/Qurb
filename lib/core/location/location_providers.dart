import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../prefs/prefs_providers.dart';
import 'location_repository.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository(ref.read(supabaseClientProvider));
});

/// Fixed Riyadh coordinate used when [demoLocationProvider] is on.
/// Apple reviewers test from Cupertino; without this override they would
/// see no posts because seed data is anchored to Saudi cities.
const _demoLat = 24.7136;
const _demoLng = 46.6753;

/// Holds the most recent `LocationResult` for the lifetime of the session.
/// Triggered explicitly via `ref.read(myLocationProvider.notifier).acquire()`
/// — never on app boot, so the OS prompt fires at a point the user expects.
///
/// `acquire()` is **idempotent under concurrency**: if a call is already
/// in flight (the Geolocator timeout is 8 s, so two rapid taps used to
/// queue two OS prompts and two set_my_location RPCs) the same Future is
/// returned. Surfaces an `acquiringProvider` flag so the UI can show a
/// spinner during the wait instead of leaving the "Enable location" CTA
/// looking unresponsive.
class MyLocationController extends Notifier<LocationResult?> {
  Future<LocationResult>? _inFlight;

  @override
  LocationResult? build() => null;

  Future<LocationResult> acquire() {
    final existing = _inFlight;
    if (existing != null) return existing;
    final demo = ref.read(demoLocationProvider);
    final fut = demo
        ? ref
            .read(locationRepositoryProvider)
            .setManualLocation(_demoLat, _demoLng)
        : ref.read(locationRepositoryProvider).acquireAndSync();
    _inFlight = fut;
    ref.read(locationAcquiringProvider.notifier).state = true;
    return fut.then((r) {
      state = r;
      return r;
    }).whenComplete(() {
      _inFlight = null;
      // The controller may have been disposed (autoDispose-style) before
      // the future settles — read defensively.
      try {
        ref.read(locationAcquiringProvider.notifier).state = false;
      } catch (_) {/* ref invalidated; nothing to do */}
    });
  }
}

final myLocationProvider =
    NotifierProvider<MyLocationController, LocationResult?>(
  MyLocationController.new,
);

/// True while a `MyLocationController.acquire()` is awaiting Geolocator
/// or set_my_location. The "Enable location" CTA flips to a spinner.
final locationAcquiringProvider = StateProvider<bool>((_) => false);

/// Convenience read for screens that only want the (lat, lng) when available.
({double lat, double lng})? latLngFrom(LocationResult? r) {
  if (r is LocationOk) return (lat: r.lat, lng: r.lng);
  return null;
}
