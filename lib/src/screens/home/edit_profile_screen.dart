import 'dart:io'; // Pour File
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // Pour choisir l'image
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../app_themes.dart';
// Importe ton widget de champ texte personnalisé si tu l'utilises
import '../widgets/custom_text_field.dart';



class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(); // Email (non modifiable)
  final _phoneController = TextEditingController();

  String? _selectedCivilite;
  File? _imageFile; // Fichier image sélectionné
  String? _initialPhotoPath; // Chemin initial de la photo depuis AuthService

  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // Options pour la civilité
  final List<String> _civiliteOptions = ['M.', 'Mme', 'Mlle'];

  @override
  void initState() {
    super.initState();
    // Charger les données initiales depuis AuthService
    final auth = Provider.of<AuthService>(context, listen: false);
    _nameController.text = auth.fullName ?? '';
    _emailController.text = auth.email ?? '';
    _phoneController.text = auth.phone ?? '';
    _selectedCivilite = auth.civilite;
    _initialPhotoPath = auth.photoPath; // Récupère le chemin stocké
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --- Fonction pour choisir une image ---
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Erreur _pickImage: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la sélection de l\'image.')),
      );
    }
  }





  // ✅ MODIFICATION DE LA FONCTION _saveProfile
  Future<void> _saveProfile() async {
    // 1. Valide le formulaire (nom, téléphone, etc.)
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Récupère le service d'authentification
    final auth = Provider.of<AuthService>(context, listen: false);

    // 3. LOGIQUE CONDITIONNELLE
    // On utilise le nouveau getter qui couvre Google ET Apple
    if (auth.isSocialUser) {
      // CAS A : Utilisateur Social -> PAS DE MOT DE PASSE
      print("Utilisateur Social (Google/Apple) : Sauvegarde directe.");
      await _executeSave();
    } else {
      // CAS B : Utilisateur Classique -> MOT DE PASSE REQUIS
      final bool? passwordVerified = await _showPasswordVerificationModal();

      if (passwordVerified == true) {
        await _executeSave();
      }
    }
  }




  // RENOMME CECI: de _saveProfile à _executeSave
  Future<void> _executeSave() async {
    // Ton code existant ne change pas
    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);

      bool success = await auth.updateUserProfile(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        civilite: _selectedCivilite,
        imageFile: _imageFile,
        email: auth.email,
        username: auth.username,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès!')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        _showError('Erreur lors de la mise à jour du profil.');
      }

    } catch (e) {
      print("Erreur _saveProfile: $e");
      if (mounted) _showError('Une erreur inattendue est survenue.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }



  /// Affiche le Modal (Bottom Sheet) pour la vérification du mot de passe
  Future<bool?> _showPasswordVerificationModal() {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true, // Permet au modal de s'élever au-dessus du clavier
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        // On passe le padding du clavier au widget
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: _PasswordVerificationSheet(), // Le widget qui contient le champ
        );
      },
    );
  }





  // Fonction pour afficher les erreurs
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ImageProvider? profileImageProvider;
    if (_imageFile != null) {
      // 1. L'utilisateur a choisi un NOUVEAU fichier sur son téléphone
      profileImageProvider = FileImage(_imageFile!);
    } else if (_initialPhotoPath != null && _initialPhotoPath!.isNotEmpty) {

      // --- CORRECTION DÉFINITIVE ---
      // 2. On charge l'URL Internet sauvegardée
      profileImageProvider = NetworkImage(_initialPhotoPath!);
      // profileImageProvider = FileImage(File(_initialPhotoPath!)); // <-- SUPPRIME/COMMENte L'ANCIENNE LIGNE
      // --- FIN CORRECTION ---

    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.editProfileTitle,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- Section Photo de Profil ---
              Center(
                child: Stack(
                  clipBehavior: Clip.none, // Permet à l'icône de déborder
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: profileImageProvider,
                      // Affiche une icône par défaut si aucune image n'est disponible
                      child: (profileImageProvider == null)
                          ? Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),)
                          : null,
                    ),


                    // ✅ 1. L'ÉTIQUETTE BAPTISÉ (En haut à gauche)
                    // On utilise Provider pour vérifier l'état
                    if (Provider.of<AuthService>(context).isBaptized)
                      Positioned(
                        top: 0,
                        left: -10, // Décalé un peu à gauche pour le style
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0,2))]
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.water_drop_rounded, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                "BAPTISÉ",
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),

                    Positioned(
                      bottom: 0,
                      right: -10, // Ajuste pour positionner l'icône
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor, // Ou une autre couleur
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2), // Bordure blanche
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          onPressed: _pickImage,
                          tooltip: 'Changer la photo',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

             // --- Champ Nom Complet ---
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration(label: l10n.editProfileNameLabel, icon: Icons.person_outline),
                validator: (value) => (value == null || value.isEmpty) ? l10n.editProfileNameError : null,
              ),
              const SizedBox(height: 20),

              // --- Champ Email (Non modifiable) ---
              TextFormField(
                controller: _emailController,
                readOnly: true,
                // ✅ CORRECTION : Fond grisé adapté au mode (Clair ou Sombre)
                decoration: _buildInputDecoration(label: l10n.editProfileEmailLabel, icon: Icons.email_outlined).copyWith(
                  fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.05), // 5% d'opacité du texte (gris léger)
                ),
              ),
              const SizedBox(height: 20),

              // --- Champ Téléphone ---
              TextFormField(
                controller: _phoneController,
                decoration: _buildInputDecoration(label: l10n.editProfilePhoneLabel, icon: Icons.phone_outlined),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return l10n.editProfilePhoneError;
                  // Ajoute d'autres validations si nécessaire (format, longueur)
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Champ Civilité ---
              DropdownButtonFormField<String>(
                value: _selectedCivilite,
                items: _civiliteOptions.map((civilite) {
                  return DropdownMenuItem(value: civilite, child: Text(civilite));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCivilite = value);
                },
                decoration: _buildInputDecoration(label: l10n.editProfileCiviliteLabel, icon: Icons.wc_outlined),
                validator: (value) => (value == null) ? l10n.editProfileCiviliteError : null,
              ),
              const SizedBox(height: 40),

              // --- Bouton Sauvegarder ---
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor, // Adapte la couleur
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(l10n.editProfileSaveButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40),
              // --- BOUTON DE DÉCONNEXION AJOUTÉ ICI ---
              Center(
                child: TextButton(
                  onPressed: _showLogoutDialog, // Fonction que nous allons ajouter
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.errorColor, // En rouge
                  ),
                  child: Text(
                    l10n.editProfileLogoutButton, // TODO: Utilise l10n.settingsLogoutButton
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Espace en bas
            ],
          ),
        ),
      ),
    );
  }


  void _showLogoutDialog() async {
    // Assure-toi d'avoir les imports pour l10n, GoogleFonts, et AuthService
    final l10n = AppLocalizations.of(context)!;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Theme.of(context).cardTheme.color,
        elevation: 20,
        shadowColor: Colors.black.withOpacity(0.3),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: AppTheme.errorColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.drawerLogoutTitle,
              style: GoogleFonts.cormorantGaramond(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.drawerLogoutMessage,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            child: Text(
              l10n.drawerLogoutCancel,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.drawerLogoutConfirm,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      final auth = Provider.of<AuthService>(context, listen: false);
      await auth.logout();

      if (context.mounted) {
        // Navigue vers l'écran de login
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      }
    }
  }


  InputDecoration _buildInputDecoration({required String label, required IconData icon}) {
    // On récupère le thème actuel
    final theme = Theme.of(context);

    return InputDecoration(
      labelText: label,
      // Couleur de l'icône dynamique
      prefixIcon: Icon(icon, color: theme.colorScheme.onSurface.withOpacity(0.6)),

      // BORDURES DYNAMIQUES (Utilise dividerColor du thème)
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
      ),

      // FOND DYNAMIQUE
      filled: true,
      // Utilise la couleur définie dans inputDecorationTheme (Gris foncé en sombre, Blanc en clair)
      fillColor: theme.inputDecorationTheme.fillColor ?? theme.cardTheme.color,

      // COULEUR DU LABEL
      labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
    );
  }


}



