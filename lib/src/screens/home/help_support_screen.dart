import 'package:flutter/material.dart';
import '../../theme.dart';
import '../widgets/modern_card.dart';
import '../widgets/logo_widget.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.white,
        ),
        backgroundColor: AppTheme.primaryColor,
        title: const Text("Aide et support",
          style: TextStyle(
            color: Colors.white, // 👈 garde le titre en blanc
          ),
        ),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const SanctaMissaLogo(),
                const SizedBox(height: 20),
                ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("FAQ", style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      _buildFaqItem("Comment changer mon mot de passe ?",
                          "Allez dans Paramètres > Sécurité."),
                      _buildFaqItem("Comment activer les notifications ?",
                          "Allez dans Paramètres > Notifications."),
                      _buildFaqItem("J’ai un problème avec mon compte",
                          "Contactez notre support."),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: ouvrir email ou WhatsApp support
                        },
                        icon: const Icon(Icons.contact_support_outlined),
                        label: const Text("Contacter le support"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(answer, style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}