// card_payment_modal.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../widgets/logo_widget.dart';

Future<void> showCardPaymentModal(BuildContext context, {
  required int amountXof, // montant en XOF (entier)
}) {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _cardCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController(); // MM/YY
  final _cvvCtrl = TextEditingController();

  String _selectedCountry = "Côte d'Ivoire"; // valeur par défaut
  bool _isLoading = false;

  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setState) {
        Future<void> _submit() async {
          if (!_formKey.currentState!.validate()) return;

          final name = _nameCtrl.text.trim();
          final cardNumber = _cardCtrl.text.replaceAll(' ', '');
          final expiry = _expiryCtrl.text.trim();
          final cvv = _cvvCtrl.text.trim();

          if (cardNumber.length < 12 || cvv.length < 3) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Numéro de carte ou CVV invalide')),
            );
            return;
          }

          setState(() => _isLoading = true);

          try {
            final backendUrl = Uri.parse('https://ton-backend.com/api/create-streetpay-session');

            final resp = await http.post(
              backendUrl,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'amount': amountXof.toString(),
                'currency': 'XOF',
                'reference': 'txn_${DateTime.now().millisecondsSinceEpoch}',
                'country': _selectedCountry, // pays choisi
                'card': {
                  'holder_name': name,
                  'number': cardNumber,
                  'expiry': expiry,
                  'cvv': cvv,
                },
              }),
            );

            if (resp.statusCode == 200) {
              final data = jsonDecode(resp.body);
              final checkoutUrl = data['checkout_url'] as String?;
              if (checkoutUrl != null && await canLaunchUrl(Uri.parse(checkoutUrl))) {
                await launchUrl(Uri.parse(checkoutUrl), mode: LaunchMode.externalApplication);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Impossible d’ouvrir la page de paiement')),
                );
              }
            } else {
              String message = 'Erreur lors de la création du paiement';
              try {
                final j = jsonDecode(resp.body);
                if (j is Map && j['error'] != null) message = j['error'].toString();
                else if (j is Map && j['message'] != null) message = j['message'].toString();
              } catch (_) {}
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Erreur réseau ou serveur')),
            );
          } finally {
            setState(() => _isLoading = false);
          }
        }

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo en haut
                  const SanctaMissaLogo(),

                  Text('Payer $amountXof XOF',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Entrez les informations de votre carte',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Sélection du pays
                        DropdownButtonFormField<String>(
                          value: _selectedCountry,
                          decoration: const InputDecoration(labelText: 'Pays'),
                          items: const [
                            DropdownMenuItem(
                                value: "Côte d'Ivoire",
                                child: Text("Côte d'Ivoire")),
                            DropdownMenuItem(
                                value: "Sénégal", child: Text("Sénégal")),
                            DropdownMenuItem(
                                value: "Mali", child: Text("Mali")),
                            DropdownMenuItem(
                                value: "Burkina Faso",
                                child: Text("Burkina Faso")),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedCountry = value);
                            }
                          },
                        ),
                        const SizedBox(height: 8),

                        TextFormField(
                          controller: _nameCtrl,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(labelText: 'Nom sur la carte'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                        ),
                        const SizedBox(height: 8),

                        TextFormField(
                          controller: _cardCtrl,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(labelText: 'Numéro de carte'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Requis';
                            final digits = v.replaceAll(' ', '');
                            if (digits.length < 12) return 'Numéro invalide';
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _expiryCtrl,
                                keyboardType: TextInputType.datetime,
                                decoration: const InputDecoration(labelText: 'MM/AA'),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Requis';
                                  if (!RegExp(r'^\d{2}\/\d{2}$').hasMatch(v)) return 'Format MM/AA';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _cvvCtrl,
                                keyboardType: TextInputType.number,

                                decoration: const InputDecoration(labelText: 'CVV'),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Requis';
                                  if (v.length < 3) return 'CVV invalide';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _isLoading
                            ? const CircularProgressIndicator()
                            : Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Annuler'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _submit,
                                child: const Text('Payer'),
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
      });
    },
  );
}