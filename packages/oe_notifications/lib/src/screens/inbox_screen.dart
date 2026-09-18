import 'package:flutter/material.dart';

import '../models/notification_item.dart';
import '../repository/notification_repository.dart';

/// In-app rider notification inbox.
///
/// Lists dummy (or future live) [NotificationItem]s, marks a row read on tap,
/// and shows an empty state when the inbox has no rows.
class InboxScreen extends StatefulWidget {
  /// Creates the inbox.
  const InboxScreen({
    super.key,
    required this.repository,
    this.title = 'Notifications',
  });

  /// Key for the empty-state placeholder.
  static const Key emptyStateKey = ValueKey<String>('inbox-empty');

  /// Key for the inbox [ListView].
  static const Key listKey = ValueKey<String>('inbox-list');

  /// Key for a single inbox row.
  static Key itemKey(String id) => ValueKey<String>('inbox-item-$id');

  /// Inbox data source. Dummy implementations must not hit the network.
  final NotificationRepository repository;

  /// App-bar title.
  final String title;

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  late Future<_InboxSnapshot> _snapshot;

  @override
  void initState() {
    super.initState();
    _snapshot = _load();
  }

  Future<_InboxSnapshot> _load() async {
    final items = await widget.repository.list();
    final unread = await widget.repository.unreadCount();
    return _InboxSnapshot(items: items, unreadCount: unread);
  }

  Future<void> _markRead(String id) async {
    await widget.repository.markRead(id);
    if (!mounted) {
      return;
    }
    setState(() {
      _snapshot = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_InboxSnapshot>(
      future: _snapshot,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final unreadLabel =
            data == null ? widget.title : '${data.unreadCount} unread';

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              if (data != null)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Text(
                      unreadLabel,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
            ],
          ),
          body: _buildBody(snapshot),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<_InboxSnapshot> snapshot) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = snapshot.data!.items;
    if (items.isEmpty) {
      return const Center(
        key: InboxScreen.emptyStateKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none, size: 48),
            SizedBox(height: 12),
            Text('No notifications'),
          ],
        ),
      );
    }

    return ListView.separated(
      key: InboxScreen.listKey,
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          key: InboxScreen.itemKey(item.id),
          title: Text(
            item.title,
            style: TextStyle(
              fontWeight: item.read ? FontWeight.w400 : FontWeight.w700,
            ),
          ),
          subtitle: Text(item.body),
          trailing: item.read
              ? null
              : const Icon(Icons.circle, size: 10, color: Colors.blue),
          onTap: () => _markRead(item.id),
        );
      },
    );
  }
}

class _InboxSnapshot {
  const _InboxSnapshot({
    required this.items,
    required this.unreadCount,
  });

  final List<NotificationItem> items;
  final int unreadCount;
}
