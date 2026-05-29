// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => '4Directions';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginEmailHint => 'Email address';

  @override
  String get loginPasswordHint => 'Password';

  @override
  String get loginButton => 'Sign in';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardAnimals => 'Animals';

  @override
  String get dashboardFields => 'Fields';

  @override
  String get dashboardAlerts => 'Alerts';

  @override
  String get cattleTitle => 'Cattle';

  @override
  String get goatTitle => 'Goats';

  @override
  String get poultryTitle => 'Poultry';

  @override
  String get cropTitle => 'Crops';

  @override
  String get traceabilityTitle => 'Traceability';

  @override
  String get payrollTitle => 'Payroll';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get addAnimal => 'Add Animal';

  @override
  String get addFlock => 'Add Flock';

  @override
  String get saveButton => 'Save';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteButton => 'Delete';

  @override
  String get editButton => 'Edit';

  @override
  String get searchHint => 'Search…';

  @override
  String trialExpiresSoon(int days) {
    return 'Trial expires in $days day(s). Upgrade to continue.';
  }

  @override
  String get upgradeNow => 'Upgrade Now';

  @override
  String get errorGeneral => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'No internet connection. Check your network.';

  @override
  String get errorUnauthorized => 'Session expired. Please sign in again.';

  @override
  String get logoutButton => 'Sign out';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get profileTitle => 'My Profile';
}
