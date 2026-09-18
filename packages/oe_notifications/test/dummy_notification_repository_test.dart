import 'package:flutter_test/flutter_test.dart';
import 'package:oe_notifications/oe_notifications.dart';

void main() {
  late DummyNotificationRepository repo;

  setUp(() {
    repo = DummyNotificationRepository();
  });

  group('NotificationConfig', () {
    test('defaults baseUrl to loopback :8080, not a live host', () {
      final config = NotificationConfig();
      expect(config.baseUrl, NotificationConfig.defaultBaseUrl);
      expect(config.baseUrl, 'http://127.0.0.1:8080');
      expect(config.baseUrl.contains('ordereasy.win'), isFalse);
      expect(repo.config.baseUrl, NotificationConfig.defaultBaseUrl);
    });

    test('rejects live OrderEasy production hosts', () {
      final liveApex = 'https://${'ordereasy'}.${'win'}';
      final liveApi = 'https://api.${'ordereasy'}.${'win'}';
      expect(() => NotificationConfig(baseUrl: liveApex), throwsArgumentError);
      expect(() => NotificationConfig(baseUrl: liveApi), throwsArgumentError);
      expect(
        () => DummyNotificationRepository(
          config: NotificationConfig(baseUrl: liveApi),
        ),
        throwsArgumentError,
      );
    });

    test('rejects an empty or non-absolute baseUrl', () {
      expect(() => NotificationConfig(baseUrl: ''), throwsArgumentError);
      expect(() => NotificationConfig(baseUrl: 'not-a-url'), throwsArgumentError);
    });
  });

  group('DummyNotificationRepository seed fixtures', () {
    test('seeds rider inbox items without touching the network', () async {
      final items = await repo.list();

      expect(items, isNotEmpty);
      expect(items.length, NotificationFixtures.seed.length);
      expect(
        items.map((item) => item.id),
        NotificationFixtures.seed.map((item) => item.id),
      );
      expect(items.every((item) => item.title.isNotEmpty), isTrue);
      expect(items.every((item) => item.body.isNotEmpty), isTrue);
    });

    test('lists newest createdAt first', () async {
      final items = await repo.list();
      final createdAt = items.map((item) => item.createdAt).toList();
      final sorted = List<DateTime>.from(createdAt)
        ..sort((a, b) => b.compareTo(a));
      expect(createdAt, sorted);
    });

    test('empty fixture set has zero items and zero unread', () async {
      final empty = DummyNotificationRepository.empty();

      expect(await empty.list(), isEmpty);
      expect(await empty.unreadCount(), 0);
    });
  });

  group('unread count', () {
    test('counts unread seed items', () async {
      final items = await repo.list();
      final expected = items.where((item) => !item.read).length;

      expect(expected, greaterThan(0));
      expect(await repo.unreadCount(), expected);
      expect(await repo.unreadCount(), 3);
    });
  });

  group('mark-read', () {
    test('markRead flips the item and decreases unread count', () async {
      final before = await repo.unreadCount();
      final unread = (await repo.list()).firstWhere((item) => !item.read);

      final updated = await repo.markRead(unread.id);

      expect(updated.id, unread.id);
      expect(updated.read, isTrue);
      expect(updated.title, unread.title);
      expect(updated.body, unread.body);
      expect(await repo.unreadCount(), before - 1);

      final listed = (await repo.list()).firstWhere((item) => item.id == unread.id);
      expect(listed.read, isTrue);
      expect(listed, updated);
    });

    test('markRead is idempotent for an already-read item', () async {
      final read = (await repo.list()).firstWhere((item) => item.read);
      final before = await repo.unreadCount();

      final updated = await repo.markRead(read.id);

      expect(updated.read, isTrue);
      expect(updated.id, read.id);
      expect(await repo.unreadCount(), before);
    });

    test('markRead throws for an unknown id', () async {
      await expectLater(
        repo.markRead('missing-id'),
        throwsA(isA<ArgumentError>()),
      );
      expect(await repo.unreadCount(), 3);
    });
  });
}
