import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour le formatage de la date
import 'package:intl/date_symbol_data_local.dart'; // Pour la locale française
import 'package:table_calendar/table_calendar.dart';
import '../../../l10n/app_localizations.dart';
import '../../app_themes.dart'; // Assure-toi que le chemin est correct
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'dart:async';

// --- ÉTAPE 1 : NOUVEAU MODÈLE DE DONNÉES ---
// Nous remplaçons Map<String, String> par une classe dédiée
// --- NOUVEAU MODÈLE DE DONNÉES (BASÉ SUR L'API) ---
class EventModel {
  final int id;
  final String titre;
  final String? typeEvent; // "ENJGK", "pacques", "Fête", "Messe"
  final String? description;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String lieu;
  final String? celebrant;
  final String participationFrais;
  final String? imageUrl;
  final String parishName;

  EventModel({
    required this.id,
    required this.titre,
    this.typeEvent,
    this.description,
    required this.dateDebut,
    required this.dateFin,
    required this.lieu,
    this.celebrant,
    required this.participationFrais,
    this.imageUrl,
    required this.parishName,
  });

// --- CORRECTION ICI ---
  // Renommée en 'fromJson' (au lieu de fromListJson)
  // Gère les données de la LISTE et du DÉTAIL
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      titre: json['titre'] ?? 'Sans titre',
      typeEvent: json['type_event'],
      description: json['description'], // L'API le fournit dans les deux cas
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
      lieu: json['lieu'] ?? 'Lieu inconnu',
      celebrant: json['celebrant'],
      participationFrais: json['participation_frais'] ?? '0.00',
      imageUrl: _fixImageUrl(json['image_url']),
      parishName: json['paroisse']?['name'] ?? 'Paroisse inconnue',
    );
  }
  // --- FIN CORRECTION ---

  // Helper pour corriger les URL en 127.0.0.1
  static String? _fixImageUrl(String? url) {
    if (url == null) return null;
    return url.replaceFirst(
        "http://127.0.0.1:8081",
        "https://sancta-missa.com"
    );
  }

  // Formatters (utilisés par l'UI)
  String get startTime => DateFormat('HH:mm', 'fr_FR').format(dateDebut);
  String get endTime => DateFormat('HH:mm', 'fr_FR').format(dateFin);

}

// --- FIN ÉTAPE 1 ---
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late Future<List<EventModel>> _eventsFuture;
  late AuthService _authService;

  // --- DÉFINITION DES ONGLETS ET FILTRES ---
