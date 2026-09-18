/// A single in-app inbox row for a delivery-partner rider.
class NotificationItem {
  /// Creates an inbox item.
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });

  /// Reconstructs an item from [json].
  ///
  /// Accepts camelCase and snake_case keys.
  /// Throws [FormatException] when required fields are missing.
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final body = json['body'];
    final createdAt = _readTime(json, 'createdAt', 'created_at');
    if (id is! String || id.isEmpty) {
      throw const FormatException('NotificationItem.id is required');
    }
    if (title is! String || title.isEmpty) {
      throw const FormatException('NotificationItem.title is required');
    }
    if (body is! String || body.isEmpty) {
      throw const FormatException('NotificationItem.body is required');
    }
    if (createdAt == null) {
      throw const FormatException('NotificationItem.createdAt is required');
    }
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      read: _readBool(json, 'read'),
    );
  }

  /// Stable identifier.
  final String id;

  /// Short headline shown in the inbox list.
  final String title;

  /// Longer message body.
  final String body;

  /// When the notification was created.
  final DateTime createdAt;

  /// Whether the rider has opened this row.
  final bool read;

  /// Serializes this item using camelCase keys.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'body': body,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'read': read,
      };

  /// Copy with selected fields replaced.
  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? read,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationItem &&
        other.id == id &&
        other.title == title &&
        other.body == body &&
        other.createdAt == createdAt &&
        other.read == read;
  }

  @override
  int get hashCode => Object.hash(id, title, body, createdAt, read);

  @override
  String toString() => 'NotificationItem(id: $id, read: $read)';

  static bool _readBool(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is bool) {
      return value;
    }
    return false;
  }

  static DateTime? _readTime(
    Map<String, dynamic> json,
    String camel,
    String snake,
  ) {
    final value = json[camel] ?? json[snake];
    if (value is DateTime) {
      return value.toUtc();
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value).toUtc();
    }
    return null;
  }
}
