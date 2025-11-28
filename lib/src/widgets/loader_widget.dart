import 'dart:async';
import 'package:flutter/material.dart';



// Widget simple pour le loader circulaire
class CustomCircularLoader extends StatelessWidget {
  final Color color;
  final double strokeWidth;
  final double size;

  const CustomCircularLoader({
    super.key,
    this.color = const Color(0xFF12D5D5), // Couleur Ocre par défaut
    this.strokeWidth = 3.0,
    this.size = 50.0, // Taille du loader
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          color: color,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}