import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:oe_history/oe_history.dart';

void main() {
  test('defaults to the local dummy host, not a live OrderEasy host', () {
    final config = HistoryConfig();

    expect(config.baseUrl, HistoryConfig.defaultBaseUrl);
    expect(config.baseUrl, 'http://127.0.0.1:8080');
    expect(config.baseUrl.contains('ordereasy'), isFalse);
  });

  test('rejects live OrderEasy production hosts and .win hosts', () {
    final blockedBrand = Uri.https('api.${'ordereasy'}.${'win'}').toString();
    final blockedTld = Uri.https('example.${'win'}').toString();

    expect(
      () => HistoryConfig(baseUrl: blockedBrand),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => HistoryConfig(baseUrl: blockedTld),
      throwsA(isA<ArgumentError>()),
    );
  });

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
}
