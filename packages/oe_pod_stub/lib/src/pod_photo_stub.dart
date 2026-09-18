/// Stub image + metadata. Never a camera capture or uploaded file.
class PodPhotoStub {
  const PodPhotoStub({
    required this.uri,
    this.mimeType = defaultMimeType,
    this.fileName,
    this.byteLength = defaultByteLength,
    this.capturedAt,
    this.note,
  });

  static const defaultMimeType = 'image/jpeg';
  static const defaultByteLength = 1024;

  /// Default dummy URI for [orderId], matching the rider app photo stub.
  static String uriFor(String orderId) => 'stub://photo/$orderId';

  factory PodPhotoStub.forOrder(
    String orderId, {
    DateTime? capturedAt,
    String? note,
    String mimeType = defaultMimeType,
    int byteLength = defaultByteLength,
  }) {
    return PodPhotoStub(
      uri: uriFor(orderId),
      mimeType: mimeType,
      fileName: 'pod-$orderId.jpg',
      byteLength: byteLength,
      capturedAt: capturedAt,
      note: note,
    );
  }

  /// Stub URI (`stub://photo/{orderId}` by default).
  final String uri;

  /// Declared media type. Default `image/jpeg`.
  final String mimeType;

  /// Dummy file name; no file is created.
  final String? fileName;

  /// Dummy byte length; no bytes are stored.
  final int byteLength;

  final DateTime? capturedAt;
  final String? note;

  factory PodPhotoStub.fromJson(Map<String, Object?> json) {
    final uri = json['uri'];
    if (uri is! String || uri.isEmpty) {
      throw const FormatException('PodPhotoStub.uri is required');
    }

    final mime = json['mimeType'] ?? json['mime_type'] ?? defaultMimeType;
    if (mime is! String) {
      throw const FormatException('PodPhotoStub.mimeType must be a string');
    }

    final fileName = json['fileName'] ?? json['file_name'];
    if (fileName != null && fileName is! String) {
      throw const FormatException('PodPhotoStub.fileName must be a string');
    }

    final note = json['note'];
    if (note != null && note is! String) {
      throw const FormatException('PodPhotoStub.note must be a string');
    }

    return PodPhotoStub(
      uri: uri,
      mimeType: mime,
      fileName: fileName as String?,
      byteLength: _readInt(
        json['byteLength'] ?? json['byte_length'],
        fallback: defaultByteLength,
        field: 'byteLength',
      ),
      capturedAt: _readDateTime(json['capturedAt'] ?? json['captured_at']),
      note: note as String?,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'uri': uri,
      'mimeType': mimeType,
      'byteLength': byteLength,
      if (fileName != null) 'fileName': fileName,
      if (capturedAt != null) 'capturedAt': capturedAt!.toUtc().toIso8601String(),
      if (note != null) 'note': note,
    };
  }

  static int _readInt(Object? value, {required int fallback, required String field}) {
    if (value == null) {
      return fallback;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    throw FormatException('PodPhotoStub.$field must be a number');
  }

  static DateTime? _readDateTime(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.parse(value);
    }
    throw const FormatException('PodPhotoStub.capturedAt must be a timestamp');
  }

  @override
  bool operator ==(Object other) {
    return other is PodPhotoStub &&
        other.uri == uri &&
        other.mimeType == mimeType &&
        other.fileName == fileName &&
        other.byteLength == byteLength &&
        other.capturedAt == capturedAt &&
        other.note == note;
  }

  @override
  int get hashCode => Object.hash(
        uri,
        mimeType,
        fileName,
        byteLength,
        capturedAt,
        note,
      );

  @override
  String toString() {
    return 'PodPhotoStub(uri: $uri, mimeType: $mimeType, fileName: $fileName, '
        'byteLength: $byteLength, capturedAt: $capturedAt, note: $note)';
  }
}
