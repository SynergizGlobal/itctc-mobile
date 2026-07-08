import 'package:geocoding/geocoding.dart';

class LocationAddressFormatter {
  LocationAddressFormatter._();

  static String fromPlacemark(Placemark place) {
    final parts = <String>[];

    void add(String? value) {
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty) return;
      if (parts.contains(trimmed)) return;
      parts.add(trimmed);
    }

    final thoroughfare = [
      if (place.subThoroughfare?.trim().isNotEmpty == true) place.subThoroughfare!.trim(),
      if (place.thoroughfare?.trim().isNotEmpty == true) place.thoroughfare!.trim(),
    ].join(' ');

    add(thoroughfare.isNotEmpty ? thoroughfare : null);
    add(place.street);
    add(place.name);
    add(place.subLocality);
    add(place.locality);
    add(place.subAdministrativeArea);
    add(place.administrativeArea);
    add(place.postalCode);
    add(place.country);

    return parts.join(', ');
  }
}
