import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../widgets/modern_card.dart';
import '../../theme.dart';
import '../widgets/logo_widget.dart';

class PersonalInfoScreen extends StatefulWidget {
  final AuthService auth;

  const PersonalInfoScreen({Key? key, required this.auth}) : super(key: key);

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  // ✅ état par champ
  Map<String, bool> _editingField = {
    "name": false,
    "email": false,
    "phone": false,
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.auth.fullName ?? '');
    _emailController = TextEditingController(text: widget.auth.email ?? '');
    _phoneController = TextEditingController(text: widget.auth.phone ?? '');
  }

  void _toggleField(String key) {
    setState(() {
      _editingField[key] = !(_editingField[key] ?? false);
    });
  }

  Future<void> _saveField(String key) async {
    // TODO: sauvegarder la valeur modifiée dans Firestore / API
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _editingField[key] = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('$key mis à jour avec succès'),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.white, // 👈 force le back button en blanc
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          "Mes informations personnelles",
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
            crossAxisAlignment: CrossAxisAlignment.start, // 👈 aligne à gauche
            children: [
              const SizedBox(height: 20),
              const SanctaMissaLogo(),
              const SizedBox(height: 20),
              _buildPersonalInfo(widget.auth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfo(AuthService auth) {
    return ModernCard(
      child: Column(
        children: [
          _buildInfoField(
            keyName: "name",
            icon: Icons.person_outline,
            label: 'Nom complet',
            value: auth.fullName ?? 'Non défini',
            controller: _nameController,
          ),
          const Divider(height: 32),
          _buildInfoField(
            keyName: "email",
            icon: Icons.email_outlined,
            label: 'Email',
            value: auth.email ?? 'Non défini',
            controller: _emailController,
          ),
          const Divider(height: 32),
          _buildInfoField(
            keyName: "phone",
            icon: Icons.phone_outlined,
            label: 'Téléphone',
            value: auth.phone ?? 'Non défini',
            controller: _phoneController,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required String keyName,
    required IconData icon,
    required String label,
    required String value,
    TextEditingController? controller,
    bool isEditable = true,
  }) {
    final isEditing = _editingField[keyName] ?? false;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  )),
              const SizedBox(height: 4),
              if (isEditing && controller != null)
                TextField(
                  controller: controller,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                )
              else
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        if (isEditable)
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit_outlined,
                color: AppTheme.primaryColor),
            onPressed: () {
              if (isEditing) {
                _saveField(keyName);
              } else {
                _toggleField(keyName);
              }
            },
          )
      ],
    );
  }
}