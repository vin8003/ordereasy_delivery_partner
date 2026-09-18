import '../dto/delivery_dto.dart';

/// Thin mapper helpers kept separate for unit testing.
class DeliveryMapper {
  const DeliveryMapper._();

  static List<DeliveryDto> listFromJson(List<dynamic> raw) {
    return raw
        .cast<Map<String, dynamic>>()
        .map(DeliveryDto.fromJson)
        .toList(growable: false);
  }
}

/// Display helpers that hide blank/null optional fields.
class DisplayHelpers {
  const DisplayHelpers._();

  static bool hasText(String? value) =>
      value != null && value.trim().isNotEmpty;

  static String? nullableText(String? value) =>
      hasText(value) ? value!.trim() : null;

  static String formatAddress({
    required String addressLine,
    String? landmark,
    required String city,
    String? pincode,
  }) {
    final parts = <String>[
      addressLine,
      if (hasText(landmark)) landmark!.trim(),
      city,
      if (hasText(pincode)) pincode!.trim(),
    ];
    return parts.join(', ');
  }

  static String? formatCod(double? amount) {
    if (amount == null) return null;
    return 'COD ₹${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';
  }
}
