import '../../../api/jmix/jmix_rest_connector.dart';
import '../../../business/business_ops.dart';

/// Per-entity field labels/messages; returns `{}` if the request fails.
final class LoadFieldMessagesForEntityUseCase {
  LoadFieldMessagesForEntityUseCase(this._rest);

  final JmixRestConnector _rest;

  Future<Map<String, dynamic>> call(String entityName) {
    return BusinessOps.run('jmix.fieldMessages', () async {
      try {
        return await _rest.messagesEntity(entityName);
      } catch (_) {
        return {};
      }
    });
  }
}
