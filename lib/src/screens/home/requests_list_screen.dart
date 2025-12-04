import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Pour le FAB
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../app_themes.dart'; // Assure-toi que le chemin est correct
import 'package:maparoisse/src/screens/widgets/primary_button.dart';
import 'package:maparoisse/utils/navigation_state.dart';
import 'package:provider/provider.dart'; // <-- AJOUTE cet import
import '../../services/auth_service.dart'; // <-- MODIFIE cet import
import 'package:maparoisse/src/screens/home/parish_detail_screen.dart';
import 'package:maparoisse/src/widgets/request_detail_modal.dart';

// Retire les imports non utilisés comme AnimatedHeader, ModernCard, etc. si tu ne les utilises plus ici

// Modèle de données simplifié (AJOUTE le champ isFavorite)
// Tu devras adapter ton vrai modèle Request
class Request {
  final String id;
  final String intention;
  final String paroisse;
  final String date; // Doit être un format parsable (ISO ou dd/MM/yyyy/HH:mm)
  final String status; // 'En attente', 'Confirmé', 'Célébré', 'Annulé'
  final bool isFavorite; // CHAMP IMPORTANT POUR LES FAVORIS

  Request({
    required this.id,
    required this.intention,
    required this.paroisse,
    required this.date,
    required this.status,
    this.isFavorite = false,
  });
}


class RequestsListScreen extends StatefulWidget {
  final VoidCallback? onNewRequest; // Pour naviguer vers la création
  const RequestsListScreen({super.key, this.onNewRequest});

  @override
  State<RequestsListScreen> createState() => _RequestsListScreenState();
}

class _RequestsListScreenState extends State<RequestsListScreen> with TickerProviderStateMixin, WidgetsBindingObserver  {
  late TabController _tabController;
  bool _isRefreshing = false;
  late AuthService _authService;

  bool _isLoading = true;


  // --- Données de l'API ---
  List<dynamic> _allRequests = []; // Remplacera les données fictives
  // --- Fin Données API ---

  final List<String> _tabs = ['En cours', 'Historique', 'Favoris'];
  final Color _ocreColor = const Color(0xFFC0A040);


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _authService = Provider.of<AuthService>(context, listen: false);

