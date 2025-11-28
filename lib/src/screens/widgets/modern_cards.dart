import 'package:flutter/material.dart';
import 'dart:ui';
import '../../app_themes.dart';

class ModernCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  /// ✅ Définir le style visuel
  final bool isGlassomorphism;
  final bool hasGlow;

  /// ✅ Couleur de fond
  final Color? backgroundColor;

  /// ✅ Ombres personnalisées
  final List<BoxShadow>? customShadows;

  /// ✅ Rayon des bords
  final double? borderRadius;

  /// ✅ Bordure (style + couleur + largeur)
  final BorderSide? border;

  /// ✅ Nouveaux paramètres pratiques
  final Color? color;
  final Color? borderColor;// alias pour backgroundColor
  final double? borderWidth; // utilisé si border != null
  final List<BoxShadow>? boxShadow; // alias pour customShadows

  const ModernCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.isGlassomorphism = false,
    this.hasGlow = false,
    this.backgroundColor,
    this.customShadows,
    this.borderRadius,
    this.border,
    this.color,
    this.borderColor,
    this.borderWidth,
    this.boxShadow,
  }) : super(key: key);


  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
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
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveMargin = widget.margin ?? EdgeInsets.zero;
    final effectivePadding = widget.padding ?? const EdgeInsets.all(20);
    final effectiveBorderRadius = widget.borderRadius ?? AppTheme.radiusMedium;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          margin: effectiveMargin,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: widget.onTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(effectiveBorderRadius),
                  boxShadow: widget.hasGlow
                      ? AppTheme.glowShadow
                      .map((shadow) => shadow.copyWith(
                    blurRadius: shadow.blurRadius * _elevationAnimation.value,
                  ))
                      .toList()
                      : widget.customShadows ??
                      AppTheme.cardShadow
                          .map((shadow) => shadow.copyWith(
                        blurRadius: shadow.blurRadius * _elevationAnimation.value,
                      ))
                          .toList(),
                ),
                child: widget.isGlassomorphism
                    ? _buildGlassCard(effectivePadding, effectiveBorderRadius)
                    : _buildRegularCard(effectivePadding, effectiveBorderRadius),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassCard(EdgeInsetsGeometry padding, double borderRadius) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.glassGradient,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          padding: padding,
          child: widget.child,
        ),
      ),
    );
  }

  Widget _buildRegularCard(EdgeInsetsGeometry padding, double borderRadius) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppTheme.cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: widget.border != null
            ? Border.fromBorderSide(widget.border!) // transforme BorderSide → Border
            : null,
        gradient: widget.backgroundColor == null ? AppTheme.cardGradient : null,
      ),
      padding: padding,
      child: widget.child,
    );
  }
}

// Widget spécialisé pour les cartes avec effet de parallaxe
class ParallaxCard extends StatelessWidget {
  final Widget child;
  final double offset;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ParallaxCard({
    Key? key,
    required this.child,
    this.offset = 0.0,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, offset * 0.3), // Effet de parallaxe subtil
      child: ModernCard(
        padding: padding,
        margin: margin,
        child: child,
      ),
    );
  }
}

// Widget pour les cartes avec gradient animé
class GradientCard extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const GradientCard({
    Key? key,
    required this.child,
    required this.colors,
    this.padding,
    this.margin,
    this.onTap,
  }) : super(key: key);

  @override
  State<GradientCard> createState() => _GradientCardState();
}

class _GradientCardState extends State<GradientCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            gradient: LinearGradient(
              colors: widget.colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                _animation.value * 0.3,
                0.5,
                1.0 - (_animation.value * 0.3),
              ],
            ),
            boxShadow: AppTheme.elevatedShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Padding(
                padding: widget.padding ?? const EdgeInsets.all(20),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Widget pour les métriques avec animation
class AnimatedMetricCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const AnimatedMetricCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedMetricCard> createState() => _AnimatedMetricCardState();
}

class _AnimatedMetricCardState extends State<AnimatedMetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      onTap: widget.onTap,
      hasGlow: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.color,
                    size: 32,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            widget.value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: widget.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.title,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}