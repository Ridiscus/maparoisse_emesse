// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'E-MESSE';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccountSectionTitle => 'Account';

  @override
  String get settingsEditProfile => 'Edit Profile';

  @override
  String get settingsChangePassword => 'Change Password';

  @override
  String get settingsNotificationsSectionTitle => 'Notifications';

  @override
  String get settingsSmsNotifications => 'SMS';

  @override
  String get settingsEmailNotifications => 'Email';

  @override
  String get settingsPushNotifications => 'Push Notifications';

  @override
  String get settingsGeneralPrefsSectionTitle => 'General Preferences';

  @override
  String get settingsAppLanguage => 'App Language';

  @override
  String get settingsFontSize => 'Font Size';

  @override
  String get settingsVoiceReader => 'Voice Reader';

  @override
  String get settingsAppTheme => 'App Theme';

  @override
  String get settingsFaqHelp => 'FAQ / Help';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsLogoutButton => 'Log Out';

  @override
  String get settingsCurrentLanguageFrench => 'French';

  @override
  String get settingsCurrentLanguageEnglish => 'English';

  @override
  String get languageSelectorTitle => 'Choose a language';

  @override
  String get languageChangedSuccess => 'Language changed successfully!';

  @override
  String get drawerLogoutTitle => 'Logout';

  @override
  String get drawerLogoutMessage => 'Are you sure you want to log out?';

  @override
  String get drawerLogoutCancel => 'Cancel';

  @override
  String get drawerLogoutConfirm => 'Log Out';

  @override
  String get myRequests => 'My Requests';

  @override
  String get noRequests => 'No request matches this status.';

  @override
  String get emptyRequestsMessage =>
      'You have not made any request yet.\nStart by creating your first request.';

  @override
  String get makeRequest => 'Make a request';

  @override
  String get featureUnavailable => 'Feature coming soon!';

  @override
  String get loadingLabel => 'Loading...';

  @override
  String get errorLabel => 'Error';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get loginTitle => 'Login';

  @override
  String get registerTitle => 'Register';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get usernameLabel => 'Username';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get phoneLabel => 'Phone Number';

  @override
  String get civiliteLabel => 'Title';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get oldPasswordLabel => 'Old Password';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get requiredField => 'Required field';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get passwordTooShort => 'At least 8 characters required.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordMustBeDifferent => 'Must be different from the old one';

  @override
  String homeWelcome(String userName) {
    return 'Welcome, $userName!';
  }

  @override
  String get homeGreeting => 'Peace be with you.';

  @override
  String get homeNextMassesTitle => 'Your Upcoming Masses';

  @override
  String get homeLocationTitle => 'Your Current Location';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get fontSizeSmall => 'Small';

  @override
  String get fontSizeMedium => 'Medium';

  @override
  String get fontSizeLarge => 'Large';

  @override
  String get loginHintEmailOrUser => 'Email or Username';

  @override
  String get loginHintPassword => 'Password';

  @override
  String get loginBtnLabel => 'Login';

  @override
  String get loginCreateAccount => 'Create an account';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginOrContinue => 'Or continue with';

  @override
  String get loginValEmailEmpty => 'Please enter your email or username';

  @override
  String get loginValEmailShort => 'Must contain at least 3 characters';

  @override
  String get loginValPassEmpty => 'Please enter your password';

  @override
  String get loginValPassShort => 'Password must contain at least 8 characters';

  @override
  String get loginSuccess => 'Login successful!';

  @override
  String get loginErrorCredentials => 'Incorrect credentials. Please check.';

  @override
  String get loginErrorGoogleToken =>
      'Unable to retrieve Google authentication token.';

  @override
  String loginSuccessGoogle(String name) {
    return 'Logged in: $name!';
  }

  @override
  String get loginErrorGoogleLink =>
      'Unable to link this Google account. Check if it is already used.';

  @override
  String get loginErrorGoogleGeneric =>
      'An error occurred while signing in with Google.';

  @override
  String get registerSubtitle => 'Join our community';

  @override
  String get registerStep3Title => 'Profile Picture';

  @override
  String get registerCivilityLabel => 'Title';

  @override
  String get registerCivilityMr => 'Mr.';

  @override
  String get registerCivilityMrs => 'Mrs.';

  @override
  String get registerCivilityMs => 'Miss';

  @override
  String get registerCivilityFather => 'Father';

  @override
  String get registerCivilitySister => 'Sister';

  @override
  String get registerCivilityBrother => 'Brother';

  @override
  String get registerLabelName => 'Last Name';

  @override
  String get registerLabelFirstName => 'First Name';

  @override
  String get registerLabelParish => 'Parish (Optional)';

  @override
  String get registerHintParishSearch => 'Search a parish...';

  @override
  String get registerImgChoose => 'Choose a photo';

  @override
  String get registerImgChange => 'Change photo';

  @override
  String get registerImgDelete => 'Delete';

  @override
  String get registerImgSourceTitle => 'Choose a source';

  @override
  String get registerImgCamera => 'Camera';

  @override
  String get registerImgGallery => 'Gallery';

  @override
  String get registerBtnNext => 'Next';

  @override
  String get registerBtnPrev => 'Previous';

  @override
  String get registerBtnSubmit => 'Sign Up';

  @override
  String get registerAlreadyAccount => 'Already have an account?';

  @override
  String get registerBtnLogin => 'Login';

  @override
  String get valReqName => 'Please enter your last name';

  @override
  String get valReqFirstName => 'Please enter your first name';

  @override
  String get valReqEmail => 'Please enter a valid email';

  @override
  String get valReqPhone => 'Please enter your phone number';

  @override
  String get valInvalidPhone => 'Invalid number (10 digits required)';

  @override
  String get valReqUsername => 'Please choose a username';

  @override
  String get valShortUsername => 'Minimum 3 characters';

  @override
  String get valReqPass => 'Password required';

  @override
  String get valShortPass => 'Minimum 8 characters';

  @override
  String get valPassMismatch => 'Passwords do not match';

  @override
  String get errRegisterFixErrors => 'Please fix the errors before continuing.';

  @override
  String get errRegisterUsernameTaken => 'This username is already taken.';

  @override
  String get errRegisterEmailTaken => 'This email is already used.';

  @override
  String get errRegisterGeneric => 'An error occurred during registration.';

  @override
  String get successRegister => 'Account created successfully! Please log in.';

  @override
  String get errImagePick => 'Error selecting image';

  @override
  String get errCivilityRequired => 'Please select your title';

  @override
  String get successRegisterRedirect =>
      'Registration successful! Redirecting...';

  @override
  String get registerStep1Title => 'Personal Information';

  @override
  String get registerStep1Subtitle =>
      'Please fill in your personal information';

  @override
  String get registerLabelCivility => 'Title *';

  @override
  String get registerGenderMale => 'Male';

  @override
  String get registerGenderFemale => 'Female';

  @override
  String get registerLabelFullName => 'Full Name';

  @override
  String get registerHintFullName => 'Ex: John Doe';

  @override
  String get registerLabelUsername => 'Username';

  @override
  String get registerHintUsername => 'Ex: john_doe';

  @override
  String get registerLabelEmail => 'Email address';

  @override
  String get registerHintEmail => 'Ex: john@example.com';

  @override
  String get registerLabelPhone => 'Phone number';

  @override
  String get registerHintPhone => 'Ex: +33 6 12 34 56 78';

  @override
  String get registerStep2Title => 'Account Security';

  @override
  String get registerStep2Subtitle =>
      'Choose a secure password for your account';

  @override
  String get registerLabelPassword => 'Password';

  @override
  String get registerHintPassword => 'Minimum 8 characters';

  @override
  String get registerLabelConfirmPass => 'Confirm password';

  @override
  String get registerHintConfirmPass => 'Re-enter your password';

  @override
  String get registerPassReqTitle => 'Password Requirements';

  @override
  String get registerPassReqLen => 'At least 8 characters';

  @override
  String get registerPassReqMix => 'Mix of letters and numbers recommended';

  @override
  String get registerPassReqCommon => 'Avoid common passwords';

  @override
  String get valNameEmpty => 'Please enter your full name';

  @override
  String get valNameShort => 'The name must contain at least 2 characters';

  @override
  String get valUsernameEmpty => 'Please choose a username';

  @override
  String get valUsernameShort => 'Username must contain at least 3 characters';

  @override
  String get valUsernameInvalid => 'Only letters, numbers and _ are allowed';

  @override
  String get valEmailEmpty => 'Please enter your email';

  @override
  String get valEmailInvalid => 'Please enter a valid email';

  @override
  String get valPhoneEmpty => 'Please enter your phone number';

  @override
  String get valPhonePrefix =>
      'The number must start with the country code (e.g., +225)';

  @override
  String get valPhoneShort => 'Phone number too short';

  @override
  String get valPhoneFormat => 'Invalid format (only + and digits)';

  @override
  String get valPassEmpty => 'Please enter a password';

  @override
  String get valPassShort => 'Password must contain at least 8 characters';

  @override
  String get valConfirmPassEmpty => 'Please confirm your password';

  @override
  String get homeHello => 'Hello';

  @override
  String get homeLocationUnknown => 'Unknown location';

  @override
  String get homeLocationDisabled => 'Location disabled';

  @override
  String get homeLocationDenied => 'Permission denied';

  @override
  String get homeLocationBlocked => 'Permission blocked';

  @override
  String get homeLocationNotFound => 'Address not found';

  @override
  String get homeLocationPosNotFound => 'Position not found';

  @override
  String get homeLocationError => 'Location error';

  @override
  String get homeMapError => 'Unable to open map application.';

  @override
  String get homeStatusTitle => 'My Mass Status';

  @override
  String get homeStatusPending => 'Pending';

  @override
  String get homeStatusCelebrated => 'Celebrated';

  @override
  String get homeStatusUpcoming => 'Upcoming';

  @override
  String get homeQuickActionsTitle => 'Quick Actions';

  @override
  String get homeBtnRequest => 'Make a request';

  @override
  String get homeBtnEvents => 'View events';

  @override
  String get homeBtnParishes => 'Parishes';

  @override
  String get homeUpcomingSectionTitle => 'Upcoming Masses';

  @override
  String get homeNoUpcoming => 'No confirmed upcoming mass.';

  @override
  String get homeParishSectionTitle => 'Nearby Parishes';

  @override
  String get online => 'Online';

  @override
  String welcomeUser(Object userName) {
    return 'Welcome, $userName!';
  }

  @override
  String get peaceMessage => 'Peace be with you.';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get status_waiting_payment => 'Awaiting Payment';

  @override
  String get status_waiting_confirmation => 'Awaiting Confirmation';

  @override
  String get status_confirmed => 'Confirmed';

  @override
  String get status_celebrated => 'Celebrated';

  @override
  String get status_cancelled => 'Cancelled';

  @override
  String get modal_pending => 'Pending Masses';

  @override
  String get modal_celebrated => 'Celebrated Masses';

  @override
  String get modal_upcoming => 'Upcoming Masses';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get editProfileSaveButton => 'Save changes';

  @override
  String get editProfileLogoutButton => 'Log Out';

  @override
  String get editProfileNameLabel => 'Full Name';

  @override
  String get editProfileEmailLabel => 'Email address';

  @override
  String get editProfilePhoneLabel => 'Phone number';

  @override
  String get editProfileCiviliteLabel => 'Title';

  @override
  String get editProfileCiviliteM => 'Mr.';

  @override
  String get editProfileCiviliteMme => 'Mrs.';

  @override
  String get editProfileCiviliteMlle => 'Miss';

  @override
  String get editProfileNameError => 'Please enter your name';

  @override
  String get editProfilePhoneError => 'Please enter your phone number';

  @override
  String get editProfileCiviliteError => 'Please select a title';

  @override
  String get editProfileImageError => 'Error selecting image.';

  @override
  String get editProfileUpdateSuccess => 'Profile updated successfully!';

  @override
  String get editProfileUpdateError => 'Error updating profile.';

  @override
  String get editProfileUnexpectedError => 'An unexpected error occurred.';

  @override
  String get logoutDialogTitle => 'Logout';

  @override
  String get logoutDialogMessage => 'Do you really want to log out?';

  @override
  String get logoutDialogCancel => 'Cancel';

  @override
  String get logoutDialogConfirm => 'Log Out';

  @override
  String get passwordModalTitle => 'Verify your password';

  @override
  String get passwordModalPlaceholder => 'Your password';

  @override
  String get passwordModalButton => 'Verify';

  @override
  String get passwordModalEmpty => 'Please enter your password.';

  @override
  String get passwordModalIncorrect => 'Incorrect password. Please try again.';

  @override
  String get passwordModalError => 'An error occurred. Please try again.';

  @override
  String get confirmIdentity => 'Confirm your identity';

  @override
  String get enterPasswordToSave =>
      'To save your changes, please enter your current password.';

  @override
  String get currentPassword => 'Current password';

  @override
  String get verifyAndSave => 'Verify and Save';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get enterEmailToReceiveCode =>
      'Enter your email address to receive a verification code.';

  @override
  String get invalidEmailError => 'Please enter a valid email.';

  @override
  String get sendCode => 'Send Code';

  @override
  String get emailSendError => 'Unable to send email. Check the address.';

  @override
  String get unknownError => 'An error occurred.';

  @override
  String get otpTitle => 'Verification';

  @override
  String get enterCode => 'Enter the code';

  @override
  String otpSentTo(String email) {
    return 'We sent a 6-digit code to\n$email';
  }

  @override
  String get otpLabel => '6-digit code';

  @override
  String get otpInvalidError => 'Please enter a valid code.';

  @override
  String get verifyButton => 'Verify';

  @override
  String get otpIncorrectError => 'Incorrect code. Please try again.';

  @override
  String get resetPasswordTitle => 'New Password';

  @override
  String get createNewPassword => 'Create a new password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordMismatch => 'Passwords do not match.';

  @override
  String get validate => 'Valider';

  @override
  String get passwordChangedSuccess => 'Password changed successfully!';

  @override
  String get resetFailed =>
      'Unable to change the password. The code may have expired.';

  @override
  String get unexpectedError => 'An unexpected error occurred.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get deleteAll => 'Delete all';

  @override
  String get deleteAllConfirmationTitle => 'Confirmation';

  @override
  String get deleteAllConfirmationMessage =>
      'Do you really want to delete all your notifications? This action is irreversible.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get loadNotificationsError => 'Unable to load notifications.';

  @override
  String get markAllAsReadError => 'Error: Unable to mark as read.';

  @override
  String get deleteAllError => 'Error: Unable to delete all.';

  @override
  String get oops => 'Oops!';

  @override
  String get noNotificationsTitle => 'No notifications';

  @override
  String get noNotificationsMessage =>
      'Your important notifications will appear here.';

  @override
  String notificationDeleted(String title) {
    return 'Notification \"$title\" deleted.';
  }

  @override
  String get searchParishTitle => 'Search a parish';

  @override
  String get searchHint => 'Parish, city, district...';

  @override
  String get parishesSectionTitle => 'Parishes';

  @override
  String get retryButton => 'Retry';

  @override
  String get loadingErrorMessage => 'Unable to load data';

  @override
  String get noParishesFound => 'No parish found.';

  @override
  String get noParishesAvailable => 'No parish available.';

  @override
  String get unknownParish => 'Unknown parish';

  @override
  String get detailsButton => 'Details';

  @override
  String get internetError => 'No Internet connection. Check your network.';

  @override
  String get connectionError => 'Connection error.';

  @override
  String get descriptionUnavailable => 'Description unavailable.';

  @override
  String get offeringSuggested => 'Suggested mass offering:';

  @override
  String get moreDetailsButton => 'More details';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get parishAddedFavorite => 'Parish added to favorites!';

  @override
  String get parishRemovedFavorite => 'Parish removed from favorites.';

  @override
  String get favoritesUpdateError => 'Error updating favorites.';

  @override
  String get mapsOpenError => 'Unable to open map application.';

  @override
  String get events_title => 'Events';

  @override
  String get events_none => 'No event for this category';

  @override
  String get events_none_with_dot => 'No event for this category.';

  @override
  String get error_generic => 'An error occurred.';

  @override
  String get error_no_internet => 'No Internet. Check your network.';

  @override
  String get error_timeout => 'Server not responding. Try again later.';

  @override
  String get tab_all => 'All';

  @override
  String get requests_title => 'My requests';

  @override
  String get tab_in_progress => 'In progress';

  @override
  String get tab_history => 'History';

  @override
  String get tab_favorites => 'Favorites';

  @override
  String get error_loading => 'Loading error';

  @override
  String get list_updated => 'List updated';

  @override
  String get generic_error => 'Error';

  @override
  String get unknown_date => 'Unknown date';

  @override
  String get empty_requests => 'No request found';

  @override
  String get empty_favorites => 'No favorite';

  @override
  String get close => 'Close';

  @override
  String get pay_now => 'Pay now';

  @override
  String get print_receipt => 'Print receipt';

  @override
  String get request_details_title => 'Request details';

  @override
  String get intention => 'Intention';

  @override
  String get parish => 'Parish';

  @override
  String get date => 'Date';

  @override
  String get celebration => 'Celebration';

  @override
  String get intercessor => 'Intercessor';

  @override
  String get offering => 'Offering';

  @override
  String get no_favorite_title => 'No favorite';

  @override
  String get no_result_title => 'No result';

  @override
  String get no_favorite_message =>
      'You haven\'t added any parish to your favorites yet. Tap ⭐️ to add one.';

  @override
  String get no_result_message => 'No request matches this tab.';

  @override
  String get favorites_updated => 'Favorites updated';

  @override
  String get parish_data_invalid => 'Error: Invalid parish data';

  @override
  String favorite_removed(Object parishName) {
    return '\"$parishName\" removed from favorites';
  }

  @override
  String get favorite_remove_error => 'Error while removing favorite';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_event => 'Event';

  @override
  String get nav_requests => 'Requests';

  @override
  String get nav_parish => 'Parish';
}
