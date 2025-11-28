import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../widgets/app_drawer.dart';
import '../widgets/modern_cards.dart';
import '../../app_themes.dart';
import '../../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'personal_info_screen.dart';
import 'security_screen.dart';
import 'help_support_screen.dart';
import 'notifications_screen.dart';
import 'package:maparoisse/providers/theme_provider.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _avatarController;
  late ScrollController _scrollController;

  late final List<ProfileMenuItem> _securityItems;
  late final List<ProfileMenuItem> _supportItems;
  late final TabController _tabController;

  double _scrollOffset = 0.0;
  bool _isExpanded = true;



  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this); // <-- AJOUTER CETTE LIGNE



     _securityItems = [
      ProfileMenuItem(
        icon: Icons.person_3_outlined,
        title: 'Informations personnelles',
        subtitle: 'Modifier vos données personnelles',
        color: AppTheme.primaryColor,
        onTap: (context, auth) {
          // On navigue vers notre nouvelle page
          Navigator.pushNamed(context, '/personalinfo');
        },
      ),
      ProfileMenuItem(
        icon: Icons.security_outlined,
        title: 'Sécurité & Confidentialité',
        subtitle: 'Gérer votre mot de passe et sécurité',
        color: AppTheme.successColor,
        onTap: (context, auth) {
          // On navigue vers notre nouvelle page
          Navigator.pushNamed(context, '/settings');
        },
      ),
    ];

     _supportItems = [
       ProfileMenuItem(
         icon: Icons.favorite_border,
         title: 'Paroisses favorites',
         subtitle: 'Gérer vos paroisses préférées',
         color: AppTheme.warningColor, // Une couleur qui se démarque
         onTap: (context, auth) {
           // On navigue vers notre nouvelle page
           Navigator.pushNamed(context, '/favorites');
         },
       ),
       ProfileMenuItem(
         icon: Icons.help_outline,
         title: 'Aide & Support',
         subtitle: 'FAQ, contact et assistance',
         color: AppTheme.secondaryColor,
         onTap: (context, auth) {
           // On navigue vers notre nouvelle page
           Navigator.pushNamed(context, '/help');
         },
       ),
      ProfileMenuItem(
        icon: Icons.notifications_outlined,
        title: 'Notifications',
        subtitle: 'Gérer vos préférences de notification',
        color: AppTheme.accentColor,
        onTap: (context, auth) {
          // On navigue vers notre nouvelle page
          Navigator.pushNamed(context, '/notification');
        },
      ),
      ProfileMenuItem(
        icon: Icons.dark_mode_outlined,
        title: 'Thème & Apparence',
        subtitle: 'Personnaliser l\'interface',
        color: AppTheme.infoColor,
        onTap: (context, auth) {
          _showThemeDialog(context); // ✅ Appel correct
        },
      ),
    ];





    _avatarController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);


    _scrollController = ScrollController()
      ..addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
      _isExpanded = _scrollOffset < 100;
    });
  }

  @override
  void dispose() {
    _avatarController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ... (le reste de ton code)

  // REMPLACEZ VOTRE MÉTHODE BUILD PAR CELLE-CI

  @override
  Widget build(BuildContext context) {
    // On définit la hauteur de notre en-tête fixe.
    // 280.0 correspond à la hauteur de votre ancien en-tête déplié.
    const double headerHeight = 360.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // On retire extendBodyBehindAppBar qui n'est plus utile avec un Stack
      // extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. LE CONTENU QUI DÉFILE (placé en premier, donc en dessous)
          SingleChildScrollView(
            // On garde le controller pour savoir quand on scrolle, si besoin pour d'autres effets
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            // Le Padding en haut est CRUCIAL : il crée un espace vide de la taille
            // de l'en-tête pour que le contenu ne commence pas caché derrière.
            child: Padding(
              padding: const EdgeInsets.only(top: headerHeight),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  _buildTabbedSections(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // 2. L'EN-TÊTE FIXE (placé en deuxième, donc au-dessus)
          Container(
            height: headerHeight,
            child: _buildProfileHeader(), // On réutilise votre superbe en-tête
          ),

          // 3. LE BOUTON MENU (placé en dernier, donc par-dessus tout)
          SafeArea(
            child: Container(
              height: 40.0,
              width: 40.0,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.cardShadow,
              ),
              child: IconButton(
                // 1. On change l'icône pour celle des réglages
                icon: const Icon(Icons.settings_rounded),

                onPressed: () {
                  // 2. On change l'action pour naviguer vers une nouvelle page
                  Navigator.pushNamed(context, '/parametres');
                },
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }





  // AJOUTEZ CETTE NOUVELLE FONCTION

  Widget _buildTabbedSections() {
    return Column(
      children: [
        // 1. LA BARRE D'ONGLETS
        TabBar(
          controller: _tabController,
          isScrollable: false, // On veut que les onglets prennent toute la largeur
          indicatorSize: TabBarIndicatorSize.label, // Indicateur juste sous le texte
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(
              icon: Icon(Icons.shield_outlined),
              text: 'Sécurité',
            ),
            Tab(
              icon: Icon(Icons.help_outline),
              text: 'Assistance',
            ),
          ],
        ),

        // 2. LE CONTENU DES ONGLETS
        // On utilise un SizedBox pour donner une hauteur fixe au TabBarView,
        // ce qui est nécessaire car il est dans un SingleChildScrollView.
        SizedBox(
          height: 380, // On garde la même hauteur que votre ancien widget horizontal
          child: TabBarView(
            controller: _tabController,
            children: [
              // Contenu de l'onglet "Sécurité"
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: ModernCard(
                  color: Theme.of(context).scaffoldBackgroundColor
.withOpacity(0.5),
                  borderColor: AppTheme.primaryColor.withOpacity(0.3),
                  child: Column(
                    children: _securityItems.map((item) => _buildMenuItem(item)).toList(),
                  ),
                ),
              ),

              // Contenu de l'onglet "Assistance"
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: ModernCard(
                  color: Theme.of(context).scaffoldBackgroundColor
.withOpacity(0.5),
                  borderColor: AppTheme.primaryColor.withOpacity(0.3),
                  child: Column(
                    children: _supportItems.map((item) => _buildMenuItem(item)).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }




  // COLLEZ CE NOUVEAU CODE À LA PLACE DE L'ANCIENNE FONCTION _buildProfileHeader

  // COLLEZ CE NOUVEAU CODE À LA PLACE DE L'ANCIENNE FONCTION _buildProfileHeader

  Widget _buildProfileHeader() {
    return Consumer<AuthService>(
      builder: (context, auth, child) {
        return Stack(
          children: [
            // 1. Le fond dégradé (inchangé)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                // On remplace 'gradient' par 'color' avec votre couleur bleue
                color: const Color(0xFF172AFF),
                boxShadow: [
                  // ...
                ],
              ),
            ),

            // 2. Les icônes décoratives (inchangées)
            Positioned(
              top: 60,
              right: -50,
              child: Icon(
                Icons.church_outlined,
                size: 200,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              child: Transform.rotate(
                angle: -0.2,
                child: Icon(
                  Icons.spa_outlined,
                  size: 100,
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
            ),

            // 3. Le contenu du profil (avatar, nom, etc.)
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ... L'avatar, le nom, et l'email ne changent pas ...
                    AnimatedBuilder(
                      animation: _avatarController,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.8),
                                Colors.white.withOpacity(0.3),
                              ],
                              transform: GradientRotation(
                                _avatarController.value * 2 * math.pi,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor:
                              AppTheme.primaryColor.withOpacity(0.1),
                              backgroundImage: auth.photoPath != null
                                  ? NetworkImage(auth.photoPath!)
                                  : null,
                              child: auth.photoPath == null
                                  ? Icon(
                                Icons.person,
                                size: 40,
                                color: AppTheme.primaryColor,
                              )
                                  : null,
                            ),

                          ),
                        );
                      },
                    ).animate().scale(duration: 1000.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            auth.fullName ?? 'Utilisateur',
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                auth.email ?? 'email@example.com',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. AJOUT : L'icône de déconnexion en bas à gauche
            Positioned(
              right: 16,
              top: 16,
              child: SafeArea( // SafeArea pour ne pas être sous la barre de navigation système
                child: IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  color: Colors.white.withOpacity(0.8),
                  iconSize: 28,
                  tooltip: 'Se déconnecter',
                  onPressed: _showLogoutDialog, // <-- On réutilise la même fonction !
                ),
              ),
            ),
          ],
        );
      },
    );
  }



  Widget _buildSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Sécurité & Confidentialité',
          icon: Icons.shield_outlined,
          color: AppTheme.successColor,
        ),

        const SizedBox(height: 16),

        ModernCard(
          color: Theme.of(context).scaffoldBackgroundColor
.withOpacity(0.5), // Rendu semi-transparent
          borderColor: AppTheme.primaryColor.withOpacity(0.3), // Bordure légère pour la délimitation
          borderWidth: 1.0,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          child: Column(
            children: _securityItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return Column(
                children: [
                  _buildMenuItem(item),
                  if (index < _securityItems.length - 1) ...[
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppTheme.dividerColor.withOpacity(0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              );
            }).toList(),
          ),
        ).animate()
            .fadeIn(delay: 200.ms, duration: 600.ms)
            .slideX(begin: -0.3, delay: 200.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Assistance & Préférences',
          icon: Icons.help_outline,
          color: AppTheme.secondaryColor,
        ),

        const SizedBox(height: 16),

        ModernCard(
          color: Theme.of(context).scaffoldBackgroundColor
.withOpacity(0.5), // Rendu semi-transparent
          borderColor: AppTheme.primaryColor.withOpacity(0.3), // Bordure légère pour la délimitation
          borderWidth: 1.0,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          child: Column(
            children: _supportItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return Column(
                children: [
                  _buildMenuItem(item),
                  if (index < _supportItems.length - 1) ...[
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppTheme.dividerColor.withOpacity(0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              );
            }).toList(),
          ),
        ).animate()
            .fadeIn(delay: 400.ms, duration: 600.ms)
            .slideX(begin: -0.3, delay: 400.ms, duration: 600.ms),
      ],
    );
  }



  Widget _buildHorizontalSections() {
    return SizedBox(
      height: 380, // Garder une hauteur fixe pour le défilement horizontal
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Important pour l'alignement
          children: [
            const SizedBox(width: 20),
            // Carte Sécurité & Confidentialité
            SizedBox(
              width: 280,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    title: 'Sécurité & Confidentialité',
                    icon: Icons.shield_outlined,
                    color: AppTheme.successColor,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ModernCard(
                      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                      borderColor: AppTheme.primaryColor.withOpacity(0.3),
                      borderWidth: 1.0,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      child: SingleChildScrollView( // Permet au contenu de la carte de défiler
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: _securityItems
                                .map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildMenuItem(item),
                            ))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Carte Assistance & Préférences
            SizedBox(
              width: 280,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    title: 'Assistance & Préférences',
                    icon: Icons.help_outline,
                    color: AppTheme.secondaryColor,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ModernCard(
                      color: Theme.of(context).scaffoldBackgroundColor
.withOpacity(0.5),
                      borderColor: AppTheme.primaryColor.withOpacity(0.3),

                      borderWidth: 1.0,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      child: SingleChildScrollView( // Permet au contenu de la carte de défiler
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: _supportItems
                                .map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildMenuItem(item),
                            ))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }




  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
        ),
      ],
    ).animate()
        .fadeIn(duration: 600.ms)
        .slideX(begin: -0.3, duration: 600.ms);
  }

  Widget _buildMenuItem(ProfileMenuItem item) {
    return Consumer<AuthService>(
      builder: (context, auth, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => item.onTap(context, auth),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: item.color.withOpacity(0.2)),
                    ),
                    child: Icon(
                      item.icon,
                      color: item.color,
                      size: 24,
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .scale(duration: 3000.ms, begin: const Offset(0.95, 0.95)),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: item.color,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  void _showLogoutDialog() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        elevation: 20,
        shadowColor: Colors.black.withOpacity(0.3),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: AppTheme.errorColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Déconnexion',
                style: GoogleFonts.cormorantGaramond(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Êtes-vous sûr de vouloir vous déconnecter ?',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.warningColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.warningColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Vos données locales seront conservées',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.warningColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            child: Text(
              'Annuler',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.errorColor,
                  AppTheme.errorColor.darken(),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Se déconnecter',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ).animate()
          .scale(duration: 300.ms, curve: Curves.elasticOut)
          .fadeIn(duration: 300.ms),
    );

    if (shouldLogout == true && context.mounted) {
      final auth = Provider.of<AuthService>(context, listen: false);

      // Animation de fermeture
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black54,
                Colors.black87,
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Colors.white,
                ),
                SizedBox(height: 16),
                Text(
                  'Déconnexion en cours...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ).animate()
            .fadeIn(duration: 200.ms),
      );

      await Future.delayed(const Duration(milliseconds: 1500));
      await auth.logout();

      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.palette_outlined,
                color: AppTheme.infoColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Thème & Apparence',
              style: GoogleFonts.cormorantGaramond(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // On vérifie le thème actuel pour savoir quelle option est sélectionnée
                _buildThemeOption(
                  'Clair',
                  Icons.light_mode,
                  themeProvider.themeMode == ThemeMode.light,
                      () => themeProvider.setThemeMode(ThemeMode.light), // Action au clic
                ),
                const SizedBox(height: 12),
                _buildThemeOption(
                  'Sombre',
                  Icons.dark_mode,
                  themeProvider.themeMode == ThemeMode.dark,
                      () => themeProvider.setThemeMode(ThemeMode.dark),
                ),
                const SizedBox(height: 12),
                _buildThemeOption(
                  'Automatique',
                  Icons.auto_mode,
                  themeProvider.themeMode == ThemeMode.system,
                      () => themeProvider.setThemeMode(ThemeMode.system),
                ),
              ],
            ),
          ).animate()
              .scale(duration: 300.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 300.ms);
        },
        ),
    );
  }

  Widget _buildThemeOption(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: AppTheme.primaryColor.withOpacity(0.3)) : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primaryColor : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: isSelected ? AppTheme.primaryColor : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? Icon(
          Icons.check_circle,
          color: AppTheme.primaryColor,
        )
            : null,
        onTap: () {
          onTap(); // On exécute l'action pour changer le thème
          Navigator.of(context).pop(); // On ferme le dialogue
        },
      ),
    );
  }
}

// Classe pour les éléments de menu du profil
class ProfileMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Function(BuildContext context, AuthService auth) onTap;

  ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
