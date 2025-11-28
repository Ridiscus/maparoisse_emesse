// Dans votre fichier sancta_missa_logo.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SanctaMissaLogo extends StatelessWidget {
  const SanctaMissaLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF172AFF),
                const Color(0xFF172AFF),
                const Color(0xFF172AFF),],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF172AFF),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: const Center(
            child: FaIcon(
              FontAwesomeIcons.church,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'E-Messe',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: const Color(0xFF172AFF),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}