// lib/src/screens/password_reset/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maparoisse/src/services/auth_service.dart';
import 'package:maparoisse/src/app_themes.dart';
import 'package:maparoisse/src/widgets/loader_widget.dart'; // Assure-toi que le chemin est bon
import 'package:maparoisse/src/screens/password_reset/otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final success = await authService.requestPasswordReset(_emailCtrl.text.trim());

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(email: _emailCtrl.text.trim()),
        ));
      } else {
        _showError("Impossible d'envoyer l'e-mail. Vérifiez l'adresse.");
      }
    } catch (e) {
      _showError("Une erreur est survenue.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Mot de passe oublié"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.email_outlined, size: 80, color: AppTheme.primaryColor),
                    const SizedBox(height: 20),
                    const Text(
                      "Réinitialiser le mot de passe",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Entrez votre adresse e-mail pour recevoir un code de vérification.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 16),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return 'Veuillez entrer un e-mail valide.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _sendEmail,
                      style: ElevatedButton.styleFrom(

                        backgroundColor: AppTheme.primaryColor,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Envoyer le code", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const CustomCircularLoader(),
            ),
        ],
      ),
    );
  }

  void _showError(String message) {
    // (Tu peux copier ta fonction _showError de LoginScreen ici pour un snackbar en haut)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }
}