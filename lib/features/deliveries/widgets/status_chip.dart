import 'package:flutter/material.dart';

import '../../../domain/models/delivery_status.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final DeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Color bg;
    final Color fg;
    switch (status) {
      case DeliveryStatus.outForDelivery:
        bg = scheme.secondaryContainer;
        fg = scheme.onSecondaryContainer;
      case DeliveryStatus.delivered:
        bg = scheme.primaryContainer;
        fg = scheme.onPrimaryContainer;
      case DeliveryStatus.deliveryFailed:
        bg = scheme.errorContainer;
        fg = scheme.onErrorContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
