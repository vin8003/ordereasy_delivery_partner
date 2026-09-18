import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('package sources never hardcode a live OrderEasy production URL', () {
    final urlLiteral = RegExp(
      r'''https?://[^\s'"\\]*ordereasy\.win''',
      caseSensitive: false,
    );
    final hits = <String>[];

    for (final root in [Directory('lib'), Directory('test')]) {
      if (!root.existsSync()) {
        continue;
      }
      for (final entity in root.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }
        final text = entity.readAsStringSync();
        if (urlLiteral.hasMatch(text)) {
          hits.add(entity.path);
        }
      }
    }

    expect(hits, isEmpty, reason: 'Hardcoded production URL found in: $hits');
  });

  test('lib sources never mention the blocked production hostname', () {
    final banned = ['ordereasy', 'win'].join('.');
    final libDir = Directory('lib');
    final hits = <String>[];

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      if (entity.readAsStringSync().contains(banned)) {
        hits.add(entity.path);
      }
    }

    expect(hits, isEmpty, reason: '$banned found in: $hits');
  });
}
