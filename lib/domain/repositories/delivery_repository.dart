import '../models/delivery.dart';

abstract class DeliveryRepository {
  Future<List<Delivery>> fetchAssignedDeliveries();
  Future<Delivery> fetchDelivery(String id);
  Future<Delivery> updateStatus(String id, StatusUpdateRequest request);
}
