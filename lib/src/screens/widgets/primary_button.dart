import 'package:flutter/material.dart';
import '../../theme.dart';

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
  success,
  error,
  warning,
}

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final ButtonType type;
  final Size? minimumSize;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool expanded;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.minimumSize,
    this.padding,
    this.borderRadius,
    this.expanded = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case ButtonType.primary:
        return AppTheme.primaryColor;
      case ButtonType.secondary:
        return AppTheme.secondaryColor;
      case ButtonType.success:
        return AppTheme.successColor;
      case ButtonType.error:
        return AppTheme.errorColor;
      case ButtonType.warning:
        return AppTheme.warningColor;
      case ButtonType.outline:
      case ButtonType.text:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor() {
    switch (widget.type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.success:
      case ButtonType.error:
        return Colors.white;
      case ButtonType.warning:
        return AppTheme.textPrimary;
      case ButtonType.outline:
      case ButtonType.text:
        return AppTheme.primaryColor;
    }
  }

  BorderSide? _getBorderSide() {
    switch (widget.type) {
      case ButtonType.outline:
        return BorderSide(color: AppTheme.primaryColor, width: 1.5);
      default:
        return null;
    }
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getForegroundColor()),
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        // mainAxisSize: MainAxisSize.min, // Expanded force la Row à prendre toute la largeur, donc on peut enlever ça.
        mainAxisAlignment: MainAxisAlignment.center, // Pour centrer le contenu dans le bouton
        children: [
          Icon(widget.icon, size: 20),
          const SizedBox(width: 8),
          // LA SOLUTION : On utilise Expanded pour que le texte gère l'espace intelligemment
          Expanded(
            child: Text(
              widget.text,
              // Ces deux lignes sont optionnelles mais recommandées pour un joli rendu :
              overflow: TextOverflow.ellipsis, // Coupe le texte avec "..." s'il est trop long
              maxLines: 1,                    // S'assure que le texte reste sur une seule ligne
            ),
          ),
        ],
      );
    }

    return Text(widget.text);
  }

  @override
  Widget build(BuildContext context) {
    Widget button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Container(
        width: widget.expanded ? double.infinity : null,
        child: ElevatedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _getBackgroundColor(),
            foregroundColor: _getForegroundColor(),
            elevation: widget.type == ButtonType.text ? 0 : 2,
            shadowColor: widget.type == ButtonType.text
                ? Colors.transparent
                : _getBackgroundColor().withOpacity(0.3),
            side: _getBorderSide(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
            ),
            padding: widget.padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            minimumSize: widget.minimumSize ?? const Size(120, 48),
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ).copyWith(
            elevation: MaterialStateProperty.resolveWith<double>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) return 0;
                if (states.contains(MaterialState.pressed)) return 1;
                if (widget.type == ButtonType.text) return 0;
                return 2;
              },
            ),
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) {
                  return _getBackgroundColor().withOpacity(0.5);
                }
                if (states.contains(MaterialState.pressed)) {
                  return _getBackgroundColor().withOpacity(0.9);
                }
                return _getBackgroundColor();
              },
            ),
          ),
          child: _buildContent(),
        ),
      ),
    );

    return GestureDetector(
      onTapDown: widget.onPressed != null && !widget.isLoading ? _onTapDown : null,
      onTapUp: widget.onPressed != null && !widget.isLoading ? _onTapUp : null,
      onTapCancel: widget.onPressed != null && !widget.isLoading ? _onTapCancel : null,
      child: button,
    );
  }
}

// Boutons spécialisés avec styles prédéfinis
class SuccessButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;

  const SuccessButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      type: ButtonType.success,
      expanded: expanded,
    );
  }
}

class ErrorButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;

  const ErrorButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      type: ButtonType.error,
      expanded: expanded,
    );
  }
}

class OutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;

  const OutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      type: ButtonType.outline,
      expanded: expanded,
    );
  }
}