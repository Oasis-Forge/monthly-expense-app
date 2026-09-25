import 'dart:async';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../l10n/languages.dart';
import '../models/budget.dart';
import '../models/csv_export.dart';
import '../models/insights.dart';
import '../models/money.dart';
import '../models/period.dart';
import '../models/reminders.dart';
import '../models/transaction.dart';
import '../models/transfer.dart';
import '../providers/ads_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/ads_config.dart';
import '../services/reminder_service.dart';
import 'account_filter_button.dart';
import 'accounts_screen.dart';
import 'ad_slot.dart';
import 'add_transaction_screen.dart';
import 'amount_style.dart';
import 'backup_screen.dart';
import 'budget_progress.dart';
import 'budgets_screen.dart';
import 'categories_screen.dart';
import 'csv_export_action.dart';
import 'day_strip.dart';
import 'delete_snack_bar.dart';
import 'haptics.dart';
import 'insights_screen.dart';
import 'notes_screen.dart';
import 'period_selector.dart';
import 'recurring_screen.dart';
import 'report_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'transaction_detail_screen.dart';
import 'transaction_row_menu.dart';
import 'transfer_screen.dart';
import 'trash_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  /// Opens [screen]. When leaving it is a seam (ADS-11), the full-screen ad
  /// is fetched on the way in — never waited for — and offered on the way
  /// back, once the screen it belonged to has gone (ADS-13, ADS-14).
  static void _open(BuildContext context, Widget screen) {
    // Home's own route, captured before the push: still there under
    // whatever [screen] pushes.
    final homeRoute = ModalRoute.of(context);
    final opened = Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => screen));
    if (screen is! InsightsScreen) return;
    // The providers outlive the route, so the way back needs no context.
    final ads = context.read<AdsProvider>();
    // Captured before the wait, so a shortcut or widget tap that fires while
    // Insights is open is caught even when it moves on to nothing at all —
    // popping straight back to Home for HomeWidgetAction.openHome, say —
    // and so leaves Home looking like the current route again by the time
    // this runs (rules-22-25-31-35#6).
    final navigationEpoch = ads.navigationEpoch;
    unawaited(ads.primeInterstitial());
    unawaited(
      opened.then((_) async {
        // A shortcut or widget tap can pop back to Home and immediately
        // push a fresh form in the same beat Insights' route future
        // resolves in, so Home is no longer on top by the time this runs.
        // Treat that exactly like ADS-13's "no ad ready" case rather than
        // show the full-screen ad over whatever opened instead (ADS-1,
        // ADS-11, ADS-14, rules-22-25-31-35#6). The same tap can also leave
        // Home on top with nothing pushed at all, which looks identical to
        // an ordinary "back to Home" unless the navigation epoch moved.
        if (homeRoute?.isCurrent != true ||
            ads.navigationEpoch != navigationEpoch) {
          await ads.dropPrimedInterstitial();
          return;
        }
        await ads.showAtSeam(AdSeam.leftInsights);
      }),
    );
  }

  /// Exports the selected period's transactions and transfers, across every
  /// account: the CSV export is one of the things the account choice must
  /// not reach, the same as budgets (ACC-7, BAK-5).
  static Future<void> _exportPeriod(
    BuildContext context,
    TransactionProvider provider,
  ) {
    final period = provider.period;
    return exportCsv(
      context,
      name: '${isoDate(period.start)}_${isoDate(period.lastDay)}',
      transactions: provider.everyAccountPeriodTransactions,
      transfers: provider.everyAccountPeriodTransfers,
    );
  }
}

/// Home's own state is the budgets card: whether the user has it open, and
/// whether the list being scrolled has folded it away for now (BUD-9). The
/// summary card needs no state — it is a header inside the same scroll, and
/// shrinks with it (BAL-7).
class _HomeScreenState extends State<HomeScreen> {
  final _budgets = ExpansibleController();

  /// What the user last chose for the budgets card; it starts closed (BUD-7).
  bool _budgetsWanted = false;

  /// Whether scrolling folded it away, so the top can put it back (BUD-9).
  bool _foldedByScroll = false;

  /// True while we drive the card ourselves, so its callback doesn't mistake
  /// our fold for the user closing it.
  bool _driving = false;

  /// Whether the card is on screen at all: without budgets there is nothing
  /// for the controller to talk to.
  bool _budgetsShown = false;

  /// Folds the budgets card while the list is scrolled, and puts it back when
  /// the list comes to rest at the top (BUD-9). Only the user's own scrolling
  /// counts: a correction the list makes to itself never folds anything, which
  /// is what kept the old summary card flickering.
  bool _onScroll(ScrollNotification notification) {
    if (!_budgetsShown) return false;
    // A drag, not a correction the list makes to itself: dragDetails is null
    // when the position is only being brought back inside its own bounds,
    // which is what kept the old summary card flickering.
    if (notification is ScrollUpdateNotification &&
        notification.dragDetails != null &&
        notification.metrics.pixels > 24 &&
        _budgetsWanted &&
        !_foldedByScroll) {
      _foldedByScroll = true;
      _driving = true;
      _budgets.collapse();
    } else if (notification is ScrollEndNotification &&
        notification.metrics.pixels <= 0 &&
        _foldedByScroll) {
      _foldedByScroll = false;
      _driving = true;
      _budgets.expand();
    }
    return false;
  }

