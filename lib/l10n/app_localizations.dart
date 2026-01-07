import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'E-MESSE'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @settingsAccountSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get settingsAccountSectionTitle;

  /// No description provided for @settingsEditProfile.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get settingsEditProfile;

  /// No description provided for @settingsChangePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get settingsChangePassword;

  /// No description provided for @settingsNotificationsSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get settingsNotificationsSectionTitle;

  /// No description provided for @settingsSmsNotifications.
  ///
  /// In fr, this message translates to:
  /// **'SMS'**
  String get settingsSmsNotifications;

  /// No description provided for @settingsEmailNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get settingsEmailNotifications;

  /// No description provided for @settingsPushNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications Push'**
  String get settingsPushNotifications;

  /// No description provided for @settingsGeneralPrefsSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Préférences Générales'**
  String get settingsGeneralPrefsSectionTitle;

  /// No description provided for @settingsAppLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue de l\'application'**
  String get settingsAppLanguage;

  /// No description provided for @settingsFontSize.
  ///
  /// In fr, this message translates to:
  /// **'Taille de la police'**
  String get settingsFontSize;

  /// No description provided for @settingsVoiceReader.
  ///
  /// In fr, this message translates to:
  /// **'Lecteur vocal'**
  String get settingsVoiceReader;

  /// No description provided for @settingsAppTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème de l\'application'**
  String get settingsAppTheme;

  /// No description provided for @settingsFaqHelp.
  ///
  /// In fr, this message translates to:
  /// **'FAQ / Aide'**
  String get settingsFaqHelp;

  /// No description provided for @settingsTutorials.
  ///
  /// In fr, this message translates to:
  /// **'Tutoriels vidéo'**
  String get settingsTutorials;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsLogoutButton.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get settingsLogoutButton;

  /// No description provided for @settingsCurrentLanguageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get settingsCurrentLanguageFrench;

  /// No description provided for @settingsCurrentLanguageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get settingsCurrentLanguageEnglish;

  /// No description provided for @languageSelectorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une langue'**
  String get languageSelectorTitle;

  /// No description provided for @languageChangedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Langue changée avec succès !'**
  String get languageChangedSuccess;

  /// No description provided for @drawerLogoutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get drawerLogoutTitle;

  /// No description provided for @drawerLogoutMessage.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir vous déconnecter ?'**
  String get drawerLogoutMessage;

  /// No description provided for @drawerLogoutCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get drawerLogoutCancel;

  /// No description provided for @drawerLogoutConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get drawerLogoutConfirm;

  /// No description provided for @myRequests.
  ///
  /// In fr, this message translates to:
  /// **'Mes demandes'**
  String get myRequests;

  /// No description provided for @noRequests.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande ne correspond à ce statut.'**
  String get noRequests;

  /// No description provided for @emptyRequestsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas encore fait de demande.\nCommencez par créer votre première demande.'**
  String get emptyRequestsMessage;

  /// No description provided for @makeRequest.
  ///
  /// In fr, this message translates to:
  /// **'Faire une demande'**
  String get makeRequest;

  /// No description provided for @featureUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Fonctionnalité à venir !'**
  String get featureUnavailable;

  /// No description provided for @loadingLabel.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loadingLabel;

  /// No description provided for @errorLabel.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get errorLabel;

  /// No description provided for @saveChanges.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les modifications'**
  String get saveChanges;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginTitle;

  /// No description provided for @registerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get registerTitle;

  /// Label du champ de saisie email
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get passwordLabel;

  /// No description provided for @usernameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur'**
  String get usernameLabel;

  /// No description provided for @fullNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get fullNameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get phoneLabel;

  /// No description provided for @civiliteLabel.
  ///
  /// In fr, this message translates to:
  /// **'Civilité'**
  String get civiliteLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPasswordLabel;

  /// No description provided for @oldPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ancien mot de passe'**
  String get oldPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get newPasswordLabel;

  /// No description provided for @requiredField.
  ///
  /// In fr, this message translates to:
  /// **'Champ requis'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 8 caractères requis.'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordMustBeDifferent.
  ///
  /// In fr, this message translates to:
  /// **'Doit être différent de l\'ancien'**
  String get passwordMustBeDifferent;

  /// No description provided for @homeWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue, {userName} !'**
  String homeWelcome(String userName);

  /// No description provided for @homeGreeting.
  ///
  /// In fr, this message translates to:
  /// **'Que la paix soit avec vous.'**
  String get homeGreeting;

  /// No description provided for @homeNextMassesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos prochaines Messes'**
  String get homeNextMassesTitle;

  /// No description provided for @homeLocationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre Position Actuelle'**
  String get homeLocationTitle;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get themeSystem;

  /// No description provided for @fontSizeSmall.
  ///
  /// In fr, this message translates to:
  /// **'Petite'**
  String get fontSizeSmall;

  /// No description provided for @fontSizeMedium.
  ///
  /// In fr, this message translates to:
  /// **'Moyenne'**
  String get fontSizeMedium;

  /// No description provided for @fontSizeLarge.
  ///
  /// In fr, this message translates to:
  /// **'Grande'**
  String get fontSizeLarge;

  /// No description provided for @loginHintEmailOrUser.
  ///
  /// In fr, this message translates to:
  /// **'E-mail ou Nom d\'utilisateur'**
  String get loginHintEmailOrUser;

  /// No description provided for @loginHintPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get loginHintPassword;

  /// No description provided for @loginBtnLabel.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginBtnLabel;

  /// No description provided for @loginCreateAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get loginCreateAccount;

  /// No description provided for @loginForgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get loginForgotPassword;

  /// No description provided for @loginOrContinue.
  ///
  /// In fr, this message translates to:
  /// **'Ou continuer avec'**
  String get loginOrContinue;

  /// No description provided for @loginValEmailEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir votre email ou nom d\'utilisateur'**
  String get loginValEmailEmpty;

  /// No description provided for @loginValEmailShort.
  ///
  /// In fr, this message translates to:
  /// **'Doit contenir au moins 3 caractères'**
  String get loginValEmailShort;

  /// No description provided for @loginValPassEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir votre mot de passe'**
  String get loginValPassEmpty;

  /// No description provided for @loginValPassShort.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit contenir au moins 8 caractères'**
  String get loginValPassShort;

  /// No description provided for @loginSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Connexion réussie !'**
  String get loginSuccess;

  /// No description provided for @loginErrorCredentials.
  ///
  /// In fr, this message translates to:
  /// **'Identifiants incorrects. Veuillez vérifier.'**
  String get loginErrorCredentials;

  /// No description provided for @loginErrorGoogleToken.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de récupérer le jeton d\'authentification Google.'**
  String get loginErrorGoogleToken;

  /// No description provided for @loginSuccessGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Connecté : {name} !'**
  String loginSuccessGoogle(String name);

  /// No description provided for @loginErrorGoogleLink.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de lier ce compte Google. Vérifiez s\'il est déjà utilisé.'**
  String get loginErrorGoogleLink;

  /// No description provided for @loginErrorGoogleGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue lors de la connexion avec Google.'**
  String get loginErrorGoogleGeneric;

  /// No description provided for @registerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez notre communauté'**
  String get registerSubtitle;

  /// No description provided for @registerStep3Title.
  ///
  /// In fr, this message translates to:
  /// **'Photo de profil'**
  String get registerStep3Title;

  /// No description provided for @registerCivilityLabel.
  ///
  /// In fr, this message translates to:
  /// **'Civilité'**
  String get registerCivilityLabel;

  /// No description provided for @registerCivilityMr.
  ///
  /// In fr, this message translates to:
  /// **'Monsieur'**
  String get registerCivilityMr;

  /// No description provided for @registerCivilityMrs.
  ///
  /// In fr, this message translates to:
  /// **'Madame'**
  String get registerCivilityMrs;

  /// No description provided for @registerCivilityMs.
  ///
  /// In fr, this message translates to:
  /// **'Mademoiselle'**
  String get registerCivilityMs;

  /// No description provided for @registerCivilityFather.
  ///
  /// In fr, this message translates to:
  /// **'Père'**
  String get registerCivilityFather;

  /// No description provided for @registerCivilitySister.
  ///
  /// In fr, this message translates to:
  /// **'Soeur'**
  String get registerCivilitySister;

  /// No description provided for @registerCivilityBrother.
  ///
  /// In fr, this message translates to:
  /// **'Frère'**
  String get registerCivilityBrother;

  /// No description provided for @registerLabelName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get registerLabelName;

  /// No description provided for @registerLabelFirstName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get registerLabelFirstName;

  /// No description provided for @registerLabelParish.
  ///
  /// In fr, this message translates to:
  /// **'Paroisse (Optionnel)'**
  String get registerLabelParish;

  /// No description provided for @registerHintParishSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une paroisse...'**
  String get registerHintParishSearch;

  /// No description provided for @registerImgChoose.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une photo'**
  String get registerImgChoose;

  /// No description provided for @registerImgChange.
  ///
  /// In fr, this message translates to:
  /// **'Changer la photo'**
  String get registerImgChange;

  /// No description provided for @registerImgDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get registerImgDelete;

  /// No description provided for @registerImgSourceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une source'**
  String get registerImgSourceTitle;

  /// No description provided for @registerImgCamera.
  ///
  /// In fr, this message translates to:
  /// **'Appareil photo'**
  String get registerImgCamera;

  /// No description provided for @registerImgGallery.
  ///
  /// In fr, this message translates to:
  /// **'Galerie'**
  String get registerImgGallery;

  /// No description provided for @registerBtnNext.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get registerBtnNext;

  /// No description provided for @registerBtnPrev.
  ///
  /// In fr, this message translates to:
  /// **'Précédent'**
  String get registerBtnPrev;

  /// No description provided for @registerBtnSubmit.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get registerBtnSubmit;

  /// No description provided for @registerAlreadyAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ?'**
  String get registerAlreadyAccount;

  /// No description provided for @registerBtnLogin.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get registerBtnLogin;

  /// No description provided for @valReqName.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre nom'**
  String get valReqName;

  /// No description provided for @valReqFirstName.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre prénom'**
  String get valReqFirstName;

  /// No description provided for @valReqEmail.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un e-mail valide'**
  String get valReqEmail;

  /// No description provided for @valReqPhone.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre téléphone'**
  String get valReqPhone;

  /// No description provided for @valInvalidPhone.
  ///
  /// In fr, this message translates to:
  /// **'Numéro invalide (10 chiffres requis)'**
  String get valInvalidPhone;

  /// No description provided for @valReqUsername.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez choisir un nom d\'utilisateur'**
  String get valReqUsername;

  /// No description provided for @valShortUsername.
  ///
  /// In fr, this message translates to:
  /// **'3 caractères minimum'**
  String get valShortUsername;

  /// No description provided for @valReqPass.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe requis'**
  String get valReqPass;

  /// No description provided for @valShortPass.
  ///
  /// In fr, this message translates to:
  /// **'8 caractères minimum'**
  String get valShortPass;

  /// No description provided for @valPassMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get valPassMismatch;

  /// No description provided for @errRegisterFixErrors.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez corriger les erreurs avant de continuer.'**
  String get errRegisterFixErrors;

  /// No description provided for @errRegisterUsernameTaken.
  ///
  /// In fr, this message translates to:
  /// **'Ce nom d\'utilisateur est déjà pris.'**
  String get errRegisterUsernameTaken;

  /// No description provided for @errRegisterEmailTaken.
  ///
  /// In fr, this message translates to:
  /// **'Cet email est déjà utilisé.'**
  String get errRegisterEmailTaken;

  /// No description provided for @errRegisterGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue lors de l\'inscription.'**
  String get errRegisterGeneric;

  /// No description provided for @successRegister.
  ///
  /// In fr, this message translates to:
  /// **'Compte créé avec succès ! Connectez-vous.'**
  String get successRegister;

  /// No description provided for @errImagePick.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la sélection de l\'image'**
  String get errImagePick;

  /// No description provided for @errCivilityRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner votre civilité'**
  String get errCivilityRequired;

  /// No description provided for @successRegisterRedirect.
  ///
  /// In fr, this message translates to:
  /// **'Inscription réussie ! Redirection...'**
  String get successRegisterRedirect;

  /// No description provided for @registerStep1Title.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles'**
  String get registerStep1Title;

  /// No description provided for @registerStep1Subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez renseigner vos informations personnelles'**
  String get registerStep1Subtitle;

  /// No description provided for @registerLabelCivility.
  ///
  /// In fr, this message translates to:
  /// **'Civilité *'**
  String get registerLabelCivility;

  /// No description provided for @registerGenderMale.
  ///
  /// In fr, this message translates to:
  /// **'Homme'**
  String get registerGenderMale;

  /// No description provided for @registerGenderFemale.
  ///
  /// In fr, this message translates to:
  /// **'Femme'**
  String get registerGenderFemale;

  /// No description provided for @registerLabelFullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get registerLabelFullName;

  /// No description provided for @registerHintFullName.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Jean Dupont'**
  String get registerHintFullName;

  /// No description provided for @registerLabelUsername.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur'**
  String get registerLabelUsername;

  /// No description provided for @registerHintUsername.
  ///
  /// In fr, this message translates to:
  /// **'Ex: jean_dupont'**
  String get registerHintUsername;

  /// No description provided for @registerLabelEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse email'**
  String get registerLabelEmail;

  /// No description provided for @registerHintEmail.
  ///
  /// In fr, this message translates to:
  /// **'Ex: jean@example.com'**
  String get registerHintEmail;

  /// No description provided for @registerLabelPhone.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get registerLabelPhone;

  /// No description provided for @registerHintPhone.
  ///
  /// In fr, this message translates to:
  /// **'Ex: +33 6 12 34 56 78'**
  String get registerHintPhone;

  /// No description provided for @registerStep2Title.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité du compte'**
  String get registerStep2Title;

  /// No description provided for @registerStep2Subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un mot de passe sécurisé pour votre compte'**
  String get registerStep2Subtitle;

  /// No description provided for @registerLabelPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get registerLabelPassword;

  /// No description provided for @registerHintPassword.
  ///
  /// In fr, this message translates to:
  /// **'Minimum 8 caractères'**
  String get registerHintPassword;

  /// No description provided for @registerLabelConfirmPass.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get registerLabelConfirmPass;

  /// No description provided for @registerHintConfirmPass.
  ///
  /// In fr, this message translates to:
  /// **'Ressaisissez votre mot de passe'**
  String get registerHintConfirmPass;

  /// No description provided for @registerPassReqTitle.
  ///
  /// In fr, this message translates to:
  /// **'Exigences du mot de passe'**
  String get registerPassReqTitle;

  /// No description provided for @registerPassReqLen.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 8 caractères'**
  String get registerPassReqLen;

  /// No description provided for @registerPassReqMix.
  ///
  /// In fr, this message translates to:
  /// **'Mélange de lettres et chiffres recommandé'**
  String get registerPassReqMix;

  /// No description provided for @registerPassReqCommon.
  ///
  /// In fr, this message translates to:
  /// **'Évitez les mots de passe courants'**
  String get registerPassReqCommon;

  /// No description provided for @valNameEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir votre nom complet'**
  String get valNameEmpty;

  /// No description provided for @valNameShort.
  ///
  /// In fr, this message translates to:
  /// **'Le nom doit contenir au moins 2 caractères'**
  String get valNameShort;

  /// No description provided for @valUsernameEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez choisir un nom d\'utilisateur'**
  String get valUsernameEmpty;

  /// No description provided for @valUsernameShort.
  ///
  /// In fr, this message translates to:
  /// **'Le nom d\'utilisateur doit contenir au moins 3 caractères'**
  String get valUsernameShort;

  /// No description provided for @valUsernameInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Seules les lettres, chiffres et _ sont autorisés'**
  String get valUsernameInvalid;

  /// No description provided for @valEmailEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir votre email'**
  String get valEmailEmpty;

  /// No description provided for @valEmailInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir un email valide'**
  String get valEmailInvalid;

  /// No description provided for @valPhoneEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir votre numéro de téléphone'**
  String get valPhoneEmpty;

  /// No description provided for @valPhonePrefix.
  ///
  /// In fr, this message translates to:
  /// **'Le numéro doit commencer par l\'indicatif (ex: +225)'**
  String get valPhonePrefix;

  /// No description provided for @valPhoneShort.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone trop court'**
  String get valPhoneShort;

  /// No description provided for @valPhoneFormat.
  ///
  /// In fr, this message translates to:
  /// **'Format invalide (seulement + et chiffres)'**
  String get valPhoneFormat;

  /// No description provided for @valPassEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir un mot de passe'**
  String get valPassEmpty;

  /// No description provided for @valPassShort.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit contenir au moins 8 caractères'**
  String get valPassShort;

  /// No description provided for @valConfirmPassEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez confirmer votre mot de passe'**
  String get valConfirmPassEmpty;

  /// No description provided for @homeHello.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour'**
  String get homeHello;

  /// No description provided for @homeLocationUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Localisation inconnue'**
  String get homeLocationUnknown;

  /// No description provided for @homeLocationDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Localisation désactivée'**
  String get homeLocationDisabled;

  /// No description provided for @homeLocationDenied.
  ///
  /// In fr, this message translates to:
  /// **'Permission refusée'**
  String get homeLocationDenied;

  /// No description provided for @homeLocationBlocked.
  ///
  /// In fr, this message translates to:
  /// **'Permission bloquée'**
  String get homeLocationBlocked;

  /// No description provided for @homeLocationNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Adresse non trouvée'**
  String get homeLocationNotFound;

  /// No description provided for @homeLocationPosNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Position introuvable'**
  String get homeLocationPosNotFound;

  /// No description provided for @homeLocationError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur localisation'**
  String get homeLocationError;

  /// No description provided for @homeMapError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir l\'application de carte.'**
  String get homeMapError;

  /// No description provided for @homeStatusTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon statut des messes'**
  String get homeStatusTitle;

  /// No description provided for @homeStatusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get homeStatusPending;

  /// No description provided for @homeStatusCelebrated.
  ///
  /// In fr, this message translates to:
  /// **'Célébrées'**
  String get homeStatusCelebrated;

  /// No description provided for @homeStatusUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get homeStatusUpcoming;

  /// No description provided for @homeQuickActionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Actions rapides'**
  String get homeQuickActionsTitle;

  /// No description provided for @homeBtnRequest.
  ///
  /// In fr, this message translates to:
  /// **'Faire une demande'**
  String get homeBtnRequest;

  /// No description provided for @homeBtnEvents.
  ///
  /// In fr, this message translates to:
  /// **'Voir événements'**
  String get homeBtnEvents;

  /// No description provided for @homeBtnParishes.
  ///
  /// In fr, this message translates to:
  /// **'Paroisses'**
  String get homeBtnParishes;

  /// No description provided for @homeUpcomingSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prochaines messes'**
  String get homeUpcomingSectionTitle;

  /// No description provided for @homeNoUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'Aucune messe confirmée à venir.'**
  String get homeNoUpcoming;

  /// No description provided for @homeParishSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paroisses à proximité'**
  String get homeParishSectionTitle;

  /// No description provided for @online.
  ///
  /// In fr, this message translates to:
  /// **'En ligne'**
  String get online;

  /// Message de bienvenue affichant le nom de l'utilisateur
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue, {userName} !'**
  String welcomeUser(Object userName);

  /// No description provided for @peaceMessage.
  ///
  /// In fr, this message translates to:
  /// **'Que la paix soit avec vous.'**
  String get peaceMessage;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @status_waiting_payment.
  ///
  /// In fr, this message translates to:
  /// **'En att. Paiement'**
  String get status_waiting_payment;

  /// No description provided for @status_waiting_confirmation.
  ///
  /// In fr, this message translates to:
  /// **'En att. Confirmation'**
  String get status_waiting_confirmation;

  /// No description provided for @status_confirmed.
  ///
  /// In fr, this message translates to:
  /// **'Confirmé'**
  String get status_confirmed;

  /// No description provided for @status_celebrated.
  ///
  /// In fr, this message translates to:
  /// **'Célébré'**
  String get status_celebrated;

  /// No description provided for @status_cancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulé'**
  String get status_cancelled;

  /// No description provided for @modal_pending.
  ///
  /// In fr, this message translates to:
  /// **'Messes en attente'**
  String get modal_pending;

  /// No description provided for @modal_celebrated.
  ///
  /// In fr, this message translates to:
  /// **'Messes célébrées'**
  String get modal_celebrated;

  /// No description provided for @modal_upcoming.
  ///
  /// In fr, this message translates to:
  /// **'Messes à venir'**
  String get modal_upcoming;

  /// No description provided for @editProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get editProfileTitle;

  /// No description provided for @editProfileSaveButton.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les modifications'**
  String get editProfileSaveButton;

  /// No description provided for @editProfileLogoutButton.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get editProfileLogoutButton;

  /// No description provided for @editProfileNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get editProfileNameLabel;

  /// No description provided for @editProfileEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail'**
  String get editProfileEmailLabel;

  /// No description provided for @editProfilePhoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get editProfilePhoneLabel;

  /// No description provided for @editProfileCiviliteLabel.
  ///
  /// In fr, this message translates to:
  /// **'Civilité'**
  String get editProfileCiviliteLabel;

  /// No description provided for @editProfileCiviliteM.
  ///
  /// In fr, this message translates to:
  /// **'M.'**
  String get editProfileCiviliteM;

  /// No description provided for @editProfileCiviliteMme.
  ///
  /// In fr, this message translates to:
  /// **'Mme'**
  String get editProfileCiviliteMme;

  /// No description provided for @editProfileCiviliteMlle.
  ///
  /// In fr, this message translates to:
  /// **'Mlle'**
  String get editProfileCiviliteMlle;

  /// No description provided for @editProfileNameError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir votre nom'**
  String get editProfileNameError;

  /// No description provided for @editProfilePhoneError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir votre numéro'**
  String get editProfilePhoneError;

  /// No description provided for @editProfileCiviliteError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner une civilité'**
  String get editProfileCiviliteError;

  /// No description provided for @editProfileImageError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la sélection de l\'image.'**
  String get editProfileImageError;

  /// No description provided for @editProfileUpdateSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour avec succès !'**
  String get editProfileUpdateSuccess;

  /// No description provided for @editProfileUpdateError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la mise à jour du profil.'**
  String get editProfileUpdateError;

  /// No description provided for @editProfileUnexpectedError.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur inattendue est survenue.'**
  String get editProfileUnexpectedError;

  /// No description provided for @logoutDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logoutDialogTitle;

  /// No description provided for @logoutDialogMessage.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment vous déconnecter ?'**
  String get logoutDialogMessage;

  /// No description provided for @logoutDialogCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get logoutDialogCancel;

  /// No description provided for @logoutDialogConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get logoutDialogConfirm;

  /// No description provided for @passwordModalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier votre mot de passe'**
  String get passwordModalTitle;

  /// No description provided for @passwordModalPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Votre mot de passe'**
  String get passwordModalPlaceholder;

  /// No description provided for @passwordModalButton.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier'**
  String get passwordModalButton;

  /// No description provided for @passwordModalEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre mot de passe.'**
  String get passwordModalEmpty;

  /// No description provided for @passwordModalIncorrect.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe incorrect. Veuillez réessayer.'**
  String get passwordModalIncorrect;

  /// No description provided for @passwordModalError.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Veuillez réessayer.'**
  String get passwordModalError;

  /// Titre du modal pour vérifier l'identité de l'utilisateur
  ///
  /// In fr, this message translates to:
  /// **'Confirmez votre identité'**
  String get confirmIdentity;

  /// Message expliquant pourquoi l'utilisateur doit entrer son mot de passe
  ///
  /// In fr, this message translates to:
  /// **'Pour enregistrer vos modifications, veuillez entrer votre mot de passe actuel.'**
  String get enterPasswordToSave;

  /// Label du champ texte du mot de passe
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel'**
  String get currentPassword;

  /// Texte du bouton pour valider et sauvegarder
  ///
  /// In fr, this message translates to:
  /// **'Vérifier et Enregistrer'**
  String get verifyAndSave;

  /// Titre de l'écran AppBar
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié'**
  String get forgotPassword;

  /// Grand titre au centre de l'écran
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser le mot de passe'**
  String get resetPassword;

  /// Sous-titre expliquant la procédure de réinitialisation
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre adresse e-mail pour recevoir un code de vérification.'**
  String get enterEmailToReceiveCode;

  /// Message d'erreur si l'email est invalide
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un e-mail valide.'**
  String get invalidEmailError;

  /// Bouton d'envoi pour le reset
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le code'**
  String get sendCode;

  /// Erreur si l'envoi échoue
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'envoyer l\'e-mail. Vérifiez l\'adresse.'**
  String get emailSendError;

  /// Erreur générique
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue.'**
  String get unknownError;

  /// Titre de l'écran OTP dans l'AppBar
  ///
  /// In fr, this message translates to:
  /// **'Vérification'**
  String get otpTitle;

  /// Titre principal pour demander le code OTP
  ///
  /// In fr, this message translates to:
  /// **'Entrez le code'**
  String get enterCode;

  /// Message de confirmation d'envoi du code OTP
  ///
  /// In fr, this message translates to:
  /// **'Nous avons envoyé un code à 6 chiffres à\n{email}'**
  String otpSentTo(String email);

  /// Label du champ de saisie OTP
  ///
  /// In fr, this message translates to:
  /// **'Code à 6 chiffres'**
  String get otpLabel;

  /// Message d'erreur si le code OTP est incomplet
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un code valide.'**
  String get otpInvalidError;

  /// Bouton pour vérifier le code OTP
  ///
  /// In fr, this message translates to:
  /// **'Vérifier'**
  String get verifyButton;

  /// Erreur si le code OTP est faux
  ///
  /// In fr, this message translates to:
  /// **'Code incorrect. Veuillez réessayer.'**
  String get otpIncorrectError;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get resetPasswordTitle;

  /// No description provided for @createNewPassword.
  ///
  /// In fr, this message translates to:
  /// **'Créez un nouveau mot de passe'**
  String get createNewPassword;

  /// No description provided for @newPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas.'**
  String get passwordMismatch;

  /// No description provided for @validate.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get validate;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe changé avec succès !'**
  String get passwordChangedSuccess;

  /// No description provided for @resetFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de changer le mot de passe. Le code a peut-être expiré.'**
  String get resetFailed;

  /// No description provided for @unexpectedError.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue.'**
  String get unexpectedError;

  /// Titre de l'AppBar des notifications
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// Tooltip pour le bouton Marquer tout comme lu
  ///
  /// In fr, this message translates to:
  /// **'Marquer tout comme lu'**
  String get markAllAsRead;

  /// Tooltip pour le bouton Supprimer tout
  ///
  /// In fr, this message translates to:
  /// **'Supprimer tout'**
  String get deleteAll;

  /// Titre du dialog de confirmation de suppression
  ///
  /// In fr, this message translates to:
  /// **'Confirmation'**
  String get deleteAllConfirmationTitle;

  /// Message du dialog de confirmation pour supprimer toutes les notifications
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment supprimer toutes vos notifications ? Cette action est irréversible.'**
  String get deleteAllConfirmationMessage;

  /// Texte du bouton Annuler dans un dialog
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// Texte du bouton Supprimer dans un dialog
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// Message d'erreur si l'on ne peut pas charger les notifications
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les notifications.'**
  String get loadNotificationsError;

  /// Message d'erreur lors du marquage de toutes les notifications comme lues
  ///
  /// In fr, this message translates to:
  /// **'Erreur: Impossible de marquer comme lu.'**
  String get markAllAsReadError;

  /// Message d'erreur lors de la suppression de toutes les notifications
  ///
  /// In fr, this message translates to:
  /// **'Erreur: Impossible de tout supprimer.'**
  String get deleteAllError;

  /// Titre de l'écran erreur
  ///
  /// In fr, this message translates to:
  /// **'Oups !'**
  String get oops;

  /// Titre affiché lorsque la liste des notifications est vide
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification'**
  String get noNotificationsTitle;

  /// Message affiché lorsque la liste des notifications est vide
  ///
  /// In fr, this message translates to:
  /// **'Vos notifications importantes apparaîtront ici.'**
  String get noNotificationsMessage;

  /// Message affiché après suppression d'une notification avec option Annuler
  ///
  /// In fr, this message translates to:
  /// **'Notification \"{title}\" supprimée.'**
  String notificationDeleted(String title);

  /// No description provided for @searchParishTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une paroisse'**
  String get searchParishTitle;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Paroisse, ville, commune...'**
  String get searchHint;

  /// No description provided for @parishesSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paroisses'**
  String get parishesSectionTitle;

  /// No description provided for @retryButton.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retryButton;

  /// No description provided for @loadingErrorMessage.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les données'**
  String get loadingErrorMessage;

  /// No description provided for @noParishesFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucune paroisse trouvée.'**
  String get noParishesFound;

  /// No description provided for @noParishesAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucune paroisse disponible.'**
  String get noParishesAvailable;

  /// No description provided for @unknownParish.
  ///
  /// In fr, this message translates to:
  /// **'Paroisse Inconnue'**
  String get unknownParish;

  /// No description provided for @detailsButton.
  ///
  /// In fr, this message translates to:
  /// **'Détails'**
  String get detailsButton;

  /// No description provided for @internetError.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion Internet. Vérifiez votre réseau.'**
  String get internetError;

  /// No description provided for @connectionError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion.'**
  String get connectionError;

  /// No description provided for @descriptionUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Description non disponible.'**
  String get descriptionUnavailable;

  /// No description provided for @offeringSuggested.
  ///
  /// In fr, this message translates to:
  /// **'Offrande de messe conseillée :'**
  String get offeringSuggested;

  /// No description provided for @moreDetailsButton.
  ///
  /// In fr, this message translates to:
  /// **'Plus de détails'**
  String get moreDetailsButton;

  /// No description provided for @addToFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter aux favoris'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Retirer des favoris'**
  String get removeFromFavorites;

  /// No description provided for @parishAddedFavorite.
  ///
  /// In fr, this message translates to:
  /// **'Paroisse ajoutée aux favoris !'**
  String get parishAddedFavorite;

  /// No description provided for @parishRemovedFavorite.
  ///
  /// In fr, this message translates to:
  /// **'Paroisse retirée des favoris.'**
  String get parishRemovedFavorite;

  /// No description provided for @favoritesUpdateError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la mise à jour des favoris.'**
  String get favoritesUpdateError;

  /// No description provided for @mapsOpenError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir l\'application de carte.'**
  String get mapsOpenError;

  /// No description provided for @events_title.
  ///
  /// In fr, this message translates to:
  /// **'Événements'**
  String get events_title;

  /// No description provided for @events_none.
  ///
  /// In fr, this message translates to:
  /// **'Aucun événement pour cette catégorie'**
  String get events_none;

  /// No description provided for @events_none_with_dot.
  ///
  /// In fr, this message translates to:
  /// **'Aucun événement pour cette catégorie.'**
  String get events_none_with_dot;

  /// No description provided for @error_generic.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue.'**
  String get error_generic;

  /// No description provided for @error_no_internet.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion Internet. Vérifiez votre réseau.'**
  String get error_no_internet;

  /// No description provided for @error_timeout.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur ne répond pas. Réessayez plus tard.'**
  String get error_timeout;

  /// No description provided for @tab_all.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get tab_all;

  /// No description provided for @requests_title.
  ///
  /// In fr, this message translates to:
  /// **'Mes demandes'**
  String get requests_title;

  /// No description provided for @tab_in_progress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get tab_in_progress;

  /// No description provided for @tab_history.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get tab_history;

  /// No description provided for @tab_favorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get tab_favorites;

  /// No description provided for @error_loading.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement'**
  String get error_loading;

  /// No description provided for @list_updated.
  ///
  /// In fr, this message translates to:
  /// **'Liste mise à jour'**
  String get list_updated;

  /// No description provided for @generic_error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get generic_error;

  /// No description provided for @unknown_date.
  ///
  /// In fr, this message translates to:
  /// **'Date inconnue'**
  String get unknown_date;

  /// No description provided for @empty_requests.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande trouvée'**
  String get empty_requests;

  /// No description provided for @empty_favorites.
  ///
  /// In fr, this message translates to:
  /// **'Aucun favori'**
  String get empty_favorites;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @pay_now.
  ///
  /// In fr, this message translates to:
  /// **'Payer maintenant'**
  String get pay_now;

  /// No description provided for @print_receipt.
  ///
  /// In fr, this message translates to:
  /// **'Imprimer le reçu'**
  String get print_receipt;

  /// No description provided for @request_details_title.
  ///
  /// In fr, this message translates to:
  /// **'Détails de la demande'**
  String get request_details_title;

  /// No description provided for @intention.
  ///
  /// In fr, this message translates to:
  /// **'Intention'**
  String get intention;

  /// No description provided for @parish.
  ///
  /// In fr, this message translates to:
  /// **'Paroisse'**
  String get parish;

  /// No description provided for @date.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @celebration.
  ///
  /// In fr, this message translates to:
  /// **'Célébration'**
  String get celebration;

  /// No description provided for @intercessor.
  ///
  /// In fr, this message translates to:
  /// **'Intercesseur'**
  String get intercessor;

  /// No description provided for @offering.
  ///
  /// In fr, this message translates to:
  /// **'Offrande'**
  String get offering;

  /// No description provided for @no_favorite_title.
  ///
  /// In fr, this message translates to:
  /// **'Aucun Favori'**
  String get no_favorite_title;

  /// No description provided for @no_result_title.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get no_result_title;

  /// No description provided for @no_favorite_message.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas encore ajouté de paroisse à vos favoris. Cliquez sur ⭐️ sur une paroisse pour l\'ajouter.'**
  String get no_favorite_message;

  /// No description provided for @no_result_message.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande ne correspond à cet onglet.'**
  String get no_result_message;

  /// No description provided for @favorites_updated.
  ///
  /// In fr, this message translates to:
  /// **'Favoris mis à jour'**
  String get favorites_updated;

  /// No description provided for @parish_data_invalid.
  ///
  /// In fr, this message translates to:
  /// **'Erreur: Données de paroisse invalides'**
  String get parish_data_invalid;

  /// No description provided for @favorite_removed.
  ///
  /// In fr, this message translates to:
  /// **'\"{parishName}\" retiré des favoris'**
  String favorite_removed(Object parishName);

  /// No description provided for @favorite_remove_error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la suppression'**
  String get favorite_remove_error;

  /// Libellé de l'onglet Accueil
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get nav_home;

  /// Libellé de l'onglet Événement
  ///
  /// In fr, this message translates to:
  /// **'Événement'**
  String get nav_event;

  /// Libellé de l'onglet Mes demandes
  ///
  /// In fr, this message translates to:
  /// **'Demandes'**
  String get nav_requests;

  /// Libellé de l'onglet Paroisse
  ///
  /// In fr, this message translates to:
  /// **'Paroisse'**
  String get nav_parish;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
