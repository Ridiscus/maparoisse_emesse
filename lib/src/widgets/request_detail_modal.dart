import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour les formats de date
// Ajoute ici tes imports pour AppTheme, AppLocalizations, PrimaryButton, etc.
import 'package:maparoisse/src/app_themes.dart';
import 'package:maparoisse/l10n/app_localizations.dart';
import 'package:maparoisse/src/services/pdf_receipt_service.dart';
import '../screens/widgets/primary_button.dart';



// ✅ On a enlevé le "_" devant le nom. C'est maintenant "RequestDetailModal".
class RequestDetailModal extends StatelessWidget {
  final Map<String, dynamic> request;
  final bool isSuccessMode;

  const RequestDetailModal({
    Key? key,
    required this.request,
    this.isSuccessMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;


    // --- LECTURE DES DONNÉES SÉCURISÉE ---
    final String intention = request['motif_intention'] ?? 'N/A';
    final String date = request['date_souhaitee'] ?? '';
    final String time = request['heure_souhaitee'] ?? '';
    final String formattedDateTime = _formatModalDateTime(date, time);
    final String celebration = request['celebration_choisie'] ?? 'N/A';
    // On gère le cas où le montant est un int ou un string
    final String montant = request['montant_offrande']?.toString() ?? '0';
    final String intercesseur = request['interception_par'] ?? 'Non spécifié';
    final String statut = request['statut'] ?? 'En attente'; // Statut par défaut
    final List<dynamic>? paiements = request['paiements'] as List?;
    // Note: Parfois l'API create ne renvoie pas le nom de la paroisse (juste l'ID).
    // On met une valeur par défaut au cas où.
    final String parishName = request['paroisse_name'] ?? 'Ma Paroisse';



    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Petite barre grise (Poignée)
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
            //decoration: BoxDecoration(
                  //color: Colors.grey[300],
                  //borderRadius: BorderRadius.circular(10),
                  //    ),
                ),
              ),

