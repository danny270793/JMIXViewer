import 'package:flutter/material.dart';

import '../business/jmix/entity_messages_labels.dart';
import '../business/jmix/entity_record_collapse_titles.dart';
import '../business/jmix/entity_value_formatting.dart';

/// One entity row: collapsed summary, expandable attribute list.
class EntityRecordExpansionTile extends StatelessWidget {
  const EntityRecordExpansionTile({
    super.key,
    required this.row,
    required this.orderedColumnKeys,
    required this.theme,
    required this.colorScheme,
    required this.entityName,
    required this.allEntityMessages,
    required this.fieldMessagesForEntity,
  });

  final Map<String, dynamic> row;
  final List<String> orderedColumnKeys;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final String entityName;
  final Map<String, dynamic> allEntityMessages;
  final Map<String, dynamic>? fieldMessagesForEntity;

  @override
  Widget build(BuildContext context) {
    final restKeys = entityRecordRestKeys(orderedColumnKeys);

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        maintainState: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        title: Tooltip(
          message: EntityRecordCollapseTitles.titleTooltip(row, orderedColumnKeys),
          child: Text(
            EntityRecordCollapseTitles.titleText(row, orderedColumnKeys),
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        children: [
          if (restKeys.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'No other fields',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < restKeys.length; i++) ...[
                    if (i > 0) const SizedBox(height: 14),
                    Text(
                      attributeSidebarLabel(
                        restKeys[i],
                        entityName,
                        allEntityMessages,
                        fieldMessagesForEntity,
                      ),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Tooltip(
                      message: EntityValueFormatting.formatFull(row[restKeys[i]]),
                      child: Text(
                        EntityValueFormatting.formatCell(row[restKeys[i]]),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.35,
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
