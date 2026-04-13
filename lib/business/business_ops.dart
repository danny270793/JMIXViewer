import 'package:flutter/foundation.dart';

import '../logging/app_logger.dart';

/// Optional hook for uncaught errors from [BusinessOps.run] / [runSync]
/// (e.g. Crashlytics, Sentry). Invoked after [AppLogger.logBusinessError].
typedef BusinessErrorListener = void Function(
  String operationName,
  Object error,
  StackTrace stackTrace,
);

/// Central entry for async/sync business work: call-site name, debug timing,
/// and consistent error reporting (log + optional [onError]).
abstract final class BusinessOps {
  BusinessOps._();

  /// Set once at startup to forward failures to analytics/crash reporting.
  static BusinessErrorListener? onError;

  /// Runs [body] with `[BIZ]` start/done timing (debug) and error handling.
  ///
  /// Use stable dotted names, e.g. `jmix.drawer.load`, `home.entityList`.
  /// When [reportErrors] is false, errors are not passed to [onError] or
  /// [AppLogger.logBusinessError] (use when the caller handles errors).
  static Future<T> run<T>(
    String name,
    Future<T> Function() body, {
    bool reportErrors = true,
  }) async {
    if (kDebugMode) {
      AppLogger.logBusinessStart(name);
    }
    final sw = Stopwatch()..start();
    try {
      final result = await body();
      sw.stop();
      if (kDebugMode) {
        AppLogger.logBusinessDone(name, sw.elapsed);
      }
      return result;
    } catch (e, st) {
      sw.stop();
      if (reportErrors) {
        AppLogger.logBusinessError(name, e, st);
        onError?.call(name, e, st);
      }
      rethrow;
    }
  }

  /// Same as [run] for synchronous work.
  static T runSync<T>(
    String name,
    T Function() body, {
    bool reportErrors = true,
  }) {
    if (kDebugMode) {
      AppLogger.logBusinessStart(name);
    }
    final sw = Stopwatch()..start();
    try {
      final result = body();
      sw.stop();
      if (kDebugMode) {
        AppLogger.logBusinessDone(name, sw.elapsed);
      }
      return result;
    } catch (e, st) {
      sw.stop();
      if (reportErrors) {
        AppLogger.logBusinessError(name, e, st);
        onError?.call(name, e, st);
      }
      rethrow;
    }
  }
}
