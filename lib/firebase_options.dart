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
    apiKey: 'AIzaSyA8JiHBH0Dc2m90j5cnK5EGWb4wmCydZ6o',
    appId: '1:970646820738:web:b6f7ab7965c8f93448a19b',
    messagingSenderId: '970646820738',
    projectId: 'zezo-6778a',
    authDomain: 'zezo-6778a.firebaseapp.com',
    storageBucket: 'zezo-6778a.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA5bpBHPLO8ipe2NbNIBU-K8SOUtveSlw4',
    appId: '1:970646820738:android:a6dc50da3c995deb48a19b',
    messagingSenderId: '970646820738',
    projectId: 'zezo-6778a',
    storageBucket: 'zezo-6778a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAIYErzxTLnZj3c5zGFzmyGrj1zay7Yskc',
    appId: '1:970646820738:ios:e34c49c7378a14ed48a19b',
    messagingSenderId: '970646820738',
    projectId: 'zezo-6778a',
    storageBucket: 'zezo-6778a.appspot.com',
    iosBundleId: 'com.example.zezo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAIYErzxTLnZj3c5zGFzmyGrj1zay7Yskc',
    appId: '1:970646820738:ios:e34c49c7378a14ed48a19b',
    messagingSenderId: '970646820738',
    projectId: 'zezo-6778a',
    storageBucket: 'zezo-6778a.appspot.com',
    iosBundleId: 'com.example.zezo',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA8JiHBH0Dc2m90j5cnK5EGWb4wmCydZ6o',
    appId: '1:970646820738:web:026a963454c50bf448a19b',
    messagingSenderId: '970646820738',
    projectId: 'zezo-6778a',
    authDomain: 'zezo-6778a.firebaseapp.com',
    storageBucket: 'zezo-6778a.appspot.com',
  );
}
