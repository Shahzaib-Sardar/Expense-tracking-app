import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'config/app_env.dart';

class DefaultFirebaseOptions {
  // Keep Firebase config outside tracked source by pulling values from
  // --dart-define or .env through AppEnv.
  static String get _apiKey => AppEnv.read('FIREBASE_API_KEY', required: true);
  static String get _projectId =>
    AppEnv.read('FIREBASE_PROJECT_ID', required: true);
  static String get _messagingSenderId =>
    AppEnv.read('FIREBASE_MESSAGING_SENDER_ID', required: true);
  static String get _storageBucket =>
    AppEnv.read('FIREBASE_STORAGE_BUCKET', required: true);
  static String get _authDomain =>
    AppEnv.read('FIREBASE_AUTH_DOMAIN', required: true);
  static String get _appIdAndroid =>
    AppEnv.read('FIREBASE_APP_ID_ANDROID', required: true);
  static String get _appIdIos =>
    AppEnv.read('FIREBASE_APP_ID_IOS', required: true);
  static String get _appIdMacos =>
    AppEnv.read('FIREBASE_APP_ID_MACOS', required: true);
  static String get _appIdWeb =>
    AppEnv.read('FIREBASE_APP_ID_WEB', required: true);
  static String get _iosBundleId =>
    AppEnv.read('FIREBASE_IOS_BUNDLE_ID', required: true);
  static String get _macosBundleId =>
    AppEnv.read('FIREBASE_MACOS_BUNDLE_ID', required: true);

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static final FirebaseOptions web = FirebaseOptions(
    apiKey: _apiKey,
    appId: _appIdWeb,
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    authDomain: _authDomain,
    storageBucket: _storageBucket,
  );

  static final FirebaseOptions android = FirebaseOptions(
    apiKey: _apiKey,
    appId: _appIdAndroid,
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
  );

  static final FirebaseOptions ios = FirebaseOptions(
    apiKey: _apiKey,
    appId: _appIdIos,
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
    iosBundleId: _iosBundleId,
  );

  static final FirebaseOptions macos = FirebaseOptions(
    apiKey: _apiKey,
    appId: _appIdMacos,
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
    iosBundleId: _macosBundleId,
  );
}