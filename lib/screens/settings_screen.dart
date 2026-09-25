import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/languages.dart';
import '../models/app_theme.dart';
import '../models/currencies.dart';
import '../models/period.dart';
import '../models/reminders.dart';
import '../models/transaction_filter.dart' show foldForSearch;
import '../providers/ads_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/authenticator.dart';
import '../services/links.dart';
import '../services/reminder_service.dart';
import 'accounts_screen.dart';
import 'backup_screen.dart';
import 'categories_screen.dart';
import 'remove_ads_screen.dart';
import 'trash_screen.dart';
import 'walkthrough_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static void _open(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  /// Changes the language, then re-words the reminders already scheduled for
  /// notes (NOTE-6), which otherwise stay in the old one until the next
  /// launch.
  static Future<void> _setLanguage(BuildContext context, String? code) async {
    final settings = context.read<SettingsProvider>();
    final transactions = context.read<TransactionProvider>();
    await settings.setLanguageCode(code);
    await transactions.rescheduleReminders(
      appLockOn: settings.appLock,
      locale: effectiveAppLocale(settings.locale),
      nudge: settings.nudgeSettings,
    );
  }

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
          ChoiceTile<String?>(
            icon: Icons.language,
            title: l10n.languageLabel,
            value: settings.languageCode,
            options: [
              (null, l10n.languageSystem),
              for (final MapEntry(key: code, value: name)
                  in appLanguages.entries)
                (code, name),
            ],
            onChanged: (code) => _setLanguage(context, code),
          ),
          ListTile(
            leading: const Icon(Icons.payments_outlined),
            title: Text(l10n.currencyLabel),
            subtitle: Text(currencyName(settings.currencyCode)),
            onTap: () => _pickCurrency(context),
          ),
          // One row, four choices: black is dark with different surfaces
          // rather than a switch of its own (THEME-1).
          ChoiceTile<AppTheme>(
            icon: Icons.brightness_6_outlined,
            title: l10n.themeLabel,
            value: settings.appTheme,
            options: [
              (AppTheme.system, l10n.themeSystem),
              (AppTheme.light, l10n.themeLight),
              (AppTheme.dark, l10n.themeDark),
              (AppTheme.black, l10n.themeBlack),
            ],
            onChanged: settings.setTheme,
          ),
          ChoiceTile<int>(
            icon: Icons.event_outlined,
            title: l10n.monthStartLabel,
            value: settings.startDay,
            options: [
              for (var day = 1; day <= 28; day++) (day, '$day'),
              (Period.lastDayOfMonth, l10n.monthStartLastDay),
            ],
            onChanged: (day) => _setStartDay(context, day),
          ),
          ChoiceTile<int?>(
            icon: Icons.view_week_outlined,
            title: l10n.weekStartLabel,
            value: settings.weekStartDay,
            options: [
              (
                null,
                l10n.weekStartDefault(
                  weekday(
                    // PER-4: the device's own region when it matches the
                    // app's language, else the language's own default.
                    deviceWeekStartIndex(
                          WidgetsBinding.instance.platformDispatcher.locales,
                          Localizations.localeOf(context).languageCode,
                        ) ??
                        MaterialLocalizations.of(context).firstDayOfWeekIndex,
                  ),
                ),
              ),
              for (var day = 0; day < 7; day++) (day, weekday(day)),
            ],
            onChanged: settings.setWeekStartDay,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.redo),
            title: Text(l10n.showCarriedForwardLabel),
            subtitle: Text(l10n.showCarriedForwardSubtitle),
            value: settings.showCarriedForward,
            onChanged: settings.setShowCarriedForward,
          ),
          const _AppLockTile(),
          SwitchListTile(
            secondary: const Icon(Icons.widgets_outlined),
            title: Text(l10n.widgetShowAmountsLabel),
            subtitle: Text(l10n.widgetShowAmountsSubtitle),
            value: settings.showWidgetAmounts,
            // Only app lock hides them, so off the setting says nothing
            // (WID-4).
            onChanged: settings.appLock ? settings.setShowWidgetAmounts : null,
          ),
          const _NudgeTile(),
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
          ListTile(
            leading: const Icon(Icons.slideshow_outlined),
            title: Text(l10n.walkthroughReplayTitle),
            subtitle: Text(l10n.walkthroughReplaySubtitle),
            trailing: const Icon(Icons.chevron_right),
            // RUN-4: the same four pages, closing back to Settings.
            onTap: () => _open(context, const WalkthroughScreen(replay: true)),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyPolicyTitle),
            trailing: const Icon(Icons.open_in_new),
            // In the device's browser, so the app itself fetches nothing
            // (RUN-2); every build shows it, the desktop ones included.
            onTap: () => openInBrowser(privacyPolicyUrl),
          ),
          const _AdsRows(),
        ],
      ),
    );
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

/// The currency's code and English name, as the currency rows show it
/// (CUR-1). Shared with the setup page (RUN-3).
String currencyName(String code) {
  for (final (currency, name) in currencies) {
    if (currency == code) return '$code · $name';
  }
  return code;
}

