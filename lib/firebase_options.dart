// File generated using FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAqeWzDPi3OV4QmnKoa-wrJvZK_4-C48wk',
    appId: '1:694518951456:android:86b8f826a2c553aeb91645',
    messagingSenderId: '694518951456',
    projectId: 'cownect-6956b',
    storageBucket: 'cownect-6956b.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAqeWzDPi3OV4QmnKoa-wrJvZK_4-C48wk',
    appId: '1:694518951456:windows:86b8f826a2c553aeb91645', // ⚠️ REEMPLAZAR con el App ID real de Firebase Console
    messagingSenderId: '694518951456',
    projectId: 'cownect-6956b',
    storageBucket: 'cownect-6956b.firebasestorage.app',
    authDomain: 'cownect-6956b.firebaseapp.com',
    // INSTRUCCIONES PARA OBTENER EL APP ID CORRECTO:
    // 1. Ve a: https://console.firebase.google.com/project/cownect-6956b/settings/general
    // 2. En "Tus apps", busca o crea la app de Windows
    // 3. Copia el "App ID" (formato: 1:694518951456:windows:XXXXXXXXX)
    // 4. Reemplaza el appId arriba con el valor real
  );
}

