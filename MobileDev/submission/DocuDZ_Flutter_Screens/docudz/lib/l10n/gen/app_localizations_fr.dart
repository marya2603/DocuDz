// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'DocuDZ';

  @override
  String get tagline => 'Dossier prêt, esprit tranquille';

  @override
  String get greeting => 'Bonjour';

  @override
  String get homeHeadline => 'Quel dossier préparez-vous ?';

  @override
  String get searchHint => 'Rechercher une démarche, un document';

  @override
  String get offlineReady => 'Hors ligne OK';

  @override
  String get continueTitle => 'Reprendre où vous en étiez';

  @override
  String nextDocument(String document) {
    return 'Ensuite : $document';
  }

  @override
  String get continueAction => 'Reprendre';

  @override
  String get servicesTitle => 'Démarches';

  @override
  String docsProgress(int done, int total) {
    return '$done/$total documents';
  }

  @override
  String docsReadyOf(int done, int total) {
    return '$done documents prêts sur $total';
  }

  @override
  String verifiedShort(String date) {
    return 'Vérifié le $date';
  }

  @override
  String lastVerified(String date) {
    return 'Dernière vérification : $date';
  }

  @override
  String get navHome => 'Accueil';

  @override
  String get navCosts => 'Frais';

  @override
  String get navOffices => 'Bureaux';

  @override
  String get navSettings => 'Réglages';

  @override
  String get notOfficialTitle => 'Service non officiel';

  @override
  String get notOfficialBody =>
      'DocuDZ est un assistant indépendant. Il n\'est lié à aucune administration et ne dépose rien à votre place. Confirmez toujours auprès du guichet.';

  @override
  String get notOfficialFooter => 'Assistant indépendant. Service non officiel.';

  @override
  String get quickSteps => 'Étapes';

  @override
  String get quickCosts => 'Frais';

  @override
  String get quickOffice => 'Bureau';

  @override
  String get requiredDocuments => 'Documents à fournir';

  @override
  String remainingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count restants',
      one: '1 restant',
      zero: 'Tout est réuni',
    );
    return '$_temp0';
  }

  @override
  String copies(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count exemplaires', one: '1 exemplaire');
    return '$_temp0';
  }

  @override
  String issuedBy(String place) {
    return 'Délivré par : $place';
  }

  @override
  String get statusReady => 'Prêt';

  @override
  String get statusToGet => 'À obtenir';

  @override
  String get reportError => 'Signaler une erreur';

  @override
  String get reportErrorHint => 'Une info dépassée ? Dites-le nous, cela aide tout le monde.';

  @override
  String get allSetTitle => 'Tout est prêt !';

  @override
  String get allSetBody => 'Votre dossier est complet. Relisez les étapes avant de partir.';

  @override
  String get sheetWhere => 'Où l\'obtenir';

  @override
  String get sheetCopies => 'Exemplaires à apporter';

  @override
  String get sheetTip => 'Bon à savoir';

  @override
  String get markGathered => 'Marquer comme obtenu';

  @override
  String get markMissing => 'Marquer comme manquant';

  @override
  String checkboxSemantics(String document, String status) {
    return '$document, $status';
  }

  @override
  String get costsTitle => 'Calcul des timbres et frais';

  @override
  String get costsSubtitle => 'Sachez exactement quoi prévoir avant de partir.';

  @override
  String get sectionStampsFees => 'Timbres et frais officiels';

  @override
  String get sectionOther => 'Autres frais';

  @override
  String get subtotal => 'Sous-total';

  @override
  String get totalToBring => 'Total à prévoir';

  @override
  String get feesMayChange => 'Les tarifs peuvent changer, vérifiez la date de dernière vérification.';

  @override
  String get free => 'Gratuit';

  @override
  String get optional => 'Facultatif';

  @override
  String qtyTimes(int qty, String price) {
    return '$qty × $price';
  }

  @override
  String get decrease => 'Diminuer';

  @override
  String get increase => 'Augmenter';

  @override
  String get stampsTip =>
      'Les timbres fiscaux se vendent à la poste et à la recette des impôts, rarement au guichet lui-même.';

  @override
  String get currency => 'DA';

  @override
  String get stepsTitle => 'Étape par étape';

  @override
  String stepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count étapes', one: '1 étape');
    return '$_temp0';
  }

  @override
  String visitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'environ $count passages au guichet',
      one: 'environ 1 passage au guichet',
    );
    return '$_temp0';
  }

  @override
  String stepLabel(int n) {
    return 'Étape $n';
  }

  @override
  String get tipAvoidTrip => 'Astuce pour éviter un aller-retour';

  @override
  String get officeTitle => 'Infos du bureau';

  @override
  String get wilaya => 'Wilaya';

  @override
  String get openNow => 'Ouvert';

  @override
  String closesAt(String time) {
    return 'ferme à $time';
  }

  @override
  String get closedNow => 'Fermé';

  @override
  String opensAt(String time) {
    return 'ouvre à $time';
  }

  @override
  String get closedToday => 'Fermé aujourd\'hui';

  @override
  String get openingHours => 'Jours et horaires';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get closed => 'Fermé';

  @override
  String get address => 'Adresse';

  @override
  String get openInMaps => 'Ouvrir dans Maps';

  @override
  String get mapOfflineCaption => 'Aperçu de carte non stocké hors ligne';

  @override
  String get mapsSnack => 'Ouvre votre application de cartes si elle est installée.';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get language => 'Langue';

  @override
  String get languageHint => 'Toute l\'application change aussitôt, arabe de droite à gauche compris.';

  @override
  String get contentSection => 'Contenu';

  @override
  String get lastContentUpdate => 'Dernière mise à jour du contenu';

  @override
  String contentVersion(String version) {
    return 'Version du contenu $version';
  }

  @override
  String get checkForUpdates => 'Rechercher des mises à jour';

  @override
  String get upToDate => 'Vos listes sont à jour.';

  @override
  String get trustSection => 'Confiance et confidentialité';

  @override
  String get privacyTitle => 'Vos données restent sur ce téléphone';

  @override
  String get privacyBody => 'Seuls vos cochages et votre langue sont enregistrés. Pas de compte, pas de pistage.';

  @override
  String get premiumTitle => 'DocuDZ Premium';

  @override
  String premiumPrice(String currency) {
    return '500 $currency / an';
  }

  @override
  String get premiumFeatures => 'Sans publicité, plusieurs profils, rappels';

  @override
  String get comingLater => 'Bientôt';

  @override
  String get about => 'À propos';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get madeBy => 'Réalisé par DRIS Fadia et NEFRAOUI Marya, ENSIA';

  @override
  String get onboardingTitle => 'Choisissez votre langue';

  @override
  String get onboardingBody => 'Préparez vos dossiers administratifs hors ligne, une étape claire à la fois.';

  @override
  String get continueButton => 'Continuer';

  @override
  String searchNoResults(String query) {
    return 'Aucun résultat pour « $query »';
  }

  @override
  String get searchNoResultsHint => 'Essayez « passeport » ou « extrait de naissance ».';

  @override
  String get searchDocuments => 'Documents correspondants';

  @override
  String get reportTitle => 'Signaler une erreur';

  @override
  String reportSubtitle(String service, String date) {
    return '$service, vérifié le $date';
  }

  @override
  String get reportWhat => 'Qu\'est-ce qui semble faux ?';

  @override
  String get reportMissingDoc => 'Document manquant';

  @override
  String get reportWrongFee => 'Tarif erroné';

  @override
  String get reportWrongOffice => 'Bureau ou horaires erronés';

  @override
  String get reportOther => 'Autre';

  @override
  String get reportDetailsHint => 'Décrivez la correction à apporter (facultatif)';

  @override
  String get reportSend => 'Envoyer le signalement';

  @override
  String get reportOfflineNote => 'Pas besoin de connexion : le signalement part dès votre retour en ligne.';

  @override
  String get reportThanks => 'Merci ! Votre signalement est enregistré.';

  @override
  String get sampleData => 'Jeu de données d\'exemple (aperçu)';

  @override
  String get langArDesc => 'Arabe, affichage de droite à gauche';

  @override
  String get langFrDesc => 'Français';

  @override
  String get langEnDesc => 'Anglais';

  @override
  String get appVersion => '1.0.0 (aperçu MVP)';

  @override
  String get officeKindLabel => 'Où déposer';

  @override
  String get onbFeat1 => 'Des listes qui marchent hors ligne';

  @override
  String get onbFeat2 => 'Les timbres additionnés pour vous';

  @override
  String get onbFeat3 => 'Le bon bureau, les bons horaires';
}
