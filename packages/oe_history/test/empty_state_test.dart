import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oe_history/oe_history.dart';

void main() {
  group('DummyHistoryRepository empty state', () {
    test('returns no completed deliveries', () async {
      final repository = DummyHistoryRepository.empty();

      final deliveries = await repository.fetchCompletedDeliveries();

      expect(deliveries, isEmpty);
      expect(groupCompletedDeliveries(deliveries), isEmpty);
    });

    test('fixture repository is not empty', () async {
      final repository = DummyHistoryRepository();

      final deliveries = await repository.fetchCompletedDeliveries();

      expect(deliveries, isNotEmpty);
      expect(
        deliveries.every(
          (d) =>
              d.status == HistoryStatus.delivered ||
              d.status == HistoryStatus.deliveryFailed,
        ),
        isTrue,
      );
      expect(groupCompletedDeliveries(deliveries), isNotEmpty);
    });
  });

  group('HistoryListScreen empty state', () {
    testWidgets('shows empty copy when the repository has no history', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HistoryListScreen(repository: DummyHistoryRepository.empty()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(HistoryListScreen.emptyStateKey), findsOneWidget);
      expect(find.text('No completed deliveries'), findsOneWidget);
      expect(
        find.text('Finished deliveries will show up here.'),
        findsOneWidget,
      );
      expect(find.byKey(HistoryListScreen.listKey), findsNothing);
    });

    testWidgets('shows date-grouped rows from dummy fixtures', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HistoryListScreen(repository: DummyHistoryRepository()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No completed deliveries'), findsNothing);
      expect(find.byKey(HistoryListScreen.listKey), findsOneWidget);
      expect(find.text('18 Sep 2026'), findsOneWidget);
      expect(find.text('17 Sep 2026'), findsOneWidget);
      expect(find.text('16 Sep 2026'), findsOneWidget);
      expect(find.text('OE-1001'), findsOneWidget);
      expect(find.text('OE-1002'), findsOneWidget);
      expect(find.text('OE-1003'), findsOneWidget);
      expect(find.text('OE-1004'), findsOneWidget);
      expect(find.text('Delivered'), findsWidgets);
      expect(find.text('Delivery failed'), findsOneWidget);
      expect(find.text('₹85.50'), findsOneWidget);
      expect(find.text('₹120.00'), findsOneWidget);
      expect(find.text('₹0.00'), findsOneWidget);
    });
  });
}