// --- NOUVELLE LOGIQUE DE CHARGEMENT ---
  List<EventModel> _allEvents = []; // Cache pour tous les événements
  List<String> _tabs = ["Tous"]; // Commence avec l'onglet statique
  bool _isLoading = true; // Un seul état de chargement
  // --- FIN NOUVELLE LOGIQUE ---
  // --- FIN DÉFINITION ---

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    // Initialise le TabController avec une longueur de 1 (juste "Tous")
    _tabController = TabController(length: 1, vsync: this);
    _selectedDay = _focusedDay;

    _authService = Provider.of<AuthService>(context, listen: false);

    // Lance le chargement groupé des onglets ET des événements
    _loadDynamicData();
  }




  // MODIFIÉ : Ajout de {bool isRefresh = false}
  Future<void> _loadDynamicData({bool isRefresh = false}) async {

    // On affiche le gros loader SEULEMENT si ce n'est pas un refresh
    if (!isRefresh) {
      setState(() => _isLoading = true);
    }

    try {
      // 1. Appelle l'API (une seule fois)
      final loadedEvents = await _authService.getEvents()
          .then((list) => list.map((json) => EventModel.fromJson(json)).toList());

      // 2. Logique d'extraction des onglets (inchangée)
      final Set<String> loadedTypesSet = {};
      for (var event in loadedEvents) {
        if (event.typeEvent != null && event.typeEvent!.isNotEmpty) {
          loadedTypesSet.add(event.typeEvent!);
        }
      }

      final List<String> loadedTypes = loadedTypesSet.toList();
      loadedTypes.sort();

      // 3. Mise à jour de l'UI
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        
        setState(() {
          _allEvents = loadedEvents;

          // On vérifie si les onglets ont changé pour éviter de casser l'UI
          // (Optionnel mais recommandé pour la stabilité)
          List<String> newTabs = [l10n.tab_all] + loadedTypes;

          // On ne recrée le controller que si le nombre d'onglets change ou au premier chargement
          if (_tabController == null || _tabs.length != newTabs.length) {
            _tabs = newTabs;
            _tabController?.dispose(); // Dispose l'ancien s'il existe
            _tabController = TabController(length: _tabs.length, vsync: this);
          } else {
            // Si les onglets sont les mêmes, on met juste à jour les données
            _tabs = newTabs;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur _loadDynamicData: $e");
      if (mounted) {
        setState(() { _isLoading = false; });
        // En cas d'erreur de refresh, on prévient l'utilisateur
        if (isRefresh) {
          _showTopNetworkError(e.toString()); // Utilise ta fonction d'erreur flottante
        }
      }
    }
  }


  Future<void> _handleRefresh() async {
    // Appelle le chargement en mode silencieux (sans cacher l'écran)
    await _loadDynamicData(isRefresh: true);
  }



  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }





  void _showEventDetails(int eventId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 20,
            top: 60,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Petit indicateur (Handle)
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

                // Le contenu du détail événement
                Flexible(
                  child: _EventDetailModal(
                    eventId: eventId,
                    authService: _authService, // Assure-toi que _authService est accessible ici
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }




  // --- À COLLER DANS CHAQUE CLASSE STATE ---
  void _showTopNetworkError(String message) {
    final l10n = AppLocalizations.of(context)!;

    if (!mounted) return;
    final double screenHeight = MediaQuery.of(context).size.height;

    String userMessage = l10n.error_generic;
    if (message.contains("SocketException") || message.contains("réseau") || message.contains("internet")) {
      userMessage = l10n.error_no_internet;
    } else if (message.contains("Timeout")) {
      userMessage = l10n.error_timeout;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(userMessage, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.only(bottom: screenHeight - 160, left: 20, right: 20),
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.events_title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined,
                color: Theme.of(context).colorScheme.onSurface,
                size: 23,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/parametres');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Le calendrier reste en haut
          _buildCalendar(),

          // Affiche le TabBar seulement si on ne charge pas (ou si c'est un refresh)
          _isLoading
              ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(child: CircularProgressIndicator(color: Color(0xFFC0A040))),
          )
              : _buildTabBar(),

          // La zone principale
          Expanded(
            child: _isLoading
                ? const Center() // Loader déjà affiché au-dessus
                : TabBarView(
              controller: _tabController,
              children: _tabs.map((tabName) {
                // 1. LOGIQUE DE FILTRE
                List<EventModel> filteredEvents;
                if (tabName == "Tous") {
                  filteredEvents = _allEvents;
                } else {
                  filteredEvents = _allEvents.where((event) {
                    return event.typeEvent == tabName;
                  }).toList();
                }

                // 2. INTÉGRATION DU REFRESH INDICATOR
                return RefreshIndicator(
                  onRefresh: _handleRefresh, // Appelle ta fonction
                  color: const Color(0xFFC0A040),
                  backgroundColor: Theme.of(context).cardTheme.color,

                  // Si la liste est vide, on met une ListView scrollable pour permettre le refresh
                  child: filteredEvents.isEmpty
                      ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Center(
                          child: Text(
                            l10n.events_none,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                      : ListView.builder(
                    // CRUCIAL : AlwaysScrollableScrollPhysics pour que le geste fonctionne tout le temps
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      // Ici on utilise ta fonction existante pour créer la carte

// Si _buildEventCard prend un EventModel, c'est parfait.
                      return _buildEventCard(filteredEvents[index]);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }





  Widget _buildCalendar() {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.only(bottom: 8), // Petit padding en bas
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: TableCalendar(
        locale: 'fr_FR',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,

        // --- NOUVEAU : CONFIGURATION DES FORMATS ---
        // 1. On définit les textes en français et on limite à Mois/Semaine (on enlève "2 semaines")
        availableCalendarFormats: const {
          CalendarFormat.month: 'Mois',
          CalendarFormat.week: 'Semaine',
        },
        // -------------------------------------------

        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          }
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() => _calendarFormat = format);
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },

        calendarStyle: CalendarStyle(
          defaultTextStyle: TextStyle(color: theme.colorScheme.onSurface),
          weekendTextStyle: TextStyle(color: theme.colorScheme.onSurface),
          outsideTextStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3)),
          todayDecoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration( // J'ai ajouté const pour optimiser
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
        ),

        headerStyle: HeaderStyle(
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          leftChevronIcon: const Icon(Icons.chevron_left, color: AppTheme.primaryColor),
          rightChevronIcon: const Icon(Icons.chevron_right, color: AppTheme.primaryColor),

          // --- NOUVEAU : LE BOUTON POUR PLIER/DÉPLIER ---
          formatButtonVisible: true, // On l'affiche pour permettre à l'user de changer
          formatButtonShowsNext: false, // Affiche le mode ACTUEL (ex: "Semaine")
          formatButtonTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold
          ),
          formatButtonDecoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          // ----------------------------------------------
        ),
      ),
    );
  }





  Widget _buildTabBar() {
    bool shouldScroll = _tabs.length > 4;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          // ✅ CORRECTION : Fond dynamique
          color: theme.cardTheme.color,

          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.cardShadow,
        ),
        child: TabBar(
          controller: _tabController,
          isScrollable: shouldScroll,
          labelPadding: EdgeInsets.symmetric(horizontal: shouldScroll ? 16.0 : 8.0),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.0),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13.0),
          indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge - 4),
              color: AppTheme.primaryColor.withOpacity(0.2),
              border: Border.all(color: AppTheme.primaryColor)
          ),
          indicatorWeight: 0,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AppTheme.primaryColor,
          // ✅ CORRECTION : Texte non sélectionné gris clair en mode sombre
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),

          tabs: _tabs.map((name) => Tab(child: Text(name, textAlign: TextAlign.center))).toList(),
        ),
      ),
    );
  }



  /// Construit une liste générique pour TOUS les onglets
  Widget _buildEventList({required List<EventModel> events}) {
    final l10n = AppLocalizations.of(context)!;
    // Trie les événements par date de début (le plus récent en premier)
    events.sort((a, b) => a.dateDebut.compareTo(b.dateDebut));

    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 20),
          child: Text(
            l10n.events_none,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return _buildEventItem(event);
        }
    );
  }



  Widget _buildEventItem(EventModel event) {
    final theme = Theme.of(context); // Raccourci thème

    return InkWell(
      onTap: () {
        _showEventDetails(event.id);
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // ✅ CORRECTION : Fond dynamique
          color: theme.cardTheme.color,

          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              child: Image.network(
                event.imageUrl ?? 'assets/images/quote_bg_8.jpg',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Image.asset(
                        'assets/images/quote_bg_8.jpg',
                        width: 48, height: 48, fit: BoxFit.cover
                    ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.titre,
                    // ✅ CORRECTION : Texte principal (automatique avec bodyLarge mais on assure)
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.lieu,
                    // ✅ CORRECTION : Texte secondaire
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              event.startTime,
              style: theme.textTheme.bodyMedium?.copyWith(
                // ✅ CORRECTION : Heure
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildEventCard(EventModel event) {
    final theme = Theme.of(context);
    final DateFormat dateFormat = DateFormat('EEE d MMM yyyy', 'fr_FR');
    final String dateStr = dateFormat.format(event.dateDebut);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          onTap: () => _showEventDetailModal(event.id), // Au clic, on ouvre le modal
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- IMAGE DE L'ÉVÉNEMENT ---
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusMedium)),
                child: SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Image.network(
                    event.imageUrl ?? 'https://via.placeholder.com/400x200', // Image par défaut
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: theme.colorScheme.surfaceVariant,
                        child: Icon(Icons.image_not_supported, color: theme.colorScheme.onSurfaceVariant),
                      );
                    },
                  ),
                ),
              ),

              // --- CONTENU ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge Type (ex: Fête, Messe...)
                    if (event.typeEvent != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.typeEvent!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),

                    // Titre
                    Text(
                      event.titre,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Date et Lieu
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: theme.colorScheme.secondary),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary),
                        ),
                        const Spacer(),

                        Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.secondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.lieu,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
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




  // --- Fonction pour ouvrir ta classe _EventDetailModal ---
  void _showEventDetailModal(int eventId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important pour que le heightFactor 0.85 fonctionne
      backgroundColor: Colors.transparent, // Laisse la modale gérer ses bords arrondis
      builder: (context) {
        // C'est ici qu'on appelle ta classe que tu as montrée
        return _EventDetailModal(
          eventId: eventId,
          authService: _authService, // On lui passe le service d'auth actuel
        );
      },
    );
  }







}




