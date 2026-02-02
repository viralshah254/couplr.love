import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/env/env_loader.dart';
import '../core/logging/app_logger.dart';
import 'app.dart';

/// Initializes env, logging, crash reporting hooks, DI, then runs the app.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvLoader.load();
  AppLogger.init();

  // Crash reporting: log Flutter framework errors and uncaught async errors.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.error(
      'FlutterError: ${details.exception}',
      details.exception,
      details.stack,
    );
  };

  runZonedGuarded(() {
    runApp(
      const ProviderScope(
        child: CouplrApp(),
      ),
    );
  }, (error, stack) {
    AppLogger.error('Uncaught error', error, stack);
  });

  // Platform dispatcher errors (e.g. from native or plugin).
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('PlatformDispatcher error', error, stack);
    return true;
  };
}
