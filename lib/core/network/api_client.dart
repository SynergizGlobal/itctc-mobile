import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import 'api_endpoints.dart';
import 'network_interceptor.dart';

class ApiClient {
  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiEndpoints.baseUrl,
                connectTimeout: AppConstants.apiConnectTimeout,
                receiveTimeout: AppConstants.apiTimeout,
                sendTimeout: AppConstants.apiTimeout,
              ),
            ) {
    _dio.interceptors.addAll([
      NetworkInterceptor(),
      if (kDebugMode)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
        ),
    ]);
  }

  final Dio _dio;

  Dio get dio => _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? parser,
  }) async {
    return _execute(
      () => _dio.get(path, queryParameters: queryParameters),
      parser: parser,
    );
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? parser,
  }) async {
    return _execute(
      () => _dio.post(path, data: data, queryParameters: queryParameters),
      parser: parser,
    );
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic data)? parser,
  }) async {
    return _execute(
      () => _dio.put(path, data: data),
      parser: parser,
    );
  }

  Future<T> delete<T>(
    String path, {
    T Function(dynamic data)? parser,
  }) async {
    return _execute(
      () => _dio.delete(path),
      parser: parser,
    );
  }

  Future<T> _execute<T>(
    Future<Response<dynamic>> Function() request, {
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await request();
      final data = response.data;

      if (parser != null) {
        return parser(data);
      }
      return data as T;
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  AppException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException(
          'No internet connection. Please check your network.',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = _extractErrorMessage(e.response?.data) ??
            'Server error occurred (${statusCode ?? 'unknown'}).';
        return ServerException(message, statusCode: statusCode);
      case DioExceptionType.cancel:
        return const NetworkException('Request was cancelled.');
      case DioExceptionType.badCertificate:
        return const NetworkException('Security certificate error.');
      case DioExceptionType.unknown:
        return NetworkException(
          e.message ?? 'Network error occurred.',
        );
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map) {
      return data['message'] as String? ??
          data['error'] as String? ??
          data['detail'] as String?;
    }
    if (data is String && data.isNotEmpty) return data;
    return null;
  }
}

final apiClientProvider = ApiClient();
