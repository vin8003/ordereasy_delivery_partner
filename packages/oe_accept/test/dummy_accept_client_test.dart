import 'package:oe_accept/oe_accept.dart';
import 'package:test/test.dart';

void main() {
  group('DummyAcceptClient', () {
    test('defaults baseUrl to loopback :8080', () {
      final client = DummyAcceptClient();
      expect(client.baseUrl, DummyAcceptClient.defaultBaseUrl);
      expect(client.baseUrl, 'http://127.0.0.1:8080');
    });

    test('acceptOrder returns success for a valid order id', () async {
      final client = DummyAcceptClient();
      final result = await client.acceptOrder('ord-123');

      expect(result.success, isTrue);
      expect(result.orderId, 'ord-123');
      expect(result.action, AcceptAction.accept);
      expect(client.lastRequest?.uri.toString(),
          'http://127.0.0.1:8080/deliveries/ord-123/accept');
    });

    test('rejectOrder returns success and echoes the reason', () async {
      final client = DummyAcceptClient();
      const reason = 'customer not available';
      final result = await client.rejectOrder('ord-456', reason);

      expect(result.success, isTrue);
      expect(result.orderId, 'ord-456');
      expect(result.action, AcceptAction.reject);
      expect(result.reason, reason);
      expect(client.lastRequest?.reason, reason);
      expect(client.lastRequest?.uri.toString(),
          'http://127.0.0.1:8080/deliveries/ord-456/reject');
    });

    test('acceptOrder fails for an empty order id', () async {
      final result = await DummyAcceptClient().acceptOrder('  ');
      expect(result.success, isFalse);
      expect(result.message, 'orderId is required');
    });

    test('rejectOrder fails without a reason', () async {
      final result = await DummyAcceptClient().rejectOrder('ord-789', ' ');
      expect(result.success, isFalse);
      expect(result.message, 'reason is required');
    });

    test('configured failing ids return failure', () async {
      final client = DummyAcceptClient(failingOrderIds: {'ord-fail'});
      final accepted = await client.acceptOrder('ord-fail');
      final rejected = await client.rejectOrder('ord-fail', 'shop closed');

      expect(accepted.success, isFalse);
      expect(rejected.success, isFalse);
      expect(rejected.reason, 'shop closed');
    });

    test('accept/reject via OrderRef {id}', () async {
      final client = DummyAcceptClient();
      const order = OrderRef(id: 'ord-ref-1');

      final accepted = await client.accept(order);
      expect(accepted.success, isTrue);
      expect(accepted.orderId, 'ord-ref-1');

      final rejected = await client.reject(order, 'too far');
      expect(rejected.success, isTrue);
      expect(rejected.reason, 'too far');
    });

    test('rejects *.ordereasy.win baseUrl', () {
      expect(
        () => DummyAcceptClient(baseUrl: 'https://api.ordereasy.win'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => DummyAcceptClient(baseUrl: 'https://ordereasy.win'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
