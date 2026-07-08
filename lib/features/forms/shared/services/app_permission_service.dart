import 'package:permission_handler/permission_handler.dart';

class AppPermissionService {
  AppPermissionService._();

  static Future<PermissionOutcome> requestLocation() async {
    return _request(Permission.locationWhenInUse);
  }

  static Future<PermissionOutcome> requestCamera() async {
    return _request(Permission.camera);
  }

  static Future<PermissionOutcome> _request(Permission permission) async {
    final current = await permission.status;
    if (current.isGranted) {
      return const PermissionOutcome.granted();
    }
    if (current.isPermanentlyDenied || current.isRestricted) {
      return const PermissionOutcome.permanentlyDenied();
    }

    final result = await permission.request();
    if (result.isGranted) {
      return const PermissionOutcome.granted();
    }
    if (result.isPermanentlyDenied || result.isRestricted) {
      return const PermissionOutcome.permanentlyDenied();
    }
    return const PermissionOutcome.denied();
  }

  static Future<bool> openSettings() => openAppSettings();
}

class PermissionOutcome {
  const PermissionOutcome.granted()
      : granted = true,
        permanentlyDenied = false;

  const PermissionOutcome.denied()
      : granted = false,
        permanentlyDenied = false;

  const PermissionOutcome.permanentlyDenied()
      : granted = false,
        permanentlyDenied = true;

  final bool granted;
  final bool permanentlyDenied;
}