  void _budgetsChanged(bool open) {
    if (_driving) {
      _driving = false;
      return;
    }
    _budgetsWanted = open;
    if (open) _foldedByScroll = false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final settings = context.watch<SettingsProvider>();
    final currency = settings.currencyFormat(l10n.localeName);
    final selectedDay = provider.selectedDay;
    // ACC-6: the account Home is showing, null while it shows every one.
    final chosenAccount = provider.accountFilterId == null
        ? null
        : provider.accountById(provider.accountFilterId!);
    // DAY-7: the chosen day on its own, whether or not it holds anything.
    final days = selectedDay != null
        ? [selectedDay]
        : ({
            ...provider.groupedByDay.keys,
            ...provider.transfersByDay.keys,
          }.toList()..sort((a, b) => b.compareTo(a)));
    // EMPTY-4: an empty day list because the account filter hides every row
    // is not the same as an empty period, and says so with a way back.
    final filterHidesRecords =
        chosenAccount != null &&
        days.isEmpty &&
        (provider.everyAccountPeriodTransactions.isNotEmpty ||
            provider.everyAccountPeriodTransfers.isNotEmpty);
    final dueCount = provider.dueOccurrences.length;
    final budgetStatuses = provider.budgetStatuses;
    final budgetSummary = BudgetSummary.of(budgetStatuses);
    // Whether there is a budgets card for _onScroll to fold (BUD-9).
    _budgetsShown = budgetSummary != null;
    final dueNotesCount = provider.notesDueInPeriod.length;
    final lastBackup = settings.lastBackupAt;
    // RUN-1: before anything is recorded, Home offers one clear action.
    final firstRun =
        provider.isLoaded &&
        provider.transactions.isEmpty &&
        provider.transfers.isEmpty &&
        provider.deletedTransactions.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: l10n.searchTooltip,
            onPressed: () => HomeScreen._open(context, const SearchScreen()),
          ),
          // NAV-6: the toolbar keeps two actions so the name still fits at
          // large text; Insights has three named rows in the drawer instead.
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTitle,
            onPressed: () => HomeScreen._open(context, const SettingsScreen()),
          ),
        ],
      ),
      // Everything that isn't Home lives here, named and grouped, instead of
      // behind a three-dot menu nobody opened (NAV-1, NAV-2).
      drawer: const _HomeDrawer(),
      body: Column(
        children: [
          // INS-4: the label opens the calendar for the period it names.
          PeriodSelector(
            onLabelTap: () =>
                HomeScreen._open(context, const InsightsScreen(initialTab: 1)),
          ),
          // DAY-1, DAY-2: the week under the period, today marked, on every
          // Home there is — the welcome included, so the day a first entry
          // lands on is never a surprise.
          const DayStrip(),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: CustomScrollView(
                slivers: [
                  // BAL-6, BAL-7: the summary is a header inside this scroll,
                  // pinned and shrinking to its one line as the entries go
                  // under it. Outside the scroll it resized their viewport
                  // instead, which dragged the list backwards under the
                  // finger and, on a short list, bounced the card open again.
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SummaryHeader(
                      income: provider.periodIncome,
                      expense: provider.periodExpense,
                      // BAL-3: the closing balance, unless carrying forward
                      // is off.
                      balance: settings.showCarriedForward
                          ? provider.closingBalance
                          : provider.periodNet,
                      carriedForward: settings.showCarriedForward
                          ? provider.carriedForward
                          : null,
                      currency: currency,
                      collapsedByHand: settings.summaryCollapsed,
                      onToggle: () => settings.setSummaryCollapsed(
                        !settings.summaryCollapsed,
                      ),
                      // ACC-6: null while Home shows every account. The
                      // default account's name is translated, so it comes
                      // through label() like everywhere else (LANG-2).
                      accountName: chosenAccount?.label(l10n),
                      // ACC-6: with one account there is nothing to switch to.
                      onPickAccount: provider.activeAccounts.length < 2
                          ? null
                          : () => pickAccountFilter(context),
                      // BAL-8: the number the app is opened to check. BAL-9:
                      // nothing at all while one account is chosen, since a
                      // budget counts every account (ACC-7) and the card is
                      // naming one.
                      heroLine: chosenAccount == null
                          ? provider.heroLine
                          : null,
                      // BUD-11: offered only while the current period has no
                      // overall budget, whichever period is on screen, and
                      // prefilled from the period before the current one so
                      // the first budget is a correction.
                      onSetBudget:
                          chosenAccount == null &&
                              provider.budgetLimit(
                                    null,
                                    provider.currentPeriod,
                                  ) ==
                                  null
                          ? () {
                              final last = provider.lastPeriodExpense;
                              // Nothing spent last period is nothing to learn
                              // from: an empty box beats a prefilled zero,
                              // which reads like a budget of none.
                              unawaited(
                                showOverallBudgetDialog(
                                  context,
                                  prefill: last.isPositive ? last : null,
                                ),
                              );
                            }
                          : null,
                      scale: MediaQuery.textScalerOf(context)
                          .scale(1)
                          .clamp(1.0, 1.4),
                    ),
                  ),
                  if (dueCount > 0)
                    SliverToBoxAdapter(
                      child: _Notice(
                        icon: Icons.event_repeat,
                        color: Theme.of(context).colorScheme.primary,
                        text: l10n.recurringDueNotice(dueCount),
                        onTap: () =>
                            HomeScreen._open(context, const RecurringScreen()),
                      ),
                    ),
                  if (dueNotesCount > 0)
                    SliverToBoxAdapter(
                      child: _Notice(
                        icon: Icons.sticky_note_2_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        text: l10n.notesDueNotice(dueNotesCount),
                        onTap: () =>
                            HomeScreen._open(context, const NotesScreen()),
                      ),
                    ),
                  // NUDGE-3: offered once, to someone who has already
                  // recorded on three separate days, and never again either
                  // way.
                  if (remindersSupported &&
                      settings.nudgeOfferPending &&
                      settings.nudgeOfferDue(provider.daysUsed.length))
                    SliverToBoxAdapter(
                      child: _Notice(
                        icon: Icons.notifications_none,
                        color: Theme.of(context).colorScheme.primary,
                        text: l10n.nudgeOfferTitle,
                        onTap: () => _acceptNudge(context),
                        onDismiss: () =>
                            context.read<SettingsProvider>().markNudgeOffered(),
                      ),
                    ),
                  if (settings.backupReminderDue(provider.transactions.length))
                    SliverToBoxAdapter(
                      child: _Notice(
                        icon: Icons.backup_outlined,
                        color: Theme.of(context).colorScheme.tertiary,
                        text: lastBackup == null
                            ? l10n.backupReminderNever
                            : l10n.backupReminderSince(
                                DateFormat.yMMMd(l10n.localeName)
                                    .format(lastBackup),
                              ),
                        onTap: () =>
                            HomeScreen._open(context, const BackupScreen()),
                        onDismiss: settings.snoozeBackupReminder,
                      ),
                    ),
                  if (firstRun)
                    const SliverFillRemaining(
                      // It fills the screen it is given, and on one too short
                      // for it — a small phone at large text — it scrolls
                      // rather than putting its button out of reach.
                      hasScrollBody: false,
                      child: _FirstRun(),
                    )
                  else if (days.isEmpty && budgetSummary == null)
                    SliverFillRemaining(
                      // The empty message needs no more than the screen it is on.
                      hasScrollBody: true,
                      child: Center(
                        child: _EmptyDayList(
                          l10n: l10n,
                          filteredByAccount: filterHidesRecords,
                          onShowAllAccounts: () {
                            provider.selectAccountFilter(null);
                            unawaited(settings.setAccountFilterId(null));
                          },
                        ),
                      ),
                    )
                  else ...[
                    // BUD-7: at the top of the list, so opening it scrolls
                    // with the days instead of squeezing them.
                    if (budgetSummary != null)
                      SliverToBoxAdapter(
                        child: _BudgetsCard(
                          summary: budgetSummary,
                          statuses: budgetStatuses,
                          currency: currency,
                          controller: _budgets,
                          onChanged: _budgetsChanged,
                        ),
                      ),
                    if (days.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: _EmptyDayList(
                              l10n: l10n,
                              filteredByAccount: filterHidesRecords,
                              onShowAllAccounts: () {
                                provider.selectAccountFilter(null);
                                unawaited(settings.setAccountFilterId(null));
                              },
                            ),
                          ),
                        ),
                      ),
                    SliverList(
                      // The list delegate, not the builder: a row has to be
                      // built to be swiped, and the days are few.
                      delegate: SliverChildListDelegate([
                        for (final day in days)
                          _DaySection(
                            day: day,
                            transactions:
                                provider.groupedByDay[day] ?? const [],
                            transfers: provider.transfersByDay[day] ?? const [],
                            totals: provider.dailyTotals[day],
                            currency: currency,
                          ),
                      ]),
                    ),
                    // Room for the add button, as the old list padding gave.
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: firstRun
          ? null
          : FloatingActionButton.extended(
              onPressed: () =>
                  HomeScreen._open(context, const AddTransactionScreen()),
              icon: const Icon(Icons.add),
              label: Text(l10n.addButton),
            ),
      // ADS-1, ADS-3: the slot goes here rather than in the body, so it sits
      // outside the day list, above the system navigation bar, and the add
      // button lifts above it instead of sitting on top of it.
      bottomNavigationBar: const AdSlot(placement: AdPlacement.home),
    );
  }
}

