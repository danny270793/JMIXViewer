import '../../../api/jmix/jmix_rest_connector.dart';
import '../../../domain/jmix/drawer_entities_result.dart';
import '../../business_use_case.dart';

/// Loads entity metadata list and global `messages/entities` for the drawer.
final class LoadDrawerEntitiesUseCase extends BusinessUseCase {
  LoadDrawerEntitiesUseCase(this._rest) : super();

  final JmixRestConnector _rest;

  Future<DrawerEntitiesResult> call() {
    return run('jmix.drawer.load', () async {
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
