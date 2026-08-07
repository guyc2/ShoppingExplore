// File generated manually to bypass Windows CLI bug
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAYLzwsl3wQp0EW-K3-pAH2Tc3pxRTSyNo',
    appId: '1:166863472939:web:c31f60d0468cb761b2dd6e',
    messagingSenderId: '166863472939',
    projectId: 'shoppingexplore-f0ad2',
    authDomain: 'shoppingexplore-f0ad2.firebaseapp.com',
    storageBucket: 'shoppingexplore-f0ad2.firebasestorage.app',
    measurementId: 'G-E5ZP8SQNCQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAYLzwsl3wQp0EW-K3-pAH2Tc3pxRTSyNo',
    appId: '1:166863472939:web:c31f60d0468cb761b2dd6e',
    messagingSenderId: '166863472939',
    projectId: 'shoppingexplore-f0ad2',
    authDomain: 'shoppingexplore-f0ad2.firebaseapp.com',
    storageBucket: 'shoppingexplore-f0ad2.firebasestorage.app',
    measurementId: 'G-E5ZP8SQNCQ',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAYLzwsl3wQp0EW-K3-pAH2Tc3pxRTSyNo',
    appId: '1:166863472939:web:c31f60d0468cb761b2dd6e',
    messagingSenderId: '166863472939',
    projectId: 'shoppingexplore-f0ad2',
    authDomain: 'shoppingexplore-f0ad2.firebaseapp.com',
    storageBucket: 'shoppingexplore-f0ad2.firebasestorage.app',
    measurementId: 'G-E5ZP8SQNCQ',
  );
}