/// Every destination that isn't Home, grouped under headings and reached
/// from the toolbar's menu button or an edge swipe (NAV-1–NAV-3, NAV-5).
class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer();

  /// Closes the drawer, then runs [go], so the drawer isn't left open behind
  /// the screen it opened (NAV-3).
  void _leave(BuildContext context, VoidCallback go) {
    Navigator.of(context).pop();
    go();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final provider = context.read<TransactionProvider>();

    Widget header(String text) => Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(28, 16, 16, 8),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );

    Widget row(IconData icon, String label, VoidCallback go) => ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () => _leave(context, go),
    );

    void open(Widget screen) => HomeScreen._open(context, screen);

    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(28, 24, 16, 8),
              child: Text(l10n.appTitle, style: theme.textTheme.titleLarge),
            ),
            header(l10n.drawerAddHeader),
            row(
              Icons.arrow_upward,
              l10n.drawerAddExpense,
              () => open(
                const AddTransactionScreen(startAs: TransactionType.expense),
              ),
            ),
            row(
              Icons.arrow_downward,
              l10n.drawerAddIncome,
              () => open(
                const AddTransactionScreen(startAs: TransactionType.income),
              ),
            ),
            row(
              Icons.swap_horiz,
              l10n.transferTitle,
              () => open(const TransferScreen()),
            ),
            header(l10n.drawerPlanHeader),
            row(
              Icons.savings_outlined,
              l10n.budgetsTitle,
              () => open(const BudgetsScreen()),
            ),
            row(
              Icons.event_repeat,
              l10n.recurringTitle,
              () => open(const RecurringScreen()),
            ),
            row(
              Icons.sticky_note_2_outlined,
              l10n.notesTitle,
              () => open(const NotesScreen()),
            ),
            header(l10n.drawerReviewHeader),
            // Each view of Insights is its own row, so the one being looked
            // for is reached in one tap rather than a tap and a tab (NAV-1).
            row(
              Icons.pie_chart_outline,
              l10n.drawerSpending,
              () => open(const InsightsScreen()),
            ),
            row(
              Icons.calendar_month_outlined,
              l10n.calendarTab,
              () => open(const InsightsScreen(initialTab: 1)),
            ),
            row(
              Icons.insights_outlined,
              l10n.trendTab,
              () => open(const InsightsScreen(initialTab: 2)),
            ),
            row(
              Icons.search,
              l10n.searchTooltip,
              () => open(const SearchScreen()),
            ),
            header(l10n.drawerManageHeader),
            row(
              Icons.account_balance_wallet_outlined,
              l10n.accountsTitle,
              () => open(const AccountsScreen()),
            ),
            row(
              Icons.category_outlined,
              l10n.categoriesTitle,
              () => open(const CategoriesScreen()),
            ),
            row(
              Icons.settings_outlined,
              l10n.settingsTitle,
              () => open(const SettingsScreen()),
            ),
            header(l10n.drawerDataHeader),
            row(
              Icons.table_view_outlined,
              l10n.exportCsvMenu,
              () => HomeScreen._exportPeriod(context, provider),
            ),
            row(
              Icons.picture_as_pdf_outlined,
              l10n.exportPdfMenu,
              () => open(const ReportScreen()),
            ),
            row(
              Icons.backup_outlined,
              l10n.backupTitle,
              () => open(const BackupScreen()),
            ),
            row(
              Icons.delete_outline,
              l10n.trashTitle,
              () => open(const TrashScreen()),
            ),
          ],
        ),
      ),
    );
  }
}

