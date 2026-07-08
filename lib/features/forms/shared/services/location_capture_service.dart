import 'package:geolocator/geolocator.dart';

import 'app_permission_service.dart';
import 'location_reverse_geocode_service.dart';

class LocationCaptureResult {
  const LocationCaptureResult._({
    this.latitude,
    this.longitude,
    this.address,
    this.capturedAt,
    this.errorMessage,
    this.permissionDenied = false,
    this.permanentlyDenied = false,
    this.servicesDisabled = false,
  });

  const LocationCaptureResult.success({
    required double latitude,
    required double longitude,
    required String address,
    required DateTime capturedAt,
  }) : this._(
          latitude: latitude,
          longitude: longitude,
          address: address,
          capturedAt: capturedAt,
        );

  const LocationCaptureResult.error(
    String message, {
    bool permissionDenied = false,
    bool permanentlyDenied = false,
    bool servicesDisabled = false,
  }) : this._(
          errorMessage: message,
          permissionDenied: permissionDenied,
          permanentlyDenied: permanentlyDenied,
          servicesDisabled: servicesDisabled,
        );

  final double? latitude;
  final double? longitude;
  final String? address;
  final DateTime? capturedAt;
  final String? errorMessage;
  final bool permissionDenied;
  final bool permanentlyDenied;
  final bool servicesDisabled;

  bool get isSuccess => latitude != null && longitude != null;
}

class LocationCaptureService {
  LocationCaptureService._();

  static Future<LocationCaptureResult> captureCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationCaptureResult.error(
        'Location services are turned off. Enable GPS in system settings, then try again.',
        servicesDisabled: true,
      );
    }

    final permission = await AppPermissionService.requestLocation();
    if (!permission.granted) {
      return LocationCaptureResult.error(
        permission.permanentlyDenied
            ? 'Location access is blocked. Open app settings to allow location while using the app.'
            : 'Location access was denied. Allow location to record the inspection site.',
        permissionDenied: true,
        permanentlyDenied: permission.permanentlyDenied,
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );

      final address = await LocationReverseGeocodeService.resolveAddress(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!LocationReverseGeocodeService.isUsableAddress(address)) {
        return const LocationCaptureResult.error(
          'Could not resolve the site address. Check internet connection and try again.',
        );
      }

      return LocationCaptureResult.success(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        capturedAt: position.timestamp,
      );
    } on LocationServiceDisabledException {
      return const LocationCaptureResult.error(
        'Location services are turned off. Enable GPS in system settings, then try again.',
        servicesDisabled: true,
      );
    } on PermissionDeniedException {
      return const LocationCaptureResult.error(
        'Location access was denied. Allow location to record the inspection site.',
        permissionDenied: true,
      );
    } catch (error) {
      return LocationCaptureResult.error('Could not get location: $error');
    }
  }
}
