import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../business/jmix/entity_messages_labels.dart';
import '../business/jmix/entity_record_collapse_titles.dart';
import '../business/jmix/entity_value_formatting.dart';
import '../providers/home_providers.dart';

/// Arguments for [EntityRecordDetailPage] (passed via GoRouter `extra`).
class EntityRecordDetailArgs {
  const EntityRecordDetailArgs({
    required this.entityName,
    required this.row,
  });

  final String entityName;
  final Map<String, dynamic> row;
}

/// Full-screen view of one entity row from the generic REST list.
class EntityRecordDetailPage extends ConsumerWidget {
  const EntityRecordDetailPage({super.key, required this.args});

  final EntityRecordDetailArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final messages = ref.watch(drawerEntitiesProvider).maybeWhen(
          data: (d) => d.messages,
          orElse: () => <String, dynamic>{},
        );

    final orderedKeys = entityRowColumnKeysSortedByDisplay(
      [args.row],
      args.entityName,
      messages,
      null,
    );

    final title = EntityRecordCollapseTitles.titleText(args.row, orderedKeys);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(
            args.entityName,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < orderedKeys.length; i++) ...[
            if (i > 0) const SizedBox(height: 20),
            Text(
              attributeSidebarLabel(
                orderedKeys[i],
                args.entityName,
                messages,
                null,
              ),
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 8),
            SelectableText(
              EntityValueFormatting.formatFull(args.row[orderedKeys[i]]),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
