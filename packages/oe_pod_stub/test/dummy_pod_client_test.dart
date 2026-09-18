import 'package:oe_pod_stub/oe_pod_stub.dart';
import 'package:test/test.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 9, 18, 10, 15);

  DummyPodClient clientWithDefaults() {
    return DummyPodClient(clock: () => fixedNow);
  }

  group('PodConfig', () {
    test('defaults to loopback dummy host, never a production OrderEasy host', () {
      final config = PodConfig();
      expect(config.baseUrl, 'http://127.0.0.1:8080');
      expect(PodConfig.defaultBaseUrl, 'http://127.0.0.1:8080');
      expect(config.attachmentUrl('ofd-1001'),
          'http://127.0.0.1:8080/rider/orders/ofd-1001/pod');
    });

    test('accepts an explicit non-production baseUrl', () {
      final config = PodConfig(baseUrl: 'http://10.0.0.8:9000/');
      expect(config.baseUrl, 'http://10.0.0.8:9000');
    });

    test('rejects live OrderEasy production hosts', () {
      final apex = Uri.https(['ordereasy', 'win'].join('.')).toString();
      final api = Uri.https('api.${['ordereasy', 'win'].join('.')}').toString();
      expect(() => PodConfig(baseUrl: apex), throwsA(isA<ArgumentError>()));
      expect(() => PodConfig(baseUrl: api), throwsA(isA<ArgumentError>()));
    });
  });

  group('DummyOfdOrders', () {
    test('assigned OFD fixture has the rider dummy ids', () {
      final orders = DummyOfdOrders.assignedOfd;
      expect(orders.map((o) => o.id), ['ofd-1001', 'ofd-1002', 'ofd-1003']);
      expect(
        orders.every((o) => o.status == OfdOrderRef.outForDelivery),
        isTrue,
      );
    });

    test('empty fixture has no OFD orders', () {
      expect(DummyOfdOrders.empty, isEmpty);
    });
  });

  group('DummyPodClient.attach', () {
    test('attaches default stub image and metadata to a known OFD id', () async {
      final client = clientWithDefaults();

      final attached = await client.attach('ofd-1001');

      expect(attached.orderId, 'ofd-1001');
      expect(attached.attachedAt, fixedNow);
      expect(attached.photo.uri, 'stub://photo/ofd-1001');
      expect(attached.photo.mimeType, 'image/jpeg');
      expect(attached.photo.fileName, 'pod-ofd-1001.jpg');
      expect(attached.photo.byteLength, 1024);
      expect(attached.photo.capturedAt, fixedNow);
      expect(client.store.attachmentFor('ofd-1001'), attached);
      expect(client.attachUrl('ofd-1001'),
          'http://127.0.0.1:8080/rider/orders/ofd-1001/pod');
    });

    test('stores caller-supplied stub metadata on a known OFD id', () async {
      final client = clientWithDefaults();
      const photo = PodPhotoStub(
        uri: 'stub://photo/ofd-1002',
        mimeType: 'image/png',
        fileName: 'doorstep.png',
        byteLength: 2048,
        note: 'Left with guard',
      );

      final attached = await client.attach('ofd-1002', photo: photo);

      expect(attached.orderId, 'ofd-1002');
      expect(attached.photo.uri, photo.uri);
      expect(attached.photo.mimeType, 'image/png');
      expect(attached.photo.fileName, 'doorstep.png');
      expect(attached.photo.byteLength, 2048);
      expect(attached.photo.note, 'Left with guard');
      expect(attached.photo.capturedAt, fixedNow);
    });

    test('throws PodOrderNotFoundException when the OFD order is missing',
        () async {
      final client = clientWithDefaults();

      await expectLater(
        () => client.attach('ofd-missing'),
        throwsA(
          isA<PodOrderNotFoundException>()
              .having((e) => e.orderId, 'orderId', 'ofd-missing'),
        ),
      );
      expect(client.store.attachments, isEmpty);
    });

    test('throws when the dummy store has no seeded OFD orders', () async {
      final client = DummyPodClient(
        store: DummyPodStore.empty(),
        clock: () => fixedNow,
      );

      await expectLater(
        () => client.attach('ofd-1001'),
        throwsA(isA<PodOrderNotFoundException>()),
      );
    });

    test('throws PodValidationException for a blank order id', () async {
      final client = clientWithDefaults();

      await expectLater(
        () => client.attach('  '),
        throwsA(
          isA<PodValidationException>().having(
            (e) => e.message,
            'message',
            'orderId is required',
          ),
        ),
      );
    });

    test('overwrites a previous stub on the same OFD id', () async {
      final client = clientWithDefaults();
      await client.attach('ofd-1003');

      final second = await client.attach(
        'ofd-1003',
        photo: const PodPhotoStub(
          uri: 'stub://photo/ofd-1003-retake',
          fileName: 'retake.jpg',
          byteLength: 4096,
        ),
      );

      expect(client.store.attachments, hasLength(1));
      expect(second.photo.uri, 'stub://photo/ofd-1003-retake');
      expect(second.photo.byteLength, 4096);
    });
  });

  group('DummyPodClient.getAttachment', () {
    test('returns null when a known OFD order has no photo yet', () async {
      final client = clientWithDefaults();
      expect(await client.getAttachment('ofd-1001'), isNull);
    });

    test('returns the stored stub after attach', () async {
      final client = clientWithDefaults();
      final attached = await client.attach('ofd-1001');
      expect(await client.getAttachment('ofd-1001'), attached);
    });

    test('throws when looking up a missing OFD order', () async {
      final client = clientWithDefaults();
      await expectLater(
        () => client.getAttachment('unknown-9'),
        throwsA(isA<PodOrderNotFoundException>()),
      );
    });
  });
}
