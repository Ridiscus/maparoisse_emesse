import 'dart:convert';
import 'package:http/http.dart' as http;

class StreetPayService {
  final String publicKey;  // côté Flutter
  final String secretKey;  // côté serveur
  final String environment; // "sandbox" ou "production"

  StreetPayService({
    required this.publicKey,
    required this.secretKey,
    this.environment = "sandbox",
  });

  /// Crée une session de paiement (appelé depuis le backend recommandé)
  Future<String?> createPaymentSession({
    required int amount, // en XOF, pas de décimales
    required String clientReference,
    String currency = "XOF",
  }) async {
    // URL du backend qui fera appel à StreetPay avec la clé secrète
    final backendUrl = environment == "sandbox"
        ? "https://ton-backend-sandbox.com/api/streetpay/session"
        : "https://ton-backend-prod.com/api/streetpay/session";

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "amount": amount,
          "currency": currency,
          "client_reference": clientReference,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data["checkout_url"]; // URL de paiement à ouvrir dans le modal
      } else {
        print("StreetPay API error: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      print("StreetPay API exception: $e");
      return null;
    }
  }
}