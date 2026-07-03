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
    super.message = 'Unauthorized - Please login again',
    super.originalException,
    super.stackTrace,
  }) : super(
         statusCode: 401,
       );
}

class ForbiddenException extends ApiException {
  ForbiddenException({
    super.message = 'Forbidden - Access denied',
    super.originalException,
    super.stackTrace,
  }) : super(
         statusCode: 403,
       );
}

class NotFoundException extends ApiException {
  NotFoundException({
    super.message = 'Resource not found',
    super.originalException,
    super.stackTrace,
  }) : super(
         statusCode: 404,
       );
}

class ServerException extends ApiException {
  ServerException({
    super.message = 'Server error - Please try again later',
    int? statusCode,
    super.originalException,
    super.stackTrace,
  }) : super(
         statusCode: statusCode ?? 500,
       );
}

class NetworkException extends ApiException {
  NetworkException({
    super.message = 'Network error - Please check your connection',
    super.originalException,
    super.stackTrace,
  }) : super(
         statusCode: null,
       );
}

class TimeoutException extends ApiException {
  TimeoutException({
    super.message = 'Request timeout - Please try again',
    super.originalException,
    super.stackTrace,
  }) : super(
         statusCode: null,
       );
}
