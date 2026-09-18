import 'package:flutter/material.dart';

import '../grouping/group_completed_deliveries.dart';
import '../models/completed_delivery.dart';
import '../models/history_day_group.dart';
import '../repository/history_repository.dart';

/// Date-grouped list of completed deliveries.
///
/// Each row shows order id, an address snippet, status, and an earnings stub.
class HistoryListScreen extends StatefulWidget {
  /// Creates a history list backed by [repository].
  const HistoryListScreen({
    super.key,
    required this.repository,
    this.title = 'Delivery history',
  });

  /// Key on the empty-state body.
  static const Key emptyStateKey = Key('oe-history-empty');

  /// Key on the grouped list.
  static const Key listKey = Key('oe-history-list');

  /// Dummy or future remote history source.
  final HistoryRepository repository;

  /// App bar title.
  final String title;

  @override
  State<HistoryListScreen> createState() => _HistoryListScreenState();
}

class _HistoryListScreenState extends State<HistoryListScreen> {
  late final Future<List<HistoryDayGroup>> _groups;

  @override
  void initState() {
    super.initState();
    _groups = widget.repository
        .fetchCompletedDeliveries()
        .then(groupCompletedDeliveries);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<HistoryDayGroup>>(
        future: _groups,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          final groups = snapshot.data ?? const <HistoryDayGroup>[];
          if (groups.isEmpty) {
            return const _EmptyHistory();
          }
          return ListView.builder(
            key: HistoryListScreen.listKey,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              return _HistoryDaySection(group: groups[index]);
            },
          );
        },
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      key: HistoryListScreen.emptyStateKey,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history,
              size: 56,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'No completed deliveries',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Finished deliveries will show up here.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryDaySection extends StatelessWidget {
  const _HistoryDaySection({required this.group});

  final HistoryDayGroup group;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              group.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          for (final delivery in group.deliveries)
            _HistoryRow(delivery: delivery),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.delivery});

  final CompletedDelivery delivery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      key: ValueKey('oe-history-row-${delivery.orderId}'),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  delivery.orderId,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                delivery.status.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            delivery.addressSnippet(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            delivery.earnings.formatted,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
