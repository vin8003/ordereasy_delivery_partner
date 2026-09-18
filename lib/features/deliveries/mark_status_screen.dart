import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../domain/models/delivery.dart';
import '../../domain/models/delivery_status.dart';

class MarkStatusScreen extends ConsumerStatefulWidget {
  const MarkStatusScreen({
    super.key,
    required this.deliveryId,
    required this.outcome,
  });

  final String deliveryId;
  final String outcome;

  @override
  ConsumerState<MarkStatusScreen> createState() => _MarkStatusScreenState();
}

class _MarkStatusScreenState extends ConsumerState<MarkStatusScreen> {
  final _noteController = TextEditingController();
  String? _photoStub;
  bool _submitting = false;
  String? _error;

  DeliveryStatus get _status {
    return widget.outcome == DeliveryStatus.deliveryFailed.apiValue
        ? DeliveryStatus.deliveryFailed
        : DeliveryStatus.delivered;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _attachPhotoStub() {
    setState(() {
      _photoStub = 'stub://photo/${widget.deliveryId}';
    });
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(deliveryRepositoryProvider).updateStatus(
            widget.deliveryId,
            StatusUpdateRequest(
              status: _status,
              note: _noteController.text,
              photoStubPath: _photoStub,
            ),
          );
      ref.invalidate(assignedDeliveriesProvider);
      ref.invalidate(deliveryDetailProvider(widget.deliveryId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Synced status → ${_status.apiValue}')),
      );
      context.go('/home');
    } catch (err) {
      if (mounted) {
        setState(() => _error = err.toString());
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFailed = _status == DeliveryStatus.deliveryFailed;

    return Scaffold(
      appBar: AppBar(
        title: Text(isFailed ? 'Mark delivery_failed' : 'Mark delivered'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Sync ${_status.apiValue} for ${widget.deliveryId}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 3,
            enabled: !_submitting,
            decoration: InputDecoration(
              labelText: isFailed ? 'Failure note (optional)' : 'Note (optional)',
              hintText: 'Hidden in UI when blank',
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _submitting ? null : _attachPhotoStub,
            icon: Icon(
              _photoStub == null ? Icons.photo_camera_outlined : Icons.check,
            ),
            label: Text(
              _photoStub == null ? 'Attach photo (stub)' : 'Photo stub attached',
            ),
          ),
          if (_photoStub != null) ...[
            const SizedBox(height: 8),
            Text(
              _photoStub!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('sync_status'),
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Sync ${_status.apiValue}'),
          ),
        ],
      ),
    );
  }
}
