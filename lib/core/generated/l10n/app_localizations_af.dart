// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Afrikaans (`af`).
class AppLocalizationsAf extends AppLocalizations {
  AppLocalizationsAf([String locale = 'af']) : super(locale);

  @override
  String get appName => '4Rigtings';

  @override
  String get loginTitle => 'Welkom Terug';

  @override
  String get loginEmailHint => 'E-posadres';

  @override
  String get loginPasswordHint => 'Wagwoord';

  @override
  String get loginButton => 'Teken in';

  @override
  String get loginForgotPassword => 'Wagwoord vergeet?';

  @override
  String get dashboardTitle => 'Kontroleskerm';

  @override
  String get dashboardAnimals => 'Diere';

  @override
  String get dashboardFields => 'Lande';

  @override
  String get dashboardAlerts => 'Waarskuwings';

  @override
  String get cattleTitle => 'Beeste';

  @override
  String get goatTitle => 'Bokke';

  @override
  String get poultryTitle => 'Pluimvee';

  @override
  String get cropTitle => 'Gewasse';

  @override
  String get traceabilityTitle => 'Naspeurbaarheid';

  @override
  String get payrollTitle => 'Loonlys';

  @override
  String get insightsTitle => 'Insigte';

  @override
  String get addAnimal => 'Dier Byvoeg';

  @override
  String get addFlock => 'Kudde Byvoeg';

  @override
  String get saveButton => 'Stoor';

  @override
  String get cancelButton => 'Kanselleer';

  @override
  String get deleteButton => 'Verwyder';

  @override
  String get editButton => 'Redigeer';

  @override
  String get searchHint => 'Soek…';

  @override
  String trialExpiresSoon(int days) {
    return 'Proeftydperk verval oor $days dag(e). Gradeer op om voort te gaan.';
  }

  @override
  String get upgradeNow => 'Gradeer Nou Op';

  @override
  String get errorGeneral =>
      'Iets het verkeerd gegaan. Probeer asseblief weer.';

  @override
  String get errorNetwork =>
      'Geen internetverbinding nie. Kontroleer u netwerk.';

  @override
  String get errorUnauthorized => 'Sessie verval. Teken asseblief weer in.';

  @override
  String get logoutButton => 'Teken uit';

  @override
  String get settingsTitle => 'Instellings';

  @override
  String get profileTitle => 'My Profiel';
}
