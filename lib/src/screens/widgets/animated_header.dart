import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../app_themes.dart';

class AnimatedHeader extends StatefulWidget {
  final double height;
  final Widget? content;

  const AnimatedHeader({
    super.key,
    required this.height,
    this.content,
  });

  @override
  State<AnimatedHeader> createState() => _AnimatedHeaderState();
}

class _AnimatedHeaderState extends State<AnimatedHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.secondaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
                stops: [
                  0.0,
                  0.5 + (math.sin(_backgroundController.value * 2 * math.pi) * 0.2),
                  1.0,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Icône de l'église (à droite)
                Positioned(
                  right: -50,
                  top: 50,
                  child: Icon(
                    Icons.church_outlined,
                    size: 200,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),

                // Temple à gauche
                Positioned(
                  left: -50,
                  top: 150,
                  child: Transform.rotate(
                    angle: -math.pi / 8,
                    child: Icon(
                      Icons.account_balance_outlined,
                      size: 150,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),

                // Colombes statiques avec une branche
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Transform.scale(
                    scale: 1.2,
                    child: Icon(
                      Icons.eco_outlined,
                      size: 30,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 10,
                  child: Icon(
                    Icons.favorite_border,
                    size: 40,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),

                // Particules animées
                ...List.generate(15, (index) {
                  final offset = (index * 0.1 + _backgroundController.value) % 1.0;
                  final x = math.sin(offset * 2 * math.pi + index) * 0.3 + 0.5;
                  final y = (offset + index * 0.05) % 1.0;

                  return Positioned(
                    left: MediaQuery.of(context).size.width * x,
                    top: widget.height * y,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(

                        color: Colors.white.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                    ).animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 2000.ms, colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.8),
                      Colors.white.withOpacity(0.3),
                    ]),
                  );
                }),
                // Le contenu principal passé en paramètre
                if (widget.content != null) widget.content!,
              ],
            ),
          );
        },
      ),
    );
  }
}