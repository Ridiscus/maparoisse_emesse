
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // <-- 1. Importer http
import 'dart:convert'; // <-- 2. Importer dart:convert pour json
import 'package:maparoisse/src/services/notification_service.dart';
import 'package:maparoisse/src/models/notification_model.dart';
import 'package:maparoisse/src/services/navigation_service.dart'; // Notre clé de navigation
import 'package:flutter/material.dart'; // Pour le (route) => false
import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'; // <--- 1. IMPORT OBLIGATOIRE

import 'package:sign_in_with_apple/sign_in_with_apple.dart';




class AuthService extends ChangeNotifier {
  // --- NOUVELLE BASE URL POUR L'API ---


  static const String _baseUrl = "https://e-messe-ci.com/api";


  // --- 1. AJOUTE CETTE LIGNE ---
  /// La liste des notifications en cache pour l'application.
  List<NotificationModel>? _notifications;
  // --- FIN AJOUT ---


  // --- MODIFICATION ---
  // Au lieu de créer une nouvelle instance, il récupère le singleton
  final NotificationService _notificationService = NotificationService();
  // --- FIN MODIFICATION ---

  // --- NOUVELLES CLÉS DE STOCKAGE ---
  // On ne stocke plus que le Token et les infos utilisateur (plus de mot de passe !)
  static const String _keyToken = "api_token";
  static const String _keyIsLoggedIn = "is_logged_in";
  static const String _keyId = "user_id";
  static const String _keyFullName = "full_name";
  static const String _keyUsername = "username";
  static const String _keyEmail = "email";
  static const String _keyPhone = "phone";
  static const String _keyPhoto = "photo_path";
  static const String _keyCivilite = "civilité";
  static const String _keyEstBaptise = "est_baptise";
  // Les clés _keyPassword, _keyGoogleId, _keyLoginMethod sont supprimées car gérées par l'API



  // --- Variables d'état ---
  bool _isAuthenticated = false;
  String? _token; // <-- Variable pour garder le token en mémoire
  int? _id;
  String? _fullName;
  String? _username;
  String? _email;
  String? _phone;
  String? _photoPath;
  String? _civilite;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  int? get id => _id;
  String? get fullName => _fullName;
  String? get username => _username;
  String? get email => _email;
  String? get phone => _phone;


  // ✅ REMPLACE LA LIGNE "String? get photoPath => _photoPath;" PAR CECI :

  String? get photoPath {
    // 1. Si vide, on renvoie null
    if (_photoPath == null || _photoPath!.isEmpty) {
      return null;
    }

    // 🚨 2. LE FIX "FRANKENSTEIN" (C'est ça qui répare ton erreur actuelle)
    // Si l'URL contient ".../storage/https...", on coupe tout ce qu'il y a avant "https"
    if (_photoPath!.contains('/storage/http')) {
      // On trouve où commence le "http" imbriqué et on ne garde que la fin
      int indexHttp = _photoPath!.indexOf('http', 5); // On cherche 'http' après les 5 premiers caractères
      if (indexHttp != -1) {
        return _photoPath!.substring(indexHttp);
      }
    }

    // 3. Si c'est une URL Google/Apple propre (commence par http), on la renvoie telle quelle
    if (_photoPath!.startsWith('http')) {
      return _photoPath;
    }

    // 4. Sinon, c'est une image locale (ex: "profiles/toto.jpg"), on ajoute ton serveur
    String cleanPath = _photoPath!.startsWith('/') ? _photoPath!.substring(1) : _photoPath!;
    return "https://e-messe-ci.com/storage/$cleanPath";
  }


  String? get civilite => _civilite;
  bool _estBaptise = false;
  // 'get password' est supprimé


  static const String _keyGoogleId = "google_id";
  static const String _keyAppleId = "apple_id";


  String? _googleId;
  String? _appleId;


  // Getter pour savoir si l'utilisateur est baptisé
  bool get isBaptized => _estBaptise;


  // ✅ AJOUTE CE GETTER
  // Cela permet de savoir facilement si le profil est complet
  bool get estIdentifie {
    // Vérifie si les infos cruciales sont présentes
    // Tu peux ajouter d'autres conditions (ex: _paroisse != null)
    return _phone != null && _phone!.isNotEmpty &&
        _fullName != null && _fullName!.isNotEmpty;
  }

