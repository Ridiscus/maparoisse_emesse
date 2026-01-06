import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../app_themes.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/modern_card.dart';
import '../widgets/primary_button.dart'; // Si tu l'as, sinon ElevatedButton

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  String? _civilite;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitCompletion() async {
    if (!_formKey.currentState!.validate()) return;
    if (_civilite == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner votre civilité"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);

      // On utilise ta fonction existante updateUserProfile
      // On envoie null pour les champs qu'on ne touche pas (nom, email, photo)
      bool success = await auth.updateUserProfile(
        fullName: auth.fullName ?? "", // On garde le nom actuel
        username: auth.username,       // On garde le user actuel
        email: auth.email,             // On garde l'email actuel
        imageFile: null,               // Pas de changement de photo

        // CE QU'ON MET À JOUR :
        phone: _phoneCtrl.text.trim(),
        civilite: _civilite,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          // 🎉 Profil complet ! Direction Dashboard
          Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erreur lors de la mise à jour."), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const Color primaryColor = Color(0xFFC0A040);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Dernière étape", style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // PAS DE BOUTON RETOUR
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Finalisez votre inscription",
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                "Nous avons besoin de ces informations pour traiter vos demandes de messes.",
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
              const SizedBox(height: 32),

// --- SÉLECTION CIVILITÉ ---
              Text("Civilité *", style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ModernCard(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      onTap: () => setState(() => _civilite = 'M.'),
                      borderColor: _civilite == 'M.' ? primaryColor : null,
                      backgroundColor: _civilite == 'M.' ? primaryColor.withOpacity(0.1) : theme.cardTheme.color,
                      child: Center(child: Text("Monsieur", style: TextStyle(fontWeight: FontWeight.w600, color: _civilite == 'M.' ? primaryColor : theme.colorScheme.onSurface))),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ModernCard(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      onTap: () => setState(() => _civilite = 'Mme'),
                      borderColor: _civilite == 'Mme' ? primaryColor : null,
                      backgroundColor: _civilite == 'Mme' ? primaryColor.withOpacity(0.1) : theme.cardTheme.color,
                      child: Center(child: Text("Madame", style: TextStyle(fontWeight: FontWeight.w600, color: _civilite == 'Mme' ? primaryColor : theme.colorScheme.onSurface))),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- CHAMP TÉLÉPHONE ---
              CustomTextField(
                controller: _phoneCtrl,
                label: "Numéro de téléphone *",
                hint: "+225 07...",
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (val) => (val == null || val.length < 8) ? "Numéro invalide" : null,
              ),

              const SizedBox(height: 40),

              // --- BOUTON VALIDER ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitCompletion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Terminer et Accéder", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}