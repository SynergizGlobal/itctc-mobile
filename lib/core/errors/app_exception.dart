sealed class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code, this.statusCode});

  final int? statusCode;
}

class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timed out. Please try again.']);
}

class CacheException extends AppException {
  const CacheException(super.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message, {this.fieldErrors = const {}});

  final Map<String, String> fieldErrors;
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'Something went wrong. Please try again.']);
}
