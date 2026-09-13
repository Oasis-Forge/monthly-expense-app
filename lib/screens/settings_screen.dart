import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/currencies.dart';
import '../models/period.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/authenticator.dart';
import 'accounts_screen.dart';
import 'backup_screen.dart';
import 'categories_screen.dart';
import 'trash_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static void _open(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();
    // 1 January 2023 was a Sunday, so day 0 of the week is its date.
    String weekday(int day) =>
        DateFormat.EEEE(l10n.localeName).format(DateTime(2023, 1, 1 + day));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.payments_outlined),
            title: Text(l10n.currencyLabel),
            subtitle: Text(_currencyLabel(settings.currencyCode)),
            onTap: () => _pickCurrency(context),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: Text(l10n.themeLabel),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              onChanged: (mode) {
                if (mode != null) settings.setThemeMode(mode);
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(l10n.themeSystem),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(l10n.themeLight),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(l10n.themeDark),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.event_outlined),
            title: Text(l10n.monthStartLabel),
            trailing: DropdownButton<int>(
              value: settings.startDay,
              onChanged: (day) {
                if (day != null) _setStartDay(context, day);
              },
              items: [
                for (var day = 1; day <= 28; day++)
                  DropdownMenuItem(value: day, child: Text('$day')),
                DropdownMenuItem(
                  value: Period.lastDayOfMonth,
                  child: Text(l10n.monthStartLastDay),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.view_week_outlined),
            title: Text(l10n.weekStartLabel),
            trailing: DropdownButton<int?>(
              value: settings.weekStartDay,
              onChanged: settings.setWeekStartDay,
              items: [
                DropdownMenuItem(
                  child: Text(
                    l10n.weekStartDefault(
                      weekday(
                        MaterialLocalizations.of(context).firstDayOfWeekIndex,
                      ),
                    ),
                  ),
                ),
                for (var day = 0; day < 7; day++)
                  DropdownMenuItem(value: day, child: Text(weekday(day))),
              ],
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.redo),
            title: Text(l10n.showCarriedForwardLabel),
            subtitle: Text(l10n.showCarriedForwardSubtitle),
            value: settings.showCarriedForward,
            onChanged: settings.setShowCarriedForward,
          ),
          const _AppLockTile(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: Text(l10n.accountsTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, const AccountsScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: Text(l10n.categoriesTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, const CategoriesScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: Text(l10n.backupTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, const BackupScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(l10n.trashTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, const TrashScreen()),
          ),
        ],
      ),
    );
  }

  static String _currencyLabel(String code) {
    for (final (currency, name) in currencies) {
      if (currency == code) return '$code · $name';
    }
    return code;
  }

  /// Saves the start day and moves the home screen to the matching period.
  static Future<void> _setStartDay(BuildContext context, int day) async {
    final transactions = context.read<TransactionProvider>();
    await context.read<SettingsProvider>().setStartDay(day);
    transactions.setStartDay(day);
  }

  /// Picks a currency, then confirms, because the change relabels every
  /// amount without converting it (CUR-3).
  static Future<void> _pickCurrency(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final l10n = AppLocalizations.of(context);
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => CurrencyPickerScreen(selected: settings.currencyCode),
      ),
    );
    if (code == null || code == settings.currencyCode || !context.mounted) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.changeCurrencyTitle(code)),
        content: Text(l10n.changeCurrencyMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.changeButton),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await settings.setCurrencyCode(code);
  }
}

/// Turns app lock on or off after the device owner authenticates (LOCK-1,
/// LOCK-3). Disabled when the device has no biometrics or screen lock.
class _AppLockTile extends StatefulWidget {
  const _AppLockTile();

  @override
  State<_AppLockTile> createState() => _AppLockTileState();
}

class _AppLockTileState extends State<_AppLockTile> {
  late final Future<bool> _available = context
      .read<Authenticator>()
      .isAvailable();
  bool _busy = false;

  Future<void> _toggle(bool on) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final settings = context.read<SettingsProvider>();
    final authenticator = context.read<Authenticator>();
    setState(() => _busy = true);
    final result = await authenticator.authenticate(l10n.appLockReason);
    // Turning the lock off never needs a check the device can't perform.
    if (result == AuthResult.success ||
        (!on && result == AuthResult.unavailable)) {
      await settings.setAppLock(on);
    } else {
      messenger.showSnackBar(SnackBar(content: Text(l10n.appLockFailed)));
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();
    return FutureBuilder<bool>(
      future: _available,
      builder: (context, snapshot) {
        final available = snapshot.data ?? false;
        return SwitchListTile(
          secondary: const Icon(Icons.lock_outline),
          title: Text(l10n.appLockLabel),
          subtitle: Text(
            available || settings.appLock
                ? l10n.appLockSubtitle
                : l10n.appLockUnavailable,
          ),
          value: settings.appLock,
          onChanged: (available || settings.appLock) && !_busy ? _toggle : null,
        );
      },
    );
  }
}

/// A searchable currency list (CUR-1); pops the chosen ISO code.
class CurrencyPickerScreen extends StatefulWidget {
  const CurrencyPickerScreen({super.key, required this.selected});

  final String selected;

  @override
  State<CurrencyPickerScreen> createState() => _CurrencyPickerScreenState();
}

class _CurrencyPickerScreenState extends State<CurrencyPickerScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = _query.trim().toLowerCase();
    final options = [
      // Keep a preselected code the list doesn't have.
      if (!currencies.any((c) => c.$1 == widget.selected))
        (widget.selected, widget.selected),
      ...currencies,
    ];

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.currencySearchHint,
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
      ),
      body: ListView(
        children: [
          for (final (code, name) in options)
            if (query.isEmpty ||
                code.toLowerCase().contains(query) ||
                name.toLowerCase().contains(query))
              ListTile(
                leading: SizedBox(
                  width: 48,
                  child: Text(
                    code,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(name),
                trailing: code == widget.selected
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(context).pop(code),
              ),
        ],
      ),
    );
  }
}
