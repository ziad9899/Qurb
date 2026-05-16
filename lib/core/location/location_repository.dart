import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Outcome of a location request. The repository never throws — it returns
/// a discriminated result so the UI can render an explanatory state instead
/// of an unhandled exception.
sealed class LocationResult {
  const LocationResult();
}

class LocationOk extends LocationResult {
  const LocationOk(this.lat, this.lng, {this.accuracyM});
  final double lat;
  final double lng;
  final double? accuracyM;
}

class LocationDenied extends LocationResult {
  const LocationDenied({this.permanent = false});
  final bool permanent;
}

class LocationServiceOff extends LocationResult {
  const LocationServiceOff();
}

class LocationUnavailable extends LocationResult {
  const LocationUnavailable(this.reason);
  final String reason;
}

class LocationRepository {
  LocationRepository(this._client);
  final SupabaseClient _client;

  /// Acquires permission (asks the OS if needed), reads the current position,
  /// and pushes it to the server (which snaps to a 100 m grid before storing).
  Future<LocationResult> acquireAndSync() async {
    final serviceOn = await Geolocator.isLocationServiceEnabled();
    if (!serviceOn) return const LocationServiceOff();

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      return const LocationDenied(permanent: true);
    }
    if (perm == LocationPermission.denied) {
      return const LocationDenied();
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      await _client.rpc('set_my_location', params: {
        'p_lat': pos.latitude,
        'p_lng': pos.longitude,
      });
      return LocationOk(pos.latitude, pos.longitude, accuracyM: pos.accuracy);
    } catch (e) {
      return LocationUnavailable(e.toString());
    }
  }

  /// Bypasses GPS and pushes a fixed coordinate to `set_my_location`.
  /// Used by the demo-location override (Settings) so Apple reviewers
  /// in Cupertino reach a populated Saudi feed without granting GPS.
  Future<LocationResult> setManualLocation(double lat, double lng) async {
    try {
      await _client.rpc('set_my_location', params: {
        'p_lat': lat,
        'p_lng': lng,
      });
      return LocationOk(lat, lng);
    } catch (e) {
      return LocationUnavailable(e.toString());
    }
  }

  /// Reads only — no permission prompt. Returns null if not yet granted.
  Future<({double lat, double lng})?> peekCurrent() async {
    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return null;
    }
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 4),
        ),
      );
      return (lat: pos.latitude, lng: pos.longitude);
    } catch (_) {
      return null;
    }
  }
}
