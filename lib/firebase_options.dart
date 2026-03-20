import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyClFVK41oHJ4zDaMR_CXZsiuT6emCbOeSg',
    appId: '1:992268766344:android:fd761cd3bbf997ddc6a33d',
    messagingSenderId: '992268766344',
    projectId: 'expense--tracking--app',
    authDomain: 'expense--tracking--app.firebaseapp.com',
    storageBucket: 'expense--tracking--app.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyClFVK41oHJ4zDaMR_CXZsiuT6emCbOeSg',
    appId: '1:992268766344:android:fd761cd3bbf997ddc6a33d',
    messagingSenderId: '992268766344',
    projectId: 'expense--tracking--app',
    storageBucket: 'expense--tracking--app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyClFVK41oHJ4zDaMR_CXZsiuT6emCbOeSg',
    appId: '1:992268766344:ios:fd761cd3bbf997ddc6a33d',
    messagingSenderId: '992268766344',
    projectId: 'expense--tracking--app',
    storageBucket: 'expense--tracking--app.firebasestorage.app',
    iosBundleId: 'com.example.expenseTracking',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyClFVK41oHJ4zDaMR_CXZsiuT6emCbOeSg',
    appId: '1:992268766344:macos:fd761cd3bbf997ddc6a33d',
    messagingSenderId: '992268766344',
    projectId: 'expense--tracking--app',
    storageBucket: 'expense--tracking--app.firebasestorage.app',
    iosBundleId: 'com.example.expenseTracking',
  );
}