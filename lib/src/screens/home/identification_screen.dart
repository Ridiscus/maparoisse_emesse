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


  final  _paroisseBaptemeCtrl = TextEditingController();


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
  int? _existingParoissienId;



  @override
  void initState() {
    super.initState();
    _prefillUserData(); // Remplit juste Nom/Tel/Photo (local)
    _loadParishes();    // Charge la liste des paroisses

    // ✅ NOUVEAU : On va chercher les détails complets sur le serveur
    // On met un petit délai pour être sûr que l'AuthService est prêt
    Future.delayed(Duration.zero, () {
      _fetchAndFillData();
    });
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






  Future<void> _fetchAndFillData() async {
    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      if (auth.id == null) return;

      if (_parishes.isEmpty) {
        await _loadParishes();
      }

      final data = await auth.getParoissien(auth.id!);

      if (data != null && mounted) {

        // --- 🕵️‍♂️ DEBUG : REGARDE ÇA DANS TA CONSOLE ---
        print("--- DEBUG DATA ---");
        print("Mouvement (Brut): ${data['est_dans_mouvement']} (Type: ${data['est_dans_mouvement'].runtimeType})");
        print("Baptisé (Brut): ${data['est_baptise']} (Type: ${data['est_baptise'].runtimeType})");
        print("------------------");
        // ----------------------------------------------

        setState(() {
          _existingParoissienId = data['id'];

          // Champs Texte
          if (data['nom_prenom'] != null) _nomPrenomsCtrl.text = data['nom_prenom'];
          if (data['adresse'] != null) _lieuHabitationCtrl.text = data['adresse'];
          if (data['telephone'] != null) _telephoneCtrl.text = data['telephone'];
          if (data['nom_mouvement'] != null) _mouvementCtrl.text = data['nom_mouvement'];
          if (data['nom_mouvement'] != null) _mouvementCtrl.text = data['nom_mouvement'];

          // ✅ REMPLISSAGE DU NOUVEAU CHAMP
          if (data['nom_paroisse_bapteme'] != null) {
            _paroisseBaptemeCtrl.text = data['nom_paroisse_bapteme'];
          }



          // Sexe
          if (data['sexe'] != null) {
            String val = data['sexe'].toString().trim();
            if (val == 'M') _sexe = 'Masculin';
            else if (val == 'F') _sexe = 'Féminin';
            else if (_sexes.contains(val)) _sexe = val;
          }

          // Dropdowns
          if (data['situation_matrimoniale'] != null && _situations.contains(data['situation_matrimoniale'])) {
            _situationMatrimoniale = data['situation_matrimoniale'];
          }
          if (data['statut_activite'] != null && _activites.contains(data['statut_activite'])) {
            _statutActivite = data['statut_activite'];
          }

          // ✅ SWITCHES : On utilise la version SUPER ROBUSTE
          _isInMovement = _parseBool(data['est_dans_mouvement']);
          _isBaptise = _parseBool(data['est_baptise']);

          // Dates
          if (data['date_naissance'] != null) {
            _dateNaissance = DateTime.tryParse(data['date_naissance']);
          }
          if (data['date_bapteme'] != null) {
            _dateBapteme = DateTime.tryParse(data['date_bapteme']);
          }

          // Paroisse
          if (data['nom_paroisse'] != null && _parishes.isNotEmpty) {
            String apiParishName = data['nom_paroisse'].toString().trim().toLowerCase();
            try {
              final parishObj = _parishes.firstWhere(
                    (p) => p['name'].toString().trim().toLowerCase() == apiParishName,
              );
              _selectedParoisseId = parishObj['id'];
            } catch (e) {
              print("Paroisse non trouvée pour : $apiParishName");
            }
          }
        });
      }
    } catch (e) {
      print("Erreur chargement: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }






  // Fonction ultra-robuste pour convertir n'importe quoi en VRAI/FAUX
  bool _parseBool(dynamic value) {
    if (value == null) return false;

    // Cas booléen direct
    if (value is bool) return value;

    // Cas entier (1 = vrai, 0 = faux)
    if (value is int) return value == 1;

    // Cas String
    if (value is String) {
      String lower = value.toLowerCase().trim();
      return lower == "1" || lower == "true" || lower == "yes" || lower == "on";
    }

    return false;
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



  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Validations manuelles (Dates, Dropdowns...)
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

        // 1. Récupération du NOM de la paroisse
        final selectedParishObj = _parishes.firstWhere(
                (p) => p['id'] == _selectedParoisseId,
            orElse: () => null
        );
        final String nomParoisseToSend = selectedParishObj != null ? selectedParishObj['name'] : "";

        // 2. Conversion du Sexe
        String sexeToSend = _sexe == 'Masculin' ? 'M' : 'F';

        // 3. Formatage des dates
        final String dateNaissFormatted = DateFormat('yyyy-MM-dd').format(_dateNaissance!);
        final String? dateBaptemeFormatted = (_isBaptise && _dateBapteme != null)
            ? DateFormat('yyyy-MM-dd').format(_dateBapteme!)
            : null;

        // ✅ 4. LE CHOIX CRUCIAL : UPDATE OU CREATE ?
        if (_existingParoissienId != null) {

          print("⚠️ TENTATIVE UPDATE");
          print("ID Paroissien à modifier : $_existingParoissienId");
          print("User ID connecté (AuthService) : ${authService.id}");


    // CAS A : UPDATE (On a déjà un ID, donc on modifie)
          final auth = Provider.of<AuthService>(context, listen: false);
          await authService.updateParoissien(
            id: auth.id!, // On passe l'ID récupéré
            nomPrenom: _nomPrenomsCtrl.text,
            dateNaissance: dateNaissFormatted,
            sexe: sexeToSend,
            situationMatrimoniale: _situationMatrimoniale!,
            adresse: _lieuHabitationCtrl.text,
            statutActivite: _statutActivite!,
            nomParoisse: nomParoisseToSend,
            telephone: _telephoneCtrl.text,
            estDansMouvement: _isInMovement,
            nomMouvement: _mouvementCtrl.text,
            estBaptise: _isBaptise,
            dateBapteme: dateBaptemeFormatted,
            photo: _imageFile, // Optionnel
          );

          if (mounted) _showSnack("Fiche mise à jour avec succès !");

        } else {

          // CAS B : CREATE (Première fois, pas d'ID)
          await authService.submitIdentification(
            nomPrenom: _nomPrenomsCtrl.text,
            dateNaissance: dateNaissFormatted,
            sexe: sexeToSend,
            situationMatrimoniale: _situationMatrimoniale!,
            adresse: _lieuHabitationCtrl.text,
            statutActivite: _statutActivite!,
            nomParoisse: nomParoisseToSend,
            telephone: _telephoneCtrl.text,
            estDansMouvement: _isInMovement,
            nomMouvement: _mouvementCtrl.text,
            estBaptise: _isBaptise,
            dateBapteme: dateBaptemeFormatted,
            photo: _imageFile,
          );

          if (mounted) _showSnack("Fidèle enregistré avec succès !");
        }

        if (mounted) {
          // On attend un petit peu pour que l'utilisateur lise le message
          await Future.delayed(const Duration(seconds: 1));
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

                    // ✅ 1. L'ÉTIQUETTE BAPTISÉ
                    // On vérifie si l'info est DÉJÀ enregistrée dans AuthService
                    if (Provider.of<AuthService>(context).isBaptized)
                      Positioned(
                        top: -5,
                        left: -5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.water_drop_rounded, color: Colors.white, size: 10),
                              SizedBox(width: 4),
                              Text(
                                "BAPTISÉ",
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
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

              // On affiche les champs SEULEMENT si baptisé est coché
              if (_isBaptise) ...[ // Utilise ...[ ] pour grouper plusieurs widgets
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _buildDateSelector("Date de Baptême", _dateBapteme, false),
                ),

                // ✅ NOUVEAU CHAMP : Paroisse de baptême
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: _buildTextField("Paroisse de baptême", _paroisseBaptemeCtrl),
                ),
              ],

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



