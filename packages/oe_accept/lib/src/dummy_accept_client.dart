import 'accept_client.dart';
import 'accept_result.dart';
import 'order_ref.dart';

/// In-memory dummy. Does not perform network I/O.
///
/// Default [baseUrl] is [defaultBaseUrl]. Hosts matching `*.ordereasy.win`
/// are rejected.
class DummyAcceptClient implements AcceptClient {
  DummyAcceptClient({
    String baseUrl = defaultBaseUrl,
    Set<String>? failingOrderIds,
  })  : baseUrl = sanitizeBaseUrl(baseUrl),
        failingOrderIds = Set<String>.unmodifiable(failingOrderIds ?? const {});

  static const defaultBaseUrl = 'http://127.0.0.1:8080';

  final String baseUrl;
  final Set<String> failingOrderIds;

  DummyRequest? lastRequest;

  static String sanitizeBaseUrl(String baseUrl) {
    final uri = Uri.parse(baseUrl);
    if (!uri.hasScheme || uri.host.isEmpty) {
      throw ArgumentError.value(baseUrl, 'baseUrl', 'must be an absolute URL');
    }
    final host = uri.host.toLowerCase();
    if (host == 'ordereasy.win' || host.endsWith('.ordereasy.win')) {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'must not use *.ordereasy.win; default is $defaultBaseUrl',
      );
    }
    return baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
  }

  Uri acceptUri(String orderId) => Uri.parse(
        '$baseUrl/deliveries/${Uri.encodeComponent(orderId)}/accept',
      );

  Uri rejectUri(String orderId) => Uri.parse(
        '$baseUrl/deliveries/${Uri.encodeComponent(orderId)}/reject',
      );

  @override
  Future<AcceptResult> acceptOrder(String orderId) async {
    final id = orderId.trim();
    lastRequest = DummyRequest(
      action: AcceptAction.accept,
      orderId: id,
      uri: acceptUri(id),
    );
    if (id.isEmpty) {
      return AcceptResult.fail(
        orderId: orderId,
        action: AcceptAction.accept,
        message: 'orderId is required',
      );
    }
    if (failingOrderIds.contains(id)) {
      return AcceptResult.fail(
        orderId: id,
        action: AcceptAction.accept,
        message: 'dummy accept failed',
      );
    }
    return AcceptResult.ok(orderId: id, action: AcceptAction.accept);
  }

  @override
  Future<AcceptResult> rejectOrder(String orderId, String reason) async {
    final id = orderId.trim();
    final trimmedReason = reason.trim();
    lastRequest = DummyRequest(
      action: AcceptAction.reject,
      orderId: id,
      reason: trimmedReason,
      uri: rejectUri(id),
    );
    if (id.isEmpty) {
      return AcceptResult.fail(
        orderId: orderId,
        action: AcceptAction.reject,
        reason: trimmedReason,
        message: 'orderId is required',
      );
    }
    if (trimmedReason.isEmpty) {
      return AcceptResult.fail(
        orderId: id,
        action: AcceptAction.reject,
        reason: reason,
        message: 'reason is required',
      );
    }
    if (failingOrderIds.contains(id)) {
      return AcceptResult.fail(
        orderId: id,
        action: AcceptAction.reject,
        reason: trimmedReason,
        message: 'dummy reject failed',
      );
    }
    return AcceptResult.ok(
      orderId: id,
      action: AcceptAction.reject,
      reason: trimmedReason,
    );
  }

  Future<AcceptResult> accept(OrderRef order) => acceptOrder(order.id);

  Future<AcceptResult> reject(OrderRef order, String reason) =>
      rejectOrder(order.id, reason);
}

/// Last dummy call (for tests / future HTTP client wiring).
class DummyRequest {
  const DummyRequest({
    required this.action,
    required this.orderId,
    required this.uri,
    this.reason,
  });

  final AcceptAction action;
  final String orderId;
  final Uri uri;
  final String? reason;
}