/// The welcome shown until the first transaction is added (RUN-1).
class _FirstRun extends StatelessWidget {
  const _FirstRun();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.savings_outlined,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.firstRunTitle,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(l10n.firstRunMessage, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  HomeScreen._open(context, const AddTransactionScreen()),
              icon: const Icon(Icons.add),
              label: Text(l10n.addFirstTransactionButton),
            ),
          ],
        ),
      ),
    );
  }
}

/// The day list's empty message: a period with nothing in it (EMPTY-3), or,
/// while an account filter hides rows the unfiltered period does have
/// (EMPTY-4, ACC-6), a message that says so and a one-tap way back to every
/// account rather than reading as an empty period that isn't one.
class _EmptyDayList extends StatelessWidget {
  const _EmptyDayList({
    required this.l10n,
    required this.filteredByAccount,
    required this.onShowAllAccounts,
  });

  final AppLocalizations l10n;
  final bool filteredByAccount;
  final VoidCallback onShowAllAccounts;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        filteredByAccount
            ? l10n.emptyPeriodFilteredByAccount
            : l10n.emptyPeriod,
        textAlign: TextAlign.center,
      ),
      if (filteredByAccount) ...[
        const SizedBox(height: 8),
        TextButton(
          onPressed: onShowAllAccounts,
          child: Text(l10n.allAccountsFilter),
        ),
      ],
    ],
  );
}

/// The period's budgets in one card: a line until it's opened, then every
/// budget's bar, as in Insights (BUD-7, BUD-8).
class _BudgetsCard extends StatelessWidget {
  const _BudgetsCard({
    required this.summary,
    required this.statuses,
    required this.currency,
    required this.controller,
    required this.onChanged,
  });

  final BudgetSummary summary;
  final List<BudgetStatus> statuses;
  final NumberFormat currency;

  /// Lets Home fold the card away while the list is scrolled (BUD-9).
  final ExpansibleController controller;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = budgetLevelColor(context, summary.level);
    // A future period has only its limits, so there's nothing used yet
    // (BUD-6).
    final line = summary.timing == PeriodTiming.future
        ? l10n.budgetsCardPlanned(summary.count)
        : l10n.budgetsCardSummary(
            NumberFormat.percentPattern(l10n.localeName)
                .format(summary.progress),
            summary.over,
          );

