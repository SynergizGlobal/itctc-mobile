import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';

import '../utils/location_address_formatter.dart';

class LocationReverseGeocodeService {
  LocationReverseGeocodeService._();

  static const unavailableLabel = 'Address unavailable';

  static Future<String> resolveAddress({
    required double latitude,
    required double longitude,
  }) async {
    final native = await _fromNativeGeocoder(latitude, longitude);
    if (isUsableAddress(native)) return native!;

    final online = await _fromNominatim(latitude, longitude);
    if (isUsableAddress(online)) return online!;

    return unavailableLabel;
  }

  static bool isUsableAddress(String? address) {
    if (address == null) return false;
    final trimmed = address.trim();
    if (trimmed.isEmpty) return false;
    return trimmed.toLowerCase() != unavailableLabel.toLowerCase();
  }

  static Future<String?> _fromNativeGeocoder(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      for (final placemark in placemarks) {
        final formatted = LocationAddressFormatter.fromPlacemark(placemark);
        if (isUsableAddress(formatted)) return formatted;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  static Future<String?> _fromNominatim(
    double latitude,
    double longitude,
  ) async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 12),
          headers: const {
            'User-Agent': 'itctc-mobile/1.0 (NHSRCL field inspection)',
          },
        ),
      );

      final response = await dio.get<Map<String, dynamic>>(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'format': 'json',
          'addressdetails': 1,
        },
      );

      final displayName = response.data?['display_name']?.toString().trim();
      if (isUsableAddress(displayName)) return displayName;

      final address = response.data?['address'];
      if (address is Map) {
        final formatted = _formatNominatimAddress(Map<String, dynamic>.from(address));
        if (isUsableAddress(formatted)) return formatted;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  static String _formatNominatimAddress(Map<String, dynamic> address) {
    final parts = <String>[];

    void add(String key) {
      final value = address[key]?.toString().trim();
      if (value == null || value.isEmpty) return;
      if (parts.contains(value)) return;
      parts.add(value);
    }

    add('road');
    add('neighbourhood');
    add('suburb');
    add('city');
    add('county');
    add('state');
    add('postcode');
    add('country');

    return parts.join(', ');
  }
}
