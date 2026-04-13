import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../business/business_ops.dart';
import '../business/jmix/entity_attribute_input_meta.dart';
import '../business/jmix/entity_messages_labels.dart';
import '../business/jmix/entity_record_collapse_titles.dart';
import '../business/jmix/entity_value_formatting.dart';
import '../l10n/app_localizations.dart';
import '../providers/entity_metadata_providers.dart';
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

String? _referenceIdText(dynamic value) {
  if (value == null) return null;
  if (value is Map && value['id'] != null) {
    return value['id'].toString();
  }
  return null;
}

String? _enumStoredId(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

String _valueToEditText(dynamic value, ParsedAttributeMeta meta) {
  if (value == null) return '';
  switch (meta.kind) {
    case AttributeInputKind.boolean:
      return value == true ? 'true' : 'false';
    case AttributeInputKind.referenceManyToOne:
      return _referenceIdText(value) ?? '';
    case AttributeInputKind.enumDropdown:
      return _enumStoredId(value) ?? '';
    case AttributeInputKind.date:
    case AttributeInputKind.dateTime:
    case AttributeInputKind.time:
      if (value is String) return value;
      return value.toString();
    case AttributeInputKind.plainString:
    case AttributeInputKind.multilineString:
      if (value is String) return value;
      return value.toString();
    case AttributeInputKind.integer:
    case AttributeInputKind.decimal:
    case AttributeInputKind.uuid:
      return value.toString();
    default:
      if (value is String) return value;
      if (value is num || value is bool) return value.toString();
      try {
        return const JsonEncoder.withIndent('  ').convert(value);
      } catch (_) {
        return value.toString();
      }
  }
}

dynamic _parseEditableValue({
  required ParsedAttributeMeta meta,
  required dynamic original,
  required String text,
  required bool? boolValue,
  required String? enumValue,
}) {
  switch (meta.kind) {
    case AttributeInputKind.readOnlyDisplay:
      return original;
    case AttributeInputKind.boolean:
      return boolValue ?? original;
    case AttributeInputKind.enumDropdown:
      return enumValue;
    case AttributeInputKind.referenceManyToOne:
      final t = text.trim();
      if (t.isEmpty) return null;
      return <String, dynamic>{'id': t};
    case AttributeInputKind.plainString:
    case AttributeInputKind.multilineString:
      return text;
    case AttributeInputKind.integer:
      final t = text.trim();
      if (t.isEmpty) return null;
      final i = int.tryParse(t);
      if (i != null) return i;
      throw const FormatException('int');
    case AttributeInputKind.decimal:
      final t = text.trim();
      if (t.isEmpty) return null;
      final d = double.tryParse(t);
      if (d != null) return d;
      throw const FormatException('decimal');
    case AttributeInputKind.uuid:
      final t = text.trim();
      if (t.isEmpty) return null;
      return t;
    case AttributeInputKind.date:
      final t = text.trim();
      if (t.isEmpty) return null;
      final d = DateTime.tryParse(t);
      if (d != null) {
        return DateFormat('yyyy-MM-dd').format(DateTime(d.year, d.month, d.day));
      }
      throw const FormatException('date');
    case AttributeInputKind.dateTime:
      final t = text.trim();
      if (t.isEmpty) return null;
      final d = DateTime.tryParse(t);
      if (d != null) return d.toIso8601String();
      throw const FormatException('dateTime');
    case AttributeInputKind.time:
      final t = text.trim();
      if (t.isEmpty) return null;
      return t;
    case AttributeInputKind.collectionJson:
    case AttributeInputKind.jsonBlob:
      final trimmed = text.trim();
      if (trimmed.isEmpty) return null;
      try {
        return jsonDecode(trimmed);
      } catch (_) {
        throw const FormatException('json');
      }
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
  final Map<String, String?> _enumValues = {};
  Map<String, Map<String, dynamic>>? _propertyByName;

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
    _enumValues.clear();
  }

  ParsedAttributeMeta _metaFor(String key) {
    final prop = _propertyByName?[key];
    return ParsedAttributeMeta.forField(
      fieldName: key,
      property: prop,
      currentValue: _row[key],
    );
  }

  Future<void> _startEdit(List<String> keys) async {
    Map<String, Map<String, dynamic>>? props;
    try {
      final metaJson =
          await ref.read(entityMetadataProvider(widget.args.entityName).future);
      props = ParsedAttributeMeta.propertyMapFromEntityMeta(metaJson);
    } catch (_) {
      props = null;
    }

    _disposeControllers();
    _propertyByName = props;

    for (final k in keys) {
      final m = ParsedAttributeMeta.forField(
        fieldName: k,
        property: props?[k],
        currentValue: _row[k],
      );
      final v = _row[k];
      if (k == 'id' || m.kind == AttributeInputKind.readOnlyDisplay) {
        continue;
      }
      if (m.kind == AttributeInputKind.boolean) {
        _boolValues[k] = v == true;
      } else if (m.kind == AttributeInputKind.enumDropdown) {
        _enumValues[k] = _enumStoredId(v);
      } else {
        _controllers[k] = TextEditingController(text: _valueToEditText(v, m));
      }
    }
    setState(() => _editing = true);
  }

  void _exitEdit() {
    _disposeControllers();
    setState(() {
      _editing = false;
      _propertyByName = null;
    });
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
        final meta = _metaFor(k);
        if (k == 'id') {
          body[k] = _row[k];
          continue;
        }
        if (meta.kind == AttributeInputKind.readOnlyDisplay) {
          body[k] = _row[k];
          continue;
        }
        final original = _row[k];
        final c = _controllers[k];
        final text = c?.text ?? '';
        body[k] = _parseEditableValue(
          meta: meta,
          original: original,
          text: text,
          boolValue: _boolValues[k],
          enumValue: _enumValues[k],
        );
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
        _propertyByName = null;
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

    // Warm cache so Edit can classify fields without waiting.
    ref.watch(entityMetadataProvider(widget.args.entityName));

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
              onPressed: _saving ? null : () => _startEdit(orderedKeys),
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
            _AttributeEditor(
              fieldKey: orderedKeys[i],
              row: _row,
              editing: _editing,
              meta: _metaFor(orderedKeys[i]),
              theme: theme,
              colorScheme: colorScheme,
              controllers: _controllers,
              boolValues: _boolValues,
              enumValues: _enumValues,
              onBoolChanged: (key, value) {
                setState(() => _boolValues[key] = value);
              },
              onEnumChanged: (key, value) {
                setState(() => _enumValues[key] = value);
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _AttributeEditor extends ConsumerWidget {
  const _AttributeEditor({
    required this.fieldKey,
    required this.row,
    required this.editing,
    required this.meta,
    required this.theme,
    required this.colorScheme,
    required this.controllers,
    required this.boolValues,
    required this.enumValues,
    required this.onBoolChanged,
    required this.onEnumChanged,
  });

  final String fieldKey;
  final Map<String, dynamic> row;
  final bool editing;
  final ParsedAttributeMeta meta;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final Map<String, TextEditingController> controllers;
  final Map<String, bool> boolValues;
  final Map<String, String?> enumValues;
  final void Function(String key, bool value) onBoolChanged;
  final void Function(String key, String? value) onEnumChanged;

  InputDecoration _decoration() {
    return InputDecoration(
      isDense: true,
      border: const OutlineInputBorder(),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = row[fieldKey];

    if (!editing || fieldKey == 'id' || meta.kind == AttributeInputKind.readOnlyDisplay) {
      return SelectableText(
        EntityValueFormatting.formatFull(value),
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
          height: 1.35,
        ),
      );
    }

    switch (meta.kind) {
      case AttributeInputKind.boolean:
        return Align(
          alignment: Alignment.centerLeft,
          child: Switch(
            value: boolValues[fieldKey] ?? (value == true),
            onChanged: (v) => onBoolChanged(fieldKey, v),
          ),
        );
      case AttributeInputKind.enumDropdown:
        final name = meta.enumClassName;
        if (name == null || name.isEmpty) {
          return _textField(
            theme,
            controllers[fieldKey],
            keyboardType: TextInputType.text,
            maxLines: 1,
          );
        }
        final asyncEnum = ref.watch(enumMetadataProvider(name));
        return asyncEnum.when(
          data: (data) {
            final raw = data['values'];
            final list = <Map<String, dynamic>>[];
            if (raw is List) {
              for (final e in raw) {
                if (e is Map<String, dynamic>) list.add(e);
              }
            }
            final current = enumValues[fieldKey] ?? _enumStoredId(value);
            final ids = list
                .map((e) => e['id'])
                .whereType<Object>()
                .map((e) => e.toString())
                .toList();
            String? effectiveValue =
                (current != null && ids.contains(current)) ? current : null;
            if (effectiveValue == null && ids.length == 1) {
              effectiveValue = ids.first;
            }
            return InputDecorator(
              decoration: _decoration(),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: effectiveValue,
                  hint: const Text('—'),
                  items: [
                    for (final e in list)
                      if (e['id'] != null)
                        DropdownMenuItem<String>(
                          value: e['id'].toString(),
                          child: Text(
                            '${e['caption'] ?? e['name'] ?? e['id']}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                  ],
                  onChanged: (v) => onEnumChanged(fieldKey, v),
                ),
              ),
            );
          },
          loading: () => const LinearProgressIndicator(minHeight: 2),
          error: (error, stackTrace) => _textField(
            theme,
            controllers[fieldKey],
            keyboardType: TextInputType.text,
            maxLines: 1,
          ),
        );
      case AttributeInputKind.date:
        return _dateRow(context, theme);
      case AttributeInputKind.dateTime:
        return _dateTimeRow(context, theme);
      case AttributeInputKind.time:
        return _timeRow(context, theme);
      case AttributeInputKind.integer:
        return _textField(
          theme,
          controllers[fieldKey],
          keyboardType: const TextInputType.numberWithOptions(
            signed: true,
            decimal: false,
          ),
          maxLines: 1,
          formatters: [FilteringTextInputFormatter.allow(RegExp(r'[-0-9]'))],
        );
      case AttributeInputKind.decimal:
        return _textField(
          theme,
          controllers[fieldKey],
          keyboardType: const TextInputType.numberWithOptions(
            signed: true,
            decimal: true,
          ),
          maxLines: 1,
        );
      case AttributeInputKind.uuid:
        return _textField(
          theme,
          controllers[fieldKey],
          keyboardType: TextInputType.text,
          maxLines: 1,
        );
      case AttributeInputKind.referenceManyToOne:
        return _textField(
          theme,
          controllers[fieldKey],
          keyboardType: TextInputType.text,
          maxLines: 1,
          hint: 'Reference id (UUID)',
        );
      case AttributeInputKind.plainString:
        return _textField(
          theme,
          controllers[fieldKey],
          keyboardType: TextInputType.text,
          maxLines: 1,
        );
      case AttributeInputKind.multilineString:
        return _textField(
          theme,
          controllers[fieldKey],
          keyboardType: TextInputType.multiline,
          maxLines: 8,
        );
      case AttributeInputKind.collectionJson:
      case AttributeInputKind.jsonBlob:
        return _textField(
          theme,
          controllers[fieldKey],
          keyboardType: TextInputType.multiline,
          maxLines: 12,
        );
      case AttributeInputKind.readOnlyDisplay:
        return SelectableText(
          EntityValueFormatting.formatFull(value),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
            height: 1.35,
          ),
        );
    }
  }

  Widget _textField(
    ThemeData theme,
    TextEditingController? controller, {
    required TextInputType keyboardType,
    required int maxLines,
    List<TextInputFormatter>? formatters,
    String? hint,
  }) {
    if (controller == null) {
      return SelectableText(
        EntityValueFormatting.formatFull(row[fieldKey]),
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
          height: 1.35,
        ),
      );
    }
    return TextField(
      controller: controller,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
        height: maxLines > 1 ? null : 1.35,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: formatters,
      decoration: _decoration().copyWith(hintText: hint),
    );
  }

  Widget _dateRow(BuildContext context, ThemeData theme) {
    final c = controllers[fieldKey];
    if (c == null) {
      return const SizedBox.shrink();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: c,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              height: 1.35,
            ),
            keyboardType: TextInputType.datetime,
            decoration: _decoration().copyWith(
              hintText: 'yyyy-MM-dd',
            ),
          ),
        ),
        IconButton(
          tooltip: 'Select date',
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            final parsed = DateTime.tryParse(c.text.trim());
            final initial = parsed != null
                ? DateTime(parsed.year, parsed.month, parsed.day)
                : DateTime.now();
            final d = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (d != null) {
              c.text = DateFormat('yyyy-MM-dd').format(d);
            }
          },
        ),
      ],
    );
  }

  Widget _dateTimeRow(BuildContext context, ThemeData theme) {
    final c = controllers[fieldKey];
    if (c == null) {
      return const SizedBox.shrink();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: c,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              height: 1.35,
            ),
            keyboardType: TextInputType.datetime,
            decoration: _decoration().copyWith(
              hintText: 'ISO-8601 date-time',
            ),
          ),
        ),
        IconButton(
          tooltip: MaterialLocalizations.of(context).datePickerHelpText,
          icon: const Icon(Icons.event),
          onPressed: () async {
            var base = DateTime.tryParse(c.text.trim()) ?? DateTime.now();
            final d = await showDatePicker(
              context: context,
              initialDate: base,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (d == null || !context.mounted) return;
            final t = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(base),
            );
            if (t == null || !context.mounted) return;
            final dt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
            c.text = dt.toIso8601String();
          },
        ),
      ],
    );
  }

  Widget _timeRow(BuildContext context, ThemeData theme) {
    final c = controllers[fieldKey];
    if (c == null) {
      return const SizedBox.shrink();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: c,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              height: 1.35,
            ),
            keyboardType: TextInputType.datetime,
            decoration: _decoration().copyWith(
              hintText: 'HH:mm:ss',
            ),
          ),
        ),
        IconButton(
          tooltip: MaterialLocalizations.of(context).timePickerDialHelpText,
          icon: const Icon(Icons.schedule),
          onPressed: () async {
            final parts = c.text.trim().split(':');
            var h = int.tryParse(parts.elementAt(0)) ?? 0;
            var m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
            if (h < 0) h = 0;
            if (m < 0) m = 0;
            final t = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(hour: h % 24, minute: m % 60),
            );
            if (t != null) {
              c.text =
                  '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
            }
          },
        ),
      ],
    );
  }
}