/// A setting that shows its current choice and opens the options in a
/// dialog, so long names in any language never squeeze the row (LANG-6).
class ChoiceTile<T> extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final T value;

  /// Each option's value and label.
  final List<(T, String)> options;
  final ValueChanged<T> onChanged;

  Future<void> _choose(BuildContext context) async {
    // A record, so choosing a null option differs from dismissing the dialog.
    final chosen = await showDialog<(T,)>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: [
          for (final (option, label) in options)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop((option,)),
              child: Row(
                children: [
                  Expanded(child: Text(label)),
                  if (option == value) const Icon(Icons.check),
                ],
              ),
            ),
        ],
      ),
    );
    if (chosen != null && chosen.$1 != value) onChanged(chosen.$1);
  }

  @override
  Widget build(BuildContext context) {
    final current = options.where((option) => option.$1 == value).firstOrNull;
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: current == null ? null : Text(current.$2),
      onTap: () => _choose(context),
    );
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
    final transactions = context.read<TransactionProvider>();
    setState(() => _busy = true);
    final result = await authenticator.authenticate(
      l10n.appLockReason,
      hint: l10n.appLockPromptHint,
      cancelButton: l10n.cancelButton,
    );
    // Turning the lock off never needs a check the device can't perform.
    if (result == AuthResult.success ||
        (!on && result == AuthResult.unavailable)) {
      await settings.setAppLock(on);
      // LOCK-2: a reminder already scheduled would otherwise keep showing the
      // note's text on the lock screen until the next launch.
      await transactions.rescheduleReminders(
        appLockOn: on,
        locale: effectiveAppLocale(settings.locale),
        nudge: settings.nudgeSettings,
      );
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
    final query = foldForSearch(_query.trim());
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
                foldForSearch(code).contains(query) ||
                foldForSearch(name).contains(query))
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

/// "Remove ads" and, where the law asks for it, "Privacy options" (PAY-7,
/// ADS-5). Neither appears on the desktop builds, which have no ads.
class _AdsRows extends StatelessWidget {
  const _AdsRows();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ads = context.watch<AdsProvider>();
    if (!ads.supported) return const SizedBox.shrink();

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.block_outlined),
          title: Text(l10n.removeAdsTitle),
          // PAY-7: the whole of the selling, in one quiet row.
          subtitle: ads.adsRemoved ? Text(l10n.removeAdsOwned) : null,
          trailing: const Icon(Icons.chevron_right),
          onTap: () => SettingsScreen._open(context, const RemoveAdsScreen()),
        ),
        // ADS-5: only in the places whose law asks for the form, and the
        // SDK is what decides that.
        if (ads.privacyOptionsRequired)
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyOptionsTitle),
            subtitle: Text(l10n.privacyOptionsSubtitle),
            onTap: ads.showPrivacyOptions,
          ),
      ],
    );
  }
}

/// The empty-day nudge, and the time of day it fires (NUDGE-3 to NUDGE-6).
/// Nothing is offered where the phone cannot schedule one (NUDGE-10).
class _NudgeTile extends StatelessWidget {
  const _NudgeTile();

  /// Turns it on or off. Permission is asked the first time one is turned
  /// on, never before (NUDGE-7), and a refusal leaves the switch alone and
  /// everything else working.
  static Future<void> _set(BuildContext context, bool on) async {
    final l10n = AppLocalizations.of(context);
    final settings = context.read<SettingsProvider>();
    final transactions = context.read<TransactionProvider>();
    final reminders = context.read<ReminderService>();
    final messenger = ScaffoldMessenger.of(context);
    if (on && !await reminders.requestPermission()) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.nudgePermissionDenied)),
      );
      return;
    }
    await settings.setEmptyDayNudge(on);
    await settings.markNudgeOffered();
    await transactions.rescheduleReminders(
      appLockOn: settings.appLock,
      locale: effectiveAppLocale(settings.locale),
      nudge: settings.nudgeSettings,
    );
  }

  static Future<void> _pickTime(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final transactions = context.read<TransactionProvider>();
    final chosen = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.nudgeHour,
        minute: settings.nudgeMinute,
      ),
    );
    if (chosen == null) return;
    // An hour outside the waking ones comes back as the default, and the row
    // shows what was kept rather than what was asked for (NUDGE-6).
    await settings.setNudgeTime(chosen.hour, chosen.minute);
    await transactions.rescheduleReminders(
      appLockOn: settings.appLock,
      locale: effectiveAppLocale(settings.locale),
      nudge: settings.nudgeSettings,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!remindersSupported) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications_none),
          title: Text(l10n.nudgeSettingsTitle),
          // Off after giving up, the row says why rather than looking as
          // though the user turned it off themselves (NUDGE-5).
          // NUDGE-9: while it is on, the row also owns up to the delay,
          // because a reminder that lands at 9:04 is not a broken one.
          // NUDGE-7: a phone currently blocking notifications says so, on
          // top of everything else, since a switch left on with nothing
          // arriving is worse than one that explains itself.
          subtitle: Text(
            settings.emptyDayNudge && settings.notificationsBlocked
                ? l10n.nudgePermissionDenied
                : settings.nudgeStopped
                ? l10n.nudgeStoppedNotice
                : settings.emptyDayNudge
                ? '${l10n.nudgeSettingsSubtitle} ${l10n.reminderMayBeLate}'
                : l10n.nudgeSettingsSubtitle,
          ),
          value: settings.emptyDayNudge,
          onChanged: (on) => _set(context, on),
        ),
        if (settings.emptyDayNudge)
          ListTile(
            title: Text(l10n.noteReminderTimeLabel),
            trailing: Text(
              MaterialLocalizations.of(context).formatTimeOfDay(
                TimeOfDay(
                  hour: settings.nudgeHour,
                  minute: settings.nudgeMinute,
                ),
              ),
            ),
            onTap: () => _pickTime(context),
          ),
      ],
    );
  }
}
