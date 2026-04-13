import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Debug-only logging for most channels. Business operation failures can also
/// be forwarded via `BusinessOps.onError` in `business_ops.dart`.
abstract final class AppLogger {
  AppLogger._();

  static void _emit(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  /// Business operation started (debug only). Pair with [logBusinessDone].
  static void logBusinessStart(String name) {
    if (!kDebugMode) return;
    _emit('[BIZ] -> $name');
  }

  /// Business operation finished (debug only).
  static void logBusinessDone(String name, Duration elapsed) {
    if (!kDebugMode) return;
    final ms = elapsed.inMilliseconds;
    _emit('[BIZ] <- $name (${ms}ms)');
  }

  /// Uncaught failure inside [BusinessOps]. Debug: full message + stack.
  /// Also use [BusinessOps.onError] for release crash reporting.
  static void logBusinessError(String name, Object error, StackTrace stack) {
    if (!kDebugMode) return;
    _emit('[BIZ] !! $name: $error');
    _emit(stack.toString());
  }

  /// Logs the resolved URL for an outgoing Dio request (method + full URI).
  static void logHttpRequest(RequestOptions options) {
    if (!kDebugMode) return;
    final method = options.method.toUpperCase();
    _emit('[HTTP] $method ${options.uri}');
  }

  /// Logs a navigation event: [type] (push, pop, replace, remove) and path from → to.
  static void logNavigation(String type, String from, String to) {
    if (!kDebugMode) return;
    _emit('[NAV] $type: $from → $to');
  }

  /// Logs a user-triggered action (debug only), e.g. sidebar select or paging.
  /// Use a stable [name] such as `home.selectEntity`; optional [detail] for context.
  /// Do not use for taps whose only effect is [Navigator]/GoRouter navigation—those show as [NAV].
  static void logUserAction(String name, [String? detail]) {
    if (!kDebugMode) return;
    if (detail != null && detail.isNotEmpty) {
      _emit('[ACTION] $name — $detail');
    } else {
      _emit('[ACTION] $name');
    }
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
