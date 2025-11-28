import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Modal dynamique pour Wave
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Modal Wave (Production)
void showWaveModal(BuildContext context, {required String checkoutUrl}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1DC8FF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Paiement via Wave",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "Cliquez sur le bouton ci-dessous pour payer directement dans l'application Wave.",
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Bouton Payer
              ElevatedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(checkoutUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Impossible d'ouvrir Wave")),
                    );
                  }
                },
                icon: const Icon(Icons.payment),
                label: const Text("Payer via Wave"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1DC8FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                "Téléchargez l'application Wave si vous ne l'avez pas :",
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  GestureDetector(
                    onTap: () => launchUrl(
                      Uri.parse("https://play.google.com/store/apps/details?id=com.wave.personal"),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: SizedBox(
                      width: 140,
                      child: Image.network(
                        "https://play.google.com/intl/fr/badges/static/images/badges/fr_badge_web_generic.png",
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => launchUrl(

                      Uri.parse("https://apps.apple.com/us/app/wave-mobile-money/id1523884528"),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: SizedBox(
                      width: 140,
                      child: Image.network(
                        "https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/fr-fr",
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1DC8FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text("Fermer"),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}



