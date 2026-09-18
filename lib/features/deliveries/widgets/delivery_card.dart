import 'package:flutter/material.dart';

import '../../../data/mappers/delivery_mapper.dart';
import '../../../domain/models/delivery.dart';
import 'status_chip.dart';

class DeliveryCard extends StatelessWidget {
  const DeliveryCard({
    super.key,
    required this.delivery,
    required this.onTap,
  });

  final Delivery delivery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cod = DisplayHelpers.formatCod(delivery.codAmount);
    final address = DisplayHelpers.formatAddress(
      addressLine: delivery.addressLine,
      landmark: delivery.landmark,
      city: delivery.city,
      pincode: delivery.pincode,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    delivery.orderCode,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                StatusChip(status: delivery.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(delivery.customerName),
            const SizedBox(height: 2),
            Text(
              address,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (DisplayHelpers.hasText(delivery.itemSummary)) ...[
              const SizedBox(height: 6),
              Text(delivery.itemSummary!),
            ],
            if (cod != null) ...[
              const SizedBox(height: 4),
              Text(
                cod,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
