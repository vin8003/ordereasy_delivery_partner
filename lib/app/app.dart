import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';
import 'router.dart';
import 'theme.dart';

class OrderEasyDeliveryApp extends ConsumerWidget {
  const OrderEasyDeliveryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final config = ref.watch(appConfigProvider);

    return MaterialApp.router(
      title: 'OrderEasy Delivery',
      theme: buildAppTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Banner(
          message: config.useLocalFixtures ? 'FIXTURES' : 'LOCAL API',
          location: BannerLocation.topEnd,
          color: const Color(0xFF0F6B4C),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
