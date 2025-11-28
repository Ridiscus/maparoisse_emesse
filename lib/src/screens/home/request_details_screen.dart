import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../app_themes.dart';




class RequestDetailsScreen extends StatefulWidget {
  final int? requestId; // Peut être null si on a déjà les data
  final Map<String, dynamic>? initialData; // Les données reçues de la notif

  const RequestDetailsScreen({
    Key? key,
    this.requestId,
    this.initialData
  }) : super(key: key);

  @override
  _RequestDetailsScreenState createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _requestData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Si on nous a déjà passé les données (via la notif), on les affiche direct !
    if (widget.initialData != null) {
      _requestData = widget.initialData;
      _isLoading = false;
    } else if (widget.requestId != null) {
      // Sinon, on charge via l'ID (ancienne méthode)
      _fetchDetails(widget.requestId!);
    } else {
      _isLoading = false;
      _errorMessage = "Aucune donnée trouvée.";
    }
  }

  Future<void> _fetchDetails(int id) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final data = await authService.getMassRequestDetails(id);
      if (mounted) {
        setState(() {
          _requestData = data;
          _isLoading = false;
          if (data == null) _errorMessage = "Impossible de charger les détails.";
        });
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = "Erreur : $e");
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "N/A";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy', 'fr_FR').format(date);
    } catch (e) { return dateStr; }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmee': return Colors.green; // Selon ton JSON
      case 'validée': return Colors.green;
      case 'en attente': return Colors.orange;
      case 'annulée': return Colors.red;
      default: return Colors.blueGrey;
    }
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Raccourci pour le thème

    return Scaffold(
      // ✅ CORRECTION 1 : Fond dynamique (Blanc en clair, Noir en sombre)
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("Détails de la demande"),
        // Tu peux garder la couleur primaire si tu veux, ou utiliser theme.appBarTheme.backgroundColor
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white, // Texte blanc sur fond coloré
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
        // Loader adapté au fond
          child: CircularProgressIndicator(color: AppTheme.primaryColor)
      )
          : _errorMessage != null
          ? Center(
          child: Text(
            _errorMessage!,
            style: TextStyle(color: theme.colorScheme.error),
          )
      )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_requestData == null) return const SizedBox();

    final theme = Theme.of(context); // Raccourci thème

    // MAPPING DES CLÉS
    final String intention = _requestData!['motif_intention'] ?? 'Non précisé';
    final String demandeur = _requestData!['nom_demandeur'] ?? 'Anonyme';
    final String dateSouhaitee = _requestData!['date_souhaitee'] ?? '';
    final String heureSouhaitee = _requestData!['heure_souhaitee'] ?? '';
    final String montant = _requestData!['montant_offrande']?.toString() ?? '0';
    final String status = _requestData!['statut'] ?? 'Inconnu';
    final String paroisse = _requestData!['paroisse'] != null ? _requestData!['paroisse']['name'] : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Carte Statut
          Card(
            elevation: 4,
            // ✅ CORRECTION 2 : Couleur de la carte dynamique
            color: theme.cardTheme.color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline, size: 50, color: _getStatusColor(status)),
                  const SizedBox(height: 10),
                  Text(
                      status.toUpperCase(),
                      style: TextStyle(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                      )
                  ),
                  if (paroisse.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Paroisse $paroisse",
                        // ✅ CORRECTION 3 : Texte secondaire dynamique
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Carte Détails
          Card(
            elevation: 2,
            // ✅ CORRECTION 4 : Couleur de la carte dynamique
            color: theme.cardTheme.color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row(Icons.calendar_today, "Date souhaitée", "$dateSouhaitee à $heureSouhaitee"),

                  const Divider(),
                  _row(Icons.person, "Demandeur", demandeur),
                  const Divider(),
                  _row(Icons.monetization_on, "Offrande", "$montant FCFA"),
                  const Divider(),

                  // Intention
                  Text(
                      "Intention :",
                      // ✅ CORRECTION 5 : Titre section dynamique
                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)
                  ),
                  const SizedBox(height: 5),
                  Text(
                      intention,
                      // ✅ CORRECTION 6 : Contenu intention dynamique
                      style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurface.withOpacity(0.9)
                      )
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    final theme = Theme.of(context); // Raccourci thème

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 15),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        label,
                        // ✅ CORRECTION 7 : Label gris adapté au mode sombre
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))
                    ),
                    Text(
                        value,
                        // ✅ CORRECTION 8 : Valeur (Blanc en sombre, Noir en clair)
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: theme.colorScheme.onSurface
                        )
                    ),
                  ]
              )
          ),
        ],
      ),
    );
  }




}