/// --- WIDGET POUR LE MODAL DE VÉRIFICATION ---
class _PasswordVerificationSheet extends StatefulWidget {
  @override
  __PasswordVerificationSheetState createState() =>
      __PasswordVerificationSheetState();
}

class __PasswordVerificationSheetState
    extends State<_PasswordVerificationSheet> {
  final _passwordController = TextEditingController();
  bool _isModalLoading = false;
  String? _modalError;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  /// Appelé lorsque l'utilisateur appuie sur "Vérifier"
  Future<void> _verifyPassword() async {
    final l10n = AppLocalizations.of(context)!;

    if (_passwordController.text.isEmpty) {
      setState(() => _modalError = l10n.passwordModalEmpty);
      return;
    }

    setState(() {
      _isModalLoading = true;
      _modalError = null;
    });

    final auth = Provider.of<AuthService>(context, listen: false);

    try {
      final success = await auth.verifyCurrentUserPassword(_passwordController.text);

      if (success) {
        // Succès ! On ferme le modal et on renvoie 'true'
        Navigator.pop(context, true);
      } else {
        // Échec (mot de passe incorrect)
        setState(() {
          _isModalLoading = false;
          _modalError = l10n.passwordModalIncorrect;
        });
      }
    } catch (e) {
      // Erreur réseau ou autre
      setState(() {
        _isModalLoading = false;
        _modalError = l10n.passwordModalError;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Récupère le thème
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24.0),
      // ✅ CORRECTION : Ajoute une décoration pour forcer la couleur de fond du modal
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor, // ou theme.cardTheme.color
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // S'adapte au contenu
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.confirmIdentity,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.enterPasswordToSave,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _passwordController,
            obscureText: true,
            autofocus: true, // Ouvre le clavier directement
            style: TextStyle(color: theme.colorScheme.onSurface), // Couleur de la saisie
            decoration: InputDecoration(
              labelText: l10n.currentPassword,
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              errorText: _modalError, // Affiche l'erreur ici
            ),
            onSubmitted: (_) => _verifyPassword(), // Permet de valider avec "Entrée"
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isModalLoading ? null : _verifyPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
            ),
            child: _isModalLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Text(l10n.verifyAndSave, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

}