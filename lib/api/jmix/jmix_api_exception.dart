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
      final code = response?.statusCode ?? 0;
      if (data is List) {
        return JmixApiException(
          message: formatJmixValidationErrorList(data),
          statusCode: code == 0 ? null : code,
          cause: e,
        );
      }
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        if (map.containsKey('error') || map.containsKey('details')) {
          final err = JmixError.fromJson(map);
          return JmixApiException(
            message: jmixErrorUserMessage(err),
            statusCode: code == 0 ? null : code,
            error: err,
            cause: e,
          );
        }
      }
      String? raw;
      if (data is String) {
        raw = data;
      }
      return JmixApiException(
        message: raw ?? e.message ?? 'HTTP error',
        statusCode: code == 0 ? null : code,
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
