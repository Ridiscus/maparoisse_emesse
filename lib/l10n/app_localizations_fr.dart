// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'E-MESSE';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsAccountSectionTitle => 'Compte';

  @override
  String get settingsEditProfile => 'Modifier le profil';

  @override
  String get settingsChangePassword => 'Changer le mot de passe';

  @override
  String get settingsNotificationsSectionTitle => 'Notifications';

  @override
  String get settingsSmsNotifications => 'SMS';

  @override
  String get settingsEmailNotifications => 'Email';

  @override
  String get settingsPushNotifications => 'Notifications Push';

  @override
  String get settingsGeneralPrefsSectionTitle => 'Préférences Générales';

  @override
  String get settingsAppLanguage => 'Langue de l\'application';

  @override
  String get settingsFontSize => 'Taille de la police';

  @override
  String get settingsVoiceReader => 'Lecteur vocal';

  @override
  String get settingsAppTheme => 'Thème de l\'application';

  @override
  String get settingsFaqHelp => 'FAQ / Aide';

  @override
  String get settingsTutorials => 'Tutoriels vidéo';

  @override
  String get settingsPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get settingsLogoutButton => 'Se déconnecter';

  @override
  String get settingsCurrentLanguageFrench => 'Français';

  @override
  String get settingsCurrentLanguageEnglish => 'English';

  @override
  String get languageSelectorTitle => 'Choisir une langue';

  @override
  String get languageChangedSuccess => 'Langue changée avec succès !';

  @override
  String get drawerLogoutTitle => 'Déconnexion';

  @override
  String get drawerLogoutMessage =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get drawerLogoutCancel => 'Annuler';

  @override
  String get drawerLogoutConfirm => 'Se déconnecter';

  @override
  String get myRequests => 'Mes demandes';

  @override
  String get noRequests => 'Aucune demande ne correspond à ce statut.';

  @override
  String get emptyRequestsMessage =>
      'Vous n\'avez pas encore fait de demande.\nCommencez par créer votre première demande.';

  @override
  String get makeRequest => 'Faire une demande';

  @override
  String get featureUnavailable => 'Fonctionnalité à venir !';

  @override
  String get loadingLabel => 'Chargement...';

  @override
  String get errorLabel => 'Erreur';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get loginTitle => 'Se connecter';

  @override
  String get registerTitle => 'Inscription';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get usernameLabel => 'Nom d\'utilisateur';

  @override
  String get fullNameLabel => 'Nom complet';

  @override
  String get phoneLabel => 'Numéro de téléphone';

  @override
  String get civiliteLabel => 'Civilité';

  @override
  String get confirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get oldPasswordLabel => 'Ancien mot de passe';

  @override
  String get newPasswordLabel => 'Nouveau mot de passe';

  @override
  String get requiredField => 'Champ requis';

  @override
  String get invalidEmail => 'Email invalide';

  @override
  String get passwordTooShort => 'Au moins 8 caractères requis.';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passwordMustBeDifferent => 'Doit être différent de l\'ancien';

  @override
  String homeWelcome(String userName) {
    return 'Bienvenue, $userName !';
  }

  @override
  String get homeGreeting => 'Que la paix soit avec vous.';

  @override
  String get homeNextMassesTitle => 'Vos prochaines Messes';

  @override
  String get homeLocationTitle => 'Votre Position Actuelle';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Système';

  @override
  String get fontSizeSmall => 'Petite';

  @override
  String get fontSizeMedium => 'Moyenne';

  @override
  String get fontSizeLarge => 'Grande';

  @override
  String get loginHintEmailOrUser => 'E-mail ou Nom d\'utilisateur';

  @override
  String get loginHintPassword => 'Mot de passe';

  @override
  String get loginBtnLabel => 'Se connecter';

  @override
  String get loginCreateAccount => 'Créer un compte';

  @override
  String get loginForgotPassword => 'Mot de passe oublié ?';

  @override
  String get loginOrContinue => 'Ou continuer avec';

  @override
  String get loginValEmailEmpty =>
      'Veuillez saisir votre email ou nom d\'utilisateur';

  @override
  String get loginValEmailShort => 'Doit contenir au moins 3 caractères';

  @override
  String get loginValPassEmpty => 'Veuillez saisir votre mot de passe';

  @override
  String get loginValPassShort =>
      'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get loginSuccess => 'Connexion réussie !';

  @override
  String get loginErrorCredentials =>
      'Identifiants incorrects. Veuillez vérifier.';

  @override
  String get loginErrorGoogleToken =>
      'Impossible de récupérer le jeton d\'authentification Google.';

  @override
  String loginSuccessGoogle(String name) {
    return 'Connecté : $name !';
  }

  @override
  String get loginErrorGoogleLink =>
      'Impossible de lier ce compte Google. Vérifiez s\'il est déjà utilisé.';

  @override
  String get loginErrorGoogleGeneric =>
      'Une erreur est survenue lors de la connexion avec Google.';

  @override
  String get registerSubtitle => 'Rejoignez notre communauté';

  @override
  String get registerStep3Title => 'Photo de profil';

  @override
  String get registerCivilityLabel => 'Civilité';

  @override
  String get registerCivilityMr => 'Monsieur';

  @override
  String get registerCivilityMrs => 'Madame';

  @override
  String get registerCivilityMs => 'Mademoiselle';

  @override
  String get registerCivilityFather => 'Père';

  @override
  String get registerCivilitySister => 'Soeur';

  @override
  String get registerCivilityBrother => 'Frère';

  @override
  String get registerLabelName => 'Nom';

  @override
  String get registerLabelFirstName => 'Prénom';

  @override
  String get registerLabelParish => 'Paroisse (Optionnel)';

  @override
  String get registerHintParishSearch => 'Rechercher une paroisse...';

  @override
  String get registerImgChoose => 'Choisir une photo';

  @override
  String get registerImgChange => 'Changer la photo';

  @override
  String get registerImgDelete => 'Supprimer';

  @override
  String get registerImgSourceTitle => 'Choisir une source';

  @override
  String get registerImgCamera => 'Appareil photo';

  @override
  String get registerImgGallery => 'Galerie';

  @override
  String get registerBtnNext => 'Suivant';

  @override
  String get registerBtnPrev => 'Précédent';

  @override
  String get registerBtnSubmit => 'S\'inscrire';

  @override
  String get registerAlreadyAccount => 'Déjà un compte ?';

  @override
  String get registerBtnLogin => 'Se connecter';

  @override
  String get valReqName => 'Veuillez entrer votre nom';

  @override
  String get valReqFirstName => 'Veuillez entrer votre prénom';

  @override
  String get valReqEmail => 'Veuillez entrer un e-mail valide';

  @override
  String get valReqPhone => 'Veuillez entrer votre téléphone';

  @override
  String get valInvalidPhone => 'Numéro invalide (10 chiffres requis)';

  @override
  String get valReqUsername => 'Veuillez choisir un nom d\'utilisateur';

  @override
  String get valShortUsername => '3 caractères minimum';

  @override
  String get valReqPass => 'Mot de passe requis';

  @override
  String get valShortPass => '8 caractères minimum';

  @override
  String get valPassMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get errRegisterFixErrors =>
      'Veuillez corriger les erreurs avant de continuer.';

  @override
  String get errRegisterUsernameTaken => 'Ce nom d\'utilisateur est déjà pris.';

  @override
  String get errRegisterEmailTaken => 'Cet email est déjà utilisé.';

  @override
  String get errRegisterGeneric =>
      'Une erreur est survenue lors de l\'inscription.';

  @override
  String get successRegister => 'Compte créé avec succès ! Connectez-vous.';

  @override
  String get errImagePick => 'Erreur lors de la sélection de l\'image';

  @override
  String get errCivilityRequired => 'Veuillez sélectionner votre civilité';

  @override
  String get successRegisterRedirect => 'Inscription réussie ! Redirection...';

  @override
  String get registerStep1Title => 'Informations personnelles';

  @override
  String get registerStep1Subtitle =>
      'Veuillez renseigner vos informations personnelles';

  @override
  String get registerLabelCivility => 'Civilité *';

  @override
  String get registerGenderMale => 'Homme';

  @override
  String get registerGenderFemale => 'Femme';

  @override
  String get registerLabelFullName => 'Nom complet';

  @override
  String get registerHintFullName => 'Ex: Jean Dupont';

  @override
  String get registerLabelUsername => 'Nom d\'utilisateur';

  @override
  String get registerHintUsername => 'Ex: jean_dupont';

  @override
  String get registerLabelEmail => 'Adresse email';

  @override
  String get registerHintEmail => 'Ex: jean@example.com';

  @override
  String get registerLabelPhone => 'Numéro de téléphone';

  @override
  String get registerHintPhone => 'Ex: +33 6 12 34 56 78';

  @override
  String get registerStep2Title => 'Sécurité du compte';

  @override
  String get registerStep2Subtitle =>
      'Choisissez un mot de passe sécurisé pour votre compte';

  @override
  String get registerLabelPassword => 'Mot de passe';

  @override
  String get registerHintPassword => 'Minimum 8 caractères';

  @override
  String get registerLabelConfirmPass => 'Confirmer le mot de passe';

  @override
  String get registerHintConfirmPass => 'Ressaisissez votre mot de passe';

  @override
  String get registerPassReqTitle => 'Exigences du mot de passe';

  @override
  String get registerPassReqLen => 'Au moins 8 caractères';

  @override
  String get registerPassReqMix => 'Mélange de lettres et chiffres recommandé';

  @override
  String get registerPassReqCommon => 'Évitez les mots de passe courants';

  @override
  String get valNameEmpty => 'Veuillez saisir votre nom complet';

  @override
  String get valNameShort => 'Le nom doit contenir au moins 2 caractères';

  @override
  String get valUsernameEmpty => 'Veuillez choisir un nom d\'utilisateur';

  @override
  String get valUsernameShort =>
      'Le nom d\'utilisateur doit contenir au moins 3 caractères';

  @override
  String get valUsernameInvalid =>
      'Seules les lettres, chiffres et _ sont autorisés';

  @override
  String get valEmailEmpty => 'Veuillez saisir votre email';

  @override
  String get valEmailInvalid => 'Veuillez saisir un email valide';

  @override
  String get valPhoneEmpty => 'Veuillez saisir votre numéro de téléphone';

  @override
  String get valPhonePrefix =>
      'Le numéro doit commencer par l\'indicatif (ex: +225)';

  @override
  String get valPhoneShort => 'Numéro de téléphone trop court';

  @override
  String get valPhoneFormat => 'Format invalide (seulement + et chiffres)';

  @override
  String get valPassEmpty => 'Veuillez saisir un mot de passe';

  @override
  String get valPassShort =>
      'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get valConfirmPassEmpty => 'Veuillez confirmer votre mot de passe';

  @override
  String get homeHello => 'Bonjour';

  @override
  String get homeLocationUnknown => 'Localisation inconnue';

  @override
  String get homeLocationDisabled => 'Localisation désactivée';

  @override
  String get homeLocationDenied => 'Permission refusée';

  @override
  String get homeLocationBlocked => 'Permission bloquée';

  @override
  String get homeLocationNotFound => 'Adresse non trouvée';

  @override
  String get homeLocationPosNotFound => 'Position introuvable';

  @override
  String get homeLocationError => 'Erreur localisation';

  @override
  String get homeMapError => 'Impossible d\'ouvrir l\'application de carte.';

  @override
  String get homeStatusTitle => 'Mon statut des messes';

  @override
  String get homeStatusPending => 'En attente';

  @override
  String get homeStatusCelebrated => 'Célébrées';

  @override
  String get homeStatusUpcoming => 'À venir';

  @override
  String get homeQuickActionsTitle => 'Actions rapides';

  @override
  String get homeBtnRequest => 'Faire une demande';

  @override
  String get homeBtnEvents => 'Voir événements';

  @override
  String get homeBtnParishes => 'Paroisses';

  @override
  String get homeUpcomingSectionTitle => 'Prochaines messes';

  @override
  String get homeNoUpcoming => 'Aucune messe confirmée à venir.';

  @override
  String get homeParishSectionTitle => 'Paroisses à proximité';

  @override
  String get online => 'En ligne';

  @override
  String welcomeUser(Object userName) {
    return 'Bienvenue, $userName !';
  }

  @override
  String get peaceMessage => 'Que la paix soit avec vous.';

  @override
  String get settings => 'Paramètres';

  @override
  String get notifications => 'Notifications';

  @override
  String get status_waiting_payment => 'En att. Paiement';

  @override
  String get status_waiting_confirmation => 'En att. Confirmation';

  @override
  String get status_confirmed => 'Confirmé';

  @override
  String get status_celebrated => 'Célébré';

  @override
  String get status_cancelled => 'Annulé';

  @override
  String get modal_pending => 'Messes en attente';

  @override
  String get modal_celebrated => 'Messes célébrées';

  @override
  String get modal_upcoming => 'Messes à venir';

  @override
  String get editProfileTitle => 'Modifier le profil';

  @override
  String get editProfileSaveButton => 'Enregistrer les modifications';

  @override
  String get editProfileLogoutButton => 'Se déconnecter';

  @override
  String get editProfileNameLabel => 'Nom complet';

  @override
  String get editProfileEmailLabel => 'Adresse e-mail';

  @override
  String get editProfilePhoneLabel => 'Numéro de téléphone';

  @override
  String get editProfileCiviliteLabel => 'Civilité';

  @override
  String get editProfileCiviliteM => 'M.';

  @override
  String get editProfileCiviliteMme => 'Mme';

  @override
  String get editProfileCiviliteMlle => 'Mlle';

  @override
  String get editProfileNameError => 'Veuillez saisir votre nom';

  @override
  String get editProfilePhoneError => 'Veuillez saisir votre numéro';

  @override
  String get editProfileCiviliteError => 'Veuillez sélectionner une civilité';

  @override
  String get editProfileImageError =>
      'Erreur lors de la sélection de l\'image.';

  @override
  String get editProfileUpdateSuccess => 'Profil mis à jour avec succès !';

  @override
  String get editProfileUpdateError =>
      'Erreur lors de la mise à jour du profil.';

  @override
  String get editProfileUnexpectedError =>
      'Une erreur inattendue est survenue.';

  @override
  String get logoutDialogTitle => 'Déconnexion';

  @override
  String get logoutDialogMessage => 'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get logoutDialogCancel => 'Annuler';

  @override
  String get logoutDialogConfirm => 'Se déconnecter';

  @override
  String get passwordModalTitle => 'Vérifier votre mot de passe';

  @override
  String get passwordModalPlaceholder => 'Votre mot de passe';

  @override
  String get passwordModalButton => 'Vérifier';

  @override
  String get passwordModalEmpty => 'Veuillez entrer votre mot de passe.';

  @override
  String get passwordModalIncorrect =>
      'Mot de passe incorrect. Veuillez réessayer.';

  @override
  String get passwordModalError =>
      'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get confirmIdentity => 'Confirmez votre identité';

  @override
  String get enterPasswordToSave =>
      'Pour enregistrer vos modifications, veuillez entrer votre mot de passe actuel.';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get verifyAndSave => 'Vérifier et Enregistrer';

  @override
  String get forgotPassword => 'Mot de passe oublié';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get enterEmailToReceiveCode =>
      'Entrez votre adresse e-mail pour recevoir un code de vérification.';

  @override
  String get invalidEmailError => 'Veuillez entrer un e-mail valide.';

  @override
  String get sendCode => 'Envoyer le code';

  @override
  String get emailSendError =>
      'Impossible d\'envoyer l\'e-mail. Vérifiez l\'adresse.';

  @override
  String get unknownError => 'Une erreur est survenue.';

  @override
  String get otpTitle => 'Vérification';

  @override
  String get enterCode => 'Entrez le code';

  @override
  String otpSentTo(String email) {
    return 'Nous avons envoyé un code à 6 chiffres à\n$email';
  }

  @override
  String get otpLabel => 'Code à 6 chiffres';

  @override
  String get otpInvalidError => 'Veuillez entrer un code valide.';

  @override
  String get verifyButton => 'Vérifier';

  @override
  String get otpIncorrectError => 'Code incorrect. Veuillez réessayer.';

  @override
  String get resetPasswordTitle => 'Nouveau mot de passe';

  @override
  String get createNewPassword => 'Créez un nouveau mot de passe';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get passwordMismatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get validate => 'Valider';

  @override
  String get passwordChangedSuccess => 'Mot de passe changé avec succès !';

  @override
  String get resetFailed =>
      'Impossible de changer le mot de passe. Le code a peut-être expiré.';

  @override
  String get unexpectedError => 'Une erreur est survenue.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllAsRead => 'Marquer tout comme lu';

  @override
  String get deleteAll => 'Supprimer tout';

  @override
  String get deleteAllConfirmationTitle => 'Confirmation';

  @override
  String get deleteAllConfirmationMessage =>
      'Voulez-vous vraiment supprimer toutes vos notifications ? Cette action est irréversible.';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get loadNotificationsError =>
      'Impossible de charger les notifications.';

  @override
  String get markAllAsReadError => 'Erreur: Impossible de marquer comme lu.';

  @override
  String get deleteAllError => 'Erreur: Impossible de tout supprimer.';

  @override
  String get oops => 'Oups !';

  @override
  String get noNotificationsTitle => 'Aucune notification';

  @override
  String get noNotificationsMessage =>
      'Vos notifications importantes apparaîtront ici.';

  @override
  String notificationDeleted(String title) {
    return 'Notification \"$title\" supprimée.';
  }

  @override
  String get searchParishTitle => 'Rechercher une paroisse';

  @override
  String get searchHint => 'Paroisse, ville, commune...';

  @override
  String get parishesSectionTitle => 'Paroisses';

  @override
  String get retryButton => 'Réessayer';

  @override
  String get loadingErrorMessage => 'Impossible de charger les données';

  @override
  String get noParishesFound => 'Aucune paroisse trouvée.';

  @override
  String get noParishesAvailable => 'Aucune paroisse disponible.';

  @override
  String get unknownParish => 'Paroisse Inconnue';

  @override
  String get detailsButton => 'Détails';

  @override
  String get internetError =>
      'Pas de connexion Internet. Vérifiez votre réseau.';

  @override
  String get connectionError => 'Erreur de connexion.';

  @override
  String get descriptionUnavailable => 'Description non disponible.';

  @override
  String get offeringSuggested => 'Offrande de messe conseillée :';

  @override
  String get moreDetailsButton => 'Plus de détails';

  @override
  String get addToFavorites => 'Ajouter aux favoris';

  @override
  String get removeFromFavorites => 'Retirer des favoris';

  @override
  String get parishAddedFavorite => 'Paroisse ajoutée aux favoris !';

  @override
  String get parishRemovedFavorite => 'Paroisse retirée des favoris.';

  @override
  String get favoritesUpdateError =>
      'Erreur lors de la mise à jour des favoris.';

  @override
  String get mapsOpenError => 'Impossible d\'ouvrir l\'application de carte.';

  @override
  String get events_title => 'Événements';

  @override
  String get events_none => 'Aucun événement pour cette catégorie';

  @override
  String get events_none_with_dot => 'Aucun événement pour cette catégorie.';

  @override
  String get error_generic => 'Une erreur est survenue.';

  @override
  String get error_no_internet =>
      'Pas de connexion Internet. Vérifiez votre réseau.';

  @override
  String get error_timeout => 'Le serveur ne répond pas. Réessayez plus tard.';

  @override
  String get tab_all => 'Tous';

  @override
  String get requests_title => 'Mes demandes';

  @override
  String get tab_in_progress => 'En cours';

  @override
  String get tab_history => 'Historique';

  @override
  String get tab_favorites => 'Favoris';

  @override
  String get error_loading => 'Erreur de chargement';

  @override
  String get list_updated => 'Liste mise à jour';

  @override
  String get generic_error => 'Erreur';

  @override
  String get unknown_date => 'Date inconnue';

  @override
  String get empty_requests => 'Aucune demande trouvée';

  @override
  String get empty_favorites => 'Aucun favori';

  @override
  String get close => 'Fermer';

  @override
  String get pay_now => 'Payer maintenant';

  @override
  String get print_receipt => 'Imprimer le reçu';

  @override
  String get request_details_title => 'Détails de la demande';

  @override
  String get intention => 'Intention';

  @override
  String get parish => 'Paroisse';

  @override
  String get date => 'Date';

  @override
  String get celebration => 'Célébration';

  @override
  String get intercessor => 'Intercesseur';

  @override
  String get offering => 'Offrande';

  @override
  String get no_favorite_title => 'Aucun Favori';

  @override
  String get no_result_title => 'Aucun résultat';

  @override
  String get no_favorite_message =>
      'Vous n\'avez pas encore ajouté de paroisse à vos favoris. Cliquez sur ⭐️ sur une paroisse pour l\'ajouter.';

  @override
  String get no_result_message => 'Aucune demande ne correspond à cet onglet.';

  @override
  String get favorites_updated => 'Favoris mis à jour';

  @override
  String get parish_data_invalid => 'Erreur: Données de paroisse invalides';

  @override
  String favorite_removed(Object parishName) {
    return '\"$parishName\" retiré des favoris';
  }

  @override
  String get favorite_remove_error => 'Erreur lors de la suppression';

  @override
  String get nav_home => 'Accueil';

  @override
  String get nav_event => 'Événement';

  @override
  String get nav_requests => 'Demandes';

  @override
  String get nav_parish => 'Paroisse';
}