// --- MODALE DE DÉTAIL (MODIFIÉE) ---
class _EventDetailModal extends StatefulWidget {
  final int eventId;
  final AuthService authService;

  const _EventDetailModal({required this.eventId, required this.authService});

  @override
  State<_EventDetailModal> createState() => _EventDetailModalState();
}

class _EventDetailModalState extends State<_EventDetailModal> {
  // Le Future est maintenant basé sur le nouveau EventModel
  late Future<EventModel> _eventDetailFuture;


  @override
  void initState() {
    super.initState();
    _eventDetailFuture = widget.authService.getEventDetail(widget.eventId)
        .then((json) {
      // --- CORRECTION ---
      // Si l'API a renvoyé des données, on les parse
      if (json != null) {
        return EventModel.fromJson(json);
      } else {
        // Si l'API a renvoyé null (erreur 404, 500...), on propage l'erreur
        // pour que le FutureBuilder puisse l'afficher.
        throw Exception("Impossible de charger les détails de cet événement.");
      }
      // --- FIN CORRECTION ---
    });
  }

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



  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        // ✅ CORRECTION 1 : SafeArea
        child: SafeArea(
          top: false, // Pas besoin en haut (c'est un modal)
          child: Column(
            children: [
              // "Poignée" de la modale
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // FutureBuilder pour le contenu
              Expanded(
                child: FutureBuilder<EventModel>(
                  future: _eventDetailFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Erreur: ${snapshot.error}"));
                    }

                    final event = snapshot.data!;

                    // Formate la date
                    final DateFormat dateFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
                    String dateString = dateFormat.format(event.dateDebut);
                    if (!isSameDay(event.dateDebut, event.dateFin)) {
                      dateString += " au ${dateFormat.format(event.dateFin)}";
                    }

                    // Formate l'heure
                    String timeString = event.startTime;
                    if (event.endTime.isNotEmpty) {
                      timeString += " - ${event.endTime}";
                    }

                    // Formate les frais
                    String feeString = "Gratuit";
                    try {
                      double fee = double.parse(event.participationFrais);

                      if (fee > 0) {
                        feeString = "${NumberFormat.decimalPattern('fr_FR').format(fee)} FCFA";
                      }
                    } catch (e) {
                      feeString = event.participationFrais;
                    }

                    return ListView(
                      padding: const EdgeInsets.only(bottom: 20),
                      children: [
                        // Image
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            child: Image.network(
                              event.imageUrl ?? 'assets/images/quote_bg_2.jpg',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/quote_bg_2.jpg',
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        ),
                        // Détails
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.titre,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),

                              // Affiche la description
                              if (event.description != null && event.description!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Text(
                                    event.description!,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                        fontSize: 15,
                                        height: 1.4
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 24),
                              _buildDetailRow(context, Icons.church_outlined, "paroisse", event.parishName),
                              _buildDetailRow(context, Icons.calendar_today_outlined, "Date", dateString),
                              _buildDetailRow(context, Icons.access_time_outlined, "Heure", timeString),
                              _buildDetailRow(context, Icons.location_on_outlined, "Lieu", event.lieu),
                              _buildDetailRow(context, Icons.payments_outlined, "Participation", feeString),

                              // --- AJOUT ICI ---
                              // Affiche le type d'événement s'il existe
                              if (event.typeEvent != null && event.typeEvent!.isNotEmpty)
                                _buildDetailRow(context, Icons.category_outlined, "Type", event.typeEvent!),
                              // --- FIN AJOUT ---

                              if (event.celebrant != null && event.celebrant!.isNotEmpty)
                                _buildDetailRow(context, Icons.person_outline, "Célébrant", event.celebrant!),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}