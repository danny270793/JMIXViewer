import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../business/business_ops.dart';
import '../business/jmix/entity_messages_labels.dart';
import '../business/jmix/entity_record_collapse_titles.dart';
import '../business/jmix/entity_value_formatting.dart';
import '../l10n/app_localizations.dart';
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

String? _entityIdForRestPath(Map<String, dynamic> row) {
  final id = row['id'];
  if (id is String && id.isNotEmpty) return id;
  if (id is Map) {
    final nested = id['id'];
    if (nested is String && nested.isNotEmpty) return nested;
  }
  return null;
}

String _valueToEditText(dynamic value) {
  if (value == null) return '';
  if (value is bool) {
    return value ? 'true' : 'false';
  }
  if (value is String) return value;
  if (value is num) return value.toString();
  try {
    return const JsonEncoder.withIndent('  ').convert(value);
  } catch (_) {
    return value.toString();
  }
}

dynamic _parseFieldFromText(dynamic original, String text) {
  if (original is String) {
    return text;
  }
  if (original is bool) {
    throw StateError('boolean field must use switch');
  }
  final trimmed = text.trim();
  if (original == null) {
    if (trimmed.isEmpty) return null;
    try {
      return jsonDecode(trimmed);
    } catch (_) {
      return text;
    }
  }
  if (trimmed.isEmpty) {
    return null;
  }
  if (original is int) {
    final i = int.tryParse(trimmed);
    if (i != null) return i;
    throw const FormatException('int');
  }
  if (original is double) {
    final d = double.tryParse(trimmed);
    if (d != null) return d;
    throw const FormatException('double');
  }
  if (original is num) {
    final i = int.tryParse(trimmed);
    if (i != null) return i;
    final d = double.tryParse(trimmed);
    if (d != null) return d;
    throw const FormatException('num');
  }
  try {
    return jsonDecode(trimmed);
  } catch (_) {
    throw const FormatException('json');
  }
}

/// Full-screen view of one entity row from the generic REST list.
class EntityRecordDetailPage extends ConsumerStatefulWidget {
  const EntityRecordDetailPage({super.key, required this.args});

  final EntityRecordDetailArgs args;

  @override
  ConsumerState<EntityRecordDetailPage> createState() =>
      _EntityRecordDetailPageState();
}

class _EntityRecordDetailPageState extends ConsumerState<EntityRecordDetailPage> {
  late Map<String, dynamic> _row;
  bool _editing = false;
  bool _saving = false;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _boolValues = {};

  @override
  void initState() {
    super.initState();
    _row = Map<String, dynamic>.from(widget.args.row);
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    _boolValues.clear();
  }

  void _enterEdit(Iterable<String> keys) {
    _disposeControllers();
    for (final k in keys) {
      final v = _row[k];
      if (k == 'id') {
        continue;
      }
      if (v is bool) {
        _boolValues[k] = v;
      } else {
        _controllers[k] = TextEditingController(text: _valueToEditText(v));
      }
    }
    setState(() => _editing = true);
  }

  void _exitEdit() {
    _disposeControllers();
    setState(() => _editing = false);
  }

  Future<void> _save(List<String> keys, AppLocalizations l10n) async {
    final entityId = _entityIdForRestPath(_row);
    if (entityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.entityRecordMissingId)),
      );
      return;
    }

    final body = <String, dynamic>{};
    for (final k in keys) {
      try {
        if (k == 'id') {
          body[k] = _row[k];
          continue;
        }
        final original = _row[k];
        if (original is bool) {
          body[k] = _boolValues[k] ?? original;
          continue;
        }
        final c = _controllers[k];
        final text = c?.text ?? '';
        body[k] = _parseFieldFromText(original, text);
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.entityRecordFieldInvalid(k))),
        );
        return;
      }
    }

    setState(() => _saving = true);
    try {
      final updated = await BusinessOps.run(
        'entityRecord.update',
        () => ref.read(jmixRestConnectorProvider).updateEntity(
              widget.args.entityName,
              entityId,
              body,
            ),
      );
      if (!mounted) return;
      _disposeControllers();
      setState(() {
        _row = Map<String, dynamic>.from(updated);
        _editing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.entityRecordSaveSuccess)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.entityRecordSaveFailed('$e'))),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final messages = ref.watch(drawerEntitiesProvider).maybeWhen(
          data: (d) => d.messages,
          orElse: () => <String, dynamic>{},
        );

    final orderedKeys = entityRowColumnKeysSortedByDisplay(
      [_row],
      widget.args.entityName,
      messages,
      null,
    );

    final title = EntityRecordCollapseTitles.titleText(_row, orderedKeys);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: l10n.entityRecordEdit,
              onPressed: _saving ? null : () => _enterEdit(orderedKeys),
            )
          else ...[
            TextButton(
              onPressed: _saving ? null : _exitEdit,
              child: Text(l10n.entityRecordCancel),
            ),
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: l10n.entityRecordSave,
              onPressed: _saving ? null : () => _save(orderedKeys, l10n),
            ),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(
            widget.args.entityName,
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
                widget.args.entityName,
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
            _FieldBlock(
              fieldKey: orderedKeys[i],
              row: _row,
              editing: _editing,
              theme: theme,
              colorScheme: colorScheme,
              controllers: _controllers,
              boolValues: _boolValues,
              onBoolChanged: (key, value) {
                setState(() => _boolValues[key] = value);
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  const _FieldBlock({
    required this.fieldKey,
    required this.row,
    required this.editing,
    required this.theme,
    required this.colorScheme,
    required this.controllers,
    required this.boolValues,
    required this.onBoolChanged,
  });

  final String fieldKey;
  final Map<String, dynamic> row;
  final bool editing;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final Map<String, TextEditingController> controllers;
  final Map<String, bool> boolValues;
  final void Function(String key, bool value) onBoolChanged;

  @override
  Widget build(BuildContext context) {
    final value = row[fieldKey];

    if (!editing || fieldKey == 'id') {
      return SelectableText(
        EntityValueFormatting.formatFull(value),
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
          height: 1.35,
        ),
      );
    }

    if (value is bool) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Switch(
          value: boolValues[fieldKey] ?? value,
          onChanged: (v) => onBoolChanged(fieldKey, v),
        ),
      );
    }

    final controller = controllers[fieldKey];
    if (controller == null) {
      return SelectableText(
        EntityValueFormatting.formatFull(value),
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
          height: 1.35,
        ),
      );
    }

    final isMultiline = value != null &&
        value is! String &&
        value is! num;

    return TextField(
      controller: controller,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
        height: isMultiline ? null : 1.35,
      ),
      maxLines: isMultiline ? 12 : 1,
      keyboardType:
          isMultiline ? TextInputType.multiline : TextInputType.text,
      decoration: InputDecoration(
        isDense: true,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      ),
    );
  }
}