    return Card(
      // The same width as the summary card above it, so Home reads as one
      // column of cards (BUD-9).
      margin: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 4),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        // Starts closed (BUD-7), and stays as the user left it while the list
        // rebuilds. Home folds it away while the list is scrolled (BUD-9).
        key: const PageStorageKey('home-budgets'),
        controller: controller,
        onExpansionChanged: onChanged,
        leading: Icon(Icons.pie_chart_outline, color: color),
        title: Text(l10n.budgetsTitle),
        subtitle: Text(
          line,
          style: TextStyle(
            color: summary.level == BudgetLevel.ok ? null : color,
          ),
        ),
        shape: const Border(),
        collapsedShape: const Border(),
        childrenPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 4),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final status in statuses)
            BudgetProgress(status: status, currency: currency, compact: true),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            // The fuller picture, where the budgets sit above the spending by
            // category, as the drawer's row of the same name opens it.
            child: TextButton.icon(
              onPressed: () =>
                  HomeScreen._open(context, const InsightsScreen()),
              icon: const Icon(Icons.pie_chart_outline),
              label: Text(l10n.drawerSpending),
            ),
          ),
        ],
      ),
    );
  }
}

/// A tappable one-line notice under the balance card, optionally with a
/// button that dismisses it.
class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.color,
    required this.text,
    required this.onTap,
    this.onDismiss,
  });

  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback onTap;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 0,
      color: color.withValues(alpha: 0.12),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: color),
        title: Text(text),
        trailing: onDismiss == null
            ? const Icon(Icons.chevron_right)
            : IconButton(
                icon: const Icon(Icons.close),
                tooltip: AppLocalizations.of(context).notNowTooltip,
                onPressed: onDismiss,
              ),
        onTap: onTap,
      ),
    );
  }
}

/// The summary card as a pinned header (BAL-6, BAL-7). It lives inside the
/// same scroll as the entries, so the room it gives up is paid out of the
/// scroll offset in one layout pass. While it sat above the scroll view,
/// collapsing it resized the list's viewport instead: the entries lurched
/// upward at twice the speed of the finger, and on a short list the offset
/// was corrected back below the threshold, which opened the card again.
class _SummaryHeader extends SliverPersistentHeaderDelegate {
  const _SummaryHeader({
    required this.income,
    required this.expense,
    required this.balance,
    required this.carriedForward,
    required this.currency,
    required this.collapsedByHand,
    required this.onToggle,
    required this.scale,
    required this.accountName,
    required this.onPickAccount,
    required this.heroLine,
    required this.onSetBudget,
  });

  final Money income;
  final Money expense;
  final Money balance;
  final Money? carriedForward;
  final NumberFormat currency;

  /// Whether the user closed it themselves, in which case it never grows
  /// back on its own (BAL-6).
  final bool collapsedByHand;
  final VoidCallback onToggle;

  /// The chosen account's name, or null for every account (ACC-6).
  final String? accountName;

  /// Null when there is only one account, so the card shows no switch it
  /// cannot act on (ACC-6). The slot stays, keeping the label centred.
  final VoidCallback? onPickAccount;

  /// The number the card leads with, or null while one account is chosen
  /// (BAL-8, BAL-9).
  final HeroLine? heroLine;

  /// Set only when there is no overall budget to lead with, in which case the
  /// line offers to set one (BUD-11).
  final VoidCallback? onSetBudget;

  /// The text scale, so bigger text gets a taller header rather than a
  /// clipped one (LANG-4).
  final double scale;

  /// The one line, and the whole card, at normal text size. Constants, like
  /// the day strip's height, so the header's extents never depend on what it
  /// laid out. Bigger text needs more than its own factor — measured, the
  /// card is 176 at 1.0 and 264 at 1.3 — so the card's share grows by 1.7×
  /// the scale. `test/languages_test.dart` fails if that is ever too mean.
  static const _line = 60.0;
  static const _card = 176.0;

  /// What the lead line adds to both states when there is one (BAL-8). It is
  /// a known input rather than something measured, so the extents stay the
  /// constants this delegate needs them to be.
  static const _hero = 22.0;

  double get _heroRoom => heroLine == null ? 0 : _hero;

  @override
  double get minExtent => (_line + _heroRoom) * scale;

