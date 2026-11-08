import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
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
/// import 'gen/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ar'), Locale('en'), Locale('fr')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'DocuDZ'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'All set, stress less'**
  String get tagline;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get greeting;

  /// No description provided for @homeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Which file are you preparing?'**
  String get homeHeadline;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search a service or document'**
  String get searchHint;

  /// No description provided for @offlineReady.
  ///
  /// In en, this message translates to:
  /// **'Offline ready'**
  String get offlineReady;

  /// No description provided for @continueTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue where you left off'**
  String get continueTitle;

  /// No description provided for @nextDocument.
  ///
  /// In en, this message translates to:
  /// **'Next: {document}'**
  String nextDocument(String document);

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @servicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get servicesTitle;

  /// No description provided for @docsProgress.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} documents'**
  String docsProgress(int done, int total);

  /// No description provided for @docsReadyOf.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} documents ready'**
  String docsReadyOf(int done, int total);

  /// No description provided for @verifiedShort.
  ///
  /// In en, this message translates to:
  /// **'Verified {date}'**
  String verifiedShort(String date);

  /// No description provided for @lastVerified.
  ///
  /// In en, this message translates to:
  /// **'Last verified: {date}'**
  String lastVerified(String date);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCosts.
  ///
  /// In en, this message translates to:
  /// **'Costs'**
  String get navCosts;

  /// No description provided for @navOffices.
  ///
  /// In en, this message translates to:
  /// **'Offices'**
  String get navOffices;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @notOfficialTitle.
  ///
  /// In en, this message translates to:
  /// **'Not an official service'**
  String get notOfficialTitle;

  /// No description provided for @notOfficialBody.
  ///
  /// In en, this message translates to:
  /// **'DocuDZ is an independent assistant. It is not affiliated with any administration and never submits anything for you. Always confirm with the office.'**
  String get notOfficialBody;

  /// No description provided for @notOfficialFooter.
  ///
  /// In en, this message translates to:
  /// **'Independent assistant. Not an official service.'**
  String get notOfficialFooter;

  /// No description provided for @quickSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get quickSteps;

  /// No description provided for @quickCosts.
  ///
  /// In en, this message translates to:
  /// **'Costs'**
  String get quickCosts;

  /// No description provided for @quickOffice.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get quickOffice;

  /// No description provided for @requiredDocuments.
  ///
  /// In en, this message translates to:
  /// **'Required documents'**
  String get requiredDocuments;

  /// No description provided for @remainingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{All gathered} =1{1 left} other{{count} left}}'**
  String remainingCount(int count);

  /// No description provided for @copies.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 copy} other{{count} copies}}'**
  String copies(int count);

  /// No description provided for @issuedBy.
  ///
  /// In en, this message translates to:
  /// **'Issued by: {place}'**
  String issuedBy(String place);

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get statusReady;

  /// No description provided for @statusToGet.
  ///
  /// In en, this message translates to:
  /// **'To get'**
  String get statusToGet;

  /// No description provided for @reportError.
  ///
  /// In en, this message translates to:
  /// **'Report an error'**
  String get reportError;

  /// No description provided for @reportErrorHint.
  ///
  /// In en, this message translates to:
  /// **'Spotted something outdated? Tell us, it helps everyone.'**
  String get reportErrorHint;

  /// No description provided for @allSetTitle.
  ///
  /// In en, this message translates to:
  /// **'All set!'**
  String get allSetTitle;

  /// No description provided for @allSetBody.
  ///
  /// In en, this message translates to:
  /// **'Your file is complete. Review the steps before you go.'**
  String get allSetBody;

  /// No description provided for @sheetWhere.
  ///
  /// In en, this message translates to:
  /// **'Where to get it'**
  String get sheetWhere;

  /// No description provided for @sheetCopies.
  ///
  /// In en, this message translates to:
  /// **'Copies to bring'**
  String get sheetCopies;

  /// No description provided for @sheetTip.
  ///
  /// In en, this message translates to:
  /// **'Good to know'**
  String get sheetTip;

  /// No description provided for @markGathered.
  ///
  /// In en, this message translates to:
  /// **'Mark as gathered'**
  String get markGathered;

  /// No description provided for @markMissing.
  ///
  /// In en, this message translates to:
  /// **'Mark as not gathered'**
  String get markMissing;

  /// No description provided for @checkboxSemantics.
  ///
  /// In en, this message translates to:
  /// **'{document}, {status}'**
  String checkboxSemantics(String document, String status);

  /// No description provided for @costsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stamp & fee calculator'**
  String get costsTitle;

  /// No description provided for @costsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Know exactly what to bring before you go.'**
  String get costsSubtitle;

  /// No description provided for @sectionStampsFees.
  ///
  /// In en, this message translates to:
  /// **'Stamps & official fees'**
  String get sectionStampsFees;

  /// No description provided for @sectionOther.
  ///
  /// In en, this message translates to:
  /// **'Other costs'**
  String get sectionOther;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @totalToBring.
  ///
  /// In en, this message translates to:
  /// **'Total to bring'**
  String get totalToBring;

  /// No description provided for @feesMayChange.
  ///
  /// In en, this message translates to:
  /// **'Fees may change, check the last verified date.'**
  String get feesMayChange;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @qtyTimes.
  ///
  /// In en, this message translates to:
  /// **'{qty} × {price}'**
  String qtyTimes(int qty, String price);

  /// No description provided for @decrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get decrease;

  /// No description provided for @increase.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increase;

  /// No description provided for @stampsTip.
  ///
  /// In en, this message translates to:
  /// **'Fiscal stamps are sold at post offices and tax offices, rarely at the counter itself.'**
  String get stampsTip;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'DZD'**
  String get currency;

  /// No description provided for @stepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step'**
  String get stepsTitle;

  /// No description provided for @stepsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}}'**
  String stepsCount(int count);

  /// No description provided for @visitsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{about 1 office visit} other{about {count} office visits}}'**
  String visitsCount(int count);

  /// No description provided for @stepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {n}'**
  String stepLabel(int n);

  /// No description provided for @tipAvoidTrip.
  ///
  /// In en, this message translates to:
  /// **'Tip to avoid an extra trip'**
  String get tipAvoidTrip;

  /// No description provided for @officeTitle.
  ///
  /// In en, this message translates to:
  /// **'Office information'**
  String get officeTitle;

  /// No description provided for @wilaya.
  ///
  /// In en, this message translates to:
  /// **'Wilaya'**
  String get wilaya;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get openNow;

  /// No description provided for @closesAt.
  ///
  /// In en, this message translates to:
  /// **'closes at {time}'**
  String closesAt(String time);

  /// No description provided for @closedNow.
  ///
  /// In en, this message translates to:
  /// **'Closed now'**
  String get closedNow;

  /// No description provided for @opensAt.
  ///
  /// In en, this message translates to:
  /// **'opens at {time}'**
  String opensAt(String time);

  /// No description provided for @closedToday.
  ///
  /// In en, this message translates to:
  /// **'Closed today'**
  String get closedToday;

  /// No description provided for @openingHours.
  ///
  /// In en, this message translates to:
  /// **'Opening days & hours'**
  String get openingHours;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @openInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get openInMaps;

  /// No description provided for @mapOfflineCaption.
  ///
  /// In en, this message translates to:
  /// **'Map preview is not stored offline'**
  String get mapOfflineCaption;

  /// No description provided for @mapsSnack.
  ///
  /// In en, this message translates to:
  /// **'Opens your Maps app when one is installed.'**
  String get mapsSnack;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageHint.
  ///
  /// In en, this message translates to:
  /// **'The whole app switches instantly, including right-to-left Arabic.'**
  String get languageHint;

  /// No description provided for @contentSection.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get contentSection;

  /// No description provided for @lastContentUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last content update'**
  String get lastContentUpdate;

  /// No description provided for @contentVersion.
  ///
  /// In en, this message translates to:
  /// **'Content version {version}'**
  String contentVersion(String version);

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdates;

  /// No description provided for @upToDate.
  ///
  /// In en, this message translates to:
  /// **'Your checklists are up to date.'**
  String get upToDate;

  /// No description provided for @trustSection.
  ///
  /// In en, this message translates to:
  /// **'Trust & privacy'**
  String get trustSection;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on this phone'**
  String get privacyTitle;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'Only your ticks and your language are saved. No account, no tracking.'**
  String get privacyBody;

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'DocuDZ Premium'**
  String get premiumTitle;

  /// No description provided for @premiumPrice.
  ///
  /// In en, this message translates to:
  /// **'500 {currency} / year'**
  String premiumPrice(String currency);

  /// No description provided for @premiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Ad-free, several profiles, reminders'**
  String get premiumFeatures;

  /// No description provided for @comingLater.
  ///
  /// In en, this message translates to:
  /// **'Coming later'**
  String get comingLater;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @madeBy.
  ///
  /// In en, this message translates to:
  /// **'Made by DRIS Fadia & NEFRAOUI Marya, ENSIA'**
  String get madeBy;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get onboardingTitle;

  /// No description provided for @onboardingBody.
  ///
  /// In en, this message translates to:
  /// **'Prepare your administrative files offline, one clear step at a time.'**
  String get onboardingBody;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results for “{query}”'**
  String searchNoResults(String query);

  /// No description provided for @searchNoResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try “passport” or “birth certificate”.'**
  String get searchNoResultsHint;

  /// No description provided for @searchDocuments.
  ///
  /// In en, this message translates to:
  /// **'Matching documents'**
  String get searchDocuments;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report an error'**
  String get reportTitle;

  /// No description provided for @reportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{service}, last verified {date}'**
  String reportSubtitle(String service, String date);

  /// No description provided for @reportWhat.
  ///
  /// In en, this message translates to:
  /// **'What looks wrong?'**
  String get reportWhat;

  /// No description provided for @reportMissingDoc.
  ///
  /// In en, this message translates to:
  /// **'Missing document'**
  String get reportMissingDoc;

  /// No description provided for @reportWrongFee.
  ///
  /// In en, this message translates to:
  /// **'Wrong fee'**
  String get reportWrongFee;

  /// No description provided for @reportWrongOffice.
  ///
  /// In en, this message translates to:
  /// **'Wrong office or hours'**
  String get reportWrongOffice;

  /// No description provided for @reportOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportOther;

  /// No description provided for @reportDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what should be corrected (optional)'**
  String get reportDetailsHint;

  /// No description provided for @reportSend.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get reportSend;

  /// No description provided for @reportOfflineNote.
  ///
  /// In en, this message translates to:
  /// **'No connection needed: the report is queued and sent when you are back online.'**
  String get reportOfflineNote;

  /// No description provided for @reportThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Your report is saved.'**
  String get reportThanks;

  /// No description provided for @sampleData.
  ///
  /// In en, this message translates to:
  /// **'Sample dataset (design preview)'**
  String get sampleData;

  /// No description provided for @langArDesc.
  ///
  /// In en, this message translates to:
  /// **'Arabic, right-to-left layout'**
  String get langArDesc;

  /// No description provided for @langFrDesc.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get langFrDesc;

  /// No description provided for @langEnDesc.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnDesc;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'1.0.0 (MVP preview)'**
  String get appVersion;

  /// No description provided for @officeKindLabel.
  ///
  /// In en, this message translates to:
  /// **'Where to submit'**
  String get officeKindLabel;

  /// No description provided for @onbFeat1.
  ///
  /// In en, this message translates to:
  /// **'Checklists that work offline'**
  String get onbFeat1;

  /// No description provided for @onbFeat2.
  ///
  /// In en, this message translates to:
  /// **'Stamp costs added up for you'**
  String get onbFeat2;

  /// No description provided for @onbFeat3.
  ///
  /// In en, this message translates to:
  /// **'The right office, days and hours'**
  String get onbFeat3;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
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
