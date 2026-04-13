import '../../api/jmix/jmix_rest_connector.dart';

/// Metadata list plus `messages/entities` map (entity or property name → localized text).
final class DrawerEntitiesResult {
  const DrawerEntitiesResult({
    required this.metadata,
    required this.messages,
  });

  final List<Map<String, dynamic>> metadata;
  final Map<String, dynamic> messages;
}

Future<DrawerEntitiesResult> loadDrawerEntities(JmixRestConnector rest) async {
  final results = await Future.wait<Object>([
    rest.metadataListEntities(),
    rest.messagesEntities().catchError(
      (_) => <String, dynamic>{},
    ),
  ]);
  return DrawerEntitiesResult(
    metadata: results[0] as List<Map<String, dynamic>>,
    messages: Map<String, dynamic>.from(results[1] as Map),
  );
}

Future<Map<String, dynamic>> loadFieldMessagesForEntity(
  JmixRestConnector rest,
  String entityName,
) async {
  try {
    return await rest.messagesEntity(entityName);
  } catch (_) {
    return {};
  }
}