  @override
  double get maxExtent => collapsedByHand
      ? minExtent
      : (_card + _heroRoom) * (1 + (scale - 1) * 1.7);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    // Any real scroll makes it the line; the background keeps the entries
    // from showing through the room it hasn't given up yet.
    final collapsed = collapsedByHand || shrinkOffset > 4;
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ClipRect(
        child: OverflowBox(
          alignment: AlignmentDirectional.topStart.resolve(
            Directionality.of(context),
          ),
          minHeight: 0,
          maxHeight: collapsed ? minExtent : maxExtent,
          child: _SummaryCard(
            income: income,
            expense: expense,
            balance: balance,
            carriedForward: carriedForward,
            currency: currency,
            collapsed: collapsed,
            onToggle: onToggle,
            accountName: accountName,
            onPickAccount: onPickAccount,
            heroLine: heroLine,
            onSetBudget: onSetBudget,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SummaryHeader old) =>
      old.income != income ||
      old.expense != expense ||
      old.balance != balance ||
      old.carriedForward != carriedForward ||
      old.collapsedByHand != collapsedByHand ||
      old.accountName != accountName ||
      // CUR-3 changes the labels and not the values, so a new currency or a
      // new language reaches this card by the format alone: without it the
      // pinned header keeps rendering the old symbol while the day rows
      // below it have already changed.
      old.currency.currencySymbol != currency.currencySymbol ||
      old.currency.locale != currency.locale ||
      // A currency switch between two that share a symbol (USD to CLP, JPY
      // to CNY) changes no symbol or locale but does change the decimals
      // (CUR-2), which the card must still pick up (CUR-3, pr61#4).
      old.currency.decimalDigits != currency.decimalDigits ||
      // BAL-8: without these two the lead line would render once and then
      // never move again, with nothing to say so.
      old.heroLine?.kind != heroLine?.kind ||
      old.heroLine?.amount != heroLine?.amount ||
      old.heroLine?.perDay != heroLine?.perDay ||
      (old.onSetBudget == null) != (onSetBudget == null) ||
      old.scale != scale;
}

class _SummaryCard extends StatelessWidget {
  final Money income;
  final Money expense;
  final Money balance;

  /// Shown under the balance when carrying forward is on (BAL-2).
  final Money? carriedForward;
  final NumberFormat currency;

  /// Whether the card is the balance on one line (BAL-6).
  final bool collapsed;
  final VoidCallback onToggle;

  /// The chosen account's name, or null while Home shows every account. It
  /// stands in for the card's label so the figures are never read as the
  /// whole of the money by mistake (ACC-6).
  final String? accountName;

  /// Null when there is only one account, so the card shows no switch it
  /// cannot act on (ACC-6). The slot stays, keeping the label centred.
  final VoidCallback? onPickAccount;

  const _SummaryCard({
    required this.income,
    required this.expense,
    required this.balance,
    required this.carriedForward,
    required this.currency,
    required this.collapsed,
    required this.onToggle,
    required this.accountName,
    required this.onPickAccount,
    required this.heroLine,
    required this.onSetBudget,
  });

  /// The number the card leads with (BAL-8), or null while one account is
  /// chosen (BAL-9).
  final HeroLine? heroLine;

  /// Offers to set the first overall budget when there is none (BUD-11).
  final VoidCallback? onSetBudget;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final carried = carriedForward;
    final hero = heroLine;
    // ACC-6: one account's name replaces the label rather than joining it, so
    // the card is no taller and no text is pieced together (LANG-2).
    final label =
        accountName ??
        (carried == null ? l10n.periodNetLabel : l10n.balanceLabel);
    final amountColor = balanceColor(context, balance);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // BAL-6: the card itself is the switch between one line and the rest.
        onTap: onToggle,
        child: collapsed
            ? Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        // ACC-6: the way back to every account, on the one line
                        // too. This is the state a scroll leaves Home in, and the
                        // state it opens in when that is how it was left (BAL-6),
                        // so it is where the way out matters most. With every
                        // account showing there is nothing to say and nothing is
                        // shown, exactly as on Insights' banner.
                        if (accountName != null && onPickAccount != null) ...[
                          InkWell(
                            onTap: onPickAccount,
                            customBorder: const CircleBorder(),
                            child: Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 20,
                              semanticLabel: l10n.accountLabel,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        // The balance is laid out first and keeps the room it
                        // needs in any language; the label takes what is left and
                        // gives way with an ellipsis, since an account's name is
                        // the user's own words (LANG-4). Two flexible children
                        // would split the row between them instead and leave a
                        // hole after the chevron.
                        Expanded(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 12),
                        RollingAmount(
                          amount: balance,
                          currency: currency,
                          style: amountStyle(theme.textTheme.titleLarge)
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: amountColor,
                              ),
                        ),
                        Icon(
                          Icons.expand_more,
                          semanticLabel: l10n.expandSummaryTooltip,
                        ),
                      ],
                    ),
                    // BAL-8: it is on the one line too, because this is the
                    // state a scroll leaves Home in and the state most people
                    // see most of the time.
                    if (hero != null)
                      _HeroLine(
                        line: hero,
                        currency: currency,
                        onSetBudget: onSetBudget,
                      ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // ACC-6: the switch between one account and every
                        // account. It takes the room the chevron's opposite
                        // number was already holding to keep the label
                        // centred, so the card is no taller for it.
                        SizedBox(
                          width: 24,
                          child: onPickAccount == null
                              ? null
                              : InkWell(
                                  onTap: onPickAccount,
                                  customBorder: const CircleBorder(),
                                  child: Icon(
                                    Icons.account_balance_wallet_outlined,
                                    size: 20,
                                    semanticLabel: l10n.accountLabel,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Icon(
                          Icons.expand_less,
                          semanticLabel: l10n.collapseSummaryTooltip,
                        ),
                      ],
                    ),
                    RollingAmount(
                      amount: balance,
                      currency: currency,
                      style: amountStyle(theme.textTheme.headlineMedium)
                          .copyWith(
                            fontWeight: FontWeight.bold,
                            color: amountColor,
                          ),
                    ),
                    if (carried != null)
                      // One line, whatever the screen: a wrapped second line
                      // used to push the card past the header's room.
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          l10n.carriedForwardLine(currency.money(carried)),
                          maxLines: 1,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    // BAL-8: under the balance, where the eye already is.
                    if (hero != null)
                      _HeroLine(
                        line: hero,
                        currency: currency,
                        onSetBudget: onSetBudget,
                        center: true,
                      ),
                    const SizedBox(height: 12),
                    // Each side gets half the card, so long labels and large
                    // amounts fit at any text size and in every language
                    // (LANG-6).
                    Row(
                      children: [
                        Expanded(
                          child: _AmountTile(
                            label: l10n.incomeLabel,
                            amount: income,
                            color: incomeColor(context),
                            icon: Icons.arrow_downward,
                            currency: currency,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade300,
                        ),
                        Expanded(
                          child: _AmountTile(
                            label: l10n.expenseLabel,
                            amount: expense,
                            color: expenseColor(context),
                            icon: Icons.arrow_upward,
                            currency: currency,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// The one number the summary card leads with and, when there is no budget to
/// lead with, the offer to set one (BAL-8, BUD-11).
class _HeroLine extends StatelessWidget {
  const _HeroLine({
    required this.line,
    required this.currency,
    required this.onSetBudget,
    this.center = false,
  });

  final HeroLine line;
  final NumberFormat currency;
  final VoidCallback? onSetBudget;

  /// The opened card centres its column; the one line reads from the start.
  final bool center;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    String money(Money amount) => currency.money(amount);
    final perDay = line.perDay;
    final text = switch (line.kind) {
      HeroLineKind.leftToSpend => l10n.budgetLeftPerDay(
        money(line.amount),
        money(perDay!),
      ),
      HeroLineKind.limitReached => l10n.budgetLimitReached,
      HeroLineKind.overBudget => l10n.budgetOverBy(money(line.amount)),
      HeroLineKind.spentSoFar => l10n.homeSpentPerDay(
        money(line.amount),
        money(perDay!),
      ),
      HeroLineKind.spentTotal => l10n.totalSpent(money(line.amount)),
    };
    final over =
        line.kind == HeroLineKind.overBudget ||
        line.kind == HeroLineKind.limitReached;
    final label = Text(
      text,
      maxLines: 1,
      style: theme.textTheme.bodySmall?.copyWith(
        color: over ? expenseColor(context) : null,
        fontWeight: over ? FontWeight.bold : null,
      ),
    );
    final setBudget = onSetBudget;
    // One line in every language, whatever else is on it: a wrapped one would
    // push the card past the room the header set aside for it, and this line
    // carries an offer in some languages half again as long as the English
    // (LANG-4, LANG-6).
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: center
          ? Alignment.center
          : AlignmentDirectional.centerStart.resolve(
              Directionality.of(context),
            ),
      child: setBudget == null
          ? label
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                label,
                const SizedBox(width: 8),
                // BUD-11: its own target. The card's own tap folds it away
                // (BAL-6), so an offer without one would never be taken.
                InkWell(
                  onTap: setBudget,
                  child: Text(
                    l10n.homeSetBudget,
                    maxLines: 1,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _AmountTile extends StatelessWidget {
  final String label;
  final Money amount;
  final Color color;
  final IconData icon;
  final NumberFormat currency;

  const _AmountTile({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // A large amount shrinks to fit rather than breaking across lines.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            currency.money(amount),
            style: amountStyle(Theme.of(context).textTheme.titleMedium)
                .copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// The day header's date and its "nothing recorded" line (DAY-7): a fixed
/// grey, darker in the light theme and lighter in the dark one, so each
/// clears 4.5:1 against the card's surface and surfaceContainerLow (A11Y-3).
/// Colors.grey.shade600 cleared neither.
const dayHeaderInkLight = 0xFF616161;
const dayHeaderInkDark = 0xFF9E9E9E;

Color dayHeaderColor(BuildContext context) => Color(
  Theme.of(context).brightness == Brightness.dark
      ? dayHeaderInkDark
      : dayHeaderInkLight,
);

/// One day's entries under its date, with what the day came to (DAY-7). A
/// day chosen in the strip is shown even when it holds nothing.
class _DaySection extends StatelessWidget {
  final DateTime day;
  final List<ExpenseTransaction> transactions;
  final List<Transfer> transfers;

  /// The day's own income and expense, or null for a day with neither.
  final DayTotals? totals;
  final NumberFormat currency;

  const _DaySection({
    required this.day,
    required this.transactions,
    required this.transfers,
    required this.totals,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dayTotals = totals ?? const DayTotals();
    final empty = transactions.isEmpty && transfers.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat.yMMMd(l10n.localeName).format(day),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: dayHeaderColor(context),
                  ),
                ),
              ),
              // DAY-7: income and expense stay apart, as they do for the
              // period above (BAL-1).
              if (dayTotals.income.isPositive)
                _DayTotal(
                  amount: dayTotals.income,
                  isIncome: true,
                  currency: currency,
                ),
              if (dayTotals.income.isPositive && dayTotals.expense.isPositive)
                const SizedBox(width: 8),
              if (dayTotals.expense.isPositive)
                _DayTotal(
                  amount: dayTotals.expense,
                  isIncome: false,
                  currency: currency,
                ),
            ],
          ),
        ),
        if (empty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Text(
              l10n.dayEmpty,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: dayHeaderColor(context),
              ),
            ),
          ),
        for (final tx in transactions)
          _TransactionTile(transaction: tx, currency: currency),
        for (final transfer in transfers)
          _TransferTile(transfer: transfer, currency: currency),
      ],
    );
  }
}

/// One side of a day's total, coloured like the summary card's (DAY-7).
///
/// A11Y-4: nothing here carries meaning by colour alone. The sign, not just
/// the ink, says which side this is (CUR-5).
class _DayTotal extends StatelessWidget {
  const _DayTotal({
    required this.amount,
    required this.isIncome,
    required this.currency,
  });

  final Money amount;
  final bool isIncome;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    return Text(
      signedAmount(currency, amount, isIncome: isIncome),
      style: amountStyle(Theme.of(context).textTheme.labelLarge).copyWith(
        color: signedColor(context, isIncome: isIncome),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// A red swipe background shared by transaction and transfer rows.
Widget _deleteBackground() => Container(
  color: Colors.red,
  alignment: AlignmentDirectional.centerEnd,
  padding: const EdgeInsetsDirectional.only(end: 20),
  child: const Icon(Icons.delete, color: Colors.white),
);

class _TransactionTile extends StatelessWidget {
  final ExpenseTransaction transaction;
  final NumberFormat currency;

  const _TransactionTile({required this.transaction, required this.currency});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final category = provider.categoryById(transaction.categoryId);
    final categoryName = category?.label(l10n) ?? '';
    final isIncome = transaction.type == TransactionType.income;
    final color = signedColor(context, isIncome: isIncome);

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: _deleteBackground(),
      // HAP-3: the swipe says when letting go would delete the row.
      onUpdate: swipeUpdate,
      // Delete before the row animates away; if that fails, it slides back.
      confirmDismiss: (_) async {
        final messenger = ScaffoldMessenger.of(context);
        try {
          await provider.deleteTransaction(transaction.id);
        } catch (_) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.deleteFailed)));
          return false;
        }
        showDeletedSnackBar(messenger, provider, l10n, transaction.id);
        return true;
      },
      child: ListTile(
        // The category's colour, not the green or red of income and expense
        // (CAT-6): the amount at the other end of the row already says which
        // of the two this is, and saying it twice cost the row the one thing
        // it could not otherwise show.
        leading: CircleAvatar(
          backgroundColor: categoryTint(category),
          child: Text(
            category?.icon ?? '📦',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        title: Text(transaction.label(category, l10n)),
        subtitle: Text(
          provider.isUpcoming(transaction)
              ? l10n.upcomingCategory(categoryName)
              : categoryName,
        ),
        // ROW-1: the amount, then the row's own menu.
        trailing: TransactionRowTrailing(
          transaction: transaction,
          amount: Text(
            signedAmount(currency, transaction.amount, isIncome: isIncome),
            // The sign stays in front of the amount in Arabic (LANG-5).
            style: amountStyle(
              TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionDetailScreen(id: transaction.id),
          ),
        ),
      ),
    );
  }
}

/// A transfer row: never income or expense, so it has no sign (ACC-3).
class _TransferTile extends StatelessWidget {
  final Transfer transfer;
  final NumberFormat currency;

  const _TransferTile({required this.transfer, required this.currency});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final from = provider.accountById(transfer.fromAccountId)?.label(l10n);
    final to = provider.accountById(transfer.toAccountId)?.label(l10n);
    final description = transfer.note ?? l10n.transferLabel;

    return Dismissible(
      key: ValueKey('transfer-${transfer.id}'),
      direction: DismissDirection.endToStart,
      background: _deleteBackground(),
      // HAP-3: as on a transaction row.
      onUpdate: swipeUpdate,
      confirmDismiss: (_) async {
        final messenger = ScaffoldMessenger.of(context);
        try {
          await provider.deleteTransfer(transfer.id);
        } catch (_) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.transferSaveFailed)),
          );
          return false;
        }
        showTransferDeletedSnackBar(messenger, provider, l10n, transfer.id);
        return true;
      },
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.swap_horiz)),
        title: Text(l10n.transferRoute(from ?? '', to ?? '')),
        subtitle: Text(
          provider.isUpcomingDate(transfer.date)
              ? l10n.upcomingCategory(description)
              : description,
        ),
        trailing: Text(
          currency.money(transfer.amount),
          style: amountStyle(const TextStyle(fontWeight: FontWeight.w600)),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TransferScreen(editing: transfer)),
        ),
      ),
    );
  }
}

/// Turns the empty-day nudge on from Home's offer (NUDGE-3), asking the
/// phone for permission first (NUDGE-7). Either answer counts as the one
/// offer, so this is the last time it is put in front of anyone.
Future<void> _acceptNudge(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final settings = context.read<SettingsProvider>();
  final transactions = context.read<TransactionProvider>();
  final reminders = context.read<ReminderService>();
  final messenger = ScaffoldMessenger.of(context);
  final allowed = await reminders.requestPermission();
  await settings.markNudgeOffered();
  if (!allowed) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.nudgePermissionDenied)));
    return;
  }
  await settings.setEmptyDayNudge(true);
  await transactions.rescheduleReminders(
    appLockOn: settings.appLock,
    locale: effectiveAppLocale(settings.locale),
    nudge: settings.nudgeSettings,
  );
}
