import '../../domain/models/delivery.dart';
import '../../domain/repositories/delivery_repository.dart';
import '../datasources/dummy_delivery_api.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  DeliveryRepositoryImpl({required DummyDeliveryApi api}) : _api = api;

  final DummyDeliveryApi _api;

  @override
  Future<List<Delivery>> fetchAssignedDeliveries() async {
    final dtos = await _api.fetchAssigned();
    return dtos.map((d) => d.toDomain()).toList(growable: false);
  }

  @override
  Future<Delivery> fetchDelivery(String id) async {
    final dto = await _api.fetchById(id);
    return dto.toDomain();
  }

  @override
  Future<Delivery> updateStatus(String id, StatusUpdateRequest request) async {
    final dto = await _api.updateStatus(id: id, request: request);
    return dto.toDomain();
  }
}
