// Your own sandbox keys, kept out of the repo. Debug builds read assets/keys.local.json in the
// shared example package (it is gitignored), and Settings > Saved Keys switches between them.
// See assets/keys.local.example.json for the format.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SavedKey {
  const SavedKey({required this.name, required this.publicKey, this.merchantId = ''});

  final String name;
  final String publicKey;
  final String merchantId;
}

class LocalKeys {
  /// Read each time so edits to the file show up the next time Settings opens (after a hot restart).
  static Future<List<SavedKey>> all() async {
    if (!kDebugMode) return [];
    try {
      final text = await rootBundle.loadString('packages/checkout_example/assets/keys.local.json', cache: false);
      return [
        for (final entry in (jsonDecode(text) as List).whereType<Map<String, dynamic>>())
          if (entry['publicKey'] is String)
            SavedKey(
              name: entry['name'] as String? ?? entry['publicKey'] as String,
              publicKey: entry['publicKey'] as String,
              merchantId: entry['merchantId'] as String? ?? '',
            ),
      ];
    } catch (_) {
      return [];
    }
  }
}
