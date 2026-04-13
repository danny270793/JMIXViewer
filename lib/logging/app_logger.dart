import 'dart:convert';

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

  /// Logs a completed Dio call: status, duration, method, full URI (debug only).
  /// For POST/PUT/PATCH, logs [requestBody] on the following line(s) when non-null.
  static void logHttpCompleted({
    required int? statusCode,
    required int elapsedMs,
    required String method,
    required Uri uri,
    Object? requestBody,
  }) {
    if (!kDebugMode) return;
    final m = method.toUpperCase();
    final code = statusCode?.toString() ?? '—';
    _emit('[HTTP] $code ${elapsedMs}ms $m $uri');
    if (requestBody != null &&
        (m == 'POST' || m == 'PUT' || m == 'PATCH')) {
      final formatted = _formatHttpRequestBodyForLog(requestBody);
      if (formatted.isNotEmpty) {
        _emit('[HTTP] body:\n$formatted');
      }
    }
  }

  static String _formatHttpRequestBodyForLog(Object data) {
    try {
      if (data is String) {
        return _truncateHttpLog(data);
      }
      if (data is Map || data is List) {
        return _truncateHttpLog(
          const JsonEncoder.withIndent('  ').convert(data),
        );
      }
      if (data is FormData) {
        final buf = StringBuffer();
        for (final e in data.fields) {
          buf.writeln('${e.key}: ${e.value}');
        }
        if (data.files.isNotEmpty) {
          buf.writeln('(${data.files.length} file(s))');
        }
        return _truncateHttpLog(buf.isEmpty ? '(empty FormData)' : buf.toString());
      }
      return _truncateHttpLog(data.toString());
    } catch (e) {
      return _truncateHttpLog('<body log error: $e>');
    }
  }

  /// Debug: logs response body when Dio fails ([DioException]) — e.g. 5xx or transport errors.
  static void logHttpErrorResponseBody(DioException err) {
    if (!kDebugMode) return;
    final data = err.response?.data;
    if (data == null) return;
    final uri = err.requestOptions.uri;
    final formatted = _formatHttpRequestBodyForLog(data);
    if (formatted.isNotEmpty) {
      _emit('[HTTP] error response body for $uri:\n$formatted');
    }
  }

  /// Debug: logs body when status is not 2xx but Dio still returned a [Response] (e.g. 4xx).
  static void logHttpNonSuccessResponseBody(Uri uri, dynamic data) {
    if (!kDebugMode) return;
    final formatted = _formatHttpRequestBodyForLog(data);
    if (formatted.isNotEmpty) {
      _emit('[HTTP] response body (non-success) $uri:\n$formatted');
    }
  }

  static String _truncateHttpLog(String s, [int maxChars = 32000]) {
    if (s.length <= maxChars) return s;
    return '${s.substring(0, maxChars)}… (${s.length} chars total)';
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

/// Attaches to Dio: logs status, elapsed time, method, and URL after each call.
final class HttpRequestUrlInterceptor extends Interceptor {
  static const _kStopwatch = '__appLoggerHttpSw';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_kStopwatch] = Stopwatch()..start();
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _emitFor(response.requestOptions, response.statusCode);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _emitFor(err.requestOptions, err.response?.statusCode);
    AppLogger.logHttpErrorResponseBody(err);
    handler.next(err);
  }

  void _emitFor(RequestOptions options, int? statusCode) {
    final sw = options.extra[_kStopwatch] as Stopwatch?;
    sw?.stop();
    final ms = sw?.elapsedMilliseconds ?? 0;
    AppLogger.logHttpCompleted(
      statusCode: statusCode,
      elapsedMs: ms,
      method: options.method,
      uri: options.uri,
      requestBody: options.data,
    );
  }
}
