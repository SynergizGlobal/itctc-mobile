import 'package:flutter/material.dart';

import '../errors/app_exception.dart';
import 'dialog_service.dart';

class ErrorHandler {
  ErrorHandler._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void initialize() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
    };
  }

  static void handle(Object error, {StackTrace? stackTrace, VoidCallback? onRetry}) {
    final message = _resolveMessage(error);
    final title = _resolveTitle(error);

    DialogService.showError(
      title: title,
      message: message,
      onRetry: onRetry,
    );
  }

  static String _resolveMessage(Object error) {
    if (error is AppException) return error.message;
    return 'An unexpected error occurred. Please try again.';
  }

  static String _resolveTitle(Object error) {
    return switch (error) {
      NetworkException() => 'Connection Error',
      TimeoutException() => 'Timeout',
      ServerException() => 'Server Error',
      ValidationException() => 'Validation Error',
      CacheException() => 'Storage Error',
      _ => 'Error',
    };
  }
}
