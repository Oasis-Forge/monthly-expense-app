import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';

/// Four pages on what the app does, after setup and before Home: quick
/// entry, planning, insights, and privacy. Every page can skip to the end,
/// and Settings can play it again (RUN-4, RUN-5).
class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key, this.replay = false});

  /// Opened from Settings rather than on a first launch: it closes instead of
  /// opening Home.
  final bool replay;

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Each page's icon, title, and text.
  List<(IconData, String, String)> _pages(AppLocalizations l10n) => [
    (
      Icons.bolt_outlined,
      l10n.walkthroughEntryTitle,
      l10n.walkthroughEntryBody,
    ),
    (
      Icons.event_repeat_outlined,
      l10n.walkthroughPlanTitle,
      l10n.walkthroughPlanBody,
    ),
    (
      Icons.insights_outlined,
      l10n.walkthroughInsightsTitle,
      l10n.walkthroughInsightsBody,
    ),
    (
      Icons.lock_outline,
      l10n.walkthroughPrivacyTitle,
      l10n.walkthroughPrivacyBody,
    ),
  ];

  /// Ends the walkthrough, read or skipped: it has had its turn (RUN-5).
  Future<void> _finish() async {
    if (widget.replay) {
      Navigator.of(context).pop();
      return;
    }
    await context.read<SettingsProvider>().completeWalkthrough();
  }

  Future<void> _next(int pageCount) async {
    if (_page >= pageCount - 1) return _finish();
    // A device asking for less movement gets none (RUN-4).
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(_page + 1);
    } else {
      await _controller.animateToPage(
        _page + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final pages = _pages(l10n);
    final last = _page == pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    widget.replay
                        ? l10n.walkthroughDoneButton
                        : l10n.skipButton,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (page) => setState(() => _page = page),
                itemBuilder: (context, index) {
                  final (icon, title, body) = pages[index];
                  return _Page(icon: icon, title: title, body: body);
                },
              ),
            ),
            Semantics(
              container: true,
              label: l10n.walkthroughProgress(_page + 1, pages.length),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var page = 0; page < pages.length; page++)
                    Container(
                      width: page == _page ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: page == _page
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _next(pages.length),
                  child: Text(
                    !last
                        ? l10n.walkthroughNextButton
                        : widget.replay
                        ? l10n.walkthroughDoneButton
                        : l10n.walkthroughStartButton,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One walkthrough page, its content in the middle of the page. It scrolls
/// instead when large text needs the room (LANG-6).
class _Page extends StatelessWidget {
  const _Page({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 88, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
