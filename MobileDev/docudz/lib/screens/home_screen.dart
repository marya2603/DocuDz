import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import '../widgets/chips.dart';
import '../widgets/common.dart';
import '../widgets/service_cards.dart';
import 'checklist_screen.dart';

/// S1. Service catalogue: greeting, search, "continue", 4 services (F1, F7, F8).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onSelectTab, this.initialQuery = ''});

  final ValueChanged<int>? onSelectTab;
  final String initialQuery;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final _controller = TextEditingController(text: widget.initialQuery);
  late String _query = widget.initialQuery;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openService(Service s) {
    AppScope.read(context).openService(s.id);
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ChecklistScreen(serviceId: s.id)));
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final services = state.catalog.services;
    final last = state.lastServiceId == null ? null : state.catalog.service(state.lastServiceId!);
    final q = _query.trim();

    return SafeArea(
      bottom: false,
      // Keep scrolled content out of the (edge-to-edge) status bar area.
      child: ClipRect(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.lg),
          children: [
            Row(
              children: [
                const BrandMark(size: 36),
                const SizedBox(width: AppSpacing.xs),
                const Wordmark(fontSize: 20),
                const Spacer(),
                const OfflineChip(key: ValueKey('home.offline')),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l.greeting, style: t.bodyLarge?.copyWith(color: AppColors.inkMuted)),
            Text(l.homeHeadline, key: const ValueKey('home.headline'), style: t.headlineMedium),
            const SizedBox(height: AppSpacing.md),
            TextField(
              key: const ValueKey('home.search'),
              controller: _controller,
              onChanged: (v) => setState(() => _query = v),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: q.isEmpty
                    ? null
                    : IconButton(
                        tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => setState(() {
                          _controller.clear();
                          _query = '';
                        }),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (q.isEmpty) ...[
              if (last != null) ...[
                SectionHeader(title: l.continueTitle),
                ContinueCard(key: const ValueKey('home.continue'), service: last, onContinue: () => _openService(last)),
                const SizedBox(height: AppSpacing.lg),
              ],
              SectionHeader(key: const ValueKey('home.servicesHeader'), title: l.servicesTitle),
              for (final s in services) ...[
                ServiceCard(key: ValueKey('home.card.${s.id}'), service: s, onTap: () => _openService(s)),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.sm),
              const NotOfficialNotice(key: ValueKey('home.notice'), compact: true),
            ] else
              ..._results(context, q),
          ],
        ),
      ),
    );
  }

  List<Widget> _results(BuildContext context, String q) {
    final state = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final t = Theme.of(context).textTheme;
    final services = state.catalog.services.where((s) => s.title.contains(q) || s.subtitle.contains(q)).toList();
    final docs = [
      for (final s in state.catalog.services)
        for (final d in s.documents)
          if (d.name.contains(q)) (s, d),
    ];
    if (services.isEmpty && docs.isEmpty) {
      return [
        EmptyState(
          key: const ValueKey('home.empty'),
          icon: Icons.search_off_rounded,
          title: l.searchNoResults(q),
          body: l.searchNoResultsHint,
        ),
      ];
    }
    return [
      for (final s in services) ...[
        ServiceCard(service: s, onTap: () => _openService(s)),
        const SizedBox(height: AppSpacing.sm),
      ],
      if (docs.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.xs),
        SectionHeader(title: l.searchDocuments),
        Card(
          child: Column(
            children: [
              for (final (i, (s, d)) in docs.indexed) ...[
                if (i > 0) const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
                ListTile(
                  leading: ServiceIconTile(service: s, size: 40),
                  title: Text(d.name.of(locale)),
                  subtitle: Text(s.title.of(locale), style: t.bodyMedium),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _openService(s),
                ),
              ],
            ],
          ),
        ),
      ],
    ];
  }
}