    // Charge les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _handleInitialFilter(); // Gère le filtre (code inchangé)
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    // 2. Ajoute l'observateur
    WidgetsBinding.instance.addObserver(this);

  }


  @override
  void dispose() {
    _tabController.dispose();
    // 3. Retire l'observateur
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  // 4. Ajoute cette méthode
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Si l'utilisateur revient sur l'application (ex: après avoir quitté Wave)
    if (state == AppLifecycleState.resumed) {
      // Rafraîchit les données
      _loadData(isRefresh: true);
    }
  }


  // DANS LA CLASSE _RequestsListScreenState

  void _handleInitialFilter() {
    // --- LOGIQUE POUR LE FILTRE INITIAL ---
    // (C'est le code que tu avais déjà, maintenant dans une fonction)

    // Lit la valeur du filtre une seule fois
    final initialFilter = initialRequestListFilter.value;
    if (initialFilter != null) {
      int targetTabIndex = 0; // Onglet par défaut ('En cours')

      // Détermine l'index de l'onglet cible basé sur le filtre
      if (initialFilter == 'en attente' || initialFilter == 'a venir') {
        targetTabIndex = 0; // Index de l'onglet 'En cours'
      } else if (initialFilter == 'célébré') {
        // Si 'Célébrées' a été cliqué, va à l'onglet 'Historique'
        targetTabIndex = 1; // Index de l'onglet 'Historique'
      }

      // Change l'onglet du TabController
      if (targetTabIndex < _tabController.length) {
        _tabController.animateTo(targetTabIndex);
      }

      // Réinitialise immédiatement le filtre global
      initialRequestListFilter.value = null;

      // Force une mise à jour de l'état
      setState(() {});
    }
    // --- FIN LOGIQUE FILTRE INITIAL ---
  }



  /// MODIFIÉ : Charge uniquement les demandes
  Future<void> _loadData({bool isRefresh = false}) async {
    if (!isRefresh) setState(() => _isLoading = true);

    try {
      // Lance un seul appel API
      final requests = await _authService.getMassRequests();


      // --- AJOUTE CE PRINT DE DÉBOGAGE ---
      print("--- STATUTS DES MESSES REÇUES ---");
      for (var r in requests) {
        print("ID: ${r['id']}, STATUT: ${r['statut']}");
      }
      print("----------------------------------");
      // --- FIN DU PRINT ---

      if (mounted) {
        setState(() {
          _allRequests = requests;
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur de chargement: $e"), backgroundColor: AppTheme.errorColor)
        );
      }
    }
  }



  /// MODIFIÉ : Rafraîchissement
  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await _loadData(isRefresh: true); // Recharge les données de l'API

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Liste mise à jour'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }



  List<dynamic> _getRequestsForTab(int tabIndex) {
    // Plus besoin de récupérer l10n ici pour le switch
    List<dynamic> filtered = [];

    // Statuts de la table 'messe'
    const statusNonPaye = 'en_attente_paiement';
    const statusPayeAttenteConfirm = 'en attente';
    const statusConfirme = 'confirmee';
    const statusCelebre = 'celebre';
    const statusAnnule = 'annulee';

    // ✅ CORRECTION : Switch sur l'index (entier) au lieu du texte
    switch (tabIndex) {
      case 0: // Correspond à "En cours" (tab_in_progress)
        filtered = _allRequests.where((r) {
          String status = (r['statut'] ?? '').toLowerCase();
          return status == statusNonPaye || status == statusPayeAttenteConfirm;
        }).toList();
        break;

      case 1: // Correspond à "Historique" (tab_history)
        filtered = _allRequests.where((r) {
          String status = (r['statut'] ?? '').toLowerCase();
          return status == statusConfirme || status == statusCelebre || status == statusAnnule;
        }).toList();
        break;
    }

    filtered.sort((a, b) =>
        _parseDateRobust(b['created_at']).compareTo(_parseDateRobust(a['created_at']))
    );
    return filtered;
  }






  DateTime _parseDateRobust(String? dateStr) {
    if (dateStr == null) return DateTime(1900);
    try { return DateTime.parse(dateStr); } // ISO
    catch (_) { return DateTime(1900); }
  }

  String _formatDateTime(String? dateStr, String? timeStr) {
    if (dateStr == null || timeStr == null) return "Date inconnue";
    try {
      // Combine "2025-12-01" et "18:30:00" en un DateTime
      final dateTime = DateTime.parse(dateStr + ' ' + timeStr);
      return DateFormat('dd/MM/yyyy / HH:mm', 'fr_FR').format(dateTime);
    } catch (e) {
      print("Erreur formatage date: $e");
      return dateStr;
    }
  }




  // Icônes (peut être affinée)
  IconData _getRequestIcon(String intention) {
    String lowerIntention = intention.toLowerCase();
    if (lowerIntention.contains('défunt')) return Icons.person_outline;
    if (lowerIntention.contains('aide') || lowerIntention.contains('protection') || lowerIntention.contains('santé') || lowerIntention.contains('guérison') || lowerIntention.contains('grâces')) return Icons.volunteer_activism_outlined;
    if (lowerIntention.contains('paix') || lowerIntention.contains('foi') || lowerIntention.contains('mariale') || lowerIntention.contains('afrique')) return Icons.church_outlined;
    return Icons.event_note_outlined;
  }






  void _showRequestDetails(Map<String, dynamic> request) {
    print("Données envoyées au modal: $request");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Fond invisible pour voir derrière
      builder: (context) {
        return Padding(
          // On décolle le modal des bords (Gauche/Droite/Bas)
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            // On gère la barre système du bas + une petite marge de 20px
            bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 20,
            top: 60, // Marge de sécurité en haut
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor, // Fond du modal
              borderRadius: BorderRadius.circular(24), // Coins bien ronds partout
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias, // Force le contenu à respecter les coins ronds
            child: Column(
              mainAxisSize: MainAxisSize.min, // S'adapte à la hauteur du contenu
              children: [
                // Petit indicateur (Handle) en haut
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Le contenu de ton modal
                Flexible(
                  child: RequestDetailModal(request: request),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  // --- NOUVEAU : Logique de suppression ---
  Future<void> _confirmAndDelete(int requestId) async {
    final l10n = AppLocalizations.of(context)!;

    // 1. Demander confirmation
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          title: Text("Supprimer la demande ?", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          content: Text(
            "Voulez-vous vraiment supprimer cette demande en attente de paiement ?",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
              child: const Text("Supprimer"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    // 2. Appeler l'API
    setState(() => _isLoading = true); // Petit chargement global ou local

    // Convertir l'ID dynamique en int si nécessaire
    final success = await _authService.deleteMassRequest(requestId);

    if (success && mounted) {
      // 3. Mise à jour locale : On retire l'élément de la liste _allRequests
      setState(() {
        _allRequests.removeWhere((r) => r['id'] == requestId);
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Demande supprimée avec succès."),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Impossible de supprimer cette demande."),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }


  // --- Widgets UI ---
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Cas de chargement initial
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Si _allRequests est vide après le chargement, affiche l'état vide principal
    if (_allRequests.isEmpty) {

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(),
        body: Stack( // Ajout du Stack ici aussi pour l'état vide
          fit: StackFit.expand, // Pour que l'image prenne toute la place
          children: [
            // --- Image de fond pour l'état vide ---
            Opacity(
              opacity: 0.1, // Ajuste l'opacité
              child: Image.asset(
                'assets/images/background_pattern.jpg', // REMPLACE par ton image de fond
                fit: BoxFit.contain, // Couvre tout l'espace
              ),
            ),
            // --- Contenu de l'état vide ---
            _buildEmptyState(),
          ],
        ),
      );
    }

    // Cas principal avec contenu
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Stack( // Utilisation du Stack comme conteneur principal du body
        fit: StackFit.expand, // L'image prendra toute la place disponible
        children: [
          // --- 1. Image de fond semi-transparente ---
          Positioned.fill( // Assure que l'image remplit tout l'espace du Stack
            child: Opacity(
              opacity: 0.08, // Très faible opacité, ajuste selon ton image et le mockup (entre 0.05 et 0.15)
              child: Image.asset(
                'assets/images/background_pattern.jpg', // REMPLACE par le chemin de ton image de fond
                fit: BoxFit.contain, // Couvre tout l'espace disponible
                // Optionnel: Répéter l'image si c'est un motif
                // repeat: ImageRepeat.repeat,
              ),
            ),
          ),

          // --- 2. Contenu (TabBar + TabBarView) par-dessus l'image ---
          Column(
            children: [
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: List.generate(_tabs.length, (index) {
                    String currentTab = _tabs[index];

                    if (currentTab == l10n.tab_favorites) {
                      // --- Onglet Favoris ---
                      return FutureBuilder<List<dynamic>>(
                        future: _authService.getFavoriteParishes(),
                        builder: (context, snapshot) {
                          // ... (logique du FutureBuilder reste identique)
                          if (snapshot.connectionState == ConnectionState.waiting && !_isRefreshing) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            print("Erreur chargement favoris: ${snapshot.error}");
                            return Center(child: Text('Erreur: ${snapshot.error}'));
                          }
                          final favorites = snapshot.data ?? [];

                          if (favorites.isEmpty) {
                            return _buildNoResults(true);
                          }

                          return RefreshIndicator(
                            onRefresh: _handleRefreshFavorites,
                            color: _ocreColor,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),

                              itemCount: favorites.length,
                              itemBuilder: (context, itemIndex) {
                                return _buildFavoriteParishCard(favorites[itemIndex], itemIndex);
                              },
                            ),
                          );
                        },
                      );
                    } else {
                      // --- Onglets 'En cours' et 'Historique' (MODIFIÉS) ---
                      final filteredRequests = _getRequestsForTab(index);

                      if (filteredRequests.isEmpty) {
                        return _buildNoResults(false);
                      } else {
                        return RefreshIndicator(
                          onRefresh: _handleRefresh,
                          color: _ocreColor,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                            itemCount: filteredRequests.length,
                            itemBuilder: (context, itemIndex) {
                              // On passe le Map<String, dynamic>
                              return _buildRequestCard(
                                filteredRequests[itemIndex],
                                itemIndex,
                              );
                            },
                          ),
                        );
                      }
                    }
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  AppBar _buildAppBar() {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Fond clair pour l'AppBar
      elevation: 0,
      automaticallyImplyLeading: false, // Pas de flèche retour
      title: Text(
        l10n.requests_title,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface, // Texte sombre sur fond clair
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings_outlined, color: Theme.of(context).colorScheme.onSurface,),
          onPressed: () {
            Navigator.pushNamed(context, '/parametres'); // Navigation vers Paramètres
          },
        ),
      ],
    );
  }


  Widget _buildTabBar() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          // ✅ CORRECTION 9 : Fond de la barre d'onglets
          // En mode clair : Gris très clair (Colors.grey[200])
          // En mode sombre : Gris foncé / Noir (cardTheme.color)
          color: theme.brightness == Brightness.dark
              ? theme.cardTheme.color
              : Colors.grey[200],

          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              color: _ocreColor, // L'ocre reste joli sur fond sombre ou clair
              boxShadow: [
                BoxShadow(
                  color: _ocreColor.withOpacity(0.3),
                  blurRadius: 5, offset: const Offset(0, 2),
                )
              ]
          ),
          indicatorWeight: 0,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white, // Texte sélectionné (sur fond ocre) -> Toujours Blanc

          // ✅ CORRECTION 10 : Texte non sélectionné (Gris adapté au fond)
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),

          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
          tabs: _tabs.map((tabName) => Tab(text: tabName)).toList(),
        ),
      ),
    );
  }


  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () async {

        // --- CORRECTION ---
        // 1. Navigue et ATTEND une réponse (ex: 'true' si succès)
        final result = await Navigator.pushNamed(context, '/requests');
        // --- FIN CORRECTION ---

        // 2. Rafraîchit la liste (cette ligne est déjà correcte)
        // Elle s'exécutera que la demande ait réussi ou non.
        _loadData(isRefresh: true);

        // --- AJOUT ---
        // 3. Affiche le message de succès SI la demande a réussi
        if (result == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Demande enregistrée. Vous pouvez payer depuis 'Mes demandes'."),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
        // --- FIN AJOUT ---
      },

      backgroundColor: _ocreColor,
      foregroundColor: Colors.white,
      elevation: 4.0,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, size: 30),
    ).animate().scale(
      delay: 500.ms, duration: 600.ms, curve: Curves.elasticOut,
    );
  }



  /// MODIFIÉ : _buildRequestCard
  Widget _buildRequestCard(Map<String, dynamic> request, int index) {
    final theme = Theme.of(context); // Raccourci thème

    // Lit les données de l'API
    final String intention = request['motif_intention'] ?? 'Intention non spécifiée';
    final String status = request['statut'] ?? 'inconnu';
    final String date = request['date_souhaitee'];
    final String time = request['heure_souhaitee'];
    final String parishName = request['paroisse_name'] ?? 'Paroisse inconnue';


    // Récupération sécurisée de l'ID
    final int requestId = request['id'] is int ? request['id'] : int.parse(request['id'].toString());

    // --- CONDITION : Est-ce qu'on peut supprimer ? ---
    // Uniquement si "en_attente_paiement"
    bool canDelete = status.toLowerCase() == 'en_attente_paiement';

    Widget trailingWidget = _buildStatusBadge(status);

    return GestureDetector(
      onTap: () {
        _showRequestDetails(request); // Appelle le nouveau modal
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(_getRequestIcon(intention), color: theme.colorScheme.onSurface, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    intention, // Utilise la donnée API
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ), const SizedBox(height: 4),
                  Text(
                    'Paroisse $parishName', // Utilise le nom trouvé
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateTime(date, time), // Utilise la donnée API
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // --- MODIFICATION ICI ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                trailingWidget, // Le badge de statut

                // Le bouton supprimer (visible uniquement si canDelete est vrai)
                if (canDelete)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: InkWell(
                      onTap: () => _confirmAndDelete(requestId), // Appelle la suppression
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: AppTheme.errorColor
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  /// MODIFIÉ : _buildStatusBadge (ajout de 'confirmé')
  Widget _buildStatusBadge(String status) {
    final l10n = AppLocalizations.of(context)!;

    Color backgroundColor;
    Color textColor;
    String statusText = status;
    String statusLower = status.toLowerCase();

    // Logique basée sur la table 'messe'
    switch (statusLower) {
      case 'en_attente_paiement': // Non payé
        backgroundColor = _ocreColor.withOpacity(0.15);
        textColor = _ocreColor;
        statusText = l10n.status_waiting_payment;
        break;

      case 'en attente': // Payé, en att. confirmation
        backgroundColor = AppTheme.successColor.withOpacity(0.15);
        textColor = AppTheme.successColor;
        statusText = l10n.status_waiting_confirmation;
        break;

    // --- AJOUT ---
      case 'confirmee': // Confirmé par la paroisse
        backgroundColor = AppTheme.successColor.withOpacity(0.15); // Vert aussi
        textColor = AppTheme.successColor;
        statusText = l10n.status_confirmed;
        break;
    // --- FIN AJOUT ---

      case 'celebre':
        backgroundColor = AppTheme.infoColor.withOpacity(0.15);
        textColor = AppTheme.infoColor;
        statusText = l10n.status_celebrated;
        break;

      case 'annulee':
        backgroundColor = AppTheme.errorColor.withOpacity(0.15);
        textColor = AppTheme.errorColor;
        statusText = l10n.status_cancelled;
        break;

      default:
        backgroundColor = Colors.grey.withOpacity(0.15);
        textColor = Colors.grey;
        statusText = status; // Affiche le statut inconnu
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



  // Widget pour "Aucun résultat" ou "Aucun favori"
  Widget _buildNoResults(bool isFavoriteTab) {
    final l10n = AppLocalizations.of(context)!;

    String title = isFavoriteTab ? l10n.no_favorite_title : l10n.no_result_title; // Titre adapté
    String message = isFavoriteTab
        ? l10n.no_favorite_message // Message adapté
        : l10n.no_result_message; // Message adapté
    IconData icon = isFavoriteTab ? Icons.star_border_rounded : Icons.search_off_rounded; // Icône adaptée

    // ... (le reste du widget Column reste identique, MAIS retire le bouton "Effacer Filtres" pour les favoris)
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 64.0, horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: AppTheme.textSecondary)
                  .animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))
                  .animate().fadeIn(duration: 600.ms, delay: 200.ms),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
              // Pas de bouton "Effacer filtres" ici
            ],
          ),
        ),
      ),
    );
  }


  // DANS _RequestsListScreenState
  Future<void> _handleRefreshFavorites() async {
    final l10n = AppLocalizations.of(context)!;
    // Force une reconstruction du FutureBuilder en appelant setState
    // Le FutureBuilder rappellera FavoriteService.getFavorites()
    setState(() {});
    // Simule un petit délai pour l'indicateur de rafraîchissement
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.favorites_updated),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }



  // DANS LA CLASSE _RequestsListScreenState (fichier requests_list_screen.dart)

