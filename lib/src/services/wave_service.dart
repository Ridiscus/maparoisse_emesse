// wave_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class WaveService {
  final String apiKey;
  final String environment; // sandbox ou production

  WaveService({
    required this.apiKey,
    this.environment = "production", // ou "sandbox"
  });

  /// Crée une session de paiement Wave et retourne le checkout_url
  Future<String?> createPaymentSession({
    required double amount,
    String currency = "XOF",
    String? clientReference,
  }) async {
    final baseUrl = "https://api.wave.com/v1/checkout/sessions";

    final body = {
      "amount": amount.toInt().toString(), // "1000"
      "currency": currency,               // "XOF"
      "success_url": "https://example.com/success",
      "error_url": "https://example.com/error",
      if (clientReference != null) "client_reference": clientReference,
    };

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      print("Wave response: ${response.body}"); // debug

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["wave_launch_url"]; // <-- utiliser ce champ
      } else {
        print("Wave error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Wave API exception: $e");
      return null;
    }
  }
}