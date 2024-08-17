// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        return windows;
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
    apiKey: 'AIzaSyChCCouMl-j5WB-u5NmiqE644VY1qZo4iE',
    appId: '1:974273655835:web:3ceee69090fc1008ae74be',
    messagingSenderId: '974273655835',
    projectId: 'roamify-c0130',
    authDomain: 'roamify-c0130.firebaseapp.com',
    storageBucket: 'roamify-c0130.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAB3igm4SFcKsIFtxaTgnAKwD2mhlwyiBg',
    appId: '1:974273655835:android:dda252d0f656bb44ae74be',
    messagingSenderId: '974273655835',
    projectId: 'roamify-c0130',
    storageBucket: 'roamify-c0130.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD5LX1zUVRQkMZ1zRtIJIH5qN9yf_PEcas',
    appId: '1:974273655835:ios:77f389a64a3c6fadae74be',
    messagingSenderId: '974273655835',
    projectId: 'roamify-c0130',
    storageBucket: 'roamify-c0130.appspot.com',
    iosBundleId: 'com.example.roamify',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD5LX1zUVRQkMZ1zRtIJIH5qN9yf_PEcas',
    appId: '1:974273655835:ios:77f389a64a3c6fadae74be',
    messagingSenderId: '974273655835',
    projectId: 'roamify-c0130',
    storageBucket: 'roamify-c0130.appspot.com',
    iosBundleId: 'com.example.roamify',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyChCCouMl-j5WB-u5NmiqE644VY1qZo4iE',
    appId: '1:974273655835:web:cc9a46e8e3b6f712ae74be',
    messagingSenderId: '974273655835',
    projectId: 'roamify-c0130',
    authDomain: 'roamify-c0130.firebaseapp.com',
    storageBucket: 'roamify-c0130.appspot.com',
  );
}