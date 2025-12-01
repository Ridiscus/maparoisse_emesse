import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../app_themes.dart';
import '../../services/auth_service.dart';
// import '../../../l10n/app_localizations.dart'; // Uncomment when ready
import 'package:image_picker/image_picker.dart'; // N'oublie pas d'ajouter image_picker dans pubspec.yaml






class IdentificationScreen extends StatefulWidget {
  const IdentificationScreen({super.key});

  @override
  State<IdentificationScreen> createState() => _IdentificationScreenState();
}

class _IdentificationScreenState extends State<IdentificationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nomPrenomsCtrl = TextEditingController();
  final _lieuHabitationCtrl = TextEditingController();
  final _telephoneCtrl = TextEditingController();

  // State variables for dropdowns and pickers
  DateTime? _dateNaissance;
  DateTime? _dateBapteme;
  String? _sexe;
  String? _situationMatrimoniale;
  String? _statutActivite;
  int? _selectedParoisseId; // ID of the selected parish
  bool _isInMovement = false;
  bool _isBaptise = false;
  final _mouvementCtrl = TextEditingController(); // To specify movement if 'Yes'

  // --- NOUVEAU : Gestion Image ---
  File? _imageFile; // Nouvelle image sélectionnée
  String? _initialPhotoUrl; // Photo de profil actuelle (URL)
  final ImagePicker _picker = ImagePicker();

  // Data lists
  final List<String> _sexes = ['Masculin', 'Féminin'];
  final List<String> _situations = ['Célibataire', 'Concubin(e)', 'Fiancé(e)', 'Divorcé(e)', 'Veuf/veuve', 'Marié(e)'];
  final List<String> _activites = ['Salarié', "Demandeur d'emplois", 'Retraité', 'Profession libérale'];
  List<dynamic> _parishes = []; // To store loaded parishes

  bool _isLoading = false;



  @override
  void initState() {
    super.initState();
    _loadParishes();
    _prefillUserData(); // <--- On charge les données utilisateur au démarrage
  }

  // --- 1. FONCTION POUR PRÉ-REMPLIR LES DONNÉES ---
  void _prefillUserData() {
    final auth = Provider.of<AuthService>(context, listen: false);

    // On remplit les champs texte
    _nomPrenomsCtrl.text = auth.fullName ?? '';
    _telephoneCtrl.text = auth.phone ?? '';

    // On récupère la photo de profil existante
    if (auth.photoPath != null && auth.photoPath!.isNotEmpty) {
      _initialPhotoUrl = auth.photoPath;
    }
  }




  Future<void> _loadParishes() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final parishes = await authService.getParishes();
      setState(() {
        _parishes = parishes;
      });
    } catch (e) {
      // Handle error (show snackbar)
      print("Error loading parishes: $e");
    }
  }



  // --- GESTION DE LA CAMÉRA / GALERIE ---
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Erreur image: $e");
    }
  }



  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFC0A040), // Gold color
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _dateNaissance = picked;
        } else {
          _dateBapteme = picked;
        }
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Gestion de l'affichage de l'image (Fichier local OU Réseau OU Défaut)
    ImageProvider? imageProvider;
    if (_imageFile != null) {
      imageProvider = FileImage(_imageFile!);
    } else if (_initialPhotoUrl != null) {
      imageProvider = NetworkImage(_initialPhotoUrl!);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Fiche d'identification", style: TextStyle(color: theme.colorScheme.onSurface)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECTION PHOTO DYNAMIQUE ---
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: imageProvider, // Affiche l'image si elle existe
                      child: imageProvider == null
                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFFC0A040),
                        radius: 18,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                          onPressed: _pickImage, // Ouvre la galerie
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- CHAMPS PRÉ-REMPLIS ---
              _buildTextField("Nom & Prénoms", _nomPrenomsCtrl),
              const SizedBox(height: 16),

              _buildDateSelector("Date de naissance", _dateNaissance, true),
              const SizedBox(height: 16),

              _buildDropdown("Sexe", _sexe, _sexes, (val) => setState(() => _sexe = val)),
              const SizedBox(height: 16),

              _buildDropdown("Situation Matrimoniale", _situationMatrimoniale, _situations, (val) => setState(() => _situationMatrimoniale = val)),
              const SizedBox(height: 16),

              _buildTextField("Adresse (Lieu d'Habitation)", _lieuHabitationCtrl),
              const SizedBox(height: 16),

              _buildDropdown("Statut d'Activité", _statutActivite, _activites, (val) => setState(() => _statutActivite = val)),
              const SizedBox(height: 16),

              // --- PAROISSE ---
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: "Nom de sa paroisse",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: theme.cardTheme.color,
                ),
                value: _selectedParoisseId,
                items: _parishes.map<DropdownMenuItem<int>>((dynamic parish) {
                  return DropdownMenuItem<int>(
                    value: parish['id'],
                    child: Text(parish['name'] ?? 'Inconnu'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedParoisseId = val),
                validator: (val) => val == null ? 'Veuillez sélectionner une paroisse' : null,
              ),
              const SizedBox(height: 16),

              _buildTextField("Numéro de téléphone", _telephoneCtrl, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),  // --- MOUVEMENT ---
              SwitchListTile(
                title: const Text("Êtes-vous dans un mouvement ?"),
                value: _isInMovement,
                activeColor: const Color(0xFFC0A040),
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => setState(() => _isInMovement = val),
              ),
              if (_isInMovement)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                  child: _buildTextField("Précisez le mouvement", _mouvementCtrl),
                ),

              const Divider(),

              // --- 2. NOUVELLE LOGIQUE BAPTÊME ---
              SwitchListTile(
                title: const Text("Êtes-vous baptisé ?"),
                value: _isBaptise,
                activeColor: const Color(0xFFC0A040),
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => setState(() => _isBaptise = val),
              ),

              // On affiche le sélecteur de date SEULEMENT si baptisé est cochée
              if (_isBaptise)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _buildDateSelector("Date de Baptême", _dateBapteme, false),
                ),

              const SizedBox(height: 32),

              // --- BOUTON ENREGISTRER ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC0A040),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Enregistrer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }







  // Helper widgets for cleaner code
  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).cardTheme.color,
      ),
      validator: (val) => val == null || val.isEmpty ? 'Ce champ est requis' : null,
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).cardTheme.color,
      ),
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? 'Veuillez sélectionner une option' : null,
    );
  }

  Widget _buildDateSelector(String label, DateTime? date, bool isBirthDate) {
    return InkWell(
      onTap: () => _selectDate(context, isBirthDate),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(context).cardTheme.color,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Sélectionner une date',
          style: TextStyle(color: date != null ? Theme.of(context).colorScheme.onSurface : Colors.grey),
        ),
      ),
    );
  }





  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Validations manuelles
      if (_dateNaissance == null) {
        _showSnack("Veuillez choisir votre date de naissance", isError: true);
        return;
      }
      if (_sexe == null || _situationMatrimoniale == null || _statutActivite == null || _selectedParoisseId == null) {
        _showSnack("Veuillez remplir tous les champs de sélection", isError: true);
        return;
      }
      if (_isBaptise && _dateBapteme == null) {
        _showSnack("Veuillez indiquer la date de baptême", isError: true);
        return;
      }

      setState(() => _isLoading = true);

      try {
        final authService = Provider.of<AuthService>(context, listen: false);

        // --- 1. Récupération du NOM de la paroisse à partir de l'ID ---
        // On cherche dans la liste _parishes l'élément qui a l'ID sélectionné
        final selectedParishObj = _parishes.firstWhere(
                (p) => p['id'] == _selectedParoisseId,
            orElse: () => null
        );
        final String nomParoisseToSend = selectedParishObj != null ? selectedParishObj['name'] : "";
        // -------------------------------------------------------------


        // --- CORRECTION ICI : Conversion du Sexe ---
        // Le Backend veut "M" ou "F", pas "Masculin" ou "Féminin"
        String sexeToSend = _sexe == 'Masculin' ? 'M' : 'F';
        // -------------------------------------------


        // Formatage des dates (YYYY-MM-DD)
        final String dateNaissFormatted = DateFormat('yyyy-MM-dd').format(_dateNaissance!);

        final String? dateBaptemeFormatted = (_isBaptise && _dateBapteme != null)
            ? DateFormat('yyyy-MM-dd').format(_dateBapteme!)
            : null;

        // Appel de la fonction corrigée
        await authService.submitIdentification(
          nomPrenom: _nomPrenomsCtrl.text,
          dateNaissance: dateNaissFormatted,
          sexe: sexeToSend,
          situationMatrimoniale: _situationMatrimoniale!,
          adresse: _lieuHabitationCtrl.text, // Mappé vers 'adresse'
          statutActivite: _statutActivite!,
          nomParoisse: nomParoisseToSend,    // On envoie le NOM, pas l'ID
          telephone: _telephoneCtrl.text,
          estDansMouvement: _isInMovement,
          nomMouvement: _mouvementCtrl.text,
          estBaptise: _isBaptise,
          dateBapteme: dateBaptemeFormatted,
          photo: _imageFile, // On envoie le fichier image
        );

        if (mounted) {
          _showSnack("Fidèle enregistré avec succès !");
          Navigator.pop(context);
        }

      } catch (e) {
        if (mounted) {
          _showSnack("Erreur: ${e.toString().replaceAll('Exception:', '')}", isError: true);
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }




  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}



