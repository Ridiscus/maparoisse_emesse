import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:maparoisse/src/app_themes.dart';
import '../../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:app_links/app_links.dart';

class PaymentPage extends StatefulWidget {
  final String typeIntention;
  final double montant;
  final double frais;
  final double total;
  final String reference;
  final int messeId;

  const PaymentPage({
    Key? key,
    required this.typeIntention,
    required this.montant,
    required this.frais,
    required this.total,
    required this.reference,
    required this.messeId,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  // On utilise un seul état de chargement car tout passe par CinetPay
  bool _isLoading = false;

  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    _initAppLinks();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /// Gestion des retours de paiement (Deep Links)
  Future<void> _initAppLinks() async {
    _appLinks = AppLinks();
    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      if (!mounted) return;
      print('--- Lien de retour reçu : $uri ---');

      if (uri.scheme == 'maparoisse' && uri.host == 'paiement') {
        final String? status = uri.queryParameters['status'];
        // CinetPay peut renvoyer différents statuts, adapte selon ton backend
        if (status == 'success' || status == 'ACCEPTED') {
          Navigator.pushReplacementNamed(context, '/payment-success');
        } else if (status == 'error' || status == 'REFUSED') {
          _showSnack(context, 'Le paiement a échoué.', isError: true);
        }
      }
    }, onError: (err) {
      print('Erreur app_links: $err');
    });
  }

  /// --- NOUVELLE FONCTION CINETPAY ---
  Future<void> _proceedToCinetPay(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      // 1. Appel à la nouvelle API CinetPay
      final String? checkoutUrl = await authService.initierPaiementCinetPay(
        messeId: widget.messeId,
        montant: widget.total,
      );

      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        throw Exception("L'URL de paiement n'a pas été générée.");
      }

      // 2. Ouvre la page CinetPay (où l'utilisateur choisira Wave, Orange, etc.)
      final Uri uri = Uri.parse(checkoutUrl);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception("Impossible d’ouvrir le lien de paiement.");
      }

    } catch (e) {
      if (mounted) {
        // Nettoyage du message d'erreur pour l'utilisateur
        String msg = e.toString().replaceAll('Exception:', '').trim();
        _showSnack(context, "Erreur: $msg", isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const ocreColor = Color(0xFFC0A040);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text("Paiement sécurisé", style: TextStyle(color: Colors.white)),
        backgroundColor: ocreColor,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fond décoratif
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset('assets/images/bras.jpg', fit: BoxFit.cover),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // --- 1. CARTE RÉCAPITULATIVE ---
                Card(
                  color: theme.cardTheme.color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: ocreColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: ocreColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.receipt_long, color: ocreColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Détails de la transaction",
                                style: TextStyle(
                                  color: ocreColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildRecapRow("Type d'intention", widget.typeIntention),
                        const Divider(height: 24),
                        _buildRecapRow("Montant", "${widget.montant} FCFA"),
                        _buildRecapRow("Frais", "${widget.frais} FCFA"),
                        const SizedBox(height: 12),
                        _buildRecapRow(
                          "Total à payer",
                          "${widget.total} FCFA",
                          bold: true,
                          color: AppTheme.primaryColor,
                          fontSize: 20,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Réf: ${widget.reference}",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // --- 2. SECTION PAIEMENT UNIQUE (CINETPAY) ---
                Text(
                  "Moyen de paiement",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Gros bouton unique pour CinetPay
                InkWell(
                  onTap: _isLoading ? null : () => _proceedToCinetPay(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isLoading ? Colors.grey : AppTheme.successColor,
                        width: 2,

                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if (_isLoading)
                          const CircularProgressIndicator(color: ocreColor)
                        else
                          Row(
                            children: [
                              // Icône à gauche
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.payment, color: Colors.green, size: 30),
                              ),
                              const SizedBox(width: 16),
                              // Textes
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Payer maintenant",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Wave, Orange, MTN, Moov, Visa...",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Flèche
                              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Petit texte de réassurance
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    const SizedBox(width: 6),
                    Text(
                      "Paiement 100% sécurisé via CinetPay",
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // --- 3. BOUTON RETOUR ---
                TextButton.icon(
                  onPressed: () {
                    final dashboardState = DashboardScreenWithIndex.globalKey.currentState;
                    dashboardState?.goToIndex(2);
                    Navigator.of(context).popUntil((route) {

                      return route.settings.name == '/dashboard' || route.isFirst;
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Annuler et retourner"),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecapRow(String label, String value,
      {bool bold = false, Color? color, double fontSize = 14}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: color ?? theme.colorScheme.onSurface,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}