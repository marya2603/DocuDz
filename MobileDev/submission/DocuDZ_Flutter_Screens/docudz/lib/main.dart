import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/progress_store.dart';
import 'data/services_repository.dart';
import 'screens/onboarding_screen.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Date symbols for ar_DZ / fr / en are compiled in: no network needed.
  await initializeDateFormatting();
  final catalog = await const ServicesRepository().load(rootBundle);
  final store = InMemoryProgressStore();
  final firstLaunch = store.loadLanguage() == null;
  final state = AppState(catalog: catalog, store: store);
  runApp(DocuDzApp(state: state, home: firstLaunch ? const OnboardingScreen() : null));
}
