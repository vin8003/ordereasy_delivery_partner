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
  List<NotificationItem>? _items;
  Object? _error;
  bool _loading = true;

  int get _unreadCount =>
      _items?.where((item) => !item.read).length ?? 0;

  @override
  void initState() {
    super.initState();
    _reload(showSpinner: false);
  }

  @override
  void didUpdateWidget(InboxScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      _reload(showSpinner: _items == null);
    }
  }

  Future<void> _reload({required bool showSpinner}) async {
    if (showSpinner) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final items = await widget.repository.list();
      if (!mounted) {
        return;
      }
      setState(() {
        _items = items;
        _error = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _markRead(NotificationItem item) async {
    if (item.read) {
      return;
    }
    await widget.repository.markRead(item.id);
    if (!mounted) {
      return;
    }
    await _reload(showSpinner: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_items != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '$_unreadCount unread',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading && _items == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items == null) {
      return Center(child: Text('Could not load notifications'));
    }

    final items = _items ?? const <NotificationItem>[];
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
              : Icon(
                  Icons.circle,
                  size: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
          onTap: () => _markRead(item),
        );
      },
    );
  }
}
