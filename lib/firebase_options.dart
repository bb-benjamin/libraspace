import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCjYTeWO-REPR1Tj5JbuygIj13-AMQ5-Pc',
    appId: '1:639965948137:android:150fe94567b51b7ec56878',
    messagingSenderId: '639965948137',
    projectId: 'libraspace-cc7da',
    storageBucket: 'libraspace-cc7da.firebasestorage.app',
  );
}
