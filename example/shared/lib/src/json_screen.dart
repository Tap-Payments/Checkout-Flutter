import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'widgets.dart';

/// Shows the configuration map as pretty JSON (sorted keys), with a Copy button.
class ConfigurationJsonScreen extends StatelessWidget {
  const ConfigurationJsonScreen({super.key, required this.configuration});

  final Map<String, dynamic> configuration;

  @override
  Widget build(BuildContext context) {
    final json = prettyJson(configuration);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration JSON'),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: json));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied')));
            },
            child: const Text('Copy'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: CardBox(
            padding: const EdgeInsets.all(16),
            child: SelectableText(json, key: const Key('configurationJson'), style: monospace.copyWith(fontSize: 12)),
          ),
        ),
      ),
    );
  }
}

/// Pretty JSON with every object's keys sorted, like the native example apps print it.
String prettyJson(Object? value) => const JsonEncoder.withIndent('  ').convert(_sorted(value));

Object? _sorted(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return {for (final key in keys) key: _sorted(value[key])};
  }
  if (value is List) return value.map(_sorted).toList();
  return value;
}
