/// Rider profile fields shown on the settings stub.
class RiderProfile {
  /// Creates a rider profile.
  ///
  /// [vehicleNumber] is optional. Null, empty, and whitespace-only
  /// values are stored as omitted (`null`).
  RiderProfile({
    required this.name,
    required this.phone,
    String? vehicleNumber,
    required this.isOnline,
  }) : vehicleNumber = _normalizeVehicle(vehicleNumber);

  /// Reconstructs a profile from [json].
  ///
  /// Accepts `vehicle_number` / `vehicleNumber` and `online` /
  /// `isOnline` / `is_online`. Missing, null, or empty vehicle numbers
  /// are omitted.
  factory RiderProfile.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    if (name is! String || name.isEmpty) {
      throw const FormatException('RiderProfile.name is required');
    }

    final phone = json['phone'];
    if (phone is! String || phone.isEmpty) {
      throw const FormatException('RiderProfile.phone is required');
    }

    return RiderProfile(
      name: name,
      phone: phone,
      vehicleNumber: _readOptionalVehicle(json),
      isOnline: _readOnline(json),
    );
  }

  /// Display name.
  final String name;

  /// Contact phone as provided.
  final String phone;

  /// Optional vehicle registration. Null when omitted.
  final String? vehicleNumber;

  /// Display-only availability flag. The settings stub does not toggle it.
  final bool isOnline;

  /// Serializes this profile.
  ///
  /// Uses snake_case `vehicle_number` and omits that key when the value
  /// is null or empty.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'phone': phone,
      'online': isOnline,
      if (vehicleNumber != null && vehicleNumber!.isNotEmpty)
        'vehicle_number': vehicleNumber,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is RiderProfile &&
        other.name == name &&
        other.phone == phone &&
        other.vehicleNumber == vehicleNumber &&
        other.isOnline == isOnline;
  }

  @override
  int get hashCode => Object.hash(name, phone, vehicleNumber, isOnline);

  @override
  String toString() {
    return 'RiderProfile(name: $name, phone: $phone, '
        'vehicleNumber: $vehicleNumber, isOnline: $isOnline)';
  }

  static String? _normalizeVehicle(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String? _readOptionalVehicle(Map<String, dynamic> json) {
    final value = json['vehicle_number'] ?? json['vehicleNumber'];
    if (value is String) {
      return _normalizeVehicle(value);
    }
    return null;
  }

  static bool _readOnline(Map<String, dynamic> json) {
    final value = json['online'] ?? json['isOnline'] ?? json['is_online'];
    return value == true;
  }
}
