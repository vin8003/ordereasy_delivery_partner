import 'dummy_pod_store.dart';
import 'pod_attachment.dart';
import 'pod_config.dart';
import 'pod_exceptions.dart';
import 'pod_photo_stub.dart';

/// In-memory dummy. Does not perform network I/O.
///
/// Attaches a stub image + metadata to an OFD order id in [store].
/// Throws [PodOrderNotFoundException] when the order is missing.
class DummyPodClient {
  DummyPodClient({
    PodConfig? config,
    DummyPodStore? store,
    DateTime Function()? clock,
  })  : config = config ?? PodConfig(),
        store = store ?? DummyPodStore(),
        _clock = clock ?? DateTime.now;

  final PodConfig config;
  final DummyPodStore store;
  final DateTime Function() _clock;

  /// Recorded dummy URI for attaching a photo to [orderId].
  String attachUrl(String orderId) => config.attachmentUrl(orderId);

  /// Attaches [photo] (or a default stub) to [orderId] in [store].
  Future<PodAttachment> attach(
    String orderId, {
    PodPhotoStub? photo,
  }) async {
    final id = _requireOrderId(orderId);
    _requireKnownOrder(id);

    if (photo != null && photo.uri.trim().isEmpty) {
      throw const PodValidationException('photo uri is required');
    }

    final now = _clock();
    final resolved = photo == null
        ? PodPhotoStub.forOrder(id, capturedAt: now)
        : _withCapturedAt(photo, now);

    final attachment = PodAttachment(
      orderId: id,
      photo: resolved,
      attachedAt: now,
    );
    store.putAttachment(attachment);
    return attachment;
  }

  /// Returns the stored stub for [orderId], or `null` if none is attached.
  ///
  /// Throws [PodOrderNotFoundException] when the OFD order is missing.
  Future<PodAttachment?> getAttachment(String orderId) async {
    final id = _requireOrderId(orderId);
    _requireKnownOrder(id);
    return store.attachmentFor(id);
  }

  String _requireOrderId(String orderId) {
    final id = orderId.trim();
    if (id.isEmpty) {
      throw const PodValidationException('orderId is required');
    }
    return id;
  }

  void _requireKnownOrder(String orderId) {
    if (!store.containsOrder(orderId)) {
      throw PodOrderNotFoundException(orderId);
    }
  }

  PodPhotoStub _withCapturedAt(PodPhotoStub photo, DateTime now) {
    if (photo.capturedAt != null) {
      return photo;
    }
    return PodPhotoStub(
      uri: photo.uri,
      mimeType: photo.mimeType,
      fileName: photo.fileName,
      byteLength: photo.byteLength,
      capturedAt: now,
      note: photo.note,
    );
  }
}
