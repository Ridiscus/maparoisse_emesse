// Fichier : lib/screens/home/history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour le formatage des dates
import '../../app_themes.dart';
import '../../models/request.dart'; // Importer votre modèle Request
import '../../services/request_service.dart'; // Importer votre service
import '../widgets/modern_card.dart'; // Importer vos widgets
import '../widgets/status_badge.dart'; // Importer vos widgets
import '../widgets/history_content.dart'; // Importer vos widgets



class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Le FutureBuilder utilisera cette variable pour charger les données
  late Future<List<Request>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  /// Charge toutes les demandes et filtre pour ne garder que l'historique
  void _loadHistory() {
    setState(() {
      _historyFuture = RequestService.getRequests().then((requests) {
        // On filtre la liste pour ne garder que les demandes célébrées
        final history = requests
            .where((req) => req.status.toLowerCase() == 'célébré')
            .toList();

        // On trie du plus récent au plus ancien
        history.sort((a, b) => _parseDate(b.date).compareTo(_parseDate(a.date)));

        return history;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.white, // 👈 force le back button en blanc
        ),
        title:  Text('Historique des demandes',
          style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor,
),
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const HistoryContent(),
    );
  }

  // --- Fonctions copiées de RequestsListScreen et adaptées ---

  DateTime _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      try {
        return DateFormat('dd/MM/yyyy').parse(dateStr);
      } catch (e) {
        return DateTime(1900);
      }
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = _parseDate(dateStr);
      return DateFormat('dd MMMM yyyy', 'fr_FR').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  IconData _getRequestIcon(String intention) {
    switch (intention.toLowerCase()) {
      case 'défunt':
        return Icons.person_outline;
      case 'action de grâces':
        return Icons.favorite_outline;
      case 'intention particulière':
        return Icons.lightbulb_outline;
      default:
        return Icons.event_note_outlined;
    }
  }

  // Version simplifiée de votre carte, sans les boutons d'action
  Widget _buildHistoryCard(Request request) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getRequestIcon(request.intention),
                  color: AppTheme.successColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${request.celebration} - ${request.paroisse}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Intention: ${request.intention}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),),
              const SizedBox(width: 4),
              Text(
                'Célébrée le: ${_formatDate(request.date)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}