import 'package:dio/dio.dart';
import 'api_config.dart';
import 'api_exception.dart';
import 'error_mapper.dart';
import 'secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio _dio;
  final _secureStorage = SecureStorageService();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    _initializeDio();
  }

  /// Initialize Dio with configuration
  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  /// Request interceptor - add auth token
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _secureStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // Silent fail - continue without token
    }
    return handler.next(options);
  }

  /// Response interceptor
  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    return handler.next(response);
  }

  /// Error interceptor - handle 401, token refresh, etc.
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 - token expired
    if (error.response?.statusCode == 401) {
      final err = error.response?.data is Map ? error.response?.data['error']?.toString() : null;
      if (err == 'TokenExpired') {
        try {
          final refreshed = await _refreshToken();
          if (refreshed) {
            return handler.resolve(
              await _dio.request(
                error.requestOptions.path,
                options: Options(method: error.requestOptions.method, headers: error.requestOptions.headers),
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              ),
            );
          }
        } catch (_) {}
      }
      if (err == 'AccountSuspended' || err == 'RefreshTokenInvalid') {
        await _secureStorage.clearAuthData();
      }
    }

    return handler.next(error);
  }

  /// Refresh access token using refresh token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      // Create new Dio instance without interceptors to avoid recursion
      final tempDio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
        ),
      );

        final response = await tempDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'] as String?;
        final newRefreshToken = response.data['refreshToken'] as String?;

        if (newAccessToken != null) {
          await _secureStorage.saveAccessToken(newAccessToken);
          if (newRefreshToken != null) {
            await _secureStorage.saveRefreshToken(newRefreshToken);
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ErrorMapper.mapDioException(e);
    } catch (e) {
      throw ApiException(
        message: 'An unexpected error occurred',
        originalException: e,
      );
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ErrorMapper.mapDioException(e);
    } catch (e) {
      throw ApiException(
        message: 'An unexpected error occurred',
        originalException: e,
      );
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ErrorMapper.mapDioException(e);
    } catch (e) {
      throw ApiException(
        message: 'An unexpected error occurred',
        originalException: e,
      );
    }
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ErrorMapper.mapDioException(e);
    } catch (e) {
      throw ApiException(
        message: 'An unexpected error occurred',
        originalException: e,
      );
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ErrorMapper.mapDioException(e);
    } catch (e) {
      throw ApiException(
        message: 'An unexpected error occurred',
        originalException: e,
      );
    }
  }

  /// Get the Dio instance directly if needed
  Dio get dio => _dio;

  /// Get secure storage instance
  SecureStorageService get secureStorage => _secureStorage;
}
