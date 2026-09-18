import 'package:flutter_test/flutter_test.dart';
import 'package:ordereasy_delivery_partner/core/config/app_config.dart';
import 'package:ordereasy_delivery_partner/domain/models/delivery_status.dart';

void main() {
  test('AppConfig defaults to local dummy host and fixtures', () {
    const config = AppConfig();
    expect(config.baseUrl, 'http://127.0.0.1:8080');
    expect(config.useLocalFixtures, isTrue);
    expect(config.baseUrl.contains('ordereasy.win'), isFalse);
  });

  test('terminal statuses are delivered and delivery_failed only', () {
    expect(DeliveryStatus.outForDelivery.isTerminal, isFalse);
    expect(DeliveryStatus.delivered.isTerminal, isTrue);
    expect(DeliveryStatus.deliveryFailed.isTerminal, isTrue);
  });
}
