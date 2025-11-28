import 'package:flutter/material.dart';
import '../../theme.dart';
import '../widgets/modern_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/logo_widget.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _isLoading = false;

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPassCtrl.text.trim() != _confirmPassCtrl.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les mots de passe ne correspondent pas")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Appeler le backend pour changer le mot de passe
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.lock_open, color: Colors.white),
              SizedBox(width: 8),
              Text("Mot de passe mis à jour avec succès"),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      Navigator.of(context).pop(); // retourne à la page paramètres
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.white,
        ),
        backgroundColor: AppTheme.primaryColor,
        centerTitle: true,
        title: const Text("Sécurité",
          style: TextStyle(
            color: Colors.white, // 👈 garde le titre en blanc
          ),
        ),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const SanctaMissaLogo(),
                const SizedBox(height: 20),
                ModernCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _currentPassCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Mot de passe actuel",
                          ),
                          validator: (v) =>
                          (v == null || v.isEmpty) ? "Requis" : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _newPassCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Nouveau mot de passe",
                          ),
                          validator: (v) =>
                          (v == null || v.length < 6) ? "Min. 6 caractères" : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPassCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Confirmer le mot de passe",
                          ),
                          validator: (v) =>

                          (v == null || v.isEmpty) ? "Requis" : null,
                        ),
                        const SizedBox(height: 24),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : PrimaryButton(
                          text: "Mettre à jour",
                          onPressed: _updatePassword,
                          minimumSize: const Size.fromHeight(50),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}