// --- MODIFIÉ pour lire le JSON imbriqué ---
  Widget _buildFavoriteParishCard(Map<String, dynamic> favoriteData, int index) {
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context); // Raccourci thème

    // 1. Extraire l'objet paroisse imbriqué
    final Map<String, dynamic>? parish = favoriteData['paroisse'];

    // Sécurité : si l'objet 'paroisse' est manquant, on affiche une erreur
    if (parish == null) {
      return const Card(child: ListTile(title: Text("Erreur: Données de paroisse invalides")));
    }

    // 2. Lire les clés depuis l'objet 'parish' (interne)
    final parishId = parish['id'] ?? 0;
    final parishName = parish['name'] ?? 'Nom inconnu';

    // 3. Lire les clés imbriquées pour la localisation
    // (Utilise '?' pour naviguer en toute sécurité dans le JSON)
    final String communeName = parish['commune']?['nom_commune'] ?? 'Commune inconnue';
    final String cityName = parish['commune']?['ville']?['nom_ville'] ?? 'Ville inconnue';

    String locationInfo = "Lieu inconnu";
    if (cityName.isNotEmpty && communeName.isNotEmpty && cityName != communeName) {
      locationInfo = "$communeName, $cityName";
    } else if (communeName.isNotEmpty) {
      locationInfo = communeName;
    } else if (cityName.isNotEmpty) {
      locationInfo = cityName;
    }

    // 4. Gérer l'image (en lisant 'profile_picture' de l'objet 'parish')
    String? imageUrl = parish['profile_picture']; // Clé de l'API (dans 'paroisse')
    ImageProvider backgroundImage;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (!imageUrl.startsWith('http')) {
        imageUrl = "https://sancta-missa.com/storage/" + imageUrl;
      }
      backgroundImage = NetworkImage(imageUrl);
    } else {
      backgroundImage = const AssetImage('assets/images/placeholder_event.jpg'); // Ton placeholder
    }

    return GestureDetector(
      onTap: () {
        // IMPORTANT : On passe l'objet 'parish' (interne) à l'écran de détail
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ParishDetailScreen(parishData: parish)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: [
            BoxShadow( color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2),)
          ],
        ),
        child: Row(
          children: [
            // Image (corrigée)
            CircleAvatar(
              radius: 20,
              backgroundImage: backgroundImage,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parishName, // Utilise la variable lue
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    locationInfo, // Utilise la variable lue
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Bouton pour retirer des favoris

            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(Icons.star, color: _ocreColor, size: 28),
              tooltip: l10n.favorite_removed(parishName),
              onPressed: () async {
                // Cette logique est correcte, elle utilise le parishId
                try {
                  if (parishId == 0) return;

                  bool success = await _authService.toggleParishFavorite(parishId);

                  if (success) {
                    setState(() {}); // Rafraîchit la liste
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.favorite_removed(parishName))),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.favorite_remove_error), backgroundColor: AppTheme.errorColor),
                    );
                  }
                } catch (e) {
                  print("Erreur removeFavorite: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.favorite_remove_error), backgroundColor: AppTheme.errorColor),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }



  // Widget pour l'état initial vide (CORRIGÉ POUR LE REFRESH)
  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;

    // 1. On enveloppe le tout dans le RefreshIndicator
    return RefreshIndicator(
      onRefresh: _handleRefresh, // Appelle ta fonction de rafraîchissement
      color: AppTheme.primaryColor, // Couleur du loader

      // 2. On utilise LayoutBuilder pour garder le centrage vertical
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            // 3. CRUCIAL : Force le scroll même si le contenu est petit
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight, // Prend toute la hauteur
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: const Icon( // const est mieux
                          Icons.event_note_outlined,
                          size: 64,
                          color: AppTheme.primaryColor,
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                      const SizedBox(height: 24),

                      Text(
                        l10n.noRequests,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface, // Mode sombre ok
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

                      const SizedBox(height: 8),

                      Text(
                        l10n.emptyRequestsMessage,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

                      const SizedBox(height: 32),

                      PrimaryButton(
                        text: l10n.makeRequest,
                        onPressed: widget.onNewRequest, // Le callback
                        icon: Icons.add_circle_outline,
                      ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(
                        begin: 0.3,
                        duration: 600.ms,
                        delay: 600.ms,
                        curve: Curves.easeOut,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}





