import 'package:flutter/material.dart';

/// Ce service nous donne une clé globale pour naviguer
/// depuis n'importe où, même sans context.
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}