              // --- LOGIQUE D'AFFICHAGE (SUCCÈS vs NORMAL) ---
              if (isSuccessMode) ...[
                // MODE SUCCÈS : Coche verte + Message
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 50
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Demande enregistrée !",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Votre demande a bien été prise en compte.\nVous pouvez payer maintenant ou plus tard.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                  ],
                )
              ] else ...[
                // MODE NORMAL : Titre + Badge statut
                Text(
                  "Détails de la demande",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  // Assure-toi d'avoir ta fonction _buildStatusBadge disponible
                  child: _buildStatusBadge(context, statut, paiements),
                ),
                const Divider(height: 32),
              ],

              // --- DÉTAILS COMMUNS ---
              _buildDetailRow(context, Icons.info_outline, "Intention", intention),
              _buildDetailRow(context, Icons.church_outlined, "Paroisse", parishName),
              _buildDetailRow(context, Icons.calendar_today_outlined, "Date", formattedDateTime),
              _buildDetailRow(context, Icons.label_outline, "Célébration", celebration),
              _buildDetailRow(context, Icons.account_balance_wallet_outlined, "Offrande", "$montant FCFA"),

              const SizedBox(height: 24),

              // --- BOUTONS D'ACTION (Payer / Fermer) ---
              // Assure-toi d'avoir ta fonction _buildActionButtons disponible
              _buildActionButtons(context, statut, request),
            ],
          ),
        ),
      ),
    );
  }




  // ✅ CORRECTION : Ajout de (BuildContext context, ...)
  Widget _buildStatusBadge(BuildContext context, String status, List<dynamic>? paiements) {
    final l10n = AppLocalizations.of(context)!;

    Color backgroundColor;
    Color textColor;
    String statusText = status;
    String statusLower = status.toLowerCase();

    switch (statusLower) {
      case 'en_attente_paiement':
        backgroundColor = const Color(0xFFC0A040).withOpacity(0.15);
        textColor = const Color(0xFFC0A040);
        statusText = l10n.status_waiting_payment; // Maintenant ça marche
        break;


      case 'en attente': // Payé, en att. confirmation (AVEC ESPACE)
        backgroundColor = AppTheme.successColor.withOpacity(0.15);
        textColor = AppTheme.successColor;
        statusText = l10n.status_waiting_confirmation;
        break;

      case 'confirmee': // Confirmé par la paroisse (AVEC 'ee')
        backgroundColor = AppTheme.successColor.withOpacity(0.15);
        textColor = AppTheme.successColor;
        statusText = l10n.status_confirmed;
        break;

      case 'celebre':
        backgroundColor = AppTheme.infoColor.withOpacity(0.15);
        textColor = AppTheme.infoColor;
        statusText = l10n.status_celebrated;
        break;

      case 'annulee': // (J'ai corrigé le 'annulea' que j'ai vu dans ton code)
        backgroundColor = AppTheme.errorColor.withOpacity(0.15);
        textColor = AppTheme.errorColor;
        statusText = l10n.status_cancelled;
        break;


      default:
        backgroundColor = Colors.grey.withOpacity(0.15);
        textColor = Colors.grey;
        statusText = status;
    }


    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Text(
        statusText,
        style: TextStyle( color: textColor, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );

  }

  // Helper pour les lignes de détail (copié de event_screen)
  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }





  Widget _buildActionButtons(BuildContext context, String statut, Map<String, dynamic> request) {
    final l10n = AppLocalizations.of(context)!;

    // Définition des statuts
    const statusEnAttentePaiement = 'en_attente_paiement';
    const statusEnAttenteValidation = 'en attente';
    const statusConfirme = 'confirmee';
    const statusCelebre = 'celebre';

    String statusLower = statut.toLowerCase();

    // Condition pour le paiement (reste inchangée)
    bool canPay = statusLower == statusEnAttentePaiement || isSuccessMode;

    // --- CAS 1: En attente de paiement (ou Succès immédiat) ---
    if (canPay) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: PrimaryButton(
              text: l10n.pay_now,
              icon: Icons.payment,
              onPressed: () {

                // --- 💰 NOUVELLE LOGIQUE : FRAIS FIXES DE 200 FCFA ---

                final List<dynamic>? paiements = request['paiements'] as List?;
                String referenceToUse = "REF_TEMP";
                double montantOffrande = 0.0;
                double montantTotal = 0.0;

                // ✅ 1. DÉFINITION DES FRAIS FIXES
                double fraisFixes = 200.0;

                // 2. Récupération de l'offrande de base
                montantOffrande = double.tryParse(request['montant_offrande']?.toString() ?? '0') ?? 0;

                // 3. Gestion de la référence (Cas Retry vs Cas Nouveau)
                if (paiements != null && paiements.isNotEmpty) {
                  // On reprend la référence existante si disponible
                  final Map<String, dynamic> paiement = paiements[0];
                  referenceToUse = paiement['reference'] ?? "REF_${request['id']}";
                } else {
                  // Nouvelle référence
                  referenceToUse = "MESSE_${request['id']}";
                }

                // ✅ 4. CALCUL DU TOTAL (On force la règle : Offrande + 200)
                // Peu importe ce que dit le backend ou l'ancien calcul, on applique la règle actuelle.
                montantTotal = montantOffrande + fraisFixes;

                final int messeId = request['id'] is int
                    ? request['id']
                    : int.tryParse(request['id'].toString()) ?? 0;

                // 5. Navigation vers l'écran de paiement
                Navigator.pushNamed(
                  context,
                  '/payment',
                  arguments: {
                    'typeIntention': request['motif_intention'],
                    'montant': montantOffrande,
                    'frais': fraisFixes, // Affiche "200.0"
                    'total': montantTotal, // Affiche "Offrande + 200.0"
                    'reference': referenceToUse,
                    'messeId': messeId,
                  },
                );
              },
            ),
          ),
        ],
      );
    }

    // --- CAS 2: Confirmé, Célébré OU En attente de validation ---
    if (statusLower == statusConfirme ||
        statusLower == statusCelebre ||
        statusLower == statusEnAttenteValidation) {

      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),

                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: PrimaryButton(
              text: l10n.print_receipt,
              icon: Icons.print_outlined,
              onPressed: () {
                final double screenHeight = MediaQuery.of(context).size.height;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.print, color: Colors.white),
                        const SizedBox(width: 12),
                        const Text(
                            'Génération du reçu en cours...',
                            style: TextStyle(fontWeight: FontWeight.w600)
                        ),
                      ],
                    ),
                    backgroundColor: AppTheme.infoColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                    ),
                    margin: EdgeInsets.only(
                        bottom: screenHeight - 165, // Ajusté pour ne pas être trop haut
                        left: 20,
                        right: 20
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );

                try {
                  final pdfService = PdfReceiptService();
                  pdfService.generateAndShowReceipt(request: request);
                } catch (e) {
                  _showError(context, "Erreur lors de la création du PDF: $e");
                }
              },
            ),
          ),
        ],
      );
    }

    // --- CAS 3: Annulé ou autre ---
    return PrimaryButton(
      text: l10n.close,
      onPressed: () => Navigator.of(context).pop(),
    );
  }






  // --- NOUVEAU : Helper pour afficher les erreurs dans le modal ---
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Helper pour formater la date/heure du modal
  String _formatModalDateTime(String dateStr, String timeStr) {
    try {
      final dateTime = DateTime.parse(dateStr + ' ' + timeStr);
      return DateFormat('EEEE d MMMM yyyy à HH:mm', 'fr_FR').format(dateTime);
    } catch (e) {
      return "$dateStr à $timeStr";
    }
  }

}


