import 'dart:io';

import 'package:oe_history/oe_history.dart';
import 'package:test/test.dart';

void main() {
  final assignedPackage = 'oe_${'orders'}';

  test('pubspec does not depend on the assigned OFD package', () {
    final yaml = File('pubspec.yaml').readAsStringSync();
    expect(yaml.contains('name: oe_history'), isTrue);
    expect(
      RegExp('^\\s+$assignedPackage\\s*:', multiLine: true).hasMatch(yaml),
      isFalse,
    );
  });

  test('Dart sources never import the assigned OFD package', () {
    final importPattern = RegExp(
      "^\\s*import\\s+['\"]package:$assignedPackage/",
      multiLine: true,
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
        if (importPattern.hasMatch(entity.readAsStringSync())) {
          hits.add(entity.path);
        }
      }
    }

    expect(hits, isEmpty, reason: 'assigned OFD import found in: $hits');
  });

  test('history types are self-contained completed rows, not assigned OFD', () {
    expect(
      HistoryStatus.values.map((s) => s.wireValue),
      isNot(contains('out_for_delivery')),
    );
    expect(
      HistoryFixtures.completed
          .every((e) => e.status.wireValue != 'out_for_delivery'),
      isTrue,
    );
  });
}
