import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/providers.dart';
import '../../data/mappers/delivery_mapper.dart';
import '../../domain/models/delivery.dart';
import 'widgets/status_chip.dart';

class DeliveryDetailScreen extends ConsumerWidget {
  const DeliveryDetailScreen({super.key, required this.deliveryId});

  final String deliveryId;

  Future<void> _navigate(BuildContext context, Delivery delivery) async {
    if (!delivery.hasCoordinates) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No coordinates on this stop')),
      );
      return;
    }
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${delivery.lat},${delivery.lng}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(deliveryDetailProvider(deliveryId));

    return Scaffold(
      appBar: AppBar(title: const Text('Delivery detail')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (delivery) => _DetailBody(
          delivery: delivery,
          onNavigate: () => _navigate(context, delivery),
          onMarkDelivered: () => context.push(
            '/deliveries/$deliveryId/mark?outcome=delivered',
          ),
          onMarkFailed: () => context.push(
            '/deliveries/$deliveryId/mark?outcome=delivery_failed',
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.delivery,
    required this.onNavigate,
    required this.onMarkDelivered,
    required this.onMarkFailed,
  });

  final Delivery delivery;
  final VoidCallback onNavigate;
  final VoidCallback onMarkDelivered;
  final VoidCallback onMarkFailed;

  @override
  Widget build(BuildContext context) {
    final assigned = DateFormat('dd MMM, hh:mm a').format(delivery.assignedAt);
    final cod = DisplayHelpers.formatCod(delivery.codAmount);
    final address = DisplayHelpers.formatAddress(
      addressLine: delivery.addressLine,
      landmark: delivery.landmark,
      city: delivery.city,
      pincode: delivery.pincode,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                delivery.orderCode,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            StatusChip(status: delivery.status),
          ],
        ),
        const SizedBox(height: 16),
        _Field(label: 'Customer', value: delivery.customerName),
        if (DisplayHelpers.hasText(delivery.customerPhone))
          _Field(label: 'Phone', value: delivery.customerPhone!),
        _Field(label: 'Address', value: address),
        if (DisplayHelpers.hasText(delivery.itemSummary))
          _Field(label: 'Items', value: delivery.itemSummary!),
        if (cod != null) _Field(label: 'Collect', value: cod),
        if (DisplayHelpers.hasText(delivery.notes))
          _Field(label: 'Notes', value: delivery.notes!),
        if (DisplayHelpers.hasText(delivery.failureReason))
          _Field(label: 'Failure reason', value: delivery.failureReason!),
        if (DisplayHelpers.hasText(delivery.photoUrl))
          _Field(label: 'Photo stub', value: delivery.photoUrl!),
        _Field(label: 'Assigned', value: assigned),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: delivery.hasCoordinates ? onNavigate : null,
          icon: const Icon(Icons.navigation_outlined),
          label: const Text('Navigate to stop'),
        ),
        if (!delivery.status.isTerminal) ...[
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('mark_delivered'),
            onPressed: onMarkDelivered,
            child: const Text('Mark delivered'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            key: const Key('mark_failed'),
            onPressed: onMarkFailed,
            child: Text(
              'Mark delivery_failed',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
