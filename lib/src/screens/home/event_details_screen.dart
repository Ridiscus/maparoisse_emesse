import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app_themes.dart'; // Adapte le chemin

class EventDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> eventData;

  const EventDetailsScreen({Key? key, required this.eventData}) : super(key: key);

  // Helper pour formater les dates
  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Date inconnue';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE d MMMM yyyy à HH:mm', 'fr_FR').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extraction des données du JSON
    final String title = eventData['titre'] ?? 'Événement';
    final String description = eventData['description'] ?? '';
    final String lieu = eventData['lieu'] ?? 'Non précisé';
    final String prix = eventData['participation_frais']?.toString() ?? 'Gratuit';
    final String type = eventData['type_event'] ?? 'Événement';
    final String? imageUrl = eventData['image'];

    // --- AJOUTE CETTE LIGNE ---
    final String paroisse = eventData['paroisse']?['name'] ?? 'Paroisse inconnue';
    // --- FIN AJOUT ---

    final String dateDebut = _formatDate(eventData['date_debut']);
    final String dateFin = _formatDate(eventData['date_fin']);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Grande image d'en-tête (SliverAppBar)
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black)]
                ),
              ),
              background: imageUrl != null
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Container(
                color: AppTheme.primaryColor,
                child: const Icon(Icons.event, size: 80, color: Colors.white24),
              ),
            ),
          ),

          // 2. Contenu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge Type
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.infoColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: TextStyle(color: AppTheme.infoColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Infos principales
                  _buildInfoRow(Icons.location_on, lieu),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.church, paroisse), // Affiche la paroisse
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.calendar_today, "Du $dateDebut"),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 36), // Alignement
                    child: Text("Au $dateFin", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.monetization_on, prix == "0.00" || prix == "0" ? "Gratuit" : "$prix FCFA"),

                  const Divider(height: 40),

                  // Description
                  const Text(
                    "À propos",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),

                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                  ),

                  const SizedBox(height: 40),

                  // Bouton d'action (Optionnel)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        // Action (ex: s'inscrire, partager...)
                      },
                      child: const Text("Je participe", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}