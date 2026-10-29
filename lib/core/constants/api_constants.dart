abstract final class ApiConstants {
  static const baseUrl = 'https://dummyjson.com';
  static const loginPath = '/auth/login';
  static const refreshPath = '/auth/refresh';
  static const productsPath = '/products';

  /// Lifetime requested for access tokens on login and refresh.
  static const sessionMinutes = 60;

  static const pageSize = 12;
  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 20);

  static const demoUsername = 'emilys';
  static const demoPassword = 'emilyspass';
}
