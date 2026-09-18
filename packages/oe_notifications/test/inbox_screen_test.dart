import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oe_notifications/oe_notifications.dart';

void main() {
  testWidgets('shows empty state when the inbox has no notifications',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: InboxScreen(
          repository: DummyNotificationRepository.empty(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(InboxScreen.emptyStateKey), findsOneWidget);
    expect(find.text('No notifications'), findsOneWidget);
    expect(find.byKey(InboxScreen.listKey), findsNothing);
  });

  testWidgets('lists seed notifications and marks an unread row read',
      (tester) async {
    final repo = DummyNotificationRepository();
    final unread = NotificationFixtures.seed.firstWhere((item) => !item.read);

    await tester.pumpWidget(
      MaterialApp(
        home: InboxScreen(repository: repo),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(InboxScreen.listKey), findsOneWidget);
    expect(find.text(unread.title), findsOneWidget);
    expect(find.text('3 unread'), findsOneWidget);

    await tester.tap(find.byKey(InboxScreen.itemKey(unread.id)));
    await tester.pumpAndSettle();

    expect(await repo.unreadCount(), 2);
    expect(find.text('2 unread'), findsOneWidget);
    expect(
      (await repo.list()).firstWhere((item) => item.id == unread.id).read,
      isTrue,
    );
  });

  testWidgets('mark-read keeps the list visible instead of a spinner',
      (tester) async {
    final inner = DummyNotificationRepository();
    final repo = _ReloadDelayRepository(inner);
    final unread = NotificationFixtures.seed.firstWhere((item) => !item.read);

    await tester.pumpWidget(
      MaterialApp(
        home: InboxScreen(repository: repo),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(InboxScreen.itemKey(unread.id)));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byKey(InboxScreen.listKey), findsOneWidget);
    expect(find.text(unread.title), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('2 unread'), findsOneWidget);
  });
}

class _ReloadDelayRepository implements NotificationRepository {
  _ReloadDelayRepository(this.inner);

  final NotificationRepository inner;
  int _listCalls = 0;

  @override
  Future<List<NotificationItem>> list() async {
    _listCalls++;
    if (_listCalls > 1) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    return inner.list();
  }

  @override
  Future<NotificationItem> markRead(String id) => inner.markRead(id);

  @override
  Future<int> unreadCount() => inner.unreadCount();
}
