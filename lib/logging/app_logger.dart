import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Debug-only logging. No output in profile or release builds.
abstract final class AppLogger {
  AppLogger._();

  static void _emit(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  /// Logs the resolved URL for an outgoing Dio request (method + full URI).
  static void logHttpRequest(RequestOptions options) {
    if (!kDebugMode) return;
    final method = options.method.toUpperCase();
    _emit('[HTTP] $method ${options.uri}');
  }
}

/// Attaches to Dio: logs each request URL in debug mode only.
final class HttpRequestUrlInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.logHttpRequest(options);
    handler.next(options);
  }
}
