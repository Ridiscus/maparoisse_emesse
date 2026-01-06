import 'package:flutter/material.dart';
import 'package:maparoisse/src/screens/auth/complete_profile_screen.dart';
import 'package:maparoisse/src/screens/home/payment_success_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/dashboard_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/payment_screen.dart';
import 'screens/home/requests_screen.dart';
import 'screens/home/profile_screen.dart';
import 'screens/home/requests_list_screen.dart';
import 'screens/home/favorite_parishes_screen.dart';
import 'screens/home/history_screen.dart';
import 'screens/home/help_support_screen.dart';
import 'screens/home/notifications_screen.dart';
import 'screens/home/security_screen.dart';
import 'screens/home/personal_info_screen.dart';
import 'services/auth_service.dart';
import 'screens/home/settings_screen.dart';



final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const SplashScreen(),
  '/register': (context) => const RegisterScreen(),
  '/login': (context) => const LoginScreen(),
  '/requests': (context) => const RequestsScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/favorites': (context) => const FavoriteParishesScreen(),
  '/complete_profile': (context) => const CompleteProfileScreen(),
  '/parametres': (context) => const SettingsScreen(),
  '/settings': (context) => const SecurityScreen(),
  '/notification': (context) => const NotificationsScreen(),
  '/payment-success': (context) => const PaymentSuccessScreen(),
  '/personalinfo': (context) => PersonalInfoScreen(
    auth: AuthService(), // ou Provider.of<AuthService>(context, listen: false)
  ),
  '/help': (context) => const HelpSupportScreen(),
  '/history': (context) => const HistoryScreen(),
  '/requests-list': (context) => const RequestsListScreen(),
  '/dashboard': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final initialIndex = args?['initialIndex'] as int? ?? 0;

    return DashboardScreenWithIndex(
      key: DashboardScreenWithIndex.globalKey,
      initialIndex: initialIndex,
    );
  },
  '/payment': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return PaymentPage(
      typeIntention: args['typeIntention'] ?? "Intention",
      montant: (args['montant'] ?? 0.0).toDouble(),
      frais: (args['frais'] ?? 0.0).toDouble(),
      total: (args['total'] ?? 0.0).toDouble(),
      reference: args['reference'] ?? "REF-${DateTime.now().millisecondsSinceEpoch}",

      // --- AJOUT IMPORTANT ---
      messeId: (args['messeId'] ?? 0) as int,
      // --- FIN AJOUT ---
    );
  },

};