import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:oe_status/oe_status.dart';
import 'package:test/test.dart';

void main() {
  group('OrderDeliveryStatus vocabulary', () {
    test('aligns with OrderEasy delivered | delivery_failed', () {
      expect(OrderDeliveryStatus.delivered, 'delivered');
      expect(OrderDeliveryStatus.deliveryFailed, 'delivery_failed');
      expect(OrderDeliveryStatus.values, ['delivered', 'delivery_failed']);
    });
  });

  group('StatusClient defaults', () {
    test('uses local 127.0.0.1:8080 origin', () {
      final client = StatusClient();
      expect(client.baseUrl, 'http://127.0.0.1:8080');
      expect(StatusClient.defaultBaseUrl, 'http://127.0.0.1:8080');
    });

    test('never hardcodes the production OrderEasy host', () {
      // Assembled so this test file is not a false positive.
      final banned = ['ordereasy', 'win'].join('.');
      expect(StatusClient.defaultBaseUrl.contains(banned), isFalse);

      final packageRoot = Directory.current.path.endsWith('oe_status')
          ? Directory.current
          : Directory('packages/oe_status');
      final libDir = Directory('${packageRoot.path}/lib');
      final sources = <File>[
        File('${packageRoot.path}/pubspec.yaml'),
        ...libDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart')),
      ];
      for (final file in sources) {
        expect(
          file.readAsStringSync().contains(banned),
          isFalse,
          reason: '${file.path} must not reference $banned',
        );
      }
    });
  });

  group('validation', () {
    late List<http.Request> requests;
    late StatusClient client;

    setUp(() {
      requests = [];
      client = StatusClient(
        httpClient: MockClient((request) async {
          requests.add(request);
          return http.Response('{}', 200);
        }),
      );
    });

    test('markFailed requires a non-empty reason', () async {
      await expectLater(
        () => client.markFailed('ord-1', ''),
        throwsA(
          isA<StatusValidationException>().having(
            (e) => e.message,
            'message',
            contains('reason'),
          ),
        ),
      );
      await expectLater(
        () => client.markFailed('ord-1', '   '),
        throwsA(isA<StatusValidationException>()),
      );
      expect(requests, isEmpty);
    });

    test('markDelivered and markFailed require orderId', () async {
      await expectLater(
        () => client.markDelivered('  '),
        throwsA(isA<StatusValidationException>()),
      );
      await expectLater(
        () => client.markFailed('', 'customer not home'),
        throwsA(isA<StatusValidationException>()),
      );
      expect(requests, isEmpty);
    });
  });

  group('markDelivered transition', () {
    test('PATCHes delivered without optional fields', () async {
      late http.Request captured;
      final client = StatusClient(
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response('{"status":"delivered"}', 200);
        }),
      );

      final result = await client.markDelivered('42');

      expect(result.orderId, '42');
      expect(result.status, OrderDeliveryStatus.delivered);
      expect(result.isDelivered, isTrue);
      expect(result.isFailed, isFalse);
      expect(result.reason, isNull);
      expect(result.note, isNull);
      expect(result.photoPath, isNull);

      expect(captured.method, 'PATCH');
      expect(
        captured.url.toString(),
        'http://127.0.0.1:8080/api/orders/42/status/',
      );
      expect(jsonDecode(captured.body), {'status': 'delivered'});
    });

    test('forwards optional note and photo path stub', () async {
      late http.Request captured;
      final client = StatusClient(
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response('{}', 200);
        }),
      );

      final result = await client.markDelivered(
        'ord-99',
        note: '  left at door  ',
        photoPath: '/tmp/proof/ord-99.jpg',
      );

      expect(result.note, 'left at door');
      expect(result.photoPath, '/tmp/proof/ord-99.jpg');
      expect(jsonDecode(captured.body), {
        'status': 'delivered',
        'note': 'left at door',
        'photo_path': '/tmp/proof/ord-99.jpg',
      });
      // Path stub only — never sent as multipart file upload.
      expect(captured.headers['content-type'], contains('application/json'));
    });
  });

  group('markFailed transition', () {
    test('PATCHes delivery_failed with required reason', () async {
      late http.Request captured;
      final client = StatusClient(
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response('{"status":"delivery_failed"}', 200);
        }),
      );

      final result = await client.markFailed(
        '77',
        'customer refused package',
      );

      expect(result.orderId, '77');
      expect(result.status, OrderDeliveryStatus.deliveryFailed);
      expect(result.isFailed, isTrue);
      expect(result.isDelivered, isFalse);
      expect(result.reason, 'customer refused package');

      expect(captured.method, 'PATCH');
      expect(
        captured.url.toString(),
        'http://127.0.0.1:8080/api/orders/77/status/',
      );
      expect(jsonDecode(captured.body), {
        'status': 'delivery_failed',
        'reason': 'customer refused package',
      });
    });

    test('forwards optional note and photo path stub on failure', () async {
      late http.Request captured;
      final client = StatusClient(
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response('{}', 204);
        }),
      );

      final result = await client.markFailed(
        'ord-7',
        'no access',
        note: 'gate locked',
        photoPath: 'file:///stub/gate.jpg',
      );

      expect(result.statusCode, 204);
      expect(result.note, 'gate locked');
      expect(result.photoPath, 'file:///stub/gate.jpg');
      expect(jsonDecode(captured.body), {
        'status': 'delivery_failed',
        'reason': 'no access',
        'note': 'gate locked',
        'photo_path': 'file:///stub/gate.jpg',
      });
    });
  });

  group('HTTP errors', () {
    test('throws StatusHttpException on non-success', () async {
      final client = StatusClient(
        httpClient: MockClient((request) async {
          return http.Response('{"error":"conflict"}', 409);
        }),
      );

      await expectLater(
        () => client.markDelivered('1'),
        throwsA(
          isA<StatusHttpException>()
              .having((e) => e.statusCode, 'statusCode', 409)
              .having((e) => e.body, 'body', contains('conflict')),
        ),
      );
    });
  });
}
