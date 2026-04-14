import '../business/business_ops.dart';

/// Base class for application use cases. Subclasses call [run] / [runSync]
/// so every operation is traced and timed via [BusinessOps].
class BusinessUseCase {
  const BusinessUseCase();

  Future<T> run<T>(
    String operationName,
    Future<T> Function() body, {
    bool reportErrors = true,
  }) =>
      BusinessOps.run(operationName, body, reportErrors: reportErrors);

  T runSync<T>(
    String operationName,
    T Function() body, {
    bool reportErrors = true,
  }) =>
      BusinessOps.runSync(operationName, body, reportErrors: reportErrors);
}
