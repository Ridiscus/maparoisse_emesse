import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../../services/auth_service.dart';
import '../widgets/modern_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../../app_themes.dart';
import 'dart:async';
import 'package:maparoisse/src/screens/home/dashboard_screen.dart';
import 'package:maparoisse/src/widgets/request_detail_modal.dart';


class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  late AnimationController _animationController;

  int _currentStep = 0;
  bool _isLoading = false;
  bool _isSearchingLocation = false;
  bool _isCurrentParishFavorite = false; // Pour savoir si l'étoile doit être pleine ou vide
  bool _isKeyboardVisible = false; // Pour suivre l'état du clavier

  final String _intention = 'AIDE, ASSISTANCE ET PROTECTION';

  // --- NOUVELLES VARIABLES D'ÉTAT ---
  late AuthService _authService;

  // Données de l'API
  List<dynamic> _allParishes = []; // Contiendra la liste de GET /paroisses
  List<dynamic> _allFavoriteParishes = []; // Contiendra la liste de GET /favoris

  // Listes pour les Dropdowns
  List<String> _villes = [];
  List<String> _communesFiltrees = [];
  List<dynamic> _paroissesFiltrees = []; // Contient des Map<String, dynamic>

  // Sélection de la paroisse
  String? _ville;
  String? _commune;
  int? _paroisseId; // <-- ID de la paroisse sélectionnée (CRUCIAL)
  String? _paroisseName; // Nom pour affichage
  // --- FIN NOUVELLES VARIABLES ---


  String? _celebration;
  final List<String> _joursQuotidienne = [];
  final List<String> _dimanches = [];
  List<DateTime> _dimanchesMois = [];

  double _montantUnitaire = 0;
  double _montantTotal = 0;

  static const double headerHeight = 280.0;

  final TextEditingController _dateCtrl = TextEditingController();
  final TextEditingController _heureCtrl = TextEditingController();
  final TextEditingController _motifCtrl = TextEditingController();
  final TextEditingController _intercesseurCtrl = TextEditingController();

  String _demandeurNom = '';
  String _demandeurEmail = '';
  String _demandeurTel = '';
  String _demandeurCivilite = '';
  String? _demandeurProfileImageUrl = '';

  final List<String> _celebrationTypes = [
    "Messe quotidienne",
    "Messe dominicale",
    "Messe solennelle",
  ];





  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
    _genererDimanches();

    WidgetsBinding.instance.addObserver(this); // <-- AJOUTE CECI

    _authService = Provider.of<AuthService>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Charge les infos utilisateur
      setState(() {
        _demandeurNom = _authService.fullName ?? '';
        _demandeurEmail = _authService.email ?? '';
        _demandeurTel = _authService.phone ?? '';
        _demandeurCivilite = _authService.civilite ?? '';
        _demandeurProfileImageUrl = _authService.photoPath;
      });
      // Charge les données de l'API
      _loadParishData();
    });
  }


  /// NOUVEAU : Charge les paroisses depuis l'API
  Future<void> _loadParishData() async { try {
    final parishes = await _authService.getParishes();
    final favorites = await _authService.getFavoriteParishes();

    // Extrait les villes uniques
    final Set<String> villesSet = {};
    for (var p in parishes) {
      if (p['ville'] != null) {
        villesSet.add(p['ville']);
      }
    }

    if (mounted) {
      setState(() {
        _allParishes = parishes;
        _allFavoriteParishes = favorites;
        _villes = villesSet.toList()..sort();
      });
    }
  } catch (e) {
    _showError("Erreur de chargement des paroisses: $e");
  }
  }

  @override
  void dispose() {
    // ... (dispose de tous les controllers)
    _motifCtrl.dispose();
    _intercesseurCtrl.dispose();
    _dateCtrl.dispose();
    _heureCtrl.dispose();
    _pageController.dispose();
    _animationController.dispose();

    WidgetsBinding.instance.removeObserver(this); // <-- AJOUTE CECI
    super.dispose();
  }


  /// MODIFIÉ : Met à jour l'étoile en appelant l'API
  Future<void> _updateFavoriteStatus() async {
    if (_paroisseId == null) {
      setState(() => _isCurrentParishFavorite = false);
      return;
    }

    try {
      final isFav = await _authService.isParishFavorite(_paroisseId!);
      if (mounted) {
        setState(() => _isCurrentParishFavorite = isFav);
      }
    } catch (e) {
      print("Erreur _updateFavoriteStatus: $e");
      setState(() => _isCurrentParishFavorite = false);
    }
  }

  // --- NOUVEAU : Détecte l'apparition du clavier ---
  @override
  void didChangeMetrics() {
    // Récupère la taille de l'espace pris par le clavier
    final bottomInset = WidgetsBinding.instance.platformDispatcher.views.first.viewInsets.bottom;

    // Si le clavier est visible (bottomInset > 0)
    final isKeyboardVisible = bottomInset > 0.0;

    // Met à jour l'état SEULEMENT si l'état a changé
    if (isKeyboardVisible != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = isKeyboardVisible;
      });
    }
  }





  /// MODIFIÉ : Affiche les favoris depuis l'API
  Future<void> _showFavoritesDialog() async {
    // Les favoris sont déjà chargés dans _allFavoriteParishes
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(children: [Icon(Icons.favorite, color: AppTheme.primaryColor), SizedBox(width: 8), Text('Choisir un favori')]),
          content: _allFavoriteParishes.isEmpty
              ? const Text('Vous n\'avez pas encore de paroisse favorite.')
              : SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _allFavoriteParishes.length,
              itemBuilder: (context, index) {
                // Lit la structure imbriquée de GET /favoris
                final favorite = _allFavoriteParishes[index];
                final Map<String, dynamic>? parish = favorite['paroisse'];

                if (parish == null) return const ListTile(title: Text("Donnée invalide"));

                final parishName = parish['name'] ?? 'N/A';
                final communeName = parish['commune']?['nom_commune'] ?? 'N/A';
                final cityName = parish['commune']?['ville']?['nom_ville'] ?? 'N/A';

                return ListTile(
                  title: Text(parishName),
                  subtitle: Text('$communeName, $cityName'),
                  onTap: () {
                    // On cherche la paroisse correspondante dans notre liste /paroisses
                    // pour récupérer le montant (que GET /favoris ne fournit pas)
                    final paroisseData = _allParishes.firstWhereOrNull((p) => p['id'] == parish['id']);

                    if (paroisseData != null) {
                      _onParishSelected(paroisseData); // Appelle la fonction helper
                      Navigator.of(context).pop();
                    } else {
                      _showError('Paroisse favorite non trouvée dans la liste principale.');
                    }
                  },
                );
              },
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fermer'))],
        );
      },
    );
  }


  Future<void> _trouverParoisseProche() async {
    // setState(() => _isSearchingLocation = true);
    _showError("Fonctionnalité indisponible. L'API ne fournit pas de coordonnées GPS pour les paroisses.");
    //
    // NOTE : Pour réactiver, l'API GET /paroisses doit renvoyer "latitude" et "longitude"
    //
    // setState(() => _isSearchingLocation = false);
  }



  // DANS LA CLASSE _RequestsScreenState (fichier requests_screen.dart)

  void _genererDimanches() {
    DateTime now = DateTime.now();
    List<DateTime> dimanches = [];
    int daysToAdd = 1;

    // Boucle jusqu'à ce qu'on ait 5 dimanches
    while (dimanches.length < 5) {
      // On vérifie chaque jour à venir
      DateTime jour = now.add(Duration(days: daysToAdd));

      // Si le jour est un dimanche ET qu'il est bien dans le futur
      // (on compare juste la date, pas l'heure)
      if (jour.weekday == DateTime.sunday &&
          jour.isAfter(DateTime(now.year, now.month, now.day))) {
        dimanches.add(jour);
      }
      daysToAdd++; // Passe au jour suivant
    }

    setState(() {
      _dimanchesMois = dimanches;
    });
  }

  void _calculerMontant() {
    int nbJours = 0;
    if (_celebration == "Messe quotidienne") {
      nbJours = _joursQuotidienne.length;
    } else if (_celebration == "Messe dominicale") {
      nbJours = _dimanches.length;
    } else if (_celebration == "Messe solennelle") {
      nbJours = 1;
    }
    setState(() {
      _montantTotal = _montantUnitaire * nbJours;
    });
  }

  void _nextStep() {
    if (_currentStep < 2) {
      if (_validateCurrentStep()) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _submitDemande();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }



  // DANS LA CLASSE _RequestsScreenState (fichier requests_screen.dart)

  /// NOUVEAU : Helper quand une paroisse est sélectionnée
  void _onParishSelected(Map<String, dynamic> paroisseData) {
    setState(() {
      _paroisseId = paroisseData['id'];
      _paroisseName = paroisseData['name'];
      _ville = paroisseData['ville'];
      _commune = paroisseData['commune'];

      // Filtre les listes pour que les dropdowns affichent la sélection
      _communesFiltrees = _allParishes
          .where((p) => p['ville'] == _ville)
          .map((p) => p['commune'] as String)
          .toSet().toList();

      _paroissesFiltrees = _allParishes
          .where((p) => p['ville'] == _ville && p['commune'] == _commune)
          .toList();

      // --- CORRECTION : Récupère le montant de l'API ---
      final dynamic rawAmount = paroisseData['montant_unitaire'];
      double parsedAmount = 0.0; // Montant par défaut si null ou invalide

      if (rawAmount is num) {
        // Si c'est un nombre (int ou double)
        parsedAmount = rawAmount.toDouble();
      } else if (rawAmount is String) {
        // Si c'est une chaîne (ex: "2000.00")
        parsedAmount = double.tryParse(rawAmount) ?? 0.0;
      }
      // Si rawAmount est null, parsedAmount restera 0.0

      _montantUnitaire = parsedAmount;
      // --- FIN CORRECTION ---

      _calculerMontant();
    });
    _updateFavoriteStatus(); // Vérifie si elle est favorite
  }






  /// MODIFIÉ : Validation avec vérification du montant
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Intention
        if (_motifCtrl.text.trim().isEmpty) {
          _showError('Veuillez saisir le motif détaillé.');
          return false;
        }
        return true;

      case 1: // Détails messe
      // 1. Vérifications des champs obligatoires
        if (_paroisseId == null) {
          _showError('Veuillez sélectionner une paroisse.');
          return false;
        }
        if (_celebration == null || _celebration!.isEmpty) {
          _showError('Veuillez sélectionner le type de célébration.');
          return false;
        }
        if (_celebration == 'Messe quotidienne' && _joursQuotidienne.isEmpty) {
          _showError('Veuillez sélectionner au moins un jour.');
          return false;
        }
        if (_celebration == 'Messe dominicale' && _dimanches.isEmpty) {
          _showError('Veuillez sélectionner au moins un dimanche.');
          return false;
        }
        if (_dateCtrl.text.isEmpty) {
          _showError('Veuillez sélectionner une date pour la messe.');
          return false;
        }
        if (_heureCtrl.text.isEmpty) {
          _showError('Veuillez sélectionner une heure pour la messe.');
          return false;
        }

        // ✅ AJOUT : VÉRIFICATION DU MONTANT
        // Le montant doit être strictement supérieur ou égal à 100 FCFA
        if (_montantTotal < 100) {
          if (_montantTotal == 0) {
            _showError('Le montant total est de 0 FCFA. Impossible de poursuivre.');
          } else {
            _showError('Le montant minimum requis est de 100 FCFA.');
          }
          return false; // BLOQUE LE PASSAGE À L'ÉTAPE SUIVANTE
        }

        return true;

      default:
        return true;
    }
  }





  /// NOUVEAU : Réinitialise le formulaire à son état initial
  void _resetForm() {
    setState(() {
      // Réinitialise les sélections
      _paroisseId = null;
      _paroisseName = null;
      _ville = null;
      _commune = null;
      _celebration = null;
      _paroissesFiltrees = [];
      _communesFiltrees = [];
      _joursQuotidienne.clear();
      _dimanches.clear();
      _montantUnitaire = 0;
      _montantTotal = 0;

      // Vide les controllers de texte
      _motifCtrl.clear();
      _intercesseurCtrl.clear();
      _dateCtrl.clear();
      _heureCtrl.clear();

      // Remet le PageView à la première étape
      _currentStep = 0;
      _pageController.jumpToPage(0);
    });
  }




  Future<void> _submitDemande() async {
    // 1. Validation locale
    if (!_validateCurrentStep()) return;

    setState(() => _isLoading = true);

    try {
      // Formatage des dates pour l'API
      final dateSouhaitee = DateFormat('dd/MM/yyyy').parse(_dateCtrl.text);
      final dateSouhaiteeFormatted = DateFormat('yyyy-MM-dd').format(dateSouhaitee);
      final heureSouhaiteeFormatted = _heureCtrl.text;

      // Gestion des jours sélectionnés
      List<String>? jours;
      if (_celebration == "Messe quotidienne") {
        jours = _joursQuotidienne;
      } else if (_celebration == "Messe dominicale") {
        jours = _dimanches;
      }

      // 2. Appel API (Le code que tu m'as montré est bon)
      final newRequestData = await _authService.createMassRequest(
        paroisseId: _paroisseId!,
        intercesseur: _intercesseurCtrl.text,
        motif: _motifCtrl.text,
        dateSouhaitee: dateSouhaiteeFormatted,
        heureSouhaitee: heureSouhaiteeFormatted,
        celebration: _celebration!,
        nomDemandeur: _demandeurNom,
        emailDemandeur: _demandeurEmail,
        telDemandeur: _demandeurTel,
        montant: _montantTotal,
        joursSelectionnes: jours,
      );

      if (mounted) {
        // 3. Succès ! On nettoie le formulaire
        _resetForm();

        // 4. On ouvre le Modal "Succès" (qui remonte du bas)
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true, // Important pour voir tout le contenu
          backgroundColor: Colors.transparent, // Pour avoir les coins arrondis propres
          builder: (context) => RequestDetailModal(
            request: newRequestData, // On passe les données reçues de l'API
            isSuccessMode: true,     // <--- C'EST ICI QU'ON ACTIVE LA COCHE VERTE
          ),
        );

        // 5. Quand l'utilisateur ferme le modal, on va sur l'onglet "Mes demandes"
        DashboardScreenWithIndex.globalKey.currentState?.goToIndex(3);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur : ${e.toString().replaceAll("Exception:", "")}'),
              backgroundColor: AppTheme.errorColor
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }





  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _formatDateFr(DateTime d) {
    return DateFormat("EEEE dd/MM/yyyy", "fr_FR").format(d);
  }



  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Formulez une intention de prière';
      case 1:
        return 'Offrez une messe';
      case 2:
        return 'Récapitulatif et confirmation';
      default:
        return 'Nouvelle demande'; // Titre par défaut
    }
  }


  Widget _buildImageHeader() {
    return Container(
      height: headerHeight, // Utilise la constante de classe
      child: Stack(
        fit: StackFit.expand,
        children: [
          // --- Image de Fond ---
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
            child: Image.asset(
              'assets/images/quote_bg_4.jpg', // REMPLACE par ton image
              fit: BoxFit.cover,
            ),
          ),

          // --- Dégradé sombre ---
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.7], // Ajuste pour plus de dégradé en haut
              ),
            ),
          ),

          // --- AppBar Transparente (CORRIGÉE) ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                // 1. SUPPRIMER le bouton 'leading' (bouton retour)
                automaticallyImplyLeading: false,
                // 2. AJOUTER le titre "Nouvelle demande"
                title: Text(
                  'Nouvelle demande',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white, // Texte blanc
                      shadows: [ // Ombre pour lisibilité
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 2.0,
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ]
                  ),
                ), // 3. AJOUTER l'icône 'actions' (paramètres)
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 8.0), // Marge à droite
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), // Fond semi-transparent
                      shape: BoxShape.circle, // Forme circulaire
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
                      onPressed: () {
                        Navigator.pushNamed(context, '/parametres'); // Navigue vers paramètres
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Titre de l'Étape (en bas de l'image) ---
          // (Cette partie reste identique)
          Positioned(
            bottom: 20,
            left: 24,
            right: 24,
            child: Text(
              _getStepTitle(_currentStep),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ]
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, duration: 400.ms),
          ),
        ],
      ),
    );
  }




  @override
  Widget build(BuildContext context) {

    // --- AJOUT : Calcule la hauteur du header ---
    final double currentHeaderHeight = _isKeyboardVisible ? 0 : headerHeight;
    // --- FIN AJOUT ---

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor
,
      resizeToAvoidBottomInset: true, // Important pour le clavier
      body: Stack(
        children: [
          // --- 1. LE CONTENU QUI DÉFILE (Formulaire) ---
          Padding(
            // Le Padding commence APRÈS l'image header
            padding: EdgeInsets.only(top: currentHeaderHeight),
            child: Column(
              children: [
                // La barre de progression (reste identique)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    // ... (Code de la barre de progression inchangé) ...
                    children: List.generate(3, (index) {
                      final isActive = index <= _currentStep;
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppTheme.primaryColor
                                : AppTheme.textTertiary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ).animate().scaleX(
                          duration: 300.ms,
                          delay: Duration(milliseconds: index * 100),
                        ),
                      );
                    }),
                  ),
                ),
                // Le PageView (reste identique)
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildMotifStep(),
                      _buildMassDetailsStep(),
                      _buildConfirmationStep(),
                    ],
                  ),
                ),
                // Espace pour le footer (reste identique)
                const SizedBox(height: 90),
              ],
            ),
          ),

          // --- 2. L'EN-TÊTE IMAGE FIXE (Au-dessus) ---

          // --- MODIFICATION : Enveloppe le header dans un AnimatedContainer ---
          AnimatedContainer(
            duration: const Duration(milliseconds: 250), // Vitesse de l'animation
            curve: Curves.easeInOut,
            height: currentHeaderHeight,
            clipBehavior: Clip.hardEdge, // Cache l'image quand elle rétrécit
            decoration: const BoxDecoration(),
            child: _buildImageHeader(),
          ),
          // --- FIN MODIFICATION ---

          // --- 3. LE FOOTER AVEC LES BOUTONS (Par-dessus tout, en bas) ---
          Positioned(
            left: 0,
            right: 0,
            bottom: 0, // Reste collé en bas
            child: Container(
              // On enveloppe dans un Container avec une couleur de fond pour cacher ce qui passe derrière
              color: Theme.of(context).scaffoldBackgroundColor,

              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  // ❌ SUPPRIME : MediaQuery.of(context).viewInsets.bottom
                  // ✅ GARDE JUSTE : Une marge fixe pour l'esthétique
                  bottom: 20,
                  top: 12,
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Retour'),
                            onPressed: _previousStep,
                            style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Theme.of(context).dividerColor)
                            ),
                          ),
                        ),
                      if (_currentStep > 0) const SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton(
                          text: _currentStep == 2 ? 'Confirmer' : 'Suivant',
                          onPressed: _isLoading ? null : _nextStep,
                          isLoading: _isLoading && _currentStep == 2,
                          icon: _currentStep ==  2 ? Icons.send : Icons.arrow_forward,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  /// NOUVEAU : Gère le "Pull to Refresh"
  Future<void> _handleRefresh() async {
    // 1. Recharge les données des paroisses et favoris
    await _loadParishData();

    // 2. (Optionnel) Tu peux aussi rafraîchir le statut favori si une paroisse est sélectionnée
    if (_paroisseId != null) {
      await _updateFavoriteStatus();
    }

    // Petite pause pour l'UX (pour voir le rond tourner un peu)
    await Future.delayed(const Duration(milliseconds: 500));
  }



  // --- WIDGET POUR L'ÉTAPE 1 (CORRIGÉ AVEC REFRESH) ---
  Widget _buildMotifStep() {
    final theme = Theme.of(context);

    // ✅ 1. Envelopper avec RefreshIndicator
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.primaryColor, // Couleur Ocre
      backgroundColor: theme.cardTheme.color, // Fond adapté au mode

      child: SingleChildScrollView(
        // ✅ 2. AJOUTER LA PHYSIQUE OBLIGATOIRE
        // Permet de "tirer" l'écran même s'il y a peu de contenu
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (Tout le reste de ton code reste identique) ...
            Text(
              'Motif de la demande',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, duration: 600.ms),

            const SizedBox(height: 8),

            Text(
              'Intention: $_intention',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

            const SizedBox(height: 32),

            CustomTextField(
              controller: _motifCtrl,
              label: 'Motif détaillé *',
              hint: 'Décrivez pourquoi vous demandez l\'aide...',
              maxLines: 5,
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.3, duration: 600.ms),

            const SizedBox(height: 32),

            CustomTextField(
              controller: _intercesseurCtrl,
              label: 'Par l\'intercession de (optionnel)',
              hint: 'Ex: La Vierge Marie, Saint Joseph...',
              prefixIcon: Icons.person_search,
            ).animate().fadeIn(delay: 600.ms),

            // ✅ 3. AJOUTER UN ESPACE EN BAS (Pour éviter que le bouton flottant ne cache le texte)
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }


  // --- 3. MODIFICATION : Mise à jour de l'interface (Détails Messe) ---
  Widget _buildMassDetailsStep() {
    final theme = Theme.of(context);

    // ✅ 1. ENVELOPPER DANS REFRESH INDICATOR
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.primaryColor,
      backgroundColor: theme.cardTheme.color,

      child: SingleChildScrollView(
        // ✅ 2. PHYSIQUE DE SCROLL OBLIGATOIRE
        // Permet de rafraîchir même si le contenu est court
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Détails de la messe',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, duration: 600.ms),
            const SizedBox(height: 32),

            // --- Bouton GPS (DÉSACIVÉ) ---
            PrimaryButton(
              text: 'Suggérer la paroisse la plus proche',
              onPressed: null, // DÉSACIVÉ
              icon: Icons.location_disabled,
            ),
            const SizedBox(height: 4),
            const Center(child: Text("Fonctionnalité GPS indisponible (API)", style: TextStyle(color: Colors.grey))),

            const SizedBox(height: 16),

            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("OU", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),

            // Bouton Favoris
            OutlinedButton.icon(
              icon: const Icon(Icons.star),
              label: const Text('Choisir parmi mes favoris'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: AppTheme.primaryColor,
              ),
              onPressed: _showFavoritesDialog,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("OU", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Lancer une Recherche manuelle',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // --- SÉLECTEUR DE VILLE ---
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                hintText: 'Choisissez une ville',
                filled: true,
                fillColor: theme.inputDecorationTheme.fillColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              style: TextStyle(color: theme.colorScheme.onSurface),
              dropdownColor: theme.cardTheme.color,
              value: _ville,
              items: _villes.map((v) => DropdownMenuItem<String>(value: v, child: Text(v))).toList(),
              onChanged: (val) {
                if (val == null) return;
                setState(() {
                  _ville = val;
                  _communesFiltrees = _allParishes
                      .where((p) => p['ville'] == _ville)
                      .map((p) => p['commune'] as String)
                      .toSet()
                      .toList()..sort();

                  _commune = null;
                  _paroissesFiltrees = [];
                  _paroisseId = null;
                  _paroisseName = null;
                  _montantUnitaire = 0;
                  _calculerMontant();
                });
              },
            ),

            const SizedBox(height: 24),

            // --- SÉLECTEUR DE COMMUNE ---
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: _ville == null ? 'Choisissez d\'abord une ville' : 'Choisissez une commune',
                filled: true,
                fillColor: theme.inputDecorationTheme.fillColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              style: TextStyle(color: theme.colorScheme.onSurface),
              dropdownColor: theme.cardTheme.color,
              value: _commune,
              items: _communesFiltrees.map((c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
              onChanged: _ville == null ? null : (val) {
                if (val == null) return;
                setState(() {
                  _commune = val;
                  _paroissesFiltrees = _allParishes
                      .where((p) => p['ville'] == _ville && p['commune'] == _commune)
                      .toList();

                  _paroisseId = null;
                  _paroisseName = null;
                  _montantUnitaire = 0;
                  _calculerMontant();
                });
              },
            ),
            const SizedBox(height: 24),

            // --- SÉLECTEUR DE PAROISSE ---
            Text('Paroisse', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      hintText: _commune == null ? 'Choisissez d\'abord une commune' : 'Choisissez une paroisse',
                      filled: true,
                      fillColor: theme.inputDecorationTheme.fillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                      ),
                    ),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    dropdownColor: theme.cardTheme.color,
                    value: _paroisseId,
                    items: _paroissesFiltrees.map((p) => DropdownMenuItem<int>(
                        value: p['id'] as int,
                        child: Text(p['name'] as String, overflow: TextOverflow.ellipsis)
                    )).toList(),
                    onChanged: _commune == null ? null : (val) {
                      if (val == null) return;
                      final paroisseData = _paroissesFiltrees.firstWhere((p) => p['id'] == val);
                      _onParishSelected(paroisseData);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(_isCurrentParishFavorite ? Icons.star : Icons.star_border, color: _isCurrentParishFavorite ? AppTheme.warningColor : AppTheme.textSecondary, size: 30),
                  onPressed: (_paroisseId == null) ? null : () async {
                    bool success = await _authService.toggleParishFavorite(_paroisseId!);

                    if (success) {
                      _updateFavoriteStatus();
                      _authService.getFavoriteParishes().then((favs) {
                        if(mounted) setState(() => _allFavoriteParishes = favs);
                      });
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- DATE ET HEURE ---
            Text(
              'Date et heure de la messe *',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _dateCtrl,
                    label: 'Date souhaitée',
                    hint: 'Choisir une date',
                    prefixIcon: Icons.calendar_today,
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now().add(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: Theme.of(context).colorScheme.copyWith(
                                primary: AppTheme.primaryColor,
                                onPrimary: Colors.white,
                                onSurface: Theme.of(context).colorScheme.onSurface,
                              ),
                              dialogBackgroundColor: Theme.of(context).cardTheme.color,
                              textSelectionTheme: const TextSelectionThemeData(
                                cursorColor: Colors.black,
                                selectionHandleColor: Colors.black,
                                selectionColor: Color(0xFFCCCCCC),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) {
                        _dateCtrl.text = DateFormat('dd/MM/yyyy').format(date);
                      }
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: CustomTextField(
                    controller: _heureCtrl,
                    label: 'Heure souhaitée',
                    hint: 'Choisir une heure',
                    prefixIcon: Icons.access_time,
                    readOnly: true,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: Theme.of(context).colorScheme.copyWith(
                                primary: AppTheme.primaryColor,
                                onPrimary: Colors.white,
                                onSurface: Theme.of(context).colorScheme.onSurface,
                                surface: Theme.of(context).cardTheme.color,
                              ),
                              dialogBackgroundColor: Theme.of(context).cardTheme.color,
                              textSelectionTheme: const TextSelectionThemeData(

                                cursorColor: Colors.black,
                                selectionHandleColor: Colors.black,
                                selectionColor: Color(0xFFCCCCCC),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (time != null) {
                        _heureCtrl.text = time.format(context);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- TYPE DE CÉLÉBRATION ---
            Text(
              'Type de célébration',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 500.ms),

            const SizedBox(height: 12),

            ..._celebrationTypes.asMap().entries.map((entry) {
              final index = entry.key;
              final type = entry.value;
              final isSelected = _celebration == type;

              return ModernCard(
                margin: const EdgeInsets.only(bottom: 12),
                backgroundColor: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
                borderColor: isSelected ? AppTheme.primaryColor : null,
                onTap: () {
                  setState(() {
                    _celebration = type;
                    if (_celebration == 'Messe dominicale') _genererDimanches();
                    _calculerMontant();
                  });
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : theme.colorScheme.onSurface.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCelebrationIcon(type),
                        color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.6),
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Text(
                        type,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppTheme.primaryColor : null,
                        ),
                      ),
                    ),

                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryColor,
                      ),
                  ],
                ),
              ).animate().fadeIn(
                duration: 600.ms,
                delay: Duration(milliseconds: 600 + (index * 100)),
              ).slideX(
                begin: -0.3,
                duration: 600.ms,
                delay: Duration(milliseconds: 600 + (index * 100)),
                curve: Curves.easeOut,
              );
            }).toList(),

            if (_celebration == "Messe quotidienne") ...[
              const SizedBox(height: 24),
              _buildDaySelector(),
            ],

            if (_celebration == "Messe dominicale") ...[
              const SizedBox(height: 24),
              _buildSundaySelector(),
            ],

            // --- AFFICHAGE PRIX ---
            if (_montantTotal > 0) ...[

              const SizedBox(height: 24),
              ModernCard(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                borderColor: AppTheme.primaryColor.withOpacity(0.3),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Montant total',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          Text(
                            '${_montantTotal.toStringAsFixed(0)} FCFA',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 900.ms).scale(
                begin: const Offset(0.9, 0.9),
                duration: 600.ms,
                delay: 900.ms,
                curve: Curves.elasticOut,
              ),
            ],

            // ✅ 3. ESPACE EN BAS (Pour ne pas cacher le contenu derrière le bouton "Suivant")
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }




  Widget _buildDaySelector() {
    const jours = [
      "Lundi", "Mardi", "Mercredi", "Jeudi",
      "Vendredi", "Samedi", "Dimanche"
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sélectionnez les jours',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: jours.asMap().entries.map((entry) {
            final index = entry.key;
            final jour = entry.value;
            final isSelected = _joursQuotidienne.contains(jour);

            return FilterChip(
              label: Text(jour),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _joursQuotidienne.add(jour);
                  } else {
                    _joursQuotidienne.remove(jour);
                  }
                  _calculerMontant();
                });
              },
              backgroundColor: Theme.of(context).cardTheme.color,
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryColor,
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : Theme.of(context).dividerColor,
              ),
            ).animate().fadeIn(
              duration: 400.ms,
              delay: Duration(milliseconds: index * 50),
            ).scale(
              begin: const Offset(0.8, 0.8),
              duration: 400.ms,
              delay: Duration(milliseconds: index * 50),
              curve: Curves.easeOut,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSundaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisissez les dimanches',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        ..._dimanchesMois.asMap().entries.map((entry) {
          final index = entry.key;
          final date = entry.value;
          final formatted = _formatDateFr(date);
          final isSelected = _dimanches.contains(formatted);

          return ModernCard(
            margin: const EdgeInsets.only(bottom: 8),
            backgroundColor: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
            borderColor: isSelected ? AppTheme.primaryColor : null,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _dimanches.remove(formatted);
                } else {
                  _dimanches.add(formatted);
                }
                _calculerMontant();
              });
            },
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: isSelected ? AppTheme.primaryColor : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    formatted,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryColor : null,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(
            duration: 400.ms,
            delay: Duration(milliseconds: index * 100),
          ).slideX(
            begin: 0.3,
            duration: 400.ms,
            delay: Duration(milliseconds: index * 100),
            curve: Curves.easeOut,
          );
        }).toList(),
      ],
    );
  }


  Widget _buildConfirmationStep() {
    final theme = Theme.of(context); // Pour les couleurs du RefreshIndicator

    // ✅ 1. ENVELOPPER DANS REFRESH INDICATOR
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.primaryColor,
      backgroundColor: theme.cardTheme.color,

      child: SingleChildScrollView(
        // ✅ 2. PHYSIQUE DE SCROLL OBLIGATOIRE
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Confirmation',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, duration: 600.ms),

            const SizedBox(height: 8),

            Text(
              'Vérifiez les informations de votre demande',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

            const SizedBox(height: 32),

            // --- CARTE 1 : DÉTAILS ---
            ModernCard(
              backgroundColor: theme.cardTheme.color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.church, color: AppTheme.secondaryColor),
                      const SizedBox(width: 12),
                      Text(
                        'Détails de la messe',
                        style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Paroisse: ${_paroisseName ?? "Non spécifiée"}',
                    style: theme.textTheme.bodyLarge,
                  ),
                  Text(
                    'Type: ${_celebration ?? "Non spécifié"}',
                    style: theme.textTheme.bodyLarge,
                  ),

                  if (_montantTotal > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Montant: ${_montantTotal.toStringAsFixed(0)} FCFA',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

            const SizedBox(height: 16),

            // --- CARTE 2 : TEXTE DE LA DEMANDE ---
            ModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête demandé
                  Text(
                    'AIDE, ASSISTANCE ET PROTECTION',
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor
                    ),
                  ),
                  const Divider(height: 24),

                  // Corps du message
                  Text.rich(
                    TextSpan(
                      style: theme.textTheme.bodyLarge,
                      children: [
                        TextSpan(
                          text: '${_demandeurCivilite} ${_demandeurNom} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                            text: 'demande Aide, assistance et protection au seigneur pour ${_motifCtrl.text.isNotEmpty ? _motifCtrl.text : 'non spécifié'}'
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Par l\'intercession de ${_intercesseurCtrl.text.isNotEmpty ? _intercesseurCtrl.text : "...."}',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Date de la messe : ${_dateCtrl.text}',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Heure de la messe : ${_heureCtrl.text}',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Paroisse : ${_paroisseName ?? "Non spécifiée"}',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Type : ${_celebration ?? "Non spécifié"}',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 300.ms),

            const SizedBox(height: 16),

            // --- CARTE 3 : INFOS DEMANDEUR ---
            ModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Informations du demandeur',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Avatar de l'utilisateur
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        backgroundImage: (_demandeurProfileImageUrl != null && _demandeurProfileImageUrl!.isNotEmpty)
                            ? NetworkImage(_demandeurProfileImageUrl!) as ImageProvider<Object>?
                            : null,
                        child: (_demandeurProfileImageUrl == null || _demandeurProfileImageUrl!.isEmpty)
                            ? Icon(Icons.person, color: AppTheme.primaryColor, size: 28)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nom: ${_demandeurNom.isNotEmpty ? _demandeurNom : "N/A"}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    'Email: ${_demandeurEmail.isNotEmpty ? _demandeurEmail : "N/A"}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    'Téléphone: ${_demandeurTel.isNotEmpty ? _demandeurTel : "N/A"}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 600.ms),

            // ✅ 3. ESPACE EN BAS (Pour ne pas cacher le contenu derrière le bouton "Confirmer")
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }




  IconData _getCelebrationIcon(String type) {
    switch (type) {
      case 'Messe quotidienne':
        return Icons.today;
      case 'Messe dominicale':
        return Icons.weekend;
      case 'Messe solennelle':
        return Icons.star_outline;
      default:
        return Icons.event;
    }
  }
}





