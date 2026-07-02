class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalException;
  final StackTrace? stackTrace;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({
    String message = 'Unauthorized - Please login again',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         statusCode: 401,
         originalException: originalException,
         stackTrace: stackTrace,
       );
}

class ForbiddenException extends ApiException {
  ForbiddenException({
    String message = 'Forbidden - Access denied',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         statusCode: 403,
         originalException: originalException,
         stackTrace: stackTrace,
       );
}

class NotFoundException extends ApiException {
  NotFoundException({
    String message = 'Resource not found',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         statusCode: 404,
         originalException: originalException,
         stackTrace: stackTrace,
       );
}

class ServerException extends ApiException {
  ServerException({
    String message = 'Server error - Please try again later',
    int? statusCode,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         statusCode: statusCode ?? 500,
         originalException: originalException,
         stackTrace: stackTrace,
       );
}

class NetworkException extends ApiException {
  NetworkException({
    String message = 'Network error - Please check your connection',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         statusCode: null,
         originalException: originalException,
         stackTrace: stackTrace,
       );
}

class TimeoutException extends ApiException {
  TimeoutException({
    String message = 'Request timeout - Please try again',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         statusCode: null,
         originalException: originalException,
         stackTrace: stackTrace,
       );
}
