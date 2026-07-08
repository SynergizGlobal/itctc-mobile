import 'form_attachment.dart';

class FormSiteCapture {
  FormSiteCapture({
    this.latitude,
    this.longitude,
    this.locationAddress,
    this.locationCapturedAt,
    this.selfie,
  });

  double? latitude;
  double? longitude;
  String? locationAddress;
  DateTime? locationCapturedAt;
  FormAttachment? selfie;

  bool get hasLocation =>
      latitude != null &&
      longitude != null &&
      locationAddress != null &&
      locationAddress!.trim().isNotEmpty;

  bool get hasSelfie => selfie != null;

  bool get isComplete => hasLocation && hasSelfie;

  factory FormSiteCapture.fromMap(Map<String, dynamic>? data) {
    if (data == null) return FormSiteCapture();

    DateTime? capturedAt;
    final rawCapturedAt = data['locationCapturedAt'];
    if (rawCapturedAt is String && rawCapturedAt.isNotEmpty) {
      capturedAt = DateTime.tryParse(rawCapturedAt);
    }

    FormAttachment? selfie;
    final rawSelfie = data['selfie'];
    if (rawSelfie is Map) {
      final parsed = FormAttachment.fromMap(Map<String, dynamic>.from(rawSelfie));
      if (parsed.id.isNotEmpty && parsed.path.isNotEmpty) {
        selfie = parsed;
      }
    }

    return FormSiteCapture(
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      locationAddress: data['locationAddress']?.toString(),
      locationCapturedAt: capturedAt,
      selfie: selfie,
    );
  }

  Map<String, dynamic> toJson() => {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (locationAddress != null && locationAddress!.isNotEmpty)
          'locationAddress': locationAddress,
        if (locationCapturedAt != null)
          'locationCapturedAt': locationCapturedAt!.toIso8601String(),
        if (selfie != null) 'selfie': selfie!.toJson(),
      };

  void applyFrom(FormSiteCapture other) {
    latitude = other.latitude;
    longitude = other.longitude;
    locationAddress = other.locationAddress;
    locationCapturedAt = other.locationCapturedAt;
    selfie = other.selfie;
  }
}

String siteCaptureLocationSummary(FormSiteCapture capture) {
  if (!capture.hasLocation) return '—';

  final address = capture.locationAddress?.trim();
  if (address != null && address.isNotEmpty) {
    return address;
  }

  return '—';
}

String siteCaptureSelfieSummary(FormSiteCapture capture) {
  if (!capture.hasSelfie) return '—';
  return capture.selfie!.name;
}
