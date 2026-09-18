import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/deliveries/delivery_detail_screen.dart';
import '../features/deliveries/delivery_list_screen.dart';
import '../features/deliveries/mark_status_screen.dart';
import '../features/splash/splash_screen.dart';
import 'providers.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authSessionProvider, (_, __) {
    refresh.value++;
  });
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authSessionProvider);
      final loc = state.matchedLocation;
      final onSplash = loc == '/splash';
      final onLogin = loc == '/login';

      if (auth.isLoading || auth.isRefreshing) {
        return onSplash ? null : '/splash';
      }

      final session = auth.asData?.value;
      final loggedIn = session != null;

      if (!loggedIn) {
        return onLogin ? null : '/login';
      }

      if (onSplash || onLogin) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const DeliveryListScreen(),
      ),
      GoRoute(
        path: '/deliveries/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DeliveryDetailScreen(deliveryId: id);
        },
        routes: [
          GoRoute(
            path: 'mark',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              final outcome = state.uri.queryParameters['outcome'] ?? 'delivered';
              return MarkStatusScreen(deliveryId: id, outcome: outcome);
            },
          ),
        ],
      ),
    ],
  );
});
