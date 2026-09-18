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

  test('package never ships Windows platform files', () {
    final winPaths = <String>[];
    final skip = <String>{'.dart_tool', 'build'};
    final root = Directory.current;
    for (final entity in root.listSync(recursive: true)) {
      final path = entity.path;
      final parts = path.split(Platform.pathSeparator);
      if (parts.any(skip.contains)) {
        continue;
      }
      if (path.contains('${Platform.pathSeparator}windows${Platform.pathSeparator}') ||
          path.endsWith('.win') ||
          path.contains('.win.')) {
        winPaths.add(path);
      }
    }

    expect(winPaths, isEmpty, reason: 'Windows artifacts found in: $winPaths');
  });
}
