import '../../../api/jmix/jmix_rest_connector.dart';
import '../../business_use_case.dart';

/// Per-entity field labels/messages; returns `{}` if the request fails.
final class LoadFieldMessagesForEntityUseCase extends BusinessUseCase {
  LoadFieldMessagesForEntityUseCase(this._rest) : super();

  final JmixRestConnector _rest;

  Future<Map<String, dynamic>> call(String entityName) {
    return run('jmix.fieldMessages', () async {
      try {
        return await _rest.messagesEntity(entityName);
      } catch (_) {
        return {};
      }
    });
  }
}
