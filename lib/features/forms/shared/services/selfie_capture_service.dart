import 'package:image_picker/image_picker.dart';

import 'app_permission_service.dart';

class SelfieCaptureResult {
  const SelfieCaptureResult._({
    this.filePath,
    this.fileName,
    this.errorMessage,
    this.cancelled = false,
    this.permissionDenied = false,
    this.permanentlyDenied = false,
  });

  const SelfieCaptureResult.success({
    required String filePath,
    required String fileName,
  }) : this._(
          filePath: filePath,
          fileName: fileName,
        );

  const SelfieCaptureResult.cancelled() : this._(cancelled: true);

  const SelfieCaptureResult.error(
    String message, {
    bool permissionDenied = false,
    bool permanentlyDenied = false,
  }) : this._(
          errorMessage: message,
          permissionDenied: permissionDenied,
          permanentlyDenied: permanentlyDenied,
        );

  final String? filePath;
  final String? fileName;
  final String? errorMessage;
  final bool cancelled;
  final bool permissionDenied;
  final bool permanentlyDenied;

  bool get isSuccess => filePath != null && filePath!.isNotEmpty;
}

class SelfieCaptureService {
  SelfieCaptureService._();

  static final ImagePicker _picker = ImagePicker();

  static Future<SelfieCaptureResult> captureFrontSelfie() async {
    final permission = await AppPermissionService.requestCamera();
    if (!permission.granted) {
      return SelfieCaptureResult.error(
        permission.permanentlyDenied
            ? 'Camera access is blocked. Open app settings to allow the camera for selfies.'
            : 'Camera access was denied. Allow the camera to take an inspector selfie.',
        permissionDenied: true,
        permanentlyDenied: permission.permanentlyDenied,
      );
    }

    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
        maxWidth: 1920,
      );

      if (image == null) {
        return const SelfieCaptureResult.cancelled();
      }

      final path = image.path;
      if (path.isEmpty) {
        return const SelfieCaptureResult.error('Could not read the captured selfie.');
      }

      return SelfieCaptureResult.success(
        filePath: path,
        fileName: image.name.isNotEmpty ? image.name : 'selfie.jpg',
      );
    } catch (error) {
      return SelfieCaptureResult.error('Could not open the camera: $error');
    }
  }
}
