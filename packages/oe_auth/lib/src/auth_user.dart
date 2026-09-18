/// Authenticated delivery partner.
class AuthUser {
  /// Stable identifier for this partner.
  final String id;

  /// Phone used to sign in (as provided, trimmed).
  final String phone;

  /// Optional display name. Dummy login leaves this null.
  final String? displayName;

  /// Creates a user.
  const AuthUser({
    required this.id,
    required this.phone,
    this.displayName,
  });

  /// Reconstructs a user from [json].
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      phone: json['phone'] as String,
      displayName: json['displayName'] as String?,
    );
  }

  /// Serializes this user.
  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        if (displayName != null) 'displayName': displayName,
      };

  @override
  bool operator ==(Object other) {
    return other is AuthUser &&
        other.id == id &&
        other.phone == phone &&
        other.displayName == displayName;
  }

  @override
  int get hashCode => Object.hash(id, phone, displayName);

  @override
  String toString() => 'AuthUser(id: $id, phone: $phone)';
}
