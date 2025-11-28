import 'package:flutter/material.dart';
import 'package:maparoisse/src/screens/home/parish_detail_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../../app_themes.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class ParishScreen extends StatefulWidget {
  const ParishScreen({super.key});

  @override
  State<ParishScreen> createState() => _ParishScreenState();
}

class _ParishScreenState extends State<ParishScreen> {
  final TextEditingController _searchController = TextEditingController();

  late Future<List<dynamic>> _parishesFuture;
  bool _isLoading = true;
  List<dynamic> _allParishes = []; // Liste complète pour la recherche
  List<dynamic> _filteredParishes = []; // Liste filtrée
  bool _hasError = false; // Pour afficher un bouton "Réessayer" au milieu si vide

  @override
  void initState() {
    super.initState();
    _loadParishes();
    _searchController.addListener(_filterParishes); // Ajoute un listener pour le filtre
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterParishes);
    _searchController.dispose();
    super.dispose();
  }


  // --- FONCTION DE CHARGEMENT ADAPTÉE ---
  Future<void> _loadParishes() async {
    // Sécurité : Si le widget n'est pas là, on arrête
    if (!mounted) return;

    // 1. On lance le chargement
    setState(() {
      _isLoading = true;
      _hasError = false;
      // Optionnel : Tu peux vider la liste avant de charger si tu veux un écran blanc
      // _filteredParishes = [];
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      // 2. Appel API (On attend la réponse avec await)
      // Assure-toi que getParishes() retourne bien une List<dynamic> ou List<Map>
      final data = await authService.getParishes();

      // 3. Succès : On met à jour les données
      if (mounted) {
        setState(() {
          _allParishes = data;     // Garde une copie complète pour la recherche
          _filteredParishes = data; // Initialise la liste affichée
          _isLoading = false;
        });
      }
    } catch (e) {
      // 4. Erreur : On arrête le chargement et on affiche l'erreur
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _filteredParishes = []; // Vide la liste en cas d'erreur
        });

        // C'est ICI que le message flottant apparaît en haut
        _showTopNetworkError(e.toString());
      }
    }
  }

  // --- NOUVEAU : Logique de filtre ---
  void _filterParishes() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _filteredParishes = _allParishes;
      });
      return;
    }

    setState(() {
      _filteredParishes = _allParishes.where((parish) {
        final name = (parish['name'] ?? '').toLowerCase();
        final commune = (parish['commune'] ?? '').toLowerCase();
        final ville = (parish['ville'] ?? '').toLowerCase();

        return name.contains(query) ||
            commune.contains(query) ||
            ville.contains(query);
      }).toList();
    });
  }


  // --- FONCTION POUR AFFICHER L'ERREUR EN HAUT ---
  void _showTopNetworkError(String message) {
    final l10n = AppLocalizations.of(context)!;
    // Si le widget n'est plus là, on ne fait rien
    if (!mounted) return;

    final double screenHeight = MediaQuery.of(context).size.height;

    // On nettoie le message d'erreur brut pour l'utilisateur
    String userMessage = l10n.connectionError;
    if (message.contains("SocketException") || message.contains("réseau") || message.contains("internet")) {
      userMessage = l10n.internetError;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.white), // Icône Wifi barré
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                userMessage,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.errorColor, // Rouge
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // --- LA MAGIE POUR L'AFFICHER EN HAUT ---
        margin: EdgeInsets.only(
            bottom: screenHeight - 160, // Pousse vers le haut
            left: 20,
            right: 20
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }





  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // ... (Ton AppBar - inchangée) ...
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.searchParishTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Theme.of(context).colorScheme.onSurface,),
            onPressed: () {
              Navigator.pushNamed(context, '/parametres');
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          _buildNearbyParishesSection(),
        ],
      ),
    );
  }


  Widget _buildSearchBar() {
    final theme = Theme.of(context); // Raccourci thème
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: theme.colorScheme.onSurface), // Couleur du texte saisi
        decoration: InputDecoration(
          hintText: l10n.searchHint,
          // ✅ CORRECTION 1 : Couleur du hint dynamique
          hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),

          prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface),
          filled: true,

          // ✅ CORRECTION 2 : Fond du champ (Gris foncé en sombre, Blanc en clair)
          fillColor: theme.cardTheme.color,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
        ),
      ),
    );
  }



  Widget _buildNearbyParishesSection() {
    final theme = Theme.of(context); // Raccourci thème
    final l10n = AppLocalizations.of(context)!;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.parishesSectionTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  // Adaptation Mode Sombre : Transparent ou Gris clair
                  color: theme.brightness == Brightness.dark
                      ? Colors.transparent
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),

                // --- ICI ON REMPLACE FUTUREBUILDER PAR LA LOGIQUE D'ÉTAT ---
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                    : _hasError
                    ? Center(
                  // État d'erreur (avec bouton Réessayer)
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, size: 40, color: theme.colorScheme.error),
                      const SizedBox(height: 10),
                      Text(
                        l10n.loadingErrorMessage,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _loadParishes, // Appelle ta fonction pour réessayer
                        style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
                        child: Text(l10n.retryButton),
                      )
                    ],
                  ),
                )
                    : _filteredParishes.isEmpty
                    ? Center(
                  // État vide (Recherche ou Liste vide)
                  child: Text(
                    _searchController.text.isNotEmpty
                        ? l10n.noParishesFound
                        : l10n.noParishesAvailable,
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                )
                    : ListView.builder(
                  // État succès : Liste des paroisses
                  padding: const EdgeInsets.all(12.0),
                  itemCount: _filteredParishes.length,
                  itemBuilder: (context, index) {
                    return _buildParishItem(_filteredParishes[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // --- WIDGET ITEM ENTIÈREMENT CORRIGÉ ---
  Widget _buildParishItem(Map<String, dynamic> parish) {
    const Color detailsButtonColor = Color(0xFFC0A040);
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context); // Raccourci thème

    // --- 1. CORRECTION GESTION IMAGE (Logique de nettoyage agressive) ---
    String? imgPath = parish['profile_picture']; // C'est la bonne clé

    ImageProvider backgroundImage;
    if (imgPath != null && imgPath.isNotEmpty) {

      if (imgPath.startsWith('http')) {
        // C'est déjà une URL complète
        backgroundImage = NetworkImage(imgPath);
      }
      else {
        // --- CORRECTION DÉFINITIVE ---
        // On nettoie le chemin cassé de l'API /paroisses

        // 1. Enlève "/storage/paroisses/" (si présent)
        if (imgPath.startsWith('/storage/paroisses/')) {
          imgPath = imgPath.substring(19); // Enlève "/storage/paroisses/"
        }
        // 2. Enlève "/paroisses/" (si présent)
        else if (imgPath.startsWith('/paroisses/')) {
          imgPath = imgPath.substring(10); // Enlève "/paroisses/"
        }
        // 3. Enlève "/storage/" (si présent)
        else if (imgPath.startsWith('/storage/')) {
          imgPath = imgPath.substring(8); // Enlève "/storage/"
        }
        // 4. Enlève juste le "/" au début
        else if (imgPath.startsWith('/')) {
          imgPath = imgPath.substring(1);
        }

        // 5. Reconstruit l'URL PROPRE
        final finalUrl = "https://sancta-missa.com/storage/" + imgPath;
        print("URL Paroisse Liste: $finalUrl"); // Pour déboguer
        backgroundImage = NetworkImage(finalUrl);
        // --- FIN CORRECTION ---
      }

    } else {
      // Fallback
      backgroundImage = const AssetImage('assets/images/placeholder_event.jpg');
    }
    // --- FIN CORRECTION IMAGE ---

    // --- 2. GESTION DES INFOS (CORRECTION) ---
    // L'API renvoie 'commune' et 'ville'
    String commune = parish['commune'] ?? '';
    String ville = parish['ville'] ?? 'Lieu inconnu';

    // Construit la chaîne de localisation
    String locationInfo = ville;
    if (commune.isNotEmpty && commune != ville) {
      locationInfo = "$commune, $ville";
    }
    // --- FIN GESTION INFOS ---

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          // Image (utilise le placeholder)
          CircleAvatar(
            radius: 30,
            backgroundImage: backgroundImage,
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(width: 16),
          // Infos Paroisse (corrigées)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parish['name'] ?? l10n.unknownParish,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  locationInfo, // <-- Corrigé
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Bouton Détails
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ParishDetailScreen(parishData: parish),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: detailsButtonColor.withOpacity(0.15),
              foregroundColor: detailsButtonColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: Text(l10n.detailsButton),
          ),
        ],
      ),
    );
  }

}