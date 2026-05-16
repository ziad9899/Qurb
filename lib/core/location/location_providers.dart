import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'location_repository.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository(ref.read(supabaseClientProvider));
});

/// Holds the most recent `LocationResult` for the lifetime of the session.
/// Triggered explicitly via `ref.read(myLocationProvider.notifier).acquire()`
/// — never on app boot, so the OS prompt fires at a point the user expects.
class MyLocationController extends Notifier<LocationResult?> {
  @override
  LocationResult? build() => null;

  Future<LocationResult> acquire() async {
    final r = await ref.read(locationRepositoryProvider).acquireAndSync();
    state = r;
    return r;
  }
}

final myLocationProvider =
    NotifierProvider<MyLocationController, LocationResult?>(
  MyLocationController.new,
);

/// Convenience read for screens that only want the (lat, lng) when available.
({double lat, double lng})? latLngFrom(LocationResult? r) {
  if (r is LocationOk) return (lat: r.lat, lng: r.lng);
  return null;
}
