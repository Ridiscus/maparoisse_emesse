import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour formater l'heure
import '../../../l10n/app_localizations.dart';
import '../../app_themes.dart'; // Vérifie le chemin
// Importe tes localisations si nécessaire
// import 'package:maparoisse/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // <-- AJOUT
import '../../services/auth_service.dart'; // <-- AJOUT
import '../../models/notification_model.dart'; // <-- AJOUT (et supprime la classe d'ici)
import 'package:maparoisse/src/screens/home/request_details_screen.dart';
import 'package:maparoisse/src/screens/home/event_details_screen.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<NotificationModel> _notifications = []; // Liste des notifications

  // --- AJOUT ---
  late AuthService _authService;
  String? _error; // Pour stocker les messages d'erreur
  // --- FIN AJOUT ---

  @override
  void initState() {
    super.initState();
    // --- MODIFICATION ---
    // Récupère l'instance de AuthService
    _authService = Provider.of<AuthService>(context, listen: false);
    // Charge les notifications (ne plus utiliser Future.delayed)
    _loadNotifications();
    // --- FIN MODIFICATION ---
  }

  // --- MODIFICATION : Chargement des Notifications (Connecté) ---
  Future<void> _loadNotifications() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _error = null; // Réinitialise l'erreur
    });

    try {
      // Appelle la nouvelle fonction API 2
      final notifications = await _authService.getNotifications();

      if (mounted) {
        setState(() {
          _notifications = notifications;
          // L'API devrait les trier, mais par sécurité :
          _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = l10n.loadNotificationsError;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  // --- Action pour rafraîchir ---
  Future<void> _handleRefresh() async {
    // Appelle la vraie fonction de chargement
    await _loadNotifications();
  }



  void _onNotificationTapped(int index) async {
    final notification = _notifications[index];

    // 1. Marquer comme lu
    if (mounted && !notification.isRead) {
      setState(() {
        _notifications[index] = notification.copyWith(isRead: true);
      });
      _authService.markNotificationAsRead(notification.id);
    }

    // 2. Afficher le chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 3. TRIER avant d'appeler l'API

      // CAS 1 : C'est un ÉVÉNEMENT
      if (notification.type.toLowerCase().contains('evenement')) {
        print(">>> Détection : ÉVÉNEMENT.");

        // On récupère l'ID de l'événement des data de la notif
        final eventId = notification.data?['evenement_id'];

        if (eventId == null) {
          if (mounted) Navigator.of(context).pop();
          _showActionError("Données de notification invalides (ID manquant).");
          return;
        }

        final int eventIdAsInt = int.tryParse(eventId.toString()) ?? 0;
        print("Appel de getEventDetail avec ID: $eventIdAsInt");

        // ON APPELLE LA FONCTION QUI MARCHE
        final eventData = await _authService.getEventDetail(eventIdAsInt);

        if (!mounted) return;
        Navigator.of(context).pop(); // Ferme le loader

        if (eventData != null) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => EventDetailsScreen(eventData: eventData),
          ));
        } else {
          _showActionError("Impossible de charger les détails de l'événement.");
        }
      }

      // CAS 2 : C'est une DEMANDE DE MESSE
      else {
        print(">>> Détection : DEMANDE. Appel /detail/");

        final requestData = await _authService.getDetailsFromNotification(notification.id);

        if (!mounted) return;
        Navigator.of(context).pop(); // Ferme le loader

        if (requestData != null) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => RequestDetailsScreen(
              initialData: requestData,
              requestId: requestData['id'],
            ),
          ));
        } else {
          _showActionError("Impossible de charger les détails de la demande.");
        }
      }

    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      print("Erreur _onNotificationTapped: $e");
      _showActionError("Une erreur est survenue.");
    }
  }


  // --- MODIFICATION : Supprimer (avec "Undo" corrigé) ---
  void _deleteNotification(int index) {
    final l10n = AppLocalizations.of(context)!;
    if (!mounted) return;

    // 1. Sauvegarde l'item et l'index, puis supprime-le localement
    bool undo = false;
    final removedItem = _notifications.removeAt(index);
    setState(() {}); // Met à jour l'UI

    // 2. Affiche le SnackBar
    final snackBar = SnackBar(
      content: Text(l10n.notificationDeleted(removedItem.title)),
      action: SnackBarAction(
        label: l10n.cancel,
        onPressed: () {
          undo = true; // L'utilisateur a annulé
          if (mounted) {
            // Réinsère l'item à sa place
            setState(() => _notifications.insert(index, removedItem));
          }
        },
      ),
      duration: const Duration(seconds: 4), // Laisse le temps d'annuler
    );  // 3. Attend la fermeture du SnackBar pour appeler l'API
    ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((reason) {
      // Si le SnackBar s'est fermé SANS que l'utilisateur clique sur "Annuler"
      if (!undo) {
        // Appelle l'API 4 pour supprimer définitivement
        _authService.deleteNotification(removedItem.id).catchError((e) {
          print("Erreur (API 4): $e");
          // Si l'API échoue, réinsère l'item
          if (mounted) {
            setState(() => _notifications.insert(index, removedItem));
            // Affiche une erreur à l'utilisateur
          }
        });
      }
    });
  }



  /// --- NOUVEAU : Affiche une erreur d'action via SnackBar ---
  void _showActionError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }


  /// --- NOUVEAU : Gère "Marquer tout comme lu" ---
  Future<void> _handleMarkAllAsRead() async {
    final l10n = AppLocalizations.of(context)!;

    // 1. Mise à jour optimiste de l'UI (rapide)
    // On garde une copie en cas d'erreur
    final oldNotifications = List<NotificationModel>.from(_notifications);
    setState(() {
      _notifications = _notifications.map((n) {
        return n.copyWith(isRead: true); // Utilise la méthode copyWith
      }).toList();
    });

    // 2. Appel API
    try {
      final success = await _authService.markAllNotificationsAsRead();
      if (!success) {
        throw Exception("L'API a échoué");
      }
    } catch (e) {
      // 3. Rollback (annuler) en cas d'erreur
      _showActionError(l10n.markAllAsReadError);
      setState(() {
        _notifications = oldNotifications;
      });
    }
  }

  /// --- NOUVEAU : Gère "Supprimer tout" ---
  Future<void> _handleDeleteAll() async {
    final l10n = AppLocalizations.of(context)!;

    // 1. Demander confirmation (TRÈS IMPORTANT)
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAllConfirmationTitle),
        content: Text(l10n.deleteAllConfirmationMessage),
        actions: [
          TextButton(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: Text(l10n.delete, style: TextStyle(color: AppTheme.errorColor)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    // 2. Si l'utilisateur n'a pas confirmé
    if (confirmed != true) {
      return;
    }

    // 3. Mise à jour optimiste de l'UI
    final oldNotifications = List<NotificationModel>.from(_notifications);
    setState(() {
      _notifications.clear();
      _isLoading = true; // Affiche un loader
    });

    // 4. Appel API
    try {
      final success = await _authService.deleteAllNotifications();
      if (!success) {
        throw Exception("L'API a échoué");
      }
      // Succès : on rafraîchit la liste (qui devrait être vide)
      await _loadNotifications();
    } catch (e) {
      // 5. Rollback (annuler) en cas d'erreur
      _showActionError(l10n.deleteAllError);
      setState(() {
        _notifications = oldNotifications;
        _isLoading = false;
      });
    }
  }




  // --- Helper pour obtenir l'icône ---
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'request_update':
        return Icons.list_alt_outlined;
      case 'event':
        return Icons.event_outlined;
      case 'reminder':
        return Icons.alarm_outlined;
      case 'general':
      default:
        return Icons.notifications_outlined;
    }
  }

  // --- Helper pour formater le timestamp ---
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'maintenant';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} j';
    } else {
      return DateFormat('dd/MM/yy').format(timestamp); // Format date plus ancien
    }
  }


  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return "À l'instant";
    } else if (difference.inMinutes < 60) {
      return "Il y a ${difference.inMinutes} min";
    } else if (difference.inHours < 24) {
      return "Il y a ${difference.inHours} h";
    } else if (difference.inDays < 2) {
      return "Hier";
    } else {
      // Affiche la date pour les vieux messages (ex: 24/11/2024)
      return DateFormat('dd/MM/yyyy').format(timestamp);
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        // Pas de bouton retour ici car on suppose qu'il est accessible
        // via la BottomNav ou un Drawer. Si besoin, ajoute :
         leading: IconButton(
           icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.onSurface,),
           onPressed: () => Navigator.of(context).pop(),
         ),
        automaticallyImplyLeading: false, // Important si pas de bouton retour explicite
        title: Text(
          l10n.notificationsTitle,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,

        // --- MODIFICATION ICI : Décommente et active les actions ---
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),),
            tooltip: l10n.markAllAsRead,
            // Désactive les boutons si on charge ou si la liste est vide
            onPressed: (_isLoading || _notifications.isEmpty)
                ? null
                : _handleMarkAllAsRead,
          ),
          IconButton(
            icon: Icon(Icons.delete_sweep_outlined, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),),
            tooltip: l10n.deleteAll,
            // Désactive les boutons si on charge ou si la liste est vide
            onPressed: (_isLoading || _notifications.isEmpty)
                ? null
                : _handleDeleteAll,
          ),
        ],
        // --- FIN MODIFICATION ---
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.primaryColor,
        // --- MODIFICATION : Gestion de l'état (Loading, Erreur, Vide, Contenu) ---
        child: _buildBody(),
      ),
    );
  }




  // --- NOUVEAU WIDGET : Pour gérer les différents états de l'UI ---
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorState(_error!);
    }

    if (_notifications.isEmpty) {
      return _buildEmptyState(); // Ton widget "vide" existant
    }

    // Affiche la liste
    return ListView.builder(
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        return _buildNotificationItem(index); // Ton item existant
      },
    );
  }


  // --- Widget pour un item de notification ---
  Widget _buildNotificationItem(int index) {
    final notification = _notifications[index];
    final bool isUnread = !notification.isRead;

    // Utilise Dismissible pour permettre la suppression par swipe

    return Dismissible(
      key: Key(notification.id), // Clé unique pour chaque élément
      direction: DismissDirection.endToStart, // Swipe de droite à gauche
      onDismissed: (direction) {
        _deleteNotification(index); // Appelle la suppression
      },
      background: Container( // Fond rouge affiché pendant le swipe
        color: AppTheme.errorColor.withOpacity(0.8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Material( // Pour l'effet d'ondulation sur fond coloré
        color: isUnread ? AppTheme.primaryColor.withOpacity(0.05) : Theme.of(context).scaffoldBackgroundColor
, // Léger fond si non lu
        child: InkWell( // Pour l'effet d'ondulation et le onTap
          onTap: () {
            _onNotificationTapped(index);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône
                Icon(_getNotificationIcon(notification.type), color: isUnread ? AppTheme.primaryColor : Theme.of(context).colorScheme.onSurface.withOpacity(0.6), size: 24),
                const SizedBox(width: 16),
                // Contenu Texte
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal, // Gras si non lu
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Timestamp et indicateur Non Lu
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTimestamp(notification.timestamp),
                      style: TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                    if (isUnread) ...[ // Affiche le point bleu si non lu
                      const SizedBox(height: 8),
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor, // Ou une couleur spécifique pour "non lu"
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  // --- NOUVEAU : Widget pour l'état d'erreur ---
  Widget _buildErrorState(String message) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppTheme.errorColor),
            const SizedBox(height: 20),
            Text(
              l10n.oops,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }


// --- Widget pour l'état vide ---
  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;

    // final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 80, color: AppTheme.textTertiary),
            const SizedBox(height: 20),
            Text(
              l10n.noNotificationsTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noNotificationsMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

} // Fin de _NotificationsScreenState