// Fichier : lib/screens/home/widgets/history_content.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app_themes.dart';
import '../../models/request.dart';
import '../../services/request_service.dart';
import '../widgets/modern_card.dart';
import '../widgets/status_badge.dart';

class HistoryContent extends StatefulWidget {
  const HistoryContent({super.key});

  @override
  State<HistoryContent> createState() => _HistoryContentState();
}

class _HistoryContentState extends State<HistoryContent> {
  late Future<List<Request>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _historyFuture = RequestService.getRequests().then((requests) {
        final history = requests
            .where((req) => req.status.toLowerCase() == 'célébré')
            .toList();

        history.sort((a, b) => _parseDate(b.date).compareTo(_parseDate(a.date)));
        return history;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Request>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Erreur lors du chargement de l\'historique.'));
        }

        final historyList = snapshot.data ?? [];

        if (historyList.isEmpty) {
          return const Center(child: Text('Aucun historique disponible.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: historyList.length,
          itemBuilder: (context, index) {
            final request = historyList[index];
            return _buildHistoryCard(context, request);
          },
        );
      },
    );
  }

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

  Widget _buildHistoryCard(BuildContext context, Request request) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_note, color: AppTheme.successColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${request.celebration} - ${request.paroisse}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              StatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: 8),
          Text('Célébrée le: ${_formatDate(request.date)}'),
        ],
      ),
    );
  }
}