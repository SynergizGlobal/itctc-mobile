import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:itctc/features/forms/shared/utils/location_address_formatter.dart';

void main() {
  test('formats placemark into readable address', () {
    final address = LocationAddressFormatter.fromPlacemark(
      Placemark(
        name: 'NHSRCL Site Office',
        street: '12 Rail Marg',
        subLocality: 'Sector 18',
        locality: 'Noida',
        administrativeArea: 'Uttar Pradesh',
        postalCode: '201301',
        country: 'India',
      ),
    );

    expect(address, contains('NHSRCL Site Office'));
    expect(address, contains('Noida'));
    expect(address, contains('India'));
    expect(address, isNot(contains('28.')));
  });
}
