import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'env_loader.dart';

enum AppFlavor { dev, staging, prod }

final appFlavorProvider = Provider<AppFlavor>((ref) {
  final name = EnvLoader.get('FLAVOR', fallback: 'dev');
  return AppFlavor.values.firstWhere(
    (f) => f.name == name.toLowerCase(),
    orElse: () => AppFlavor.dev,
  );
});
