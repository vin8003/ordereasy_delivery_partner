import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('package sources never hardcode a live OrderEasy production URL', () {
    final urlLiteral = RegExp(
      r'''https?://[^\s'"\\]*ordereasy\.win''',
      caseSensitive: false,
    );
    final hits = <String>[];

    final root = Directory('lib');
    if (root.existsSync()) {
      for (final entity in root.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }
        if (urlLiteral.hasMatch(entity.readAsStringSync())) {
          hits.add(entity.path);
        }
      }
    }

    expect(hits, isEmpty, reason: 'Hardcoded production URL found in: $hits');
  });

  test('package sources never import dart:io HttpClient or package:http', () {
    final networkImport = RegExp(
      r'''import\s+['"]package:http/|import\s+['"]dart:io['"]''',
    );
    final hits = <String>[];

    final root = Directory('lib');
    if (root.existsSync()) {
      for (final entity in root.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }
        if (networkImport.hasMatch(entity.readAsStringSync())) {
          hits.add(entity.path);
        }
      }
    }

    expect(
      hits,
      isEmpty,
      reason: 'Network import found in dummy package: $hits',
    );
  });
}
