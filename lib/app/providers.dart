import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/app_config.dart';
import '../data/datasources/dummy_delivery_api.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/delivery_repository_impl.dart';
import '../domain/models/delivery.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/delivery_repository.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main()');
});

final dummyApiProvider = Provider<DummyDeliveryApi>((ref) {
  final api = DummyDeliveryApi(config: ref.watch(appConfigProvider));
  ref.onDispose(api.dispose);
  return api;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    api: ref.watch(dummyApiProvider),
    prefs: ref.watch(sharedPreferencesProvider),
  );
});

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return DeliveryRepositoryImpl(api: ref.watch(dummyApiProvider));
});

final authSessionProvider =
    StateNotifierProvider<AuthSessionController, AsyncValue<RiderSession?>>(
  (ref) => AuthSessionController(ref.watch(authRepositoryProvider)),
);

class AuthSessionController
    extends StateNotifier<AsyncValue<RiderSession?>> {
  AuthSessionController(this._repo) : super(const AsyncValue.loading()) {
    restore();
  }

  final AuthRepository _repo;

  Future<void> restore() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.restoreSession);
  }

  Future<void> login({required String phone, required String pin}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repo.login(phone: phone, pin: pin),
    );
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncValue.data(null);
  }
}

final assignedDeliveriesProvider =
    AsyncNotifierProvider<AssignedDeliveriesNotifier, List<Delivery>>(
  AssignedDeliveriesNotifier.new,
);

class AssignedDeliveriesNotifier extends AsyncNotifier<List<Delivery>> {
  @override
  Future<List<Delivery>> build() {
    return ref.read(deliveryRepositoryProvider).fetchAssignedDeliveries();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(deliveryRepositoryProvider).fetchAssignedDeliveries(),
    );
  }
}

final deliveryDetailProvider =
    FutureProvider.family<Delivery, String>((ref, id) {
  return ref.watch(deliveryRepositoryProvider).fetchDelivery(id);
});
