import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Default [FirebaseOptions] for use with your Firebase apps.
/// Configuration values are dynamically loaded from environment (.env)
/// or compile-time variables (--dart-define).
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

  static String get _apiKey =>
      dotenv.env['FIREBASE_API_KEY'] ??
      const String.fromEnvironment('FIREBASE_API_KEY');

  static String get _appId =>
      dotenv.env['FIREBASE_APP_ID'] ??
      const String.fromEnvironment(
        'FIREBASE_APP_ID',
        defaultValue: '1:166863472939:web:c31f60d0468cb761b2dd6e',
      );

  static String get _messagingSenderId =>
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ??
      const String.fromEnvironment(
        'FIREBASE_MESSAGING_SENDER_ID',
        defaultValue: '166863472939',
      );

  static String get _projectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ??
      const String.fromEnvironment(
        'FIREBASE_PROJECT_ID',
        defaultValue: 'shoppingexplore-f0ad2',
      );

  static String get _authDomain =>
      dotenv.env['FIREBASE_AUTH_DOMAIN'] ??
      const String.fromEnvironment(
        'FIREBASE_AUTH_DOMAIN',
        defaultValue: 'shoppingexplore-f0ad2.firebaseapp.com',
      );

  static String get _storageBucket =>
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ??
      const String.fromEnvironment(
        'FIREBASE_STORAGE_BUCKET',
        defaultValue: 'shoppingexplore-f0ad2.firebasestorage.app',
      );

  static String get _measurementId =>
      dotenv.env['FIREBASE_MEASUREMENT_ID'] ??
      const String.fromEnvironment(
        'FIREBASE_MEASUREMENT_ID',
        defaultValue: 'G-E5ZP8SQNCQ',
      );

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: _apiKey,
        appId: _appId,
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        authDomain: _authDomain,
        storageBucket: _storageBucket,
        measurementId: _measurementId,
      );

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: _apiKey,
        appId: _appId,
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        authDomain: _authDomain,
        storageBucket: _storageBucket,
        measurementId: _measurementId,
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: _apiKey,
        appId: _appId,
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        authDomain: _authDomain,
        storageBucket: _storageBucket,
        measurementId: _measurementId,
      );
}
