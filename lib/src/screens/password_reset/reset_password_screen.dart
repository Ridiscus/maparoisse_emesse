// lib/src/screens/password_reset/reset_password_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maparoisse/src/services/auth_service.dart';
import 'package:maparoisse/src/app_themes.dart';
import 'package:maparoisse/src/widgets/loader_widget.dart';
import 'package:maparoisse/src/screens/auth/login_screen.dart';

import '../../../l10n/app_localizations.dart'; // Pour la redirection

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
  const ResetPasswordScreen({Key? key, required this.email, required this.otp}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final success = await authService.resetPassword(
        widget.email,
        widget.otp,
        _passCtrl.text,
      );

      if (!mounted) return;

      if (success) {
        // Succès ! On affiche un message et on retourne au Login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Mot de passe changé avec succès !"),
            backgroundColor: AppTheme.successColor,
          ),
        );

        // Redirige vers Login et supprime tout l'historique de navigation
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false, // Supprime toutes les routes précédentes
        );
      } else {
        _showError("Impossible de changer le mot de passe. Le code a peut-être expiré.");
      }
    } catch (e) {
      _showError("Une erreur est survenue.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context);

    // Petit helper local pour ne pas répéter le code de décoration
    InputDecoration inputDeco(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.onSurface.withOpacity(0.6)),
        filled: true,
        fillColor: theme.cardTheme.color,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // ✅
      appBar: AppBar(
        title: Text(l10n.resetPasswordTitle, style: TextStyle(color: theme.colorScheme.onSurface)),
        backgroundColor: theme.scaffoldBackgroundColor, // ✅
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
                    Icon(Icons.lock_reset, size: 80, color: AppTheme.primaryColor),
                    const SizedBox(height: 20),
                    Text(
                      l10n.createNewPassword,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface // ✅
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // ✅ CHAMP PASSWORD 1
                    TextFormField(
                      controller: _passCtrl,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: inputDeco(l10n.newPassword, Icons.lock),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.length < 8) {
                          return l10n.passwordTooShort;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // ✅ CHAMP PASSWORD 2
                    TextFormField(
                      controller: _confirmPassCtrl,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: inputDeco(l10n.confirmPassword, Icons.lock),
                      obscureText: true,
                      validator: (value) {
                        if (value != _passCtrl.text) {
                          return l10n.passwordMismatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

                      ),
                      child: Text(l10n.validate, style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: theme.scaffoldBackgroundColor.withOpacity(0.8), // ✅
              child: const CustomCircularLoader(),
            ),
        ],
      ),
    );
  }


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }
}