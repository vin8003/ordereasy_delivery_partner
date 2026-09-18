import 'dart:convert';

import 'package:http/http.dart' as http;

import 'order_delivery_status.dart';
import 'status_exceptions.dart';
import 'status_result.dart';

/// HTTP client for OrderEasy delivery status transitions.
///
/// Default [baseUrl] is a local origin (`http://127.0.0.1:8080`). Callers
/// inject the real host; this package does not ship a production hostname.
class StatusClient {
  StatusClient({
    String baseUrl = defaultBaseUrl,
    http.Client? httpClient,
    this.accessToken,
  })  : baseUrl = _trimTrailingSlash(baseUrl),
        _httpClient = httpClient ?? http.Client(),
        _ownsClient = httpClient == null;

  /// Local OrderEasy-compatible origin. Override in production.
  static const defaultBaseUrl = 'http://127.0.0.1:8080';

  final String baseUrl;
  final String? accessToken;
  final http.Client _httpClient;
  final bool _ownsClient;

  /// Marks [orderId] as [OrderDeliveryStatus.delivered].
  ///
  /// [photoPath] is a filesystem/URI stub only — it is forwarded as
  /// `photo_path` and is never opened or uploaded as a file.
  Future<StatusResult> markDelivered(
    String orderId, {
    String? note,
    String? photoPath,
  }) {
    return _submit(
      orderId: orderId,
      status: OrderDeliveryStatus.delivered,
      note: note,
      photoPath: photoPath,
    );
  }

  /// Marks [orderId] as [OrderDeliveryStatus.deliveryFailed].
  ///
  /// [reason] is required (non-empty after trim). [photoPath] is a path stub.
  Future<StatusResult> markFailed(
    String orderId,
    String reason, {
    String? note,
    String? photoPath,
  }) {
    return _submit(
      orderId: orderId,
      status: OrderDeliveryStatus.deliveryFailed,
      reason: reason,
      note: note,
      photoPath: photoPath,
    );
  }

  Future<StatusResult> _submit({
    required String orderId,
    required String status,
    String? reason,
    String? note,
    String? photoPath,
  }) async {
    final trimmedOrderId = orderId.trim();
    if (trimmedOrderId.isEmpty) {
      throw StatusValidationException('orderId is required');
    }

    final trimmedReason = reason?.trim();
    if (status == OrderDeliveryStatus.deliveryFailed &&
        (trimmedReason == null || trimmedReason.isEmpty)) {
      throw StatusValidationException(
        'reason is required to mark delivery_failed',
      );
    }

    final payload = <String, Object?>{
      'status': status,
      if (trimmedReason != null && trimmedReason.isNotEmpty)
        'reason': trimmedReason,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      if (photoPath != null && photoPath.isNotEmpty) 'photo_path': photoPath,
    };

    final uri = _statusUri(trimmedOrderId);
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (accessToken != null && accessToken!.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };

    final response = await _httpClient.patch(
      uri,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StatusHttpException(
        statusCode: response.statusCode,
        uri: uri,
        body: response.body,
      );
    }

    return StatusResult(
      orderId: trimmedOrderId,
      status: status,
      reason: trimmedReason,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
      photoPath: photoPath?.isEmpty == true ? null : photoPath,
      statusCode: response.statusCode,
    );
  }

  /// Aligns with OrderEasy retailer: `PATCH orders/{id}/status/`.
  Uri _statusUri(String orderId) {
    return Uri.parse(
      '$baseUrl/api/orders/${Uri.encodeComponent(orderId)}/status/',
    );
  }

  void close() {
    if (_ownsClient) {
      _httpClient.close();
    }
  }

  static String _trimTrailingSlash(String value) {
    if (value.length > 1 && value.endsWith('/')) {
      return value.substring(0, value.length - 1);
    }
    return value;
  }
}
