// lib/src/screens/password_reset/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maparoisse/src/services/auth_service.dart';
import 'package:maparoisse/src/app_themes.dart';
import 'package:maparoisse/src/widgets/loader_widget.dart'; // Assure-toi que le chemin est bon
import '../../../l10n/app_localizations.dart';
import 'otp_verification_screen.dart';

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
    final l10n = AppLocalizations.of(context)!;

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
        _showError(l10n.emailSendError);
      }
    } catch (e) {
      _showError(l10n.unknownError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context); // Raccourci pour le thème

    return Scaffold(
      // ✅ FOND DYNAMIQUE
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.forgotPassword,
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
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
                    Text(
                      l10n.resetPassword,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          // ✅ TEXTE DYNAMIQUE
                          color: theme.colorScheme.onSurface
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.enterEmailToReceiveCode,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        // ✅ TEXTE SECONDAIRE DYNAMIQUE
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 16
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ✅ CHAMP EMAIL CORRIGÉ
                    TextFormField(
                      controller: _emailCtrl,
                      style: TextStyle(color: theme.colorScheme.onSurface), // Couleur de la saisie
                      decoration: InputDecoration(
                        labelText: l10n.emailLabel,
                        prefixIcon: Icon(Icons.alternate_email, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                        filled: true,
                        fillColor: theme.cardTheme.color, // Fond du champ adapté
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                        return l10n.invalidEmailError;
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

                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(l10n.sendCode, style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              // ✅ FOND DU LOADER DYNAMIQUE
              color: theme.scaffoldBackgroundColor.withOpacity(0.8),
              child: const CustomCircularLoader(), // Assure-toi que ton loader est visible sur fond noir
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