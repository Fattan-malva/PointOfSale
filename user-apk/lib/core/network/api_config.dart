/// API Configuration
class ApiConfig {
  static const String baseUrl =
      'http://localhost:3000/api'; // Change in production
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
