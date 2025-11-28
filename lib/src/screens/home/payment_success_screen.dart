import 'package:flutter/material.dart';
import 'package:maparoisse/src/app_themes.dart'; // Importe tes thèmes
import 'package:maparoisse/src/screens/widgets/primary_button.dart'; // Importe ton bouton
import 'package:maparoisse/src/screens/home/dashboard_screen.dart'; // Importe ton dashboard

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. L'icône de succès (style Djamo)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 80,
                ),
              ),
              const SizedBox(height: 32),

              // 2. Le message
              Text(
                'Paiement Réussi !',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Votre paiement a été effectué avec succès. Votre demande de messe est en cours de confirmation.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 48),

              // 3. Le bouton pour retourner aux demandes
              PrimaryButton(
                text: 'Terminé',
                onPressed: () {
                  // Renvoie au Dashboard (et change l'onglet pour voir la liste)
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardScreenWithIndex()),
                        (route) => false,
                  );
                  // Change l'onglet pour "Mes demandes" (index 2)
                  DashboardScreenWithIndex.globalKey.currentState?.goToIndex(2);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}