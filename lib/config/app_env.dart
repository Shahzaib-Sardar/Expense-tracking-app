import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  AppEnv._();

  // Precedence: --dart-define > .env > fallback.
  // This allows secure CI/CD injection while keeping local dev simple.
  static String read(
    String key, {
    String? fallback,
    bool required = false,
  }) {
    final fromDefine = _fromDefine(key);
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }

    final fromDotenv = dotenv.env[key]?.trim() ?? '';
    if (fromDotenv.isNotEmpty) {
      return fromDotenv;
    }

    if (fallback != null) {
      return fallback;
    }

    if (required) {
      throw StateError(
        'Missing required environment value for $key. '
        'Provide it in .env or with --dart-define=$key=...',
      );
    }

    return '';
  }

  static String _fromDefine(String key) {
    switch (key) {
      case 'FIREBASE_API_KEY':
        return const String.fromEnvironment('FIREBASE_API_KEY').trim();
      case 'FIREBASE_PROJECT_ID':
        return const String.fromEnvironment('FIREBASE_PROJECT_ID').trim();
      case 'FIREBASE_MESSAGING_SENDER_ID':
        return const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID').trim();
      case 'FIREBASE_STORAGE_BUCKET':
        return const String.fromEnvironment('FIREBASE_STORAGE_BUCKET').trim();
      case 'FIREBASE_AUTH_DOMAIN':
        return const String.fromEnvironment('FIREBASE_AUTH_DOMAIN').trim();
      case 'FIREBASE_APP_ID_ANDROID':
        return const String.fromEnvironment('FIREBASE_APP_ID_ANDROID').trim();
      case 'FIREBASE_APP_ID_IOS':
        return const String.fromEnvironment('FIREBASE_APP_ID_IOS').trim();
      case 'FIREBASE_APP_ID_MACOS':
        return const String.fromEnvironment('FIREBASE_APP_ID_MACOS').trim();
      case 'FIREBASE_APP_ID_WEB':
        return const String.fromEnvironment('FIREBASE_APP_ID_WEB').trim();
      case 'FIREBASE_IOS_BUNDLE_ID':
        return const String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID').trim();
      case 'FIREBASE_MACOS_BUNDLE_ID':
        return const String.fromEnvironment('FIREBASE_MACOS_BUNDLE_ID').trim();
      default:
        return '';
    }
  }
}
