// Fichier : lib/services/quote_service.dart

import 'dart:math';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/quotes_data.dart';

class QuoteService {

  /// Vérifie si une nouvelle citation doit être montrée aujourd'hui.
  /// Si oui, il la choisit, la sauvegarde et la retourne.
  /// Sinon, il retourne null.
  Future<Quote?> getQuoteForToday() async {
    final prefs = await SharedPreferences.getInstance();

    // On récupère la date d'aujourd'hui au format "année-mois-jour"
    final String todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // On regarde la dernière fois qu'on a montré une citation
    final String? lastShownDate = prefs.getString('last_quote_date');

    // Si la date n'est pas celle d'aujourd'hui, c'est le moment d'en montrer une nouvelle !
    if (lastShownDate != todayString) {
      // 1. On choisit une nouvelle citation au hasard
      final randomIndex = Random().nextInt(allQuotes.length);
      final newQuote = allQuotes[randomIndex];

      // 2. On sauvegarde la date d'aujourd'hui et l'index de la citation
      await prefs.setString('last_quote_date', todayString);
      await prefs.setInt('daily_quote_index', randomIndex);

      // 3. On retourne la citation à afficher
      return newQuote;
    }

    // Si on a déjà montré une citation aujourd'hui, on ne fait rien.
    return null;
  }
}