import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:maparoisse/src/services/navigation_service.dart'; // Notre clé globale
import 'dart:convert';

import 'package:flutter/material.dart'; // Nécessaire pour MaterialPageRoute
import 'package:provider/provider.dart'; // Pour accéder à AuthService
import 'package:maparoisse/src/services/auth_service.dart'; // Ton service
// Importe tes écrans de détails (vérifie les chemins)
import 'package:maparoisse/src/screens/home/event_details_screen.dart';
import 'package:maparoisse/src/screens/home/request_details_screen.dart';
import 'package:maparoisse/src/screens/home/notifications_screen.dart';


class NotificationService {

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();


  // --- MODIFICATION 1 : Nouvel ID pour forcer le SON ---
  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'maparoisse_channel_v2', // <--- J'ai changé le nom (v2) pour réinitialiser les réglages Android
    'Notifications MaParoisse',
    description: 'Notifications importantes (Messes, événements)',
    importance: Importance.max,
    playSound: true, // On force le son ici
  );


  /// 1. MÉTHODE PRINCIPALE D'INITIALISATION
  Future<void> init() async {
    await _fcm.requestPermission();
    await initLocalNotifications();
    _listenForForegroundMessages();
    await _listenForNotificationTaps();
  }

  /// 2. Initialise le plugin de notification locale (DEVIENT PUBLIQUE)
  Future<void> initLocalNotifications() async {

    // --- AJOUT 2 : Créer le canal ---
    // On doit créer le canal AVANT d'initialiser le plugin
    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
    // --- FIN AJOUT 2 ---

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_notification');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final String? payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          try {
            final Map<String, dynamic> data = jsonDecode(payload);
            final String? type = data['type']?.toString();
            final String? id = data['id']?.toString();

            if (type != null && id != null) {
              _handleNavigation(type: type, id: id);
            }
          } catch (e) {
            print("Erreur décodage payload local: $e");
          }
        }
      },
    );
  }

  /// 3. Écouteur pour les messages LORSQUE L'APP EST OUVERTE
  void _listenForForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("--- Message reçu (Foreground) ---");
      showLocalNotification(message);
    });
  }

  /// 4. Écouteur pour les CLICS sur une notification (App en fond ou fermée)
  Future<void> _listenForNotificationTaps() async {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("--- Clic sur notification (Background) ---");
      _handleDataNavigation(message.data);
    });

    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      print("--- Clic sur notification (Terminée) ---");
      _handleDataNavigation(initialMessage.data);
    }
  }





  /// 5. Affiche le pop-up (notification locale)
  Future<void> showLocalNotification(RemoteMessage message) async {
    String title = message.notification?.title ?? message.data['title'] ?? 'Nouvelle Notification';
    String body = message.notification?.body ?? message.data['body'] ?? 'Vous avez un nouveau message.';

    final String? type = message.data['type'];
    String? id;

    // --- CORRECTION : On gère les types EXACTS envoyés par Laravel ---
    if (type == 'messe_confirmee' || type == 'messe_en_attente_paiement' || type == 'request_update') {
      id = message.data['messe_id']?.toString() ?? message.data['request_id']?.toString();
    } else if (type == 'event') {
      id = message.data['event_id']?.toString();
    }

    String? notificationPayload;
    if (type != null) {
      // On passe le payload pour le clic
      notificationPayload = jsonEncode({
        'type': type,
        'id': id ?? '0' // ID par défaut si null
      });
    }

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_notification',
          playSound: true, // Son activé
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
      payload: notificationPayload,
    );
  }



  /// 6. Gère la navigation basée sur les "data"
  static void _handleDataNavigation(Map<String, dynamic> data) {
    print("[NavigationService] Payload reçu : $data");
    final String? type = data['type'];
    String? id;

    // Adaptation aux clés Laravel
    if (type == 'messe_confirmee' || type == 'messe_en_attente_paiement') {
      id = data['messe_id']?.toString();
    } else if (type == 'event') {
      id = data['event_id']?.toString();
    }

    if (type != null) {
      _handleNavigation(type: type, id: id);
    }
  }





  static Future<void> _handleNavigation({required String type, String? id}) async {
    final navigator = NavigationService.navigatorKey.currentState;
    final context = NavigationService.navigatorKey.currentContext;

    if (navigator == null || context == null || id == null) return;

    // Petit helper pour afficher les erreurs en Release
    void showDebugAlert(String title, String content) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
        ),
      );
    }

    // Loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFFC0A040))),
    );

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      // ==================================================
      // CAS 1 : ÉVÉNEMENT
      // ==================================================
      if (type == 'event') {
        final rawEvents = await authService.getEvents();

        // Recherche (comparaison String pour être sûr)
        final targetEvent = rawEvents.firstWhere(
              (e) => e['id'].toString() == id.toString(),
          orElse: () => null,
        );

        Navigator.of(context, rootNavigator: true).pop(); // Ferme le loader

        if (targetEvent != null) {
          navigator.push(
            MaterialPageRoute(
              // ✅ NOM CORRECT : eventData (vérifié dans ton EventDetailsScreen)
              builder: (_) => EventDetailsScreen(eventData: targetEvent),
            ),
          );
        } else {
          showDebugAlert("Erreur", "Événement introuvable (ID: $id)");
          navigator.push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
        }
      }

      // ==================================================
      // CAS 2 : MESSE / DEMANDE
      // ==================================================
      else if (type == 'messe_confirmee' || type == 'messe_en_attente_paiement' || type == 'request_update') {

        final requests = await authService.getMassRequests();

        // Recherche (comparaison String)
        // On utilise firstWhere avec orElse qui retourne null pour vérifier proprement
        final Map<String, dynamic>? targetRequest = requests.firstWhere(
              (r) => r['id'].toString() == id.toString(),
          orElse: () => {}, // Retourne map vide
        );

        Navigator.of(context, rootNavigator: true).pop(); // Ferme le loader

        if (targetRequest != null && targetRequest.isNotEmpty) {
          navigator.push(
            MaterialPageRoute(
              builder: (_) => RequestDetailsScreen(
                // ✅ CORRECTION MAJEURE ICI : initialData
                initialData: targetRequest,
              ),
            ),
          );
        } else {
          showDebugAlert("Info", "Demande introuvable (ID: $id).\nPeut-être supprimée ?");
          navigator.push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
        }
      }

      // ==================================================
      // CAS 3 : AUTRE
      // ==================================================
      else {
        Navigator.of(context, rootNavigator: true).pop();
        navigator.push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
      }

    } catch (e) {
      // Ferme le loader si encore ouvert
      try { Navigator.of(context, rootNavigator: true).pop(); } catch (_) {}

      // Affiche l'erreur sur l'écran pour que tu la voies en Release
      showDebugAlert("Erreur Technique", "Détail: $e");

      navigator.push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
    }
  }



  /// Demande la permission et récupère le Token FCM.
  Future<String?> initializeAndGetToken() async {
    bool permissionGranted = await _requestPermission();
    if (!permissionGranted) {
      print("[NotificationService] Permission de notification refusée.");
      return null;
    }
    return await getToken();
  }

  /// Demande la permission de recevoir des notifications.
  Future<bool> _requestPermission() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Récupère le token FCM unique de l'appareil.
  Future<String?> getToken() async {
    try {
      String? token = await _fcm.getToken();
      print("--- [NotificationService] Token FCM ---");
      print(token);
      print("---------------------------------------");
      return token;
    } catch (e) {
      print("[NotificationService] Erreur lors de la récupération du token: $e");
      return null;
    }
  }

  /// Gère la déconnexion.
  Future<void> handleLogout() async {
    try {
      await _fcm.deleteToken();
      print("[NotificationService] Token FCM local effacé.");
    } catch (e) {
      print("[NotificationService] Erreur lors de la suppression du token: $e");
    }
  }
}