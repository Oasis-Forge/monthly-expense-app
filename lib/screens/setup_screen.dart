import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/languages.dart';
import '../providers/settings_provider.dart';
import 'settings_screen.dart';

/// The first launch: one page for the language and the currency, both
/// preselected from the device, so most people only tap Continue. It asks for
/// nothing else, and the language chosen here is the one the walkthrough that
/// follows is read in (RUN-3).
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  static const _sides = EdgeInsets.symmetric(horizontal: 24);

  Future<void> _pickCurrency() async {
    final settings = context.read<SettingsProvider>();
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => CurrencyPickerScreen(selected: settings.currencyCode),
      ),
    );
    // No amounts exist yet, so the change needs no warning (CUR-3).
    if (code != null) await settings.setCurrencyCode(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          children: [
            Icon(
              Icons.savings_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: _sides,
              child: Text(
                l10n.firstRunTitle,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: _sides,
              child: Text(l10n.setupIntro, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            ChoiceTile<String>(
              icon: Icons.language,
              title: l10n.languageLabel,
              // The device's language until one is picked; the page switches
              // to it at once (LANG-1, RUN-3).
              value: Localizations.localeOf(context).languageCode,
              options: [
                for (final MapEntry(key: code, value: name)
                    in appLanguages.entries)
                  (code, name),
              ],
              onChanged: settings.setLanguageCode,
            ),
            ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: Text(l10n.currencyLabel),
              subtitle: Text(currencyName(settings.currencyCode)),
              onTap: _pickCurrency,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: settings.completeSetup,
                  child: Text(l10n.setupContinueButton),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
