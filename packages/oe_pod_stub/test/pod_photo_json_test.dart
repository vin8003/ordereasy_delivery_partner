import 'package:oe_pod_stub/oe_pod_stub.dart';
import 'package:test/test.dart';

void main() {
  group('PodPhotoStub JSON', () {
    test('round-trips camelCase metadata', () {
      final captured = DateTime.utc(2026, 9, 18, 10, 15);
      final photo = PodPhotoStub(
        uri: 'stub://photo/ofd-1001',
        mimeType: 'image/jpeg',
        fileName: 'pod-ofd-1001.jpg',
        byteLength: 1024,
        capturedAt: captured,
        note: 'doorstep',
      );

      final decoded = PodPhotoStub.fromJson(photo.toJson());
      expect(decoded, photo);
    });

    test('reads snake_case aliases from dummy payloads', () {
      final photo = PodPhotoStub.fromJson(const {
        'uri': 'stub://photo/ofd-1002',
        'mime_type': 'image/png',
        'file_name': 'gate.png',
        'byte_length': 512,
        'captured_at': '2026-09-18T09:05:00Z',
        'note': 'gate locked',
      });

      expect(photo.uri, 'stub://photo/ofd-1002');
      expect(photo.mimeType, 'image/png');
      expect(photo.fileName, 'gate.png');
      expect(photo.byteLength, 512);
      expect(photo.capturedAt, DateTime.utc(2026, 9, 18, 9, 5));
      expect(photo.note, 'gate locked');
    });

    test('forOrder builds the rider-app stub URI', () {
      final photo = PodPhotoStub.forOrder('ofd-1003');
      expect(photo.uri, PodPhotoStub.uriFor('ofd-1003'));
      expect(photo.uri, 'stub://photo/ofd-1003');
      expect(photo.fileName, 'pod-ofd-1003.jpg');
    });
  });

  group('PodAttachment JSON', () {
    test('round-trips an attached stub', () {
      final attachedAt = DateTime.utc(2026, 9, 18, 11);
      final attachment = PodAttachment(
        orderId: 'ofd-1001',
        photo: PodPhotoStub.forOrder(
          'ofd-1001',
          capturedAt: DateTime.utc(2026, 9, 18, 10),
        ),
        attachedAt: attachedAt,
      );

      expect(PodAttachment.fromJson(attachment.toJson()), attachment);
    });

    test('reads order_id from a dummy payload', () {
      final attachment = PodAttachment.fromJson(const {
        'order_id': 'ofd-1002',
        'photo': {
          'uri': 'stub://photo/ofd-1002',
        },
      });

      expect(attachment.orderId, 'ofd-1002');
      expect(attachment.photo.uri, 'stub://photo/ofd-1002');
    });
  });

  group('OfdOrderRef JSON', () {
    test('defaults status to out_for_delivery', () {
      final order = OfdOrderRef.fromJson(const {'id': 'ofd-1001'});
      expect(order.id, 'ofd-1001');
      expect(order.status, 'out_for_delivery');
      expect(order.toJson(), {
        'id': 'ofd-1001',
        'status': 'out_for_delivery',
      });
    });
  });
}
