import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfReceiptService {
  // --- FONCTION PRINCIPALE ---
  Future<void> generateAndShowReceipt({
    required Map<String, dynamic> request,
  }) async {
    final doc = pw.Document();

    // 1. Charger les ressources (polices, logo)
    final font = await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
    final boldFont = await rootBundle.load("assets/fonts/Poppins-Bold.ttf");
    final ttf = pw.Font.ttf(font);
    final ttfBold = pw.Font.ttf(boldFont);

    final logo = await rootBundle.load('assets/images/logo_wave.jpg');
    final logoImage = pw.Image(pw.MemoryImage(logo.buffer.asUint8List()));

    // 2. Extraire et formater les données
    final data = _extractData(request);

    // 3. Construire la page du PDF
    doc.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(base: ttf, bold: ttfBold),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return _buildPdfLayout(context, data, logoImage);
        },
      ),
    );

    // 4. Afficher l'aperçu d'impression
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  // --- HELPER : Construction de la mise en page ---
  pw.Widget _buildPdfLayout(
      pw.Context context,
      _ReceiptData data,
      pw.Image logoImage,
      ) {
    const double cardPadding = 16.0;
    const PdfColor primaryColor = PdfColor.fromInt(0xFF007BFF); // Couleur pour le titre
    const PdfColor lightGray = PdfColor.fromInt(0xFFF4F4F8);
    const PdfColor darkGray = PdfColor.fromInt(0xFFE8E8EE);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // --- 1. En-tête (style Djamo) ---
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '+ ${data.totalAmount} F',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 28,
                    color: PdfColors.green,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.SizedBox(
                  width: 300,
                  child: pw.Text(
                    'Paiement de votre offrande pour la messe via ${data.operatorName}.',
                    style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                  ),
                ),
              ],
            ),
            pw.Container(
              height: 60,
              width: 60,
              child: logoImage,
            ),
          ],
        ),
        pw.Divider(height: 32),

        // --- 2. Carte "Détails de la transaction" (style Djamo) ---
        pw.Container(
          padding: const pw.EdgeInsets.all(cardPadding),
          decoration: pw.BoxDecoration(
            color: lightGray,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              _buildDetailRow(context, 'Date & Heure', data.paymentDate),
              _buildDetailRow(context, 'Statut', data.status, color: PdfColors.green),
              _buildDetailRow(context, 'Offrande', '${data.offeringAmount} F'),
              _buildDetailRow(context, 'Frais', '${data.fees} F'),
            ],
          ),
        ),
        pw.SizedBox(height: 16),

        // --- 3. Carte "Détails de paiement" (style Djamo) ---

        pw.Container(
          padding: const pw.EdgeInsets.all(cardPadding),
          decoration: pw.BoxDecoration(
            color: darkGray,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              _buildDetailRow(context, 'Référence', data.reference),
              _buildDetailRow(context, 'Opérateur', data.operatorName),
            ],
          ),
        ),
        pw.SizedBox(height: 16),

        // --- 4. Carte "Détails de la messe" (Notre ajout) ---
        pw.Container(
          padding: const pw.EdgeInsets.all(cardPadding),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              _buildDetailRow(context, 'Intention', data.intention),
              _buildDetailRow(context, 'Paroisse', data.parishName),
              _buildDetailRow(context, 'Date de la messe', data.massDate),
            ],
          ),
        ),
      ],
    );
  }

  // --- HELPER : Pour afficher une ligne (Clé / Valeur) ---
  pw.Widget _buildDetailRow(pw.Context context, String label, String value, {PdfColor color = PdfColors.black}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey800),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER : Extraction et formatage des données (VERSION CORRIGÉE) ---
  _ReceiptData _extractData(Map<String, dynamic> request) {
    // 1. Infos de la messe (Ajout de ?? '' partout pour éviter le crash)
    final String intention = request['motif_intention']?.toString() ?? 'Intention non spécifiée';

    // Attention : parfois c'est 'paroisse_name', parfois c'est dans un objet 'paroisse'
    final String parishName = request['paroisse_name']?.toString() ?? 'Paroisse inconnue';

    final String? massDateStr = request['date_souhaitee']?.toString();
    final String? massTimeStr = request['heure_souhaitee']?.toString();

    final String status = request['statut']?.toString() ?? 'N/A';
    final double offeringAmount = double.tryParse(request['montant_offrande']?.toString() ?? '0') ?? 0;

    // 2. Infos du paiement
    // On utilise safeCast ou on vérifie que la liste n'est pas vide
    final List<dynamic> paiementsList = request['paiements'] is List ? request['paiements'] : [];
    final Map<String, dynamic> paiement = paiementsList.isNotEmpty
        ? Map<String, dynamic>.from(paiementsList.first)
        : {};

    // Sécurisation des conversions (toString() avant tryParse)
    final double totalAmount = double.tryParse(paiement['montant']?.toString() ?? '0') ?? 0;
    final String reference = paiement['reference']?.toString() ?? 'Aucune réf.';

    // Gère le cas où 'methode' est null
    final String operatorName = (paiement['methode']?.toString() ?? 'N/A').toUpperCase();

    // --- C'EST ICI QUE ÇA PLANTAIT ---
    // On autorise le null ici, car _formatDateTime sait le gérer
    final String? paymentDateStr = paiement['date_paiement']?.toString();

    // 3. Calculs et formatage
    final double fees = totalAmount - offeringAmount;

    final String formattedMassDate = _formatDateTime(massDateStr, massTimeStr, 'dd/MM/yyyy');

    // On passe le paymentDateStr (qui peut être null ou vide) sans peur
    final String formattedPaymentDate = _formatDateTime(paymentDateStr, null, 'dd/MM/yyyy à HH:mm');

    final String formattedStatus = status.toLowerCase() == 'confirmee' ? 'Confirmé'
        : (status.toLowerCase().contains('celebre') ? 'Célébré' : status);

    return _ReceiptData(
      totalAmount: totalAmount.toStringAsFixed(0),
      offeringAmount: offeringAmount.toStringAsFixed(0),
      fees: fees.toStringAsFixed(0),
      reference: reference,
      operatorName: operatorName,
      status: formattedStatus,
      paymentDate: formattedPaymentDate,
      intention: intention,
      parishName: parishName,
      massDate: formattedMassDate,
    );
  }

  String _formatDateTime(String? dateStr, String? timeStr, String format) {
    if (dateStr == null) return 'N/A';
    try {
      String fullDateStr = dateStr;
      if (timeStr != null) {
        fullDateStr += ' ' + timeStr;
      }
      final dateTime = DateTime.parse(fullDateStr);
      return DateFormat(format, 'fr_FR').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }
}

// Classe simple pour contenir nos données formatées
class _ReceiptData {
  final String totalAmount;
  final String offeringAmount;
  final String fees;
  final String reference;
  final String operatorName;
  final String status;
  final String paymentDate;
  final String intention;
  final String parishName;
  final String massDate;

  _ReceiptData({
    required this.totalAmount,
    required this.offeringAmount,
    required this.fees,
    required this.reference,
    required this.operatorName,
    required this.status,
    required this.paymentDate,
    required this.intention,
    required this.parishName,
    required this.massDate,
  });
}