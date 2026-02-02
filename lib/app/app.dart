import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/notifications/data/notification_provider.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';

/// Root Couplr app widget. Uses Riverpod, GoRouter, and design tokens.
/// Respects system text scale (large text / accessibility).
/// Triggers notification bootstrap (init + daily schedule) on first build.
class CouplrApp extends ConsumerWidget {
  const CouplrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(notificationBootstrapProvider);
    final router = ref.watch(appRouterProvider);
    final theme = ref.watch(appThemeProvider);

    return MaterialApp.router(
      title: 'Couplr',
      debugShowCheckedModeBanner: false,
      theme: theme.light,
      darkTheme: theme.dark,
      themeMode: theme.mode,
      localizationsDelegates: const [],
      supportedLocales: const [
        Locale('en'),
      ],
      routerConfig: router,
    );
  }
}
