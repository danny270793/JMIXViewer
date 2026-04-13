import '../../../api/jmix/jmix_rest_connector.dart';
import '../../../business/business_ops.dart';
import '../../../domain/jmix/drawer_entities_result.dart';

/// Loads entity metadata list and global `messages/entities` for the drawer.
final class LoadDrawerEntitiesUseCase {
  LoadDrawerEntitiesUseCase(this._rest);

  final JmixRestConnector _rest;

  Future<DrawerEntitiesResult> call() {
    return BusinessOps.run('jmix.drawer.load', () async {
      final results = await Future.wait<Object>([
        _rest.metadataListEntities(),
        _rest.messagesEntities().catchError(
          (_) => <String, dynamic>{},
        ),
      ]);
      return DrawerEntitiesResult(
        metadata: results[0] as List<Map<String, dynamic>>,
        messages: Map<String, dynamic>.from(results[1] as Map),
      );
    });
  }
}