  // Headers communs pour les requêtes API
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers pour les requêtes authentifiées
  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $_token', // Ajoute le token
  };






  // ✅ NOUVEAU GETTER : Basé sur les données de ton Backend
  bool get isSocialUser {
    // Si l'utilisateur a un ID Google OU un ID Apple stocké, c'est un social user.
    return (_googleId != null && _googleId!.isNotEmpty) ||
        (_appleId != null && _appleId!.isNotEmpty);
  }



  /// REFACTORISÉ : Vérifie le token au démarrage en appelant GET /user
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString(_keyToken);

    if (storedToken == null || storedToken.isEmpty) {
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }

    _token = storedToken; // Charge le token en mémoire


    // --- AJOUT : Rechargement des IDs Sociaux ---
    _googleId = prefs.getString(_keyGoogleId);
    _appleId = prefs.getString(_keyAppleId);
    // -------------------------------------------

    // Tente de valider le token en récupérant les infos utilisateur
    try {
      final url = Uri.parse("$_baseUrl/user");
      final response = await http.get(url, headers: _authHeaders);

      if (response.statusCode == 200) {
        // Token valide
        final data = jsonDecode(response.body);
        final apiUser = data['user'];

        // Sauvegarde les infos à jour (sauf la civilité que l'API ne renvoie pas)
        await _saveAuthData(
          token: storedToken,
          user: apiUser,
          civilite: prefs.getString(_keyCivilite), // Conserve l'ancienne civilité
        );

        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        // Token invalide (ex: 401 Unauthorized)
        print("Token invalide, déconnexion...");
        await logout(apiCall: false); // Déconnecte localement
        return false;
      }
    } catch (e) {
      print("Erreur réseau isLoggedIn: $e");
      _isAuthenticated = false; // Pas de réseau, on suppose déconnecté
      notifyListeners();
      return false;
    }
  }



  Future<bool> register({
    required String fullName,
    required String username,
    required String email,
    required String phone,
    required String password,
    required String civilite,
    String? photoPath,
  }) async {
    final url = Uri.parse("$_baseUrl/auth/register");

    try {
      var request = http.MultipartRequest('POST', url);

      // ✅ 1. HEADER IMPORTANT : Force le serveur à répondre en JSON
      request.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });

      // Champs texte
      request.fields['name'] = fullName;
      request.fields['user_name'] = username;
      request.fields['email'] = email;
      request.fields['contact'] = phone;
      request.fields['password'] = password;
      request.fields['password_confirmation'] = password;
      request.fields['civilite'] = civilite;

      // Fichier image
      if (photoPath != null && photoPath.isNotEmpty) {
        var file = await http.MultipartFile.fromPath('profile_picture', photoPath);
        request.files.add(file);
      }

      print("--- Envoi Inscription vers $url ---");

      // Envoi avec Timeout
      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);

      print("Register Status: ${response.statusCode}");
      print("Register Body: ${response.body}"); // Pour le debug

      // --- CAS 1 : SUCCÈS (200 ou 201) ---
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Note: Vérifie si ton API renvoie 'token' ou 'access_token'
        // Je mets une sécurité pour prendre l'un ou l'autre
        String token = data['access_token'] ?? data['token'];

        await _saveAuthData(
          token: token,
          user: data['user'],
          civilite: civilite,
        );

        // FCM Token (Non bloquant)
        try {
          final String? fcmToken = await _notificationService.initializeAndGetToken();
          if (fcmToken != null) {
            _sendFCMTokenToBackend(fcmToken);
          }
        } catch (e) {
          print("Erreur FCM Register: $e");
        }

        return true;
      }

      // --- CAS 2 : ERREUR DE VALIDATION (422) ---
      // C'est ici qu'on attrape "Email has already been taken"
      else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        String message = data['message'] ?? "Erreur de validation";

        // Si l'API renvoie des détails précis (ex: Laravel)
        if (data['errors'] != null && data['errors'] is Map) {
          final errors = data['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            // On prend la première erreur de la liste
            final firstKey = errors.keys.first; // ex: "email"
            final firstErrorList = errors[firstKey]; // ex: ["The email has already been taken."]
            if (firstErrorList is List && firstErrorList.isNotEmpty) {
              message = firstErrorList.first;
            }
          }
        }

        throw Exception(message); // On renvoie le message précis (ex: "Email déjà pris")
      }

      // --- CAS 3 : AUTRES ERREURS (500, 404, etc.) ---
      else {
        // On évite de décoder le JSON ici car ça peut être du HTML (Erreur serveur)
        throw Exception("Erreur serveur (${response.statusCode}). Veuillez réessayer plus tard.");
      }

    } on SocketException catch (_) {
      throw Exception('Pas de connexion Internet. Vérifiez votre réseau.');
    } on TimeoutException catch (_) {
      throw Exception('Le serveur met trop de temps à répondre. Votre connexion est peut-être trop lente.');
    } catch (e) {
      print("Erreur Register (Catch): $e");
      // On nettoie le "Exception: " pour l'affichage
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }


  // 1. AJOUTE CE GETTER
  /// Vérifie s'il y a des notifications non lues dans la liste.
  bool get hasUnreadNotifications {
    // On vérifie si la liste existe et si un seul élément a "isRead == false"
    return _notifications?.any((notif) => !notif.isRead) ?? false;
  }




  /// Fonction publique appelée par le bouton UI
  Future<bool> signInWithApple() async {
    try {
      // 1. Ouvre la fenêtre native iOS
      final AuthorizationCredentialAppleID appleCredential =
      await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 2. Prépare les données
      // Attention : email/name peuvent être null après la 1ère connexion
      String? email = appleCredential.email;
      String? fullName;

      if (appleCredential.givenName != null || appleCredential.familyName != null) {
        fullName = "${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}".trim();
      }

      print("Apple Identity Token: ${appleCredential.identityToken?.substring(0, 20)}...");
      print("Apple User ID: ${appleCredential.userIdentifier}");

      // 3. Appelle ton API Backend (La fonction qu'on vient de créer au-dessus)
      if (appleCredential.identityToken != null) {
        return await loginWithApple(
          appleCredential.identityToken!,
          appleCredential.userIdentifier!, // C'est le 'apple_id'
          email,
          fullName,
        );
      }

      return false;

    } catch (e) {
      print("Erreur Flow Apple (Annulation ou autre): $e");
      return false;
    }
  }




  /// REFACTORISÉ : Connecte un utilisateur (Gestion erreurs Internet incluse)
  Future<bool> loginWithEmailOrUsername({
    required String loginInput,
    required String password,
  }) async {
    // 1. Ton URL existante
    final url = Uri.parse("$_baseUrl/auth/login");

    final body = jsonEncode({
      "login": loginInput,
      "password": password,
    });

    try {
      // 2. On ajoute un Timeout de 15s pour ne pas bloquer indéfiniment
      final response = await http.post(
        url,
        // J'utilise explicitement les headers JSON pour la sécurité du login
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      // --- CAS 1 : SUCCÈS ---
      if (response.statusCode == 200 && data['status'] == 'success') {
        final apiUser = data['user'];
        final token = data['access_token'];

        await _saveAuthData(
          token: token,
          user: apiUser,
          civilite: null,
        );

        // --- TON BLOC FCM (PRÉSERVÉ) ---
        try {
          final String? fcmToken = await _notificationService.initializeAndGetToken();
          if (fcmToken != null) {
            // Fais-le en arrière-plan
            _sendFCMTokenToBackend(fcmToken);
          }
        } catch (e) {
          print("Erreur lors de l'initialisation du token FCM (Login): $e");
        }
        // -------------------------------

        return true; // ✅ Tout est bon
      }

      // --- CAS 2 : ERREUR D'IDENTIFIANTS (401 ou status != success) ---
      else if (response.statusCode == 401 || response.statusCode == 422 || data['status'] == 'error') {
        print("Erreur Login (API): ${data['message']}");
        return false; // ❌ Retourne FALSE pour dire "Mauvais mot de passe"
      }

      // --- CAS 3 : ERREUR SERVEUR (500, 404...) ---
      else {
        throw Exception('Erreur serveur (${response.statusCode}). Veuillez réessayer plus tard.');
      }

    } on SocketException catch (_) {
      // ⚠️ CAS 4 : PAS D'INTERNET
      throw Exception('Pas de connexion Internet. Vérifiez votre réseau.');
    } on TimeoutException catch (_) {
      // ⚠️ CAS 5 : LE SERVEUR NE RÉPOND PAS
      throw Exception('Le serveur ne répond pas. Vérifiez votre connexion.');
    } catch (e) {
      print("Erreur Login (Inconnue): $e");
      // On relance l'erreur pour l'afficher dans le SnackBar
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }






  /// REFACTORISÉ : Déconnexion (Inchangé)
  Future<void> logout({bool apiCall = true}) async {

    // --- AJOUT : Informe le backend de la déconnexion du token FCM ---
    try {
      // --- CORRECTION ICI ---
      // Appelle la nouvelle fonction publique qui ne demande pas de permission
      final String? fcmToken = await _notificationService.getToken();
      // --- FIN CORRECTION ---

      if (fcmToken != null && _token != null) {
        // Appelle l'API 6 pour désenregistrer
        await http.post(
          Uri.parse("$_baseUrl/fcm-token/unregister"), // (API 6)
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token',
          },
          body: jsonEncode({
            "fcm_token": fcmToken
          }),
        );
      }
    } catch (e) {
      print("[AuthService] Erreur lors du désenregistrement du token FCM: $e");
    }


    if (apiCall && _token != null) {
      final url = Uri.parse("$_baseUrl/auth/logout");
      try {
        await http.post(url, headers: _authHeaders);
        print("Déconnexion API réussie.");
      } catch (e) {
        print("Erreur réseau lors de la déconnexion : $e");
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Efface tout pour être sûr

    // ... tes resets de variables ...
    _googleId = null; // <-- AJOUT
    _appleId = null;  // <-- AJOUT


    // --- AJOUT : Supprime le token localement sur l'appareil ---
    await _notificationService.handleLogout();
    // --- FIN AJOUT ---

    _isAuthenticated = false;
    _token = null;
    _id = null;
    _fullName = null;
    _username = null;
    _email = null;
    _phone = null;
    _photoPath = null;
    _civilite = null;
    notifyListeners();
  }





  /// --- NOUVEAU Helper (CORRIGÉ) : Sauvegarde les données post-connexion ---
  Future<void> _saveAuthData({
    required String token,
    required Map<String, dynamic> user,
    required String? civilite,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // ... (sauvegarde token, id, name, username, email, phone... inchangés) ...
    await prefs.setString(_keyToken, token);
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setInt(_keyId, user['id']);
    await prefs.setString(_keyFullName, user['name']);
    await prefs.setString(_keyUsername, user['user_name']);
    await prefs.setString(_keyEmail, user['email']);
    await prefs.setString(_keyPhone, user['contact']);

    // --- AJOUT : Sauvegarde des IDs Sociaux ---
    String? gId = user['google_id']?.toString();
    String? aId = user['apple_id']?.toString();

    if (gId != null) await prefs.setString(_keyGoogleId, gId);
    if (aId != null) await prefs.setString(_keyAppleId, aId);

    // Mise à jour des variables locales
    _googleId = gId;
    _appleId = aId;
    // ------------------------------------------


    // 1. On récupère la valeur qui est DÉJÀ stockée dans le téléphone
    // (Celle enregistrée quand il a rempli sa fiche)
    bool currentSavedStatus = prefs.getBool(_keyEstBaptise) ?? false;
    bool finalStatus = currentSavedStatus; // Par défaut, on garde l'ancienne valeur

    // 2. On vérifie si l'API nous envoie une info (Ce qui arrive au Login ou Update, mais PAS au démarrage)
    if (user.containsKey('est_baptise') && user['est_baptise'] != null) {
      // L'API contient l'info, donc on met à jour avec la valeur de l'API
      if (user['est_baptise'] == 1 || user['est_baptise'] == true || user['est_baptise'] == "1") {
        finalStatus = true;
      } else {
        finalStatus = false;
      }
    }
    // SINON : Si 'est_baptise' n'est pas dans le JSON, on garde 'finalStatus = currentSavedStatus'

    // 3. On sauvegarde la valeur finale (Ancienne ou Nouvelle)
    await prefs.setBool(_keyEstBaptise, finalStatus);
    _estBaptise = finalStatus;

    // ---------------------------------------


    // --- CORRECTION URL IMAGE ---
    String? finalPhotoUrl;
    if (user['profile_picture'] != null && (user['profile_picture'] as String).isNotEmpty) {
      String apiPhotoPath = user['profile_picture']; // Ex: "profiles/image.jpg"

      print("Chemin photo reçu de l'API : $apiPhotoPath");

      // Si c'est déjà une URL complète (au cas où)
      if (apiPhotoPath.startsWith('http://') || apiPhotoPath.startsWith('https://')) {
        finalPhotoUrl = apiPhotoPath;
      }
      // --- LA CORRECTION EST ICI ---
      // Si c'est un chemin relatif (ex: "profiles/..." ou "/profiles/...")
      // On ajoute le préfixe /storage/
      else {
        // Retire un / au début s'il y en a un pour éviter //
        if (apiPhotoPath.startsWith('/')) {
          apiPhotoPath = apiPhotoPath.substring(1);
        }
        // Ajoute le dossier "storage"
        finalPhotoUrl = "https://e-messe-ci.com/storage/" + apiPhotoPath;
      }
      // --- FIN CORRECTION ---

      await prefs.setString(_keyPhoto, finalPhotoUrl);
      print("URL photo sauvegardée (corrigée) : $finalPhotoUrl");

    } else {
      print("Aucune photo de profil reçue de l'API.");
      await prefs.remove(_keyPhoto);
    }
    // --- FIN CORRECTION URL ---

    if (civilite != null) {
      await prefs.setString(_keyCivilite, civilite);
    }

    // ... (M-À-J de l'état local... inchangé) ...
    _isAuthenticated = true;
    _token = token;
    _id = user['id'];
    _fullName = user['name'];
    _username = user['user_name'];
    _email = user['email'];
    _phone = user['contact'];
    _photoPath = finalPhotoUrl; // Utilise l'URL corrigée
    _civilite = prefs.getString(_keyCivilite);
    _estBaptise = finalStatus;

    notifyListeners();
  }





  /// REFACTORISÉ : Met à jour les informations du profil via API
  Future<bool> updateUserProfile({
    required String fullName,
    required String phone,
    required String? civilite,
    // --- CORRECTION : Accepte un File, pas un String "photoPath" ---
    required File? imageFile,
    // --- FIN CORRECTION ---
    required String? email,
    required String? username,
  }) async {
    if (!_isAuthenticated) return false;

    final url = Uri.parse("$_baseUrl/user");

    // --- CORRECTION MAJEURE : On passe de JSON à Multipart ---
    // On ne peut pas envoyer un fichier avec http.put() et jsonEncode
    // On doit utiliser une requête "Multipart"

    try {
      // 1. Crée la requête Multipart
      // Note: Le backend s'attend peut-être à POST au lieu de PUT pour les fichiers.
      // Si PUT échoue, essaie 'POST'
      var request = http.MultipartRequest('POST', url);

      // 2. Ajoute les en-têtes d'authentification
      request.headers.addAll(_authHeaders);

      // 3. Ajoute tous les champs TEXTE
      request.fields['name'] = fullName;
      request.fields['contact'] = phone;
      if (username != null) request.fields['user_name'] = username;
      if (email != null) request.fields['email'] = email;
      if (civilite != null) request.fields['civilite'] = civilite;

      // 4. Ajoute le FICHIER (seulement s'il a été changé)
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_picture', // C'est le nom de la clé que le backend attend
            imageFile.path,
          ),
        );
      }

      // 5. Envoie la requête
      var streamedResponse = await request.send();

      // 6. Lis la réponse
      var response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        // Met à jour les infos locales avec la réponse de l'API
        await _saveAuthData(
          token: _token!,
          user: data['user'],
          civilite: civilite,
        );
        print("Profil mis à jour avec succès.");
        return true;
      } else {
        print("Erreur updateUserProfile (API): ${data['message']}");
        return false;
      }
    } catch (e) {
      print("Erreur updateUserProfile (catch): $e");
      return false;
    }
  }





  /// REFACTORISÉ : Tente de changer le mot de passe via l'API
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (!_isAuthenticated) return false;

    final url = Uri.parse("$_baseUrl/user/change-password");

    final body = jsonEncode({
      "current_password": oldPassword,
      "password": newPassword,
      "password_confirmation": newPassword, // L'API attend une confirmation
    });

    try {
      final response = await http.post(url, headers: _authHeaders, body: body);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        print("Mot de passe changé avec succès.");
        return true;
      } else {
        print("Erreur changePassword (API): ${data['message']}");
        return false;
      }
    } catch (e) {
      print("Erreur changePassword (catch): $e");
      return false;
    }
  }


  /// NOUVEAU : Met à jour les préférences de notification via l'API
  Future<bool> updateNotificationSettings({
    required bool email,
    required bool sms,
    required bool push,
  }) async {
    // On a besoin de l'ID utilisateur, s'il n'est pas chargé, on échoue.
    if (!_isAuthenticated || _id == null) return false;

    final url = Uri.parse("$_baseUrl/users/$_id/notifications");

    final body = jsonEncode({
      "emailNotif": email,
      "smsNotif": sms,
      "pushNotif": push,
    });

    try {
      final response = await http.put(url, headers: _authHeaders, body: body);

      if (response.statusCode == 200) {
        print("Préférences de notification mises à jour.");
        return true;
      } else {
        final data = jsonDecode(response.body);
        print("Erreur updateNotificationSettings (API): ${data['message']}");
        return false;
      }
    } catch (e) {
      print("Erreur updateNotificationSettings (catch): $e");
      return false;
    }
  }




  /// Gère l'inscription ou la connexion d'un utilisateur via Google
  Future<bool> registerOrLoginGoogleUser({
    required String email,
    required String? fullName,
    required String googleId,
    required String? photoUrl,
  }) async {
    // TODO: Tu dois créer un endpoint API pour la connexion Google
    // Cette fonction (qui utilise SharedPreferences) n'est plus compatible
    // avec ta logique de base de données centralisée.

    // Exemple de ce qu'il faudra faire :
    // final response = await http.post("$_baseUrl/auth/google/callback",
    //    headers: _headers,
    //    body: jsonEncode({"email": email, "googleId": googleId, ... }));
    // if (response.statusCode == 200) {
    //    final data = jsonDecode(response.body);
    //    await _saveAuthData(token: data['token'], user: data['user'], civilite: null);
    //    return true;
    // }

    print("ERREUR: La connexion Google n'est pas connectée à l'API.");
    return false; // Échoue par défaut
  }





  // DANS LA CLASSE AuthService (fichier auth_service.dart)

  /// NOUVEAU (CORRIGÉ) : Récupère la liste de toutes les paroisses
  Future<List<dynamic>> getParishes() async {
    if (!_isAuthenticated) throw Exception('Non authentifié');

    final url = Uri.parse("$_baseUrl/paroisses/");
    try {

      final response = await _handleRequest(
          http.get(url, headers: _authHeaders)
      );

      final data = jsonDecode(response.body); // Décode la réponse

      // Vérifie le statut de la réponse API
      if (response.statusCode == 200 && data['status'] == 'success') {

        // --- CORRECTION ---
        // La liste est maintenant imbriquée dans data -> data -> data
        final List<dynamic> parishList = data['data']['data'];
        // --- FIN CORRECTION ---

        return parishList;
      } else {
        print("Erreur getParishes (API): ${data['message']}");
        throw Exception('Échec du chargement des paroisses');
      }
    } catch (e) {
      print("Erreur getParishes (catch): $e");
      throw Exception('Erreur réseau: $e');
    }
  }



  // DANS LA CLASSE AuthService (fichier auth_service.dart)

  /// NOUVEAU : Récupère la liste des paroisses favorites de l'utilisateur
  Future<List<dynamic>> getFavoriteParishes() async {
    if (!_isAuthenticated) throw Exception('Non authentifié');

    // Utilise le nouvel endpoint GET /favoris/
    final url = Uri.parse("$_baseUrl/favoris/");
    try {
      final response = await _handleRequest (http.get(url, headers: _authHeaders));


      final data = jsonDecode(response.body);

      // JE FAIS UNE SUPPOSITION SUR LA STRUCTURE DE LA RÉPONSE
      // J'assume que la réponse est similaire à /paroisses
      // { "status": "success", "data": { "data": [ ... favoris ... ] } }
      // OU { "status": "success", "data": [ ... favoris ... ] }

      if (response.statusCode == 200 && data['status'] == 'success') {

        // Adapte cette ligne en fonction de la vraie structure JSON de /favoris
        if (data['data'] is List) {
          return data['data']; // Si c'est { "data": [ ... ] }
        }
        if (data['data'] is Map && data['data']['data'] is List) {
          return data['data']['data']; // Si c'est { "data": { "data": [ ... ] } }
        }

        // Si la réponse est juste une liste [ ... ]
        // return data; // Décommente si l'API renvoie une liste directe

        print("Structure de /favoris non reconnue : ${data}");
        return [];

      } else {
        print("Erreur getFavoriteParishes (API): ${data['message']}");
        throw Exception('Échec du chargement des favoris');
      }
    } catch (e) {
      print("Erreur getFavoriteParishes (catch): $e");
      throw Exception('Erreur réseau: $e');
    }
  }





  /// NOUVEAU : Vérifie si une paroisse est en favori
  Future<bool> isParishFavorite(int parishId) async {
    if (!_isAuthenticated) throw Exception('Non authentifié');

    final url = Uri.parse("$_baseUrl/favoris/check/$parishId");
    try {

      final response = await _handleRequest(
          http.get(url, headers: _authHeaders)
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // --- CORRECTION ICI ---
        // On lit la clé "favori" que l'API renvoie
        return data['favori'] == true;
        // --- FIN CORRECTION ---

      } else {
        print("Erreur API /check (status ${response.statusCode}): ${response.body}");
        return false; // Suppose "non favori" si l'API renvoie une erreur
      }
    } catch (e) {
      print("Erreur isParishFavorite (catch): $e");
      return false; // Suppose "non favori" en cas d'erreur réseau
    }
  }

  /// NOUVEAU : Ajoute/Retire une paroisse des favoris (Toggle)
  // DANS LA CLASSE AuthService (fichier auth_service.dart)

  /// NOUVEAU : Ajoute/Retire une paroisse des favoris (Toggle)
  Future<bool> toggleParishFavorite(int parishId) async {
    if (!_isAuthenticated) return false;

    // --- CORRECTION ICI ---
    // Retire le slash à la fin de 'toggle/'
    final url = Uri.parse("$_baseUrl/paroisses/toggle");
    // --- FIN CORRECTION ---

    final body = jsonEncode({
      "paroisse_id": parishId
    });

    try {
      final response = await _handleRequest(
          http.post(url, headers: _authHeaders, body: body)
      );


      final data = jsonDecode(response.body); // Décode la réponse

      if (response.statusCode == 200) {
        print("Toggle Favori: ${data['message']}"); // Ex: "Ajouté" ou "Retiré"
        return true; // Succès
      } else {
        print("Erreur toggleParishFavorite (API): ${data['message']}");
        return false;
      }
    } catch (e) {
      // L'erreur HTML (redirection) tombait probablement ici
      print("Erreur toggleParishFavorite (catch): $e");
      return false;
    }
  }




  // DANS LA CLASSE AuthService (fichier auth_service.dart)
  /// NOUVEAU (CORRIGÉ) : Récupère la liste de tous les événements
  Future<List<dynamic>> getEvents() async {
    if (!_isAuthenticated) throw Exception('Non authentifié');

    final url = Uri.parse("$_baseUrl/event/");
    try {

      final response = await _handleRequest(
          http.get(url, headers: _authHeaders)
      );

      final data = jsonDecode(response.body);

      // La liste est maintenant dans la clé "data"
      if (response.statusCode == 200) {
        // --- CORRECTION ---
        // L'API renvoie { "message": "...", "data": [ ... ] }
        final List<dynamic> eventList = data['data'];
        // --- FIN CORRECTION ---
        return eventList;
      } else {
        print("Erreur getEvents (API): ${data['message']}");
        throw Exception('Échec du chargement des événements');
      }
    } catch (e) {
      print("Erreur getEvents (catch): $e");
      throw Exception('Erreur réseau: $e');
    }
  }




  /// NOUVEAU : Récupère les détails d'un événement
  Future<Map<String, dynamic>?> getEventDetail(int eventId) async {
    if (!_isAuthenticated) {
      print("getEventDetail: Non authentifié");
      return null;
    }

    final url = Uri.parse("$_baseUrl/event/$eventId");
    try {
      final response = await _handleRequest(
          http.get(url, headers: _authHeaders)
      );

      print("--- getEventDetail (API: /event/$eventId) ---");
      print("Code: ${response.statusCode}");
      // print("Body: ${response.body}"); // On n'en a plus besoin, on sait

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // --- LA CORRECTION EST ICI ---
        // Tes logs montrent que les détails sont dans la clé "data"
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          return data['data']; // On retourne le contenu de "data"
        } else {
          print("Erreur : Clé 'data' non trouvée dans la réponse.");
          return null;
        }
      } else {
        print("Erreur getEventDetail (API): ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Erreur getEventDetail (catch): $e");
      return null;
    }
  }








  /// MODIFIÉ : Crée une demande de messe (renvoie l'objet 'messe')
  Future<Map<String, dynamic>> createMassRequest({
    required int paroisseId,
    String? intercesseur,
    required String motif,
    required String dateSouhaitee,
    required String heureSouhaitee,
    required String celebration,
    required String nomDemandeur,
    required String emailDemandeur,
    required String telDemandeur,
    required double montant,
    List<String>? joursSelectionnes,
  }) async {
    if (!_isAuthenticated) throw Exception('Non authentifié');

    final url = Uri.parse("$_baseUrl/messes");

    // ... (la logique de bodyMap reste la même) ...
    Map<String, dynamic> bodyMap = {
      "user_id": _id,
      "paroisse_id": paroisseId,
      "interception_par": intercesseur,
      "motif_intention": motif,
      "date_souhaitee": dateSouhaitee,
      "heure_souhaitee": heureSouhaitee,
      "celebration_choisie": celebration,
      "nom_demandeur": nomDemandeur,
      "email_demandeur": emailDemandeur,
      "telephone_demandeur": telDemandeur,
      "montant_offrande": montant,
    };
    if (celebration == "Messe quotidienne") {
      bodyMap['jours_quotidienne'] = joursSelectionnes;
    } else if (celebration == "Messe dominicale") {
      bodyMap['jours_dominicale'] = joursSelectionnes;
    }
    final body = jsonEncode(bodyMap);

    try {
      final response = await _handleRequest (http.post(url, headers: _authHeaders, body: body));


      final data = jsonDecode(response.body);

      // L'API renvoie 200/201 et { "status": "success", "messe": {...} }
      if ((response.statusCode == 200 || response.statusCode == 201) && data['status'] == 'success') {

        // --- CORRECTION : Renvoie l'objet 'messe' ---
        if (data['messe'] != null) {
          return data['messe'] as Map<String, dynamic>;
        } else {
          throw Exception("L'API a réussi mais n'a pas renvoyé l'objet 'messe'.");
        }
        // --- FIN CORRECTION ---

      } else {
        // ... (ta gestion d'erreur reste la même) ...
        print("Erreur createMassRequest (API): ${data['message']}");
        if (data['errors'] != null) {
          throw Exception((data['errors'] as Map).values.first[0]);
        }
        throw Exception(data['message'] ?? 'Échec de la création de la messe');
      }
    } catch (e) {
      print("Erreur createMassRequest (catch): $e");
      if (e is FormatException) {
        throw Exception('Erreur réseau (HTML reçu). Vérifiez l\'URL de l\'API.');
      }
      throw e;
    }
  }


  /// NOUVEAU : Récupère la liste des demandes de messes de l'utilisateur
  Future<List<dynamic>> getMassRequests() async {
    if (!_isAuthenticated) throw Exception('Non authentifié');

    // L'URL est GET /messes
    final url = Uri.parse("$_baseUrl/messes/");
    try {
      final response = await _handleRequest(
          http.get(url, headers: _authHeaders)
      );

      final data = jsonDecode(response.body);

      // La liste est dans la clé "messes"
      if (response.statusCode == 200 && data['status'] == 'success') {
        final List<dynamic> requests = data['messes'];
        return requests;
      } else {
        print("Erreur getMassRequests (API): ${data['message']}");
        throw Exception('Échec du chargement des demandes');
      }
    } catch (e) {
      print("Erreur getMassRequests (catch): $e");
      throw Exception('Erreur réseau: $e');
    }
  }






  /// MODIFIÉ : Récupère l'URL de checkout (envoie messe_id, montant, et tel)
  Future<String> getCheckoutUrl(int messeId, double totalAmount) async {
    if (!_isAuthenticated) throw Exception('Non authentifié');

    final url = Uri.parse("$_baseUrl/paiement/wave/checkout-url");

    // --- CORRECTION : Construit le corps exact demandé par l'API ---
    final body = jsonEncode({
      "messe_id": messeId,
      "montant": totalAmount,
      "telephone": _phone, // Utilise le téléphone stocké dans AuthService
      "devise": "XOF" // On le garde au cas où
    });
    // --- FIN CORRECTION ---

    try {
      final response = await _handleRequest(
          http.post(url, headers: _authHeaders, body: body)
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['statut'] == 'success') {

        final String? checkoutUrl = data['checkout_url'];

        if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
          return checkoutUrl;
        } else {
          throw Exception('Le serveur a confirmé le succès mais n\'a pas fourni d\'URL de paiement.');
        }

      } else {
        print("Erreur getCheckoutUrl (API): ${data['message']}");
        // Gère le cas où la validation échoue
        if (data['errors'] != null) {
          throw Exception((data['errors'] as Map).values.first[0]);
        }
        throw Exception(data['message'] ?? 'Échec de la récupération du lien de paiement');
      }
    } catch (e) {
      print("Erreur getCheckoutUrl (catch): $e");
      throw Exception('Erreur réseau: $e');
    }
  }




  Future<bool> loginWithApple(String identityToken, String appleId, String? email, String? fullName) async {
    final url = Uri.parse("$_baseUrl/auth/apple");

    final body = jsonEncode({
      "identity_token": identityToken,
      "apple_id": appleId,
      "email": email,
      "name": fullName,
    });

    print("--- [AuthService] Envoi des données Apple au Backend ---");
    print("URL Cible: $url");
    print("JSON Envoyé: $body");
    print("-------------------------------------------------------");

    try {
      final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: body
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {

        print("--- [AuthService] Réponse Apple reçue ---");
        print("Status Code: ${response.statusCode}");
        print("JSON Reçu (data): $data");
        print("---------------------------------------");

        final String apiToken = data['access_token'];
        final Map<String, dynamic> user = data['user'];

        // 3. Sauvegarde des données (CRITIQUE : Doit marcher)
        await _saveAuthData(
            token: apiToken,
            user: user,
            civilite: null
        );

        // 4. Gestion FCM (NON BLOQUANTE)
        // On isole cette partie. Si elle échoue (ex: Simulateur, erreur APNS),
        // l'utilisateur est QUAND MÊME connecté.
        try {
          print("Tentative de récupération du token FCM...");
          final String? fcmToken = await _notificationService.initializeAndGetToken();

          if (fcmToken != null) {
            // On ne met pas 'await' ici pour ne pas ralentir l'UI, ou alors un await rapide
            _sendFCMTokenToBackend(fcmToken);
          } else {
            print("⚠️ AVERTISSEMENT: Pas de token FCM (Normal sur Simulateur). Login continue.");
          }
        } catch (e) {
          print("Erreur FCM silencieuse (Apple): $e");
          // On ne fait rien, on laisse l'utilisateur entrer
        }

        return true; // ✅ SUCCÈS GARANTI

      } else {
        print("Erreur loginWithApple (API): ${data['message']}");
        return false;
      }

    } catch (e) {
      print("Erreur loginWithApple (catch): $e");
      return false;
    }
  }




  Future<bool> loginWithGoogle(String idToken, String email, String? name, String googleId, String? photoUrl) async {
    final url = Uri.parse("$_baseUrl/auth/google");

    final body = jsonEncode({
      "id_token": idToken,
      "email": email,
      "name": name ?? "",
      "googleId": googleId,
      "profile_picture": photoUrl ?? ""
    });

    print("--- [AuthService] Envoi des données Google au Backend ---");
    print("URL Cible: $url");
    print("JSON Envoyé: $body");
    print("-------------------------------------------------");

    try {
      final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: body
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {

        print("--- [AuthService] Réponse Google reçue ---");
        print("Status Code: ${response.statusCode}");
        print("JSON Reçu (data): $data");
        print("---------------------------------------------");

        final String apiToken = data['access_token'];
        final Map<String, dynamic> user = data['user'];

        // Sauvegarde critique
        await _saveAuthData(
            token: apiToken,
            user: user,
            civilite: null
        );

        // 4. Gestion FCM (NON BLOQUANTE)
        // Même logique de protection que pour Apple
        try {
          print("Tentative de récupération du token FCM (Google)...");
          final String? fcmToken = await _notificationService.initializeAndGetToken();

          if (fcmToken != null) {
            _sendFCMTokenToBackend(fcmToken);
          } else {
            print("⚠️ AVERTISSEMENT: Pas de token FCM. Login continue.");
          }
        } catch (e) {
          print("Erreur FCM silencieuse (Google): $e");
          // On continue
        }

        return true; // ✅ SUCCÈS GARANTI

      } else {
        print("Erreur loginWithGoogle (API): ${data['message']}");
        return false;
      }

    } catch (e) {
      print("Erreur loginWithGoogle (catch): $e");
      return false;
    }
  }



  /// API 1 : Envoie le token FCM au backend (après une connexion réussie)
  Future<void> _sendFCMTokenToBackend(String fcmToken) async {
    // Vérifie si l'utilisateur est authentifié et si on a le token API
    if (!_isAuthenticated || _token == null) return;

    final url = Uri.parse("$_baseUrl/fcm-token"); // (API 1)

    try {
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token', // <-- Important : Requête authentifiée
        },
        body: jsonEncode({
          "fcm_token": fcmToken
        }),
      );
      print("[AuthService] Token FCM envoyé au backend avec succès.");
    } catch (e) {
      print("[AuthService] Erreur lors de l'envoi du token FCM au backend: $e");
    }
  }


  Future<List<NotificationModel>> getNotifications() async {
    if (_token == null) throw Exception("Non authentifié");
    final url = Uri.parse("$_baseUrl/notifications");

    print("--- 1. Appel API Notifications ---");

    try {
      // Si l'erreur vient d'ici, on le saura
      final response = await _handleRequest(
          http.get(url, headers: _authHeaders)
      );

      print("--- 2. Réponse reçue: ${response.statusCode} ---");

      if (response.statusCode == 200) {
        print("--- 3. DÉBUT DÉCODAGE ---");

        // On stocke en dynamic pour ne PAS forcer de type
        final dynamic rawBody = jsonDecode(response.body);

        print("--- 4. Type des données reçues : ${rawBody.runtimeType} ---");
        // Affiche : List<dynamic> ou _Map<String, dynamic>

        List<dynamic> listToUse = [];

        if (rawBody is List) {
          print("--- 5. C'est une LISTE brute ---");
          listToUse = rawBody;
        } else if (rawBody is Map) {
          print("--- 5. C'est une MAP ---");
          // On essaie de trouver la liste dedans
          if (rawBody.containsKey('notifications')) {
            listToUse = rawBody['notifications'];
          } else if (rawBody.containsKey('data')) {
            listToUse = rawBody['data'];
          }
        }

        print("--- 6. Nombre d'éléments trouvés : ${listToUse.length} ---");

        final result = listToUse.map((json) {
          // print("Conversion élément: $json"); // Décommente si besoin
          return NotificationModel.fromJson(json);
        }).toList();

        print("--- 7. Conversion terminée avec succès ---");



        // --- PARTIE CRUCIALE (de ta 2ème fonction) ---
        _notifications = result; // 1. Met à jour le cache local
        notifyListeners();       // 2. Notifie l'UI (le point rouge !)
        // --- FIN DE L'AJOUT ---

        return _notifications ?? []; // Renvoie la liste mise à jour

      } else {
        throw Exception("Échec du chargement des notifications");
      }
    } catch (e, stackTrace) {
      print("!!! CRASH !!!");
      print("L'erreur exacte est : $e");
      print("Stacktrace: $stackTrace"); // Ça nous dira la ligne précise
      rethrow;
    }
  }







  // --- API 3 : Marquer une notification comme lue ---
  Future<bool> markNotificationAsRead(String notificationId) async {
    if (_token == null) return false;

    // 1. CORRECTION DE L'URL (Selon l'endpoint du développeur)
    final url = Uri.parse("$_baseUrl/notifications/$notificationId/mark-as-read");

    print("Tentative markAsRead sur : $url");

    try {
      // 2. L'APPEL API
      // NOTE : Essaie d'abord avec http.put.
      // Si tu reçois une erreur 405 (Method Not Allowed), remplace .put par .post
      final response = await _handleRequest(
          http.put(url, headers: _authHeaders)
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("Succès : Notification $notificationId marquée comme lue.");

        // --- AJOUTE ÇA ---
        notifyListeners(); // Met à jour l'UI (le point rouge va disparaître)

        return true;
      } else {
        print("Échec markAsRead: Code ${response.statusCode}");
        // print("Réponse: ${response.body}"); // Décommente si tu veux voir l'erreur
        return false;
      }
    } catch (e) {
      print("[markNotificationAsRead] Erreur: $e");
      return false;
    }
  }

  // --- API 4 : Supprimer une notification ---
  Future<bool> deleteNotification(String notificationId) async {
    if (_token == null) return false;

    final url = Uri.parse("$_baseUrl/notifications/$notificationId");

    try {
      final response = await _handleRequest(
          http.delete(url, headers: _authHeaders)
      );

      if (response.statusCode == 200) {
        print("Notification $notificationId supprimée (API)");
        return true;
      }
      return false;
    } catch (e) {
      print("[deleteNotification] Erreur: $e");
      return false;
    }
  }




  // --- API 5 : Marquer tout comme lu (Version Finale : PUT) ---
  Future<bool> markAllNotificationsAsRead() async {
    if (_token == null) return false;

    final url = Uri.parse("$_baseUrl/notifications/read-all");

    print("Tentative Mark All Read (via PUT) sur : $url");

    try {
      // CORRECTION : Utilisation de PUT comme confirmé par le développeur
      final response = await _handleRequest(
          http.put(url, headers: _authHeaders)
      );

      print("Code retour Mark All: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("Succès : ${response.body}");

        // --- AJOUTE ÇA ---
        notifyListeners(); // Met à jour l'UI (le point rouge va disparaître)

        return true;
      }

      print("Échec Mark All Read: ${response.statusCode} - ${response.body}");
      return false;

    } catch (e) {
      print("[markAllNotificationsAsRead] Erreur: $e");
      return false;
    }
  }




  // --- NOUVELLE API : Supprimer toutes les notifications ---
  Future<bool> deleteAllNotifications() async {
    if (_token == null) throw Exception("Non authentifié");

    // Endpoint imaginé (logique)
    final url = Uri.parse("$_baseUrl/notifications/clear-all");

    try {
      final response = await _handleRequest(
          http.delete(url, headers: _authHeaders)
      );

      if (response.statusCode == 200) {
        print("Toutes les notifications supprimées (API)");
        return true;
      }
      return false;
    } catch (e) {
      print("[deleteAllNotifications] Erreur: $e");
      rethrow;
    }
  }



  Future<http.Response> _handleRequest(Future<http.Response> request) async {
    http.Response response;

    try {
      response = await request;
    } catch (e) {
      // Erreur réseau (pas d'internet, etc.)
      print("Erreur réseau: $e");
      throw Exception("Erreur réseau. Vérifiez votre connexion.");
    }

    // --- LE POINT CLÉ ---
    if (response.statusCode == 401) {
      // 401 Unauthorized ! Le token est expiré ou invalide.
      print("[AuthService] Token expiré ou invalide (401). Déconnexion...");

      // 1. Déconnecte l'utilisateur localement SANS appeler l'API de logout
      //    (car l'API nous rejetterait de toute façon)
      await logout(apiCall: false);

      // 2. Utilise la clé de navigation globale pour forcer la redirection
      //    vers l'écran de connexion.
      final navigator = NavigationService.navigatorKey.currentState;
      if (navigator != null) {
        // Redirige vers /login et supprime toutes les autres routes
        navigator.pushNamedAndRemoveUntil('/login', (route) => false);
      }

      // 3. Lance une erreur pour arrêter la fonction d'origine.
      throw Exception("Session expirée. Veuillez vous reconnecter.");
    }
    // --- FIN DU POINT CLÉ ---

    // Si tout va bien (pas 401), on renvoie la réponse
    return response;
  }



  // --- Récupérer une demande spécifique par ID ---
  Future<Map<String, dynamic>?> getMassRequestDetails(int id) async {
    if (_token == null) return null;

    // ⚠️ Vérifie cette URL avec ton développeur si ça ne marche pas
    // Ça peut être "$_baseUrl/messes/$id" ou "$_baseUrl/intentions/$id"
    final url = Uri.parse("$_baseUrl/messes/detail/$id");

    try {
      final response = await _handleRequest(
          http.get(url, headers: _authHeaders)
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // On gère si c'est { data: {...} } ou directement {...}
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            return data['data'];
          } else if (data.containsKey('messe')) { // Parfois c'est 'messe'
            return data['messe'];
          }
          return data;
        }
      }
      return null;
    } catch (e) {
      print("Erreur getMassRequestDetails: $e");
      return null;
    }
  }




  // --- NOUVEAU : Récupérer le détail via l'ID de la notification ---
  // C'EST LA SEULE FONCTION DONT ON A BESOIN
  Future<Map<String, dynamic>?> getDetailsFromNotification(String notificationId) async {
    if (_token == null) return null;

    final url = Uri.parse("$_baseUrl/notifications/detail/$notificationId");

    try {
      final response = await _handleRequest(
          http.get(url, headers: _authHeaders)
      );

      print("--- getDetailsFromNotification ---");
      print("Code: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded; // On renvoie le JSON complet
        }
      }
      return null;
    } catch (e) {
      print("Erreur getDetailsFromNotification: $e");
      return null;
    }
  }



  // --- Pour les ÉVÉNEMENTS ---
  Future<Map<String, dynamic>?> getEventDetailsFromNotification(String notificationId) async {
    if (_token == null) return null;

    final cleanId = notificationId.trim();
    final url = Uri.parse("$_baseUrl/notifications/event/$cleanId");

    try {
      final response = await _handleRequest(
          http.get(url, headers: _authHeaders)
      );

      print("API /event/ CODE: ${response.statusCode}");
      print("API /event/ BODY: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        // Le JSON du dev montre { "status": "...", "event": {...} }
        if (decoded is Map<String, dynamic> && decoded.containsKey('event')) {
          return decoded['event']; // On extrait l'objet event
        }
      }
      return null;
    } catch (e) {
      print("Erreur getEventDetailsFromNotification: $e");
      return null;
    }
  }




  /// API 1: Demande un code de réinitialisation par email (Dynamique)
  Future<bool> requestPasswordReset(String email) async {
    // 1. L'endpoint du développeur
    final url = Uri.parse("$_baseUrl/forgot-password");

    // 2. Les en-têtes (c'est une route publique, pas besoin de token)
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // 3. Le corps de la requête
    final body = jsonEncode({'email': email});

    print("AuthService: Demande de code pour $email à $url");

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print("Réponse forgot-password: ${response.statusCode}");
      print("Body: ${response.body}");

      // 4. Gestion de la réponse

      // Cas Succès (ex: 200)
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      }
      // Cas Erreur (ex: 404 "Aucun utilisateur")
      else {
        // L'API a renvoyé une erreur (comme "email non trouvé"),
        // donc on renvoie 'false' pour que l'UI affiche le message.
        return false;
      }
    } catch (e) {
      print("[requestPasswordReset] Erreur réseau: $e");
      return false; // Échec de la connexion
    }
  }




  /// API 2: Vérifie si le code OTP est correct (Dynamique)
  Future<bool> verifyPasswordOTP(String email, String otp) async {
    // 1. L'endpoint du développeur
    final url = Uri.parse("$_baseUrl/verify-otp");

    // 2. Les en-têtes (route publique)
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // 3. Le corps de la requête
    final body = jsonEncode({
      'email': email,
      'otp': otp, // Le backend s'attend peut-être à 'code' ou 'token'
    });

    print("AuthService: Vérification du code $otp pour $email");

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print("Réponse verify-otp: ${response.statusCode}");
      print("Body: ${response.body}");

      // 4. Gestion de la réponse
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // On renvoie true SEULEMENT si l'API confirme le succès
        return data['status'] == 'success';
      } else {
        // L'API a renvoyé une erreur (404, 422 "Code invalide"),
        // donc on renvoie 'false' pour que l'UI affiche "Code incorrect".
        return false;
      }
    } catch (e) {
      print("[verifyPasswordOTP] Erreur réseau: $e");
      return false; // Échec de la connexion
    }
  }



  /// API 3: Réinitialise le mot de passe (Dynamique)
  Future<bool> resetPassword(String email, String otp, String newPassword) async {
    // 1. L'endpoint du développeur
    final url = Uri.parse("$_baseUrl/reset-password");

    // 2. Les en-têtes (route publique)
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // 3. Le corps de la requête (exactement comme demandé par le dev)
    final body = jsonEncode({
      'email': email,
      'otp': otp,
      'password': newPassword,
      'password_confirmation': newPassword, // Le backend demande la confirmation
    });

    print("AuthService: Réinitialisation du mot de passe pour $email");

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print("Réponse reset-password: ${response.statusCode}");
      print("Body: ${response.body}");

      // 4. Gestion de la réponse
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      } else {
        // L'API a renvoyé une erreur (ex: 422 "Token invalide")
        return false;
      }
    } catch (e) {
      print("[resetPassword] Erreur réseau: $e");
      return false; // Échec de la connexion
    }
  }


  // (Assure-toi d'avoir 'dart:convert' et 'http' importés)

  /// API: Vérifie le mot de passe de l'utilisateur actuel
  Future<bool> verifyCurrentUserPassword(String password) async {
    if (!_isAuthenticated) return false;

    // 1. L'endpoint que ton backend a créé
    final url = Uri.parse("$_baseUrl/user/verify-password");

    // 2. Le corps de la requête
    final body = jsonEncode({'password': password});

    print("AuthService: Vérification du mot de passe...");

    try {
      final response = await http.post(url, headers: _authHeaders, body: body);

      // 3. Gestion de la réponse
      if (response.statusCode == 200) {
        print("Vérification du mot de passe : SUCCÈS");
        return true;
      } else {
        // Le backend renvoie une erreur (401, 422) si le mot de passe est faux
        print("Vérification du mot de passe : ÉCHEC");
        return false;
      }
    } catch (e) {
      print("Erreur verifyCurrentUserPassword (catch): $e");
      return false;
    }
  }




  // Modifie le type de retour : Future<Map<String, dynamic>>
  Future<Map<String, dynamic>> deleteAccount(String password) async {
    if (!_isAuthenticated) {
      return {'success': false, 'message': 'Non authentifié'};
    }

    final url = Uri.parse("$_baseUrl/user/delete-account");

    // 1. CORRECTION CRITIQUE : Assure-toi que le type de contenu est JSON
    // Copie tes headers actuels et ajoute le Content-Type si ce n'est pas déjà fait
    final Map<String, String> headers = {
      ..._authHeaders,
      'Content-Type': 'application/json', // INDISPENSABLE pour envoyer le password
      'Accept': 'application/json',
    };

    final body = jsonEncode({
      "password": password
    });

    print("Tentative de suppression avec body: $body");

    try {
      final response = await http.delete(url, headers: headers, body: body);

      print("Statut: ${response.statusCode}");
      print("Body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        await _clearAuthData();
        return {'success': true, 'message': 'Compte supprimé'};
      } else {
        // 2. ON RENVOIE L'ERREUR EXACTE DU SERVEUR
        // Si le serveur renvoie un message, on le prend. Sinon on met le code d'erreur.
        String serverMessage = data['message'] ?? "Erreur inconnue (${response.statusCode})";
        return {'success': false, 'message': serverMessage};
      }
    } catch (e) {
      // 3. ON RENVOIE L'ERREUR DE CODE (ex: pas d'internet)
      return {'success': false, 'message': "Erreur technique : $e"};
    }
  }




  /// Helper pour vider les SharedPreferences (tu l'as peut-être déjà pour logout)
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Supprime tout

    // Réinitialise l'état local
    _isAuthenticated = false;
    _token = null;
    _id = null;
    _fullName = null;
    _username = null;
    _email = null;
    _phone = null;
    _photoPath = null;
    _civilite = null;

    notifyListeners();
  }



  // --- NOUVEAU : Paiement CinetPay ---
  Future<String?> initierPaiementCinetPay({
    required int messeId,
    required double montant
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/paiement/cinetpay/initier');

      // On récupère le token stocké (si nécessaire pour ton API)
      final token = await _token;

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "messe_id": messeId,
          // Convertit en entier si l'API attend un entier, sinon laisse en double
          "montant": montant.toInt(),
        }),
      );

      print("--- CinetPay Init Response: ${response.body} ---");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['statut'] == 'success') {
          // On retourne l'URL de paiement reçue
          return data['payment_url'];
        } else {
          throw Exception(data['message'] ?? "Erreur lors de l'initialisation CinetPay");
        }
      } else {
        throw Exception("Erreur serveur: ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur initierPaiementCinetPay: $e");
      rethrow;
    }
  }



  // --- NOUVEAU : Enregistrer la fiche fidèles (Multipart pour la photo) ---
  Future<void> submitIdentification({
    required String nomPrenom,          // Backend: nom_prenom
    required String dateNaissance,      // Backend: date_naissance
    required String sexe,               // Backend: sexe
    required String situationMatrimoniale, // Backend: situation_matrimoniale
    required String adresse,            // Backend: adresse
    required String statutActivite,     // Backend: statut_activite
    required String nomParoisse,        // Backend: nom_paroisse
    required String telephone,          // Backend: telephone
    required bool estDansMouvement,     // Backend: est_dans_mouvement
    String? nomMouvement,               // Backend: nom_mouvement
    required bool estBaptise,           // Backend: est_baptise
    String? dateBapteme,                // Backend: date_bapteme
    String? nomParoisseBapteme,
    File? photo,                        // Backend: photo
  }) async {

    // 1. Vérification auth
    // Si tu as un token stocké, récupère-le ici
    final token = await _token; // Assure-toi d'avoir cette méthode ou utilise ta variable _token

    final uri = Uri.parse("$_baseUrl/paroissien/store");

    // 2. Création de la requête Multipart (pour envoyer fichier + texte)
    var request = http.MultipartRequest('POST', uri);

    // 3. Ajout des Headers
    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    // 4. Ajout des champs Texte (Exactement comme le JSON du backend)
    request.fields['nom_prenom'] = nomPrenom;
    request.fields['date_naissance'] = dateNaissance;
    request.fields['sexe'] = sexe;
    request.fields['situation_matrimoniale'] = situationMatrimoniale;
    request.fields['adresse'] = adresse;
    request.fields['statut_activite'] = statutActivite;
    request.fields['nom_paroisse'] = nomParoisse;
    request.fields['telephone'] = telephone;

    // Les booléens doivent souvent être envoyés en "1" ou "0" ou "true"/"false" string via Multipart
    request.fields['est_dans_mouvement'] = estDansMouvement ? "1" : "0";
    request.fields['nom_mouvement'] = nomMouvement ?? "";

    request.fields['est_baptise'] = estBaptise ? "1" : "0";
    if (dateBapteme != null) {
      request.fields['date_bapteme'] = dateBapteme;
    }


    request.fields['nom_paroisse_bapteme'] = nomParoisseBapteme ?? "";


    // 5. Ajout de la Photo (si elle existe)
    if (photo != null) {
      // On devine le type mime ou on laisse le stream faire
      var stream = http.ByteStream(photo.openRead());
      var length = await photo.length();

      var multipartFile = http.MultipartFile(
        'photo', // La clé attendue par le backend
        stream,
        length,
        filename: photo.path.split('/').last,
      );
      request.files.add(multipartFile);
    }

    // 6. Envoi de la requête
    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Code: ${response.statusCode}");
      print("Réponse: ${response.body}");

      final data = jsonDecode(response.body);

      // Vérification selon le format du backend ("status": true)
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['status'] == true) {

          // On utilise les données confirmées par le serveur (data['data'])
          if (data['data'] != null) {
            await _updateLocalUserData(data['data']);
          } // ⚠️ TRES IMPORTANT : Dit à l'écran de se rafraîchir
          return;

        } else {
          throw Exception(data['message'] ?? "Erreur lors de l'enregistrement");
        }
      } else {
        throw Exception(data['message'] ?? "Erreur serveur (${response.statusCode})");
      }
    } catch (e) {
      print("Erreur submitIdentification: $e");
      rethrow;
    }
  }






  // --- NOUVEAU : Récupérer les détails du paroissien (GET) ---
  Future<Map<String, dynamic>?> getParoissien(int id) async {
    // Vérification auth
    final token = _token;
    if (token == null) return null;

    final url = Uri.parse("$_baseUrl/paroissien/$id");

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        final userData = data['data'];

        // ✅ IMPORTANT : On met à jour les variables locales pour l'affichage Accueil
        _updateLocalUserData(userData);

        return userData; // On retourne les données pour remplir le formulaire
      } else {
        print("Erreur getParoissien: ${data['message']}");
        return null;
      }
    } catch (e) {
      print("Erreur réseau getParoissien: $e");
      rethrow;
    }
  }




  // --- MISE À JOUR (VERSION UNIFIÉE : TOUJOURS MULTIPART) ---
  Future<void> updateParoissien({
    required int id,
    required String nomPrenom,
    required String dateNaissance,
    required String sexe,
    required String situationMatrimoniale,
    required String adresse,
    required String statutActivite,
    required String nomParoisse,
    required String telephone,
    required bool estDansMouvement,
    String? nomMouvement,
    required bool estBaptise,
    String? dateBapteme,
    String? nomParoisseBapteme,
    File? photo,
  }) async {
    final token = _token;
    final uri = Uri.parse("$_baseUrl/paroissien/$id");

    // ON UTILISE TOUJOURS MULTIPART REQUEST (Même sans photo)
    // C'est le seul moyen sûr que le backend PHP comprenne les champs texte ET fichier
    var request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    // ⚠️ IMPORTANT : ON N'AJOUTE PAS DE CHAMP '_method'
    // Car ton erreur précédente (405) a prouvé que la route est bien en POST natif.

    // Ajout des champs Texte
    request.fields['nom_prenom'] = nomPrenom;
    request.fields['date_naissance'] = dateNaissance;
    request.fields['sexe'] = sexe;
    request.fields['situation_matrimoniale'] = situationMatrimoniale;
    request.fields['adresse'] = adresse;
    request.fields['statut_activite'] = statutActivite;
    request.fields['nom_paroisse'] = nomParoisse;
    request.fields['telephone'] = telephone;

    // Booléens convertis en "1" ou "0"
    request.fields['est_dans_mouvement'] = estDansMouvement ? "1" : "0";
    request.fields['nom_mouvement'] = nomMouvement ?? "";
    request.fields['est_baptise'] = estBaptise ? "1" : "0";

    if (dateBapteme != null) {
      request.fields['date_bapteme'] = dateBapteme;
    }


    // ✅ 2. AJOUT DU CHAMP DANS LA REQUÊTE
    request.fields['nom_paroisse_bapteme'] = nomParoisseBapteme ?? "";

    // Ajout de la photo (Seulement si on en a une nouvelle)
    if (photo != null) {
      var stream = http.ByteStream(photo.openRead());
      var length = await photo.length();
      var multipartFile = http.MultipartFile(
        'photo',
        stream,
        length,
        filename: photo.path.split('/').last,
      );
      request.files.add(multipartFile);
    }

    try {
      print("Envoi Update vers : $uri");

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Code Update: ${response.statusCode}");
      print("Réponse Update: ${response.body}");

      final data = jsonDecode(response.body);

      // On accepte 200 ou 201
      if ((response.statusCode == 200 || response.statusCode == 201) && data['status'] == true) {

        // Mise à jour locale des données
        if (data['data'] != null) {
          await _updateLocalUserData(data['data']);
        }
        return;

      } else {
        // Si c'est encore "Action non autorisée", le problème vient peut-être de l'ID
        throw Exception(data['message'] ?? "Erreur lors de la mise à jour (${response.statusCode})");
      }

    } catch (e) {
      print("Erreur updateParoissien: $e");
      rethrow;
    }
  }



  // --- HELPER PRIVÉ : Met à jour les variables locales et SharedPreferences ---
  Future<void> _updateLocalUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Mise à jour variables mémoire
    if (data['nom_prenom'] != null) _fullName = data['nom_prenom'];
    if (data['telephone'] != null) _phone = data['telephone'];

    // Gestion robuste du booléen est_baptise (API peut renvoyer 1, "1", true)
    if (data['est_baptise'] != null) {
      _estBaptise = data['est_baptise'] == 1 || data['est_baptise'] == true || data['est_baptise'] == "1";
    }

    // 2. Mise à jour SharedPreferences (Disque)
    if (_fullName != null) await prefs.setString(_keyFullName, _fullName!);
    if (_phone != null) await prefs.setString(_keyPhone, _phone!);
    await prefs.setBool(_keyEstBaptise, _estBaptise);

    // 3. Notifier les écrans (Home, Profil...)
    notifyListeners();
  }



  // --- NOUVEAU : Supprimer une demande de messe ---
  Future<bool> deleteMassRequest(int id) async {
    // Vérification auth
    final token = _token;
    if (token == null) return false;

    final url = Uri.parse("$_baseUrl/messes/$id");

    try {
      final response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Code Delete: ${response.statusCode}");

      if (response.statusCode == 200) {
        return true; // Succès
      } else {
        final data = jsonDecode(response.body);
        print("Erreur Delete: ${data['message']}");
        return false;
      }
    } catch (e) {
      print("Erreur réseau Delete: $e");
      return false;
    }
  }








}



