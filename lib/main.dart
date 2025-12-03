
import 'package:flutter/services.dart'; // N'oublie pas cet import

import 'package:flutter/material.dart';
import 'src/app.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

// --- AJOUTS ---
import 'package:maparoisse/src/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Importer FCM
// --- FIN AJOUTS ---


// --- NOUVEAU GESTIONNAIRE DE FOND ---
// DOIT être en dehors d'une classe (top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 1. Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print("--- Message de FOND reçu ---");
  print("Data: ${message.data}");

  // 2. Appeler le service pour AFFICHER la notification
  // On crée une instance (c'est un singleton, donc c'est OK)
  final notificationService = NotificationService();

  // 3. On initialise le plugin local (obligatoire dans le handler)
  await notificationService.initLocalNotifications();

  // 4. On affiche la notification
  await notificationService.showLocalNotification(message);
}
// --- FIN DU GESTIONNAIRE ---


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);



  // --- NOUVEAU : ACTIVATION DU EDGE-TO-EDGE ---
  // 1. On active le mode plein écran total
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // 2. On définit les barres comme transparentes
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Haut transparent
    systemNavigationBarColor: Colors.transparent, // Bas transparent
    // Icônes sombres ou claires selon ton thème (ici sombres pour fond clair)
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  // --------------------------------------------


  // 1. Initialise Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. ENREGISTRE LE GESTIONNAIRE DE FOND (TRÈS IMPORTANT)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 3. Initialise le service pour le premier plan (foreground)
  // Ton appel est correct car NotificationService est un singleton
  await NotificationService().init();

  runApp(const ParoisseApp());
}