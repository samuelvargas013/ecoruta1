import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'firebase_options.dart';

/// Handler de notificaciones en segundo plano (FCM). Debe ser top-level.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // Procesamiento mínimo en background. Personalizable según necesidades.
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Inicializa Firebase con las opciones generadas por flutterfire configure.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2) Notificaciones push (FCM).
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  await FirebaseMessaging.instance.requestPermission();

  // 3) Inyección de dependencias (get_it).
  await initDependencies();

  runApp(const EcoRutaApp());
}
