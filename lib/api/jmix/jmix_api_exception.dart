import 'package:dio/dio.dart';

import 'models/jmix_error.dart';

/// Thrown when a Jmix REST or OAuth call fails with a parsed error body or transport error.
class JmixApiException implements Exception {
  JmixApiException({
    required this.message,
    this.statusCode,
    this.error,
    this.rawBody,
    this.cause,
  });

  final String message;
  final int? statusCode;
  final JmixError? error;
  final String? rawBody;
  final Object? cause;

  @override
  String toString() =>
      'JmixApiException($statusCode): $message${error != null ? ' [${error!.error}]' : ''}';

  static JmixApiException fromDio(Object e, {StackTrace? stackTrace}) {
    if (e is JmixApiException) return e;
    if (e is DioException) {
      final response = e.response;
      final data = response?.data;
      JmixError? err;
      String? raw;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('error') && data.containsKey('details')) {
          err = JmixError.fromJson(data);
        }
      } else if (data is String) {
        raw = data;
      }
      final code = response?.statusCode ?? 0;
      return JmixApiException(
        message: err?.details ?? err?.error ?? e.message ?? 'HTTP error',
        statusCode: code == 0 ? null : code,
        error: err,
        rawBody: raw,
        cause: e,
      );
    }
    return JmixApiException(
      message: e.toString(),
      cause: e,
    );
  }
}
