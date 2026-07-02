import 'dart:io';

import 'package:dio/dio.dart';
import 'api_exception.dart';

class ErrorMapper {
  /// Map Dio exception to custom ApiException
  static ApiException mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.transformTimeout:
        return TimeoutException(
          originalException: error,
          stackTrace: error.stackTrace,
        );

      case DioExceptionType.badResponse:
        return _mapResponseError(error);

      case DioExceptionType.connectionError:
        return NetworkException(
          originalException: error,
          stackTrace: error.stackTrace,
        );

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return NetworkException(
            originalException: error,
            stackTrace: error.stackTrace,
          );
        }
        return ApiException(
          message: error.message ?? 'Unknown error occurred',
          originalException: error,
          stackTrace: error.stackTrace,
        );

      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
        return ApiException(
          message: error.message ?? 'Request cancelled',
          originalException: error,
          stackTrace: error.stackTrace,
        );
    }
  }

  /// Map HTTP response error based on status code
  static ApiException _mapResponseError(DioException error) {
    final statusCode = error.response?.statusCode ?? 0;
    final responseData = error.response?.data as Map<String, dynamic>?;
    final errorMessage =
        responseData?['message'] as String? ??
        responseData?['error'] as String? ??
        'An error occurred';

    switch (statusCode) {
      case 400:
        return ApiException(
          message: errorMessage,
          statusCode: 400,
          originalException: error,
          stackTrace: error.stackTrace,
        );

      case 401:
        return UnauthorizedException(
          message: errorMessage,
          originalException: error,
          stackTrace: error.stackTrace,
        );

      case 403:
        return ForbiddenException(
          message: errorMessage,
          originalException: error,
          stackTrace: error.stackTrace,
        );

      case 404:
        return NotFoundException(
          message: errorMessage,
          originalException: error,
          stackTrace: error.stackTrace,
        );

      case 422:
        // Validation error
        final errors = responseData?['errors'] as Map<String, dynamic>?;
        final validationMessage = _formatValidationErrors(errors);
        return ApiException(
          message: validationMessage,
          statusCode: 422,
          originalException: error,
          stackTrace: error.stackTrace,
        );

      case >= 500:
        return ServerException(
          message: errorMessage,
          statusCode: statusCode,
          originalException: error,
          stackTrace: error.stackTrace,
        );

      default:
        return ApiException(
          message: errorMessage,
          statusCode: statusCode,
          originalException: error,
          stackTrace: error.stackTrace,
        );
    }
  }

  /// Format validation errors from API response
  static String _formatValidationErrors(Map<String, dynamic>? errors) {
    if (errors == null || errors.isEmpty) {
      return 'Validation error';
    }

    final errorMessages = <String>[];
    errors.forEach((field, messages) {
      if (messages is List) {
        for (final msg in messages) {
          errorMessages.add('$field: $msg');
        }
      } else {
        errorMessages.add('$field: $messages');
      }
    });

    return errorMessages.join('\n');
  }

  /// Get user-friendly error message
  static String getUserFriendlyMessage(ApiException exception) {
    return exception.message;
  }
}

// For compatibility with network exceptions
class SocketException implements Exception {
  final String message;
  SocketException(this.message);
}
