import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../domain/models/delivery.dart';
import '../../domain/models/delivery_status.dart';
import '../dto/delivery_dto.dart';
import '../mappers/delivery_mapper.dart';

/// Talks to the local dummy API or in-memory fixtures.
/// Never targets production OrderEasy hosts.
class DummyDeliveryApi {
  DummyDeliveryApi({
    required AppConfig config,
    http.Client? httpClient,
    AssetBundle? bundle,
  })  : _config = config,
        _http = httpClient ?? http.Client(),
        _bundle = bundle ?? rootBundle;

  final AppConfig _config;
  final http.Client _http;
  final AssetBundle _bundle;

  List<DeliveryDto>? _cache;

  Future<RiderSession> login({
    required String phone,
    required String pin,
  }) async {
    if (_config.useLocalFixtures) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (phone.trim().isEmpty || pin.trim().isEmpty) {
        throw const ApiException('Phone and PIN are required');
      }
      return RiderSession(
        riderId: 'rider-demo-1',
        displayName: 'Demo Rider',
        token: 'dummy-token-${phone.trim()}',
      );
    }

    final response = await _http.post(
      Uri.parse('${_config.baseUrl}/v1/rider/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'pin': pin}),
    );
    _ensureOk(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return RiderSession(
      riderId: body['rider_id'] as String,
      displayName: body['display_name'] as String,
      token: body['token'] as String,
    );
  }

  Future<List<DeliveryDto>> fetchAssigned() async {
    if (_config.useLocalFixtures) {
      final all = await _loadFixtures();
      return all
          .where((d) => d.status == DeliveryStatus.outForDelivery.apiValue)
          .toList(growable: false);
    }

    final response = await _http.get(
      Uri.parse('${_config.baseUrl}/v1/rider/deliveries?status=out_for_delivery'),
    );
    _ensureOk(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return DeliveryMapper.listFromJson(body['deliveries'] as List<dynamic>);
  }

  Future<DeliveryDto> fetchById(String id) async {
    if (_config.useLocalFixtures) {
      final all = await _loadFixtures();
      return all.firstWhere(
        (d) => d.id == id,
        orElse: () => throw const ApiException('Delivery not found'),
      );
    }

    final response = await _http.get(
      Uri.parse('${_config.baseUrl}/v1/rider/deliveries/$id'),
    );
    _ensureOk(response);
    return DeliveryDto.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<DeliveryDto> updateStatus({
    required String id,
    required StatusUpdateRequest request,
  }) async {
    if (request.status == DeliveryStatus.outForDelivery) {
      throw const ApiException('Cannot set status back to out_for_delivery');
    }

    if (_config.useLocalFixtures) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final all = await _loadFixtures();
      final index = all.indexWhere((d) => d.id == id);
      if (index < 0) {
        throw const ApiException('Delivery not found');
      }
      final current = all[index];
      final note = DisplayHelpers.nullableText(request.note);
      final updated = DeliveryDto(
        id: current.id,
        orderCode: current.orderCode,
        status: request.status.apiValue,
        customerName: current.customerName,
        customerPhone: current.customerPhone,
        addressLine: current.addressLine,
        landmark: current.landmark,
        city: current.city,
        pincode: current.pincode,
        lat: current.lat,
        lng: current.lng,
        itemSummary: current.itemSummary,
        codAmount: current.codAmount,
        notes: note ?? current.notes,
        photoUrl: request.photoStubPath ?? current.photoUrl,
        failureReason: request.status == DeliveryStatus.deliveryFailed
            ? (note ?? 'Unspecified')
            : null,
        assignedAt: current.assignedAt,
      );
      all[index] = updated;
      return updated;
    }

    final response = await _http.post(
      Uri.parse('${_config.baseUrl}/v1/rider/deliveries/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'status': request.status.apiValue,
        if (DisplayHelpers.hasText(request.note)) 'note': request.note!.trim(),
        if (DisplayHelpers.hasText(request.photoStubPath))
          'photo_stub': request.photoStubPath,
      }),
    );
    _ensureOk(response);
    return DeliveryDto.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<DeliveryDto>> _loadFixtures() async {
    if (_cache != null) return _cache!;
    final raw = await _bundle.loadString('assets/fixtures/deliveries.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _cache = DeliveryMapper.listFromJson(list).toList();
    return _cache!;
  }

  void _ensureOk(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'API ${response.statusCode}: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  void dispose() => _http.close();
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
