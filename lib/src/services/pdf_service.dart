// Fichier : lib/services/pdf_service.dart

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/request.dart'; // Assurez-vous que le chemin est correct
import '../app_themes.dart'; // Assurez-vous que le chemin est correct

class PdfService {

  static Future<void> generateAndPrintReceipt({
    required Request request,
    // Note : Le modèle 'Request' ne contient pas les infos de paiement.
    // Nous les passons donc en paramètres.
    required double montant,
    required double frais,
    required double total,
  }) async {
    final doc = pw.Document();

    // Pour un design plus pro, on peut charger une police (optionnel)
    // final font = await PdfGoogleFonts.poppinsRegular();

    // --- NOUVEAUTÉ : On charge l'image SVG ---
    final String svgIcon = await rootBundle.loadString('assets/images/Rosary.svg');

    // On ajoute une page au document
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. En-tête du reçu
              _buildHeader(request),
              pw.SizedBox(height: 20),

              // 2. Détails de la demande
              _buildRequestDetails(request),
              pw.SizedBox(height: 20),

              // 3. Récapitulatif du paiement
              _buildPaymentDetails(montant, frais, total),
              pw.SizedBox(height: 40),

              pw.Spacer(),

              // 4. Pied de page
              _buildFooter(svgIcon),
            ],
          );
        },
      ),
    );

    // Afficher l'interface d'impression/partage
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  // Widget pour l'en-tête
  static pw.Widget _buildHeader(Request request) {
    // Convertir la couleur Flutter en couleur PDF
    final statusColor = _getPdfColor(AppTheme.getStatusColor(request.status));

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Reçu de Demande de Messe', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.Text('ID Demande : ${request.id.substring(0, 8)}...'),
          ],
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: pw.BoxDecoration(
            color: statusColor,
            borderRadius: pw.BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  // Widget pour les détails de la demande
  static pw.Widget _buildRequestDetails(Request request) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Détails de la demande', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Divider(),
        _buildDetailRowPdf('Intention', request.intention),
        _buildDetailRowPdf('Célébration', request.celebration),
        _buildDetailRowPdf('Paroisse', request.paroisse),
        if (request.motif.isNotEmpty) _buildDetailRowPdf('Motif', request.motif),
        _buildDetailRowPdf('Date de la demande', request.date),
      ],
    );
  }

  // Widget pour les détails du paiement
  static pw.Widget _buildPaymentDetails(double montant, double frais, double total) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Détails du paiement', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),

        pw.Divider(),
        _buildDetailRowPdf('Montant', '${montant.toStringAsFixed(0)} FCFA'),
        _buildDetailRowPdf('Frais', '${frais.toStringAsFixed(0)} FCFA'),
        pw.Divider(),
        pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total payé', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text('${total.toStringAsFixed(0)} FCFA', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
            ]
        )
      ],
    );
  }



  // Helper pour créer une ligne de détail
  static pw.Widget _buildDetailRowPdf(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }


  // Widget pour le pied de page
  // --- MODIFICATION : Le pied de page recrée maintenant votre logo ---
  static pw.Widget _buildFooter(String svgIcon) {
    // On recrée les couleurs de votre dégradé en format PDF
    final gradient = pw.LinearGradient(
      colors: [
        PdfColor.fromHex('#4527A0'), // deepPurple.shade600
        PdfColor.fromHex('#4527A0'), // white
      ],
      begin: pw.Alignment.topLeft, // <-- On utilise pw.Alignment
      end: pw.Alignment.bottomRight, // <-- On utilise pw.Alignment
    );

    // On recrée la couleur du texte
    final textColor = PdfColor.fromHex('#311B92'); // deepPurple.shade800

    return pw.Column(
      children: [
        pw.Center(
          child: pw.Text(
            'Merci pour votre confiance',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
          ),
        ),
        pw.SizedBox(height: 24),

        // --- Reconstruction du Logo ---
        pw.Column(
          children: [
            pw.Container(
              width: 80,
              height: 80,
              decoration: pw.BoxDecoration(
                gradient: gradient,
                shape: pw.BoxShape.circle,
              ),
              child: pw.Center(
                child: pw.SvgImage(
                  svg: svgIcon,
                  width: 35,
                  height: 35,
                  colorFilter: PdfColors.white,
                ),
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              'E-Messe',
              style: pw.TextStyle(
                color: textColor,
                fontWeight: pw.FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }



  // Helper pour convertir une Color de Flutter en PdfColor
  static PdfColor _getPdfColor(Color color) {
    return PdfColor.fromInt(color.value);
  }
}