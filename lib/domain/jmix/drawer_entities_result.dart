/// Domain value: drawer metadata plus global entity messages from Jmix.
final class DrawerEntitiesResult {
  const DrawerEntitiesResult({
    required this.metadata,
    required this.messages,
  });

  final List<Map<String, dynamic>> metadata;
  final Map<String, dynamic> messages;
}
