import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    widget.focusNode?.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
    });
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    _hasError = widget.validator?.call(widget.controller?.text ?? '') != null;
    final theme = Theme.of(context); // Raccourci thème

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label!,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: _hasError
                    ? theme.colorScheme.error
                    : _isFocused
                    ? theme.primaryColor
                // ✅ CORRECTION : Texte gris clair en mode sombre
                    : theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isFocused
                ? [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            validator: widget.validator,
            // ✅ CORRECTION : Style du texte saisi (Blanc en sombre)
            style: TextStyle(color: theme.colorScheme.onSurface),
            onChanged: (text) {
              setState(() {
                _hasError = widget.validator?.call(text) != null;
              });
              widget.onChanged?.call(text);
            },
            onTap: widget.onTap,
            readOnly: widget.readOnly,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            enabled: widget.enabled,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onSubmitted,

            decoration: InputDecoration(
              hintText: widget.hint,
              // ✅ CORRECTION : Hint gris
              hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
              helperText: widget.helperText,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                widget.prefixIcon,
                // ✅ CORRECTION : Icône dynamique
                color: _isFocused
                    ? theme.primaryColor
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              )
                  : null,
              suffixIcon: widget.suffixIcon,
              filled: true,
              // ✅ CORRECTION MAJEURE : Fond dynamique
              // Si focus : Fond carte (un peu plus clair que le fond sombre)
              // Sinon : Fond input du thème
              fillColor: _isFocused
                  ? theme.cardTheme.color
                  : (theme.inputDecorationTheme.fillColor ?? theme.scaffoldBackgroundColor),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                // ✅ CORRECTION : Bordure grise adaptée au thème
                borderSide: BorderSide(
                  color: _hasError ? theme.colorScheme.error : theme.dividerColor,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.errorColor,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.errorColor,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}