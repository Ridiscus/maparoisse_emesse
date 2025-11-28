// lib/src/screens/password_reset/otp_verification_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maparoisse/src/services/auth_service.dart';
import 'package:maparoisse/src/app_themes.dart';
import 'package:maparoisse/src/widgets/loader_widget.dart';
import '../../../l10n/app_localizations.dart';
import 'reset_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({Key? key, required this.email}) : super(key: key);

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyOtp() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    final otp = _otpCtrl.text.trim();
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final success = await authService.verifyPasswordOTP(widget.email, otp);

      if (!mounted) return;

      if (success) {
        // Le code est bon, on va à l'écran de réinitialisation
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: widget.email, otp: otp),
        ));
      } else {
        _showError(l10n.otpIncorrectError);
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

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // ✅
      appBar: AppBar(
        title: Text(l10n.otpTitle, style: TextStyle(color: theme.colorScheme.onSurface)),
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
                    Icon(Icons.pin_outlined, size: 80, color: AppTheme.primaryColor),
                    const SizedBox(height: 20),
                    Text(
                      l10n.enterCode,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface // ✅
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.otpSentTo(widget.email),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6), // ✅
                          fontSize: 16
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ✅ CHAMP CODE CORRIGÉ
                    TextFormField(
                      controller: _otpCtrl,
                      style: TextStyle(color: theme.colorScheme.onSurface, letterSpacing: 5, fontWeight: FontWeight.bold), // Espacement pour le code
                      decoration: InputDecoration(
                        labelText: l10n.otpLabel,
                        prefixIcon: Icon(Icons.password, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                        filled: true,
                        fillColor: theme.cardTheme.color, // ✅
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return l10n.otpInvalidError;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(l10n.verifyButton, style: const TextStyle(color: Colors.white)),
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