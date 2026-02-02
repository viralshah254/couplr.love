import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads environment variables from .env files.
/// Call [load] before runApp (e.g. in bootstrap).
class EnvLoader {
  static bool _loaded = false;

  static Future<void> load({String filename = '.env'}) async {
    if (_loaded) return;
    try {
      await dotenv.load(fileName: 'assets/env/$filename');
    } catch (_) {
      await dotenv.load(fileName: 'assets/env/default.env');
    }
    _loaded = true;
  }

  static String get(String key, {String fallback = ''}) {
    return dotenv.env[key] ?? fallback;
  }

  static bool getBool(String key, {bool fallback = false}) {
    final v = dotenv.env[key]?.toLowerCase();
    return v == 'true' || v == '1';
  }

  static int getInt(String key, {int fallback = 0}) {
    return int.tryParse(dotenv.env[key] ?? '') ?? fallback;
  }